$env:Path = "C:\src\flutter\bin;$env:Path"
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
