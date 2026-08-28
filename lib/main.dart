import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'providers/app_providers.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseInitialized = false;
  try {
    if (kIsWeb) {
      if (AppConfig.hasFirebaseWebConfig) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: AppConfig.firebaseWebApiKey,
            appId: AppConfig.firebaseWebAppId,
            messagingSenderId: AppConfig.firebaseMessagingSenderId,
            projectId: AppConfig.firebaseProjectId,
            authDomain: AppConfig.firebaseAuthDomain,
            storageBucket: AppConfig.firebaseStorageBucket,
            measurementId: AppConfig.firebaseMeasurementId,
          ),
        );
      }
    } else {
      await Firebase.initializeApp();
    }
    firebaseInitialized = Firebase.apps.isNotEmpty;
    if (firebaseInitialized) {
      await FirebaseMessaging.instance.requestPermission();
    }
  } catch (_) {
    // Firebase will initialize once google-services.json is added for Android.
  }
  runApp(
    ProviderScope(
      overrides: [
        firebaseInitializedProvider.overrideWithValue(firebaseInitialized),
      ],
      child: const WalletApp(),
    ),
  );
}

class WalletApp extends ConsumerWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Wallet MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF0F766E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF8FAFC),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: auth.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : auth.isAuthenticated
          ? const MainShell()
          : const LoginScreen(),
    );
  }
}
