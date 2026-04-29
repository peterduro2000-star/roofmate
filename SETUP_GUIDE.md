# Roof Estimator Pro - Flutter Setup Guide

This guide will help you get the Flutter app running on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

### 1. Flutter SDK
- **Download**: https://flutter.dev/docs/get-started/install
- **Minimum Version**: Flutter 3.0.0 or higher
- **Verify Installation**:
  ```bash
  flutter --version
  flutter doctor
  ```

### 2. Dart SDK
- Comes bundled with Flutter
- **Verify**: `dart --version`

### 3. IDE/Editor
Choose one:
- **Android Studio** (recommended for Android development)
- **VS Code** with Flutter extension
- **Xcode** (for iOS development on macOS)

### 4. Platform-Specific Requirements

#### For iOS Development (macOS only)
- Xcode 13.0 or higher
- iOS deployment target: 11.0 or higher
- CocoaPods: `sudo gem install cocoapods`

#### For Android Development
- Android Studio 4.1 or higher
- Android SDK 21 or higher
- Java Development Kit (JDK) 11 or higher

## Installation Steps

### Step 1: Extract the Project

```bash
# If you have the tar.gz file
tar -xzf roof_estimator_flutter.tar.gz
cd roof_estimator_flutter

# Or if you have the zip file
unzip roof_estimator_flutter.zip
cd roof_estimator_flutter
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Generate Hive Adapters

This is **required** for local storage to work:

```bash
flutter pub run build_runner build
```

If you encounter issues, try:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the App

#### iOS (macOS only)
```bash
flutter run -d ios
```

First run will take longer as it builds the iOS app.

#### Android
```bash
flutter run -d android
```

Make sure an Android emulator is running or an Android device is connected.

#### Web (Experimental)
```bash
flutter run -d web
```

#### List Available Devices
```bash
flutter devices
```

## Running Tests

To run the unit tests for the calculation engine:

```bash
flutter test
```

Expected output: 17 tests passing

## Building for Release

### iOS Release Build
```bash
flutter build ios --release
```

Then open in Xcode to sign and deploy:
```bash
open ios/Runner.xcworkspace
```

### Android Release Build

#### APK (for direct installation)
```bash
flutter build apk --release
```

#### App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```

## Project Structure

```
roof_estimator_flutter/
├── lib/                          # Dart source code
│   ├── main.dart                # App entry point
│   ├── screens/                 # UI screens
│   ├── models/                  # Data models
│   ├── services/                # Business logic
│   └── utils/                   # Utilities
├── test/                        # Unit tests
├── assets/                      # Images, icons, fonts
├── pubspec.yaml                 # Dependencies
├── analysis_options.yaml        # Linting rules
├── README.md                    # Documentation
└── SETUP_GUIDE.md              # This file
```

## Troubleshooting

### Issue: "Flutter command not found"
**Solution**: Add Flutter to your PATH
```bash
# macOS/Linux
export PATH="$PATH:~/flutter/bin"

# Add to ~/.bashrc or ~/.zshrc for permanent setup
echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
```

### Issue: "Hive adapter generation failed"
**Solution**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Android build fails"
**Solution**: Update Android dependencies
```bash
flutter pub get
cd android
./gradlew clean
cd ..
flutter run -d android
```

### Issue: "iOS build fails"
**Solution**: Update CocoaPods
```bash
cd ios
pod install --repo-update
cd ..
flutter run -d ios
```

### Issue: "No devices found"
**Solution**: 
- For Android: Start an emulator from Android Studio or connect a device
- For iOS: Use Xcode simulator or connect an iPhone
- Check: `flutter devices`

### Issue: "Gradle build failed"
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run -d android
```

## Development Tips

### Hot Reload
During development, use hot reload for faster iteration:
- Press `r` in the terminal to hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Mode
Run with additional debugging:
```bash
flutter run -v
```

### Analyze Code
Check for code quality issues:
```bash
flutter analyze
```

### Format Code
Auto-format your code:
```bash
dart format lib/ test/
```

## Project Features

### Screens
1. **Home Screen** - View recent estimates and create new ones
2. **Roof Type Selection** - Choose between Gable, Hip, Mono-Pitch
3. **Dimension Input** - Enter building dimensions and parameters
4. **Results Screen** - View calculated material quantities
5. **Estimate Detail** - View and manage saved estimates

### Calculation Engine
- Accurate roofing material calculations
- Support for multiple roof types
- Customizable parameters (spacing, overhang, etc.)
- 10% waste allowance included

### Local Storage
- Save estimates locally using Hive
- View recent estimates on home screen
- Delete individual or all estimates

## Color Scheme

The app uses a professional color scheme:
- **Primary**: Deep Blue (#1E40AF)
- **Secondary**: Amber (#F59E0B)
- **Background**: White (#FFFFFF)
- **Surface**: Light Gray (#F8FAFC)

## Performance

- All calculations are instant (local processing)
- Smooth animations and transitions
- Efficient state management with Provider
- Fast local storage with Hive

## Next Steps

1. **Customize**: Modify colors, fonts, or text in the code
2. **Add Features**: Implement PDF export, cost calculator, etc.
3. **Deploy**: Build and publish to App Store or Google Play
4. **Test**: Run on real devices and gather feedback

## Support Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Dart Documentation**: https://dart.dev/guides
- **Provider Package**: https://pub.dev/packages/provider
- **Hive Documentation**: https://docs.hivedb.dev/

## Common Commands Reference

```bash
# Project setup
flutter pub get                    # Get dependencies
flutter pub upgrade               # Upgrade dependencies
flutter pub run build_runner build # Generate code

# Development
flutter run                        # Run app
flutter run -d <device_id>       # Run on specific device
flutter run -v                    # Verbose output
flutter test                      # Run tests

# Code quality
flutter analyze                   # Analyze code
dart format lib/                 # Format code

# Building
flutter build apk --release      # Build Android APK
flutter build ios --release      # Build iOS app
flutter build web                # Build web version

# Maintenance
flutter clean                    # Clean build artifacts
flutter doctor                   # Check environment setup
```

## Questions or Issues?

If you encounter any problems:

1. Check the troubleshooting section above
2. Run `flutter doctor` to check your environment
3. Check the README.md for more information
4. Review the Flutter documentation at https://flutter.dev

---

**Last Updated**: March 2026  
**Flutter Version**: 3.0+  
**Dart Version**: 3.0+
