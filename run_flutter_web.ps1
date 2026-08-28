$env:Path = "C:\src\flutter\bin;$env:Path"

$apiBaseUrl = if ($env:API_BASE_URL) { $env:API_BASE_URL } else { "http://localhost:4000" }
$firebaseWebApiKey = if ($env:FIREBASE_WEB_API_KEY) { $env:FIREBASE_WEB_API_KEY } else { "AIzaSyBBLZRiV0FcVu8QhPFCwA9hcLQnJuXwDTI" }
$firebaseWebAppId = if ($env:FIREBASE_WEB_APP_ID) { $env:FIREBASE_WEB_APP_ID } else { "1:241485351877:web:cd27ae67e66a74e52019ac" }
$firebaseMessagingSenderId = if ($env:FIREBASE_MESSAGING_SENDER_ID) { $env:FIREBASE_MESSAGING_SENDER_ID } else { "241485351877" }
$firebaseProjectId = if ($env:FIREBASE_PROJECT_ID) { $env:FIREBASE_PROJECT_ID } else { "wallet-admin-c7100" }
$firebaseAuthDomain = if ($env:FIREBASE_AUTH_DOMAIN) { $env:FIREBASE_AUTH_DOMAIN } else { "wallet-admin-c7100.firebaseapp.com" }
$firebaseStorageBucket = if ($env:FIREBASE_STORAGE_BUCKET) { $env:FIREBASE_STORAGE_BUCKET } else { "wallet-admin-c7100.firebasestorage.app" }
$firebaseMeasurementId = if ($env:FIREBASE_MEASUREMENT_ID) { $env:FIREBASE_MEASUREMENT_ID } else { "G-FKNJHGMWD9" }
$firebaseWebVapidKey = if ($env:FIREBASE_WEB_VAPID_KEY) { $env:FIREBASE_WEB_VAPID_KEY } else { "BO5_IFYBlfYzhtQTBQWjeQUs9dbfW3s_NYZ-ex-Q7taN42dYISjigWaGnI7uu4Ve1IYjbh5Df2c1O67PasO5SV8" }

if ($firebaseWebApiKey -and $firebaseWebAppId -and $firebaseMessagingSenderId -and $firebaseProjectId) {
@"
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "$firebaseWebApiKey",
  appId: "$firebaseWebAppId",
  messagingSenderId: "$firebaseMessagingSenderId",
  projectId: "$firebaseProjectId",
  authDomain: "$firebaseAuthDomain",
  storageBucket: "$firebaseStorageBucket",
  measurementId: "$firebaseMeasurementId"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  self.registration.showNotification(notification.title || "Wallet update", {
    body: notification.body || "",
    icon: "/icons/Icon-192.png"
  });
});
"@ | Set-Content -Path "web\firebase-messaging-sw.js" -Encoding UTF8
}

flutter pub get
flutter run -d web-server --web-hostname=localhost --web-port=5555 `
  --dart-define=API_BASE_URL="$apiBaseUrl" `
  --dart-define=FIREBASE_WEB_API_KEY="$firebaseWebApiKey" `
  --dart-define=FIREBASE_WEB_APP_ID="$firebaseWebAppId" `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$firebaseMessagingSenderId" `
  --dart-define=FIREBASE_PROJECT_ID="$firebaseProjectId" `
  --dart-define=FIREBASE_AUTH_DOMAIN="$firebaseAuthDomain" `
  --dart-define=FIREBASE_STORAGE_BUCKET="$firebaseStorageBucket" `
  --dart-define=FIREBASE_MEASUREMENT_ID="$firebaseMeasurementId" `
  --dart-define=FIREBASE_WEB_VAPID_KEY="$firebaseWebVapidKey"
