# Wallet MVP Flutter App

Customer-facing Flutter Android app for the wallet MVP.

## Features

- Phone number and PIN login via `POST /customer/login`
- JWT storage with `flutter_secure_storage`
- Dashboard balance from `GET /me`
- Recent transactions from `GET /me/transactions?limit=5`
- Full transaction history with paginated load-more behavior
- Notifications from `GET /me/notifications`
- Mark notification as read via `POST /me/notifications/:id/read`
- Read-only profile and logout
- Firebase Cloud Messaging registration after login via `POST /me/register-device-token`
- Foreground push messages shown as an in-app snackbar

## Setup

1. Install Flutter and ensure it is on your PATH:

   ```bash
   flutter doctor
   ```

2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

   This workspace was manually scaffolded because Flutter was not available in the shell that created it. If your local Flutter install asks for missing platform wrapper files, run:

   ```bash
   flutter create . --platforms=android
   flutter pub get
   ```

3. Add Firebase for Android:

   - Create or open your Firebase project.
   - Add an Android app with package name `com.example.wallet_mvp`.
   - Download `google-services.json`.
   - Place it at:

     ```text
     android/app/google-services.json
     ```

4. Run on the Android emulator:

   ```bash
   .\run_flutter_android.ps1
   ```

To run in Chrome before Android SDK is installed:

```powershell
.\run_flutter_web.ps1
```

### Real Push Notifications

Android push uses:

```text
android/app/google-services.json
```

Chrome/web push also needs Firebase web app settings and a Web Push certificate key from Firebase Console. Set these in the same PowerShell window before running:

```powershell
$env:FIREBASE_WEB_API_KEY="AIzaSyBBLZRiV0FcVu8QhPFCwA9hcLQnJuXwDTI"
$env:FIREBASE_WEB_APP_ID="1:241485351877:web:cd27ae67e66a74e52019ac"
$env:FIREBASE_MESSAGING_SENDER_ID="241485351877"
$env:FIREBASE_PROJECT_ID="wallet-admin-c7100"
$env:FIREBASE_AUTH_DOMAIN="wallet-admin-c7100.firebaseapp.com"
$env:FIREBASE_STORAGE_BUCKET="wallet-admin-c7100.firebasestorage.app"
$env:FIREBASE_WEB_VAPID_KEY="BO5_IFYBlfYzhtQTBQWjeQUs9dbfW3s_NYZ-ex-Q7taN42dYISjigWaGnI7uu4Ve1IYjbh5Df2c1O67PasO5SV8"
.\run_flutter_web.ps1
```

Those values are already the defaults in `run_flutter_web.ps1`, so normally you can just run the script directly.

The web run script creates `web/firebase-messaging-sw.js` when those values are present. After customer login, the app requests a real FCM token and posts it to:

```http
POST /me/register-device-token
```

## Release APK

The Android release build supports a signing placeholder through `android/key.properties`.

For a quick internal demo build, the Gradle config falls back to the debug signing key if `android/key.properties` is missing. For a shareable release-style APK, create a keystore and add:

```properties
storePassword=replace-me
keyPassword=replace-me
keyAlias=upload
storeFile=app/upload-keystore.jks
```

Then build the APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

The output APK is created under:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Backend URL

The app reads the API base URL from a Dart define named `API_BASE_URL`.

For the Android emulator talking to a backend on your host machine, the default is already:

```text
http://10.0.2.2:4000
```

To run against a deployed backend:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

For a release APK pointed at the deployed backend:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

To run against a different local port:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

The MVP Android manifest currently enables cleartext HTTP traffic so emulator calls to `http://10.0.2.2:4000` work. For production, use HTTPS and remove `android:usesCleartextTraffic="true"` from `android/app/src/main/AndroidManifest.xml`.

## Firebase Push Registration

Firebase initializes before `runApp()`. On startup/login, the app requests notification permission. After customer login, it gets the FCM token and sends it to the configured backend:

```http
POST /me/register-device-token
Authorization: Bearer <CUSTOMER_JWT>
Content-Type: application/json
```

```json
{
  "fcm_token": "<FCM_TOKEN>"
}
```

The same registration runs again when `FirebaseMessaging.instance.onTokenRefresh` emits a new token.

After login, the Flutter debug console prints:

```text
FCM TOKEN: <FCM_TOKEN>
register-device-token response: status=201, body={device_token: {...}}
```

To test push end to end:

1. Add `android/app/google-services.json`.
2. Run on a real Android device or emulator with Google Play services.
3. Log in as a customer.
4. Confirm the backend stores the device token.
5. Trigger a deposit from Admin Web.
6. Verify the customer device receives the push notification.

To generate a real customer JWT for manual API testing, call the backend login endpoint with the test customer's phone number and PIN:

```powershell
.\get_customer_token.ps1 -PhoneNumber "+251978164608" -Pin "1234"
```

Use the returned `token`, `jwt`, or `accessToken` value as:

```http
Authorization: Bearer <CUSTOMER_JWT>
```

To manually register an FCM token for that customer:

```powershell
.\register_fcm_token.ps1 -CustomerJwt "<CUSTOMER_JWT>" -FcmToken "<FCM_TOKEN>"
```

## API Shape Notes

The client accepts common response shapes for lists, including a top-level array or an object containing `data`, `items`, `transactions`, or `notifications`.

Expected auth response includes one of:

```json
{
  "token": "jwt"
}
```

or:

```json
{
  "jwt": "jwt"
}
```
