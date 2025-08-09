
# Deekshana Castle Management Flutter App

## Registration Module

This app supports both Android and Web platforms from a single codebase.

### Features
- Admin login screen (mock credentials: admin/admin123)
- Hosteler registration form with all required fields, file/image uploads
- List, edit, and delete hostelers
- Responsive UI for mobile and desktop
- Local storage using Hive
- State management using Provider

### How to Run

#### 1. Install dependencies
```
flutter pub get
```

#### 2. Run on Android
```
flutter run -d android
```

#### 3. Run on Web
```
flutter run -d chrome
```

#### 4. Required Packages
The following packages are used:
- provider
- hive
- hive_flutter
- image_picker
- file_picker

#### 5. Notes
- No backend integration yet; all data is stored locally.
- For file/image picking, permissions may be required on Android.
- To clear local data, uninstall the app or clear browser storage.

---
For more Flutter resources:
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
