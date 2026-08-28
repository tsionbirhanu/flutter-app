import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/wallet_notification.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

final firebaseInitializedProvider = Provider<bool>((ref) => false);

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(
    ref.watch(apiServiceProvider),
    firebaseInitialized: ref.watch(firebaseInitializedProvider),
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.error,
  });

  const AuthState.loading()
    : isLoading = true,
      isAuthenticated = false,
      error = null;

  const AuthState.signedOut({this.error})
    : isLoading = false,
      isAuthenticated = false;

  const AuthState.signedIn()
    : isLoading = false,
      isAuthenticated = true,
      error = null;

  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    unawaited(_bootstrap());
    return const AuthState.loading();
  }

  Future<void> _bootstrap() async {
    final token = await ref.read(authServiceProvider).loadToken();
    if (!ref.mounted) return;
    if (token == null) {
      state = const AuthState.signedOut();
    } else {
      state = const AuthState.signedIn();
      unawaited(
        ref.read(notificationServiceProvider).registerDeviceAfterLogin(),
      );
    }
  }

  Future<void> login(String phoneNumber, String pin) async {
    state = const AuthState.loading();
    try {
      await ref
          .read(authServiceProvider)
          .login(phoneNumber: phoneNumber, pin: pin);
      state = const AuthState.signedIn();
      ref.invalidate(meProvider);
      ref.invalidate(recentTransactionsProvider);
      unawaited(
        ref.read(notificationServiceProvider).registerDeviceAfterLogin(),
      );
    } catch (error) {
      state = AuthState.signedOut(error: '$error');
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AuthState.signedOut();
    ref.invalidate(meProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(notificationsProvider);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final meProvider = FutureProvider<Customer>((ref) async {
  final json = await ref.watch(apiServiceProvider).getMap('/me');
  return Customer.fromJson(json);
});

final recentTransactionsProvider = FutureProvider<List<WalletTransaction>>((
  ref,
) async {
  final list = await ref
      .watch(apiServiceProvider)
      .getList('/me/transactions?limit=5');
  return list
      .whereType<Map<String, dynamic>>()
      .map(WalletTransaction.fromJson)
      .take(5)
      .toList();
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<WalletNotification>>(
      NotificationsController.new,
    );

class NotificationsController extends AsyncNotifier<List<WalletNotification>> {
  @override
  Future<List<WalletNotification>> build() => _fetch();

  Future<List<WalletNotification>> _fetch() async {
    final list = await ref
        .read(apiServiceProvider)
        .getList('/me/notifications');
    return list
        .whereType<Map<String, dynamic>>()
        .map(WalletNotification.fromJson)
        .toList();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> markRead(WalletNotification notification) async {
    if (!notification.isRead) {
      await ref
          .read(apiServiceProvider)
          .post('/me/notifications/${notification.id}/read');
    }
    final current = state.value ?? const <WalletNotification>[];
    state = AsyncValue.data([
      for (final item in current)
        item.id == notification.id ? item.copyWith(isRead: true) : item,
    ]);
  }
}
