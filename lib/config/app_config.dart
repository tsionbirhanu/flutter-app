class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  static const firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyBBLZRiV0FcVu8QhPFCwA9hcLQnJuXwDTI',
  );
  static const firebaseWebAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:241485351877:web:cd27ae67e66a74e52019ac',
  );
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '241485351877',
  );
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'wallet-admin-c7100',
  );
  static const firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'wallet-admin-c7100.firebaseapp.com',
  );
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'wallet-admin-c7100.firebasestorage.app',
  );
  static const firebaseMeasurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-FKNJHGMWD9',
  );
  static const firebaseWebVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
    defaultValue:
        'BO5_IFYBlfYzhtQTBQWjeQUs9dbfW3s_NYZ-ex-Q7taN42dYISjigWaGnI7uu4Ve1IYjbh5Df2c1O67PasO5SV8',
  );

  static bool get hasFirebaseWebConfig =>
      firebaseWebApiKey.isNotEmpty &&
      firebaseWebAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;
}
