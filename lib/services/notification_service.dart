import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../config/app_config.dart';
import 'api_service.dart';

class ForegroundPush {
  const ForegroundPush({required this.title, required this.body});

  final String title;
  final String body;
}

class NotificationService {
  NotificationService(this._api, {required bool firebaseInitialized})
    : _firebaseInitialized = firebaseInitialized;

  final ApiService _api;
  final bool _firebaseInitialized;
  final _foregroundController = StreamController<ForegroundPush>.broadcast();
  StreamSubscription<String>? _tokenRefreshSubscription;
  Future<void>? _registrationAttempt;

  Stream<ForegroundPush> get foregroundMessages => _foregroundController.stream;

  Future<void> initializeForegroundHandling() async {
    if (!_firebaseInitialized) return;
    try {
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        _foregroundController.add(
          ForegroundPush(
            title: notification?.title ?? 'Wallet update',
            body: notification?.body ?? '',
          ),
        );
        debugPrint(
          'Foreground FCM message: ${notification?.title ?? 'Wallet update'} ${notification?.body ?? ''}',
        );
      });
    } catch (_) {
      return;
    }
  }

  void startTokenRefreshHandling() {
    if (!_firebaseInitialized) return;
    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen(
          (token) => unawaited(_registerToken(token)),
          onError: (error) {
            _logRegistrationMessage('FCM token refresh failed: $error');
          },
        );
  }

  Future<void> registerDeviceAfterLogin() async {
    final currentAttempt = _registrationAttempt;
    if (currentAttempt != null) return currentAttempt;

    final attempt = _registerDeviceAfterLogin();
    _registrationAttempt = attempt;
    try {
      await attempt;
    } finally {
      _registrationAttempt = null;
    }
  }

  Future<void> _registerDeviceAfterLogin() async {
    if (!_firebaseInitialized) {
      debugPrint('FCM registration skipped: Firebase is not initialized.');
      return;
    }
    if (kIsWeb && AppConfig.firebaseWebVapidKey.isEmpty) {
      debugPrint('FCM registration skipped: web VAPID key is not configured.');
      return;
    }
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      startTokenRefreshHandling();
      final token = await messaging.getToken(
        vapidKey: kIsWeb ? AppConfig.firebaseWebVapidKey : null,
      );
      _logDebugMessage('FCM TOKEN: $token');
      if (token == null || token.isEmpty) {
        _logRegistrationMessage(
          'FCM registration skipped: Firebase returned no token.',
        );
        return;
      }

      await _registerToken(token);
    } catch (error) {
      _logRegistrationMessage('FCM registration failed after login: $error');
      return;
    }
  }

  Future<void> _registerToken(String token) async {
    if (token.isEmpty) return;
    _logRegistrationMessage('Registering FCM token with backend...');

    final response = await _api.postRaw(
      '/me/register-device-token',
      body: {'fcm_token': token},
    );
    _logRegistrationMessage(
      'register-device-token response: status=${response.statusCode}, body=${response.body}',
    );
  }

  void _logRegistrationMessage(String message) {
    _logDebugMessage(message);
  }

  void _logDebugMessage(String message) {
    debugPrint(message);
    // ignore: avoid_print
    print(message);
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundController.close();
  }
}
