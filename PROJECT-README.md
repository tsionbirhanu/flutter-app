# Wallet MVP Demo Project

## What This Project Is

This repository contains the customer-facing Flutter Android app for a wallet MVP. It is intended to work with the separate backend API and the separate Next.js admin web app during an end-to-end demo.

The Flutter app lets a test customer log in with phone number and PIN, view their wallet balance, review transactions, receive notifications, and log out. The admin web app is used before opening the mobile app to register a customer and perform a deposit.

## Components

- Backend API: serves customer auth, wallet balance, transactions, notifications, admin actions, and FCM device-token registration.
- Admin web: Next.js admin interface used to seed/admin login, register test customers, and create deposits.
- Flutter Android app: customer app in this folder.

## Environment Variables

Backend API:

- `PORT`: API port. Local demo default is `4000`.
- `DATABASE_URL`: database connection string.
- `JWT_SECRET`: secret used to sign customer/admin JWTs.
- `FIREBASE_PROJECT_ID`: Firebase project ID, if backend sends push notifications.
- `FIREBASE_CLIENT_EMAIL`: Firebase service-account email, if backend sends push notifications.
- `FIREBASE_PRIVATE_KEY`: Firebase private key, if backend sends push notifications.

Admin web:

- `NEXT_PUBLIC_API_BASE_URL`: backend URL reachable from the browser, for example `http://localhost:4000`.

Flutter Android app:

- `API_BASE_URL`: passed with `--dart-define`. Defaults to `http://10.0.2.2:4000` for the Android emulator.
- For Flutter web/Chrome local demo, use `http://localhost:4000` instead.
- `android/app/google-services.json`: Firebase Android config file for package `com.example.wallet_mvp`.

## Current Local Status

- Flutter SDK is installed at `C:\src\flutter`.
- Flutter dependencies have been installed with `flutter pub get`.
- `flutter analyze` passes with no issues.
- Chrome and Edge are available Flutter devices.
- Android emulator is not available yet because Android SDK is not installed.

If `flutter` is not recognized in a new terminal, close VS Code completely and reopen it. The Flutter path added for Windows is:

```text
C:\src\flutter\bin
```

## Run the Flutter App Now in Chrome

Use this while Android Studio/Android SDK is not installed:

```powershell
cd C:\Users\tsion\Desktop\Flutter-App
.\run_flutter_web.ps1
```

Then open:

```text
http://localhost:5555
```

For Chrome/web, use `http://localhost:4000` because the app runs in your desktop browser.

## Run Later on Android Emulator

Install Android Studio and the Android SDK first. Then verify:

```powershell
flutter doctor
flutter devices
```

Run the app on Android:

```powershell
cd C:\Users\tsion\Desktop\Flutter-App
.\run_flutter_android.ps1
```

For Android emulator, use `http://10.0.2.2:4000` because the emulator reaches your computer's localhost through `10.0.2.2`.

## Local End-to-End Demo Order

1. Start the backend API.

   ```bash
   npm install
   npm run dev
   ```

   Confirm it is listening on `http://localhost:4000`.

2. Seed the admin user or demo data.

   ```bash
   npm run seed
   ```

3. Start the admin web app.

   ```bash
   npm install
   NEXT_PUBLIC_API_BASE_URL=http://localhost:4000 npm run dev
   ```

4. In the admin web app, register a test customer and set their PIN.

   The PIN is set directly in Admin Web during or after registration. Capture the customer's phone number and PIN for mobile login.

5. In the admin web app, create a deposit for that customer.

   This should create a wallet transaction and update the customer's balance.

6. Prepare the Flutter app.

   ```bash
   flutter pub get
   ```

   Add Firebase config at:

   ```text
   android/app/google-services.json
   ```

7. Open the Flutter app against the local backend.

   Current Chrome demo:

   ```powershell
   flutter run -d web-server --web-hostname=localhost --web-port=5555 --dart-define=API_BASE_URL=http://localhost:4000
   ```

   Android emulator demo after Android SDK is installed:

   ```powershell
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
   ```

8. Log in as the test customer.

   Use the phone number and PIN set in Admin Web.

9. Verify the demo result.

   The Dashboard should show the deposited balance in the large balance card, and the deposit should appear in Recent Transactions with a green `+` amount.

## Demo APK Build

For a deployed backend:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

For an emulator/local-backend demo:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Android Signing

The release build reads signing values from `android/key.properties` when present:

```properties
storePassword=replace-me
keyPassword=replace-me
keyAlias=upload
storeFile=app/upload-keystore.jks
```

If `android/key.properties` is not present, the project falls back to debug signing for quick internal demos. Use a real upload keystore for any APK shared outside the demo team.
