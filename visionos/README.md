# visionOS Platform Support

This directory contains the visionOS platform implementation for Companion Connect.

## Requirements

- Xcode 15.0 or later
- visionOS SDK 1.0 or later  
- Apple Vision Pro Simulator or device
- Flutter SDK with visionOS support

## Building for visionOS

To build and run the app for visionOS:

```bash
flutter run -d visionos --flavor development --target lib/main_development.dart
```

## Features

- Native visionOS UI integration
- Spatial computing capabilities
- Full Flutter widget support
- Multi-flavor support (development, staging, production)

## Configuration

The visionOS platform configuration is located in:
- `Runner.xcodeproj/` - Xcode project files
- `Podfile` - CocoaPods dependencies
- `Runner/Configs/` - App configuration files
- `Flutter/` - Flutter-specific configuration

## Notes

This platform follows the same architecture patterns as the iOS and macOS platforms, adapted for visionOS spatial computing paradigms.