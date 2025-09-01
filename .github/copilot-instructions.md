# Copilot Instructions for Companion Connect

## Project Overview
Companion Connect is a Flutter-based native mobile application built with Very Good CLI structure. This is a private and confidential project creating a companion app with multi-platform support (iOS, Android, Web, Windows).

## Architecture & Structure

### Project Organization
- **Main App**: `/lib/` - Flutter application code
- **Packages**: `/packages/` - Modular packages:
  - `api_client` - API communication layer
  - `app_core` - Core business logic and models
  - `app_ui` - Reusable UI components and design system
- **Flavors**: Three build flavors (development, staging, production)

### Key Files
- Entry points: `main_development.dart`, `main_staging.dart`, `main_production.dart`
- Bootstrap: `bootstrap.dart` - App initialization
- Internationalization: `/lib/l10n/` - ARB files for translations

## Coding Standards & Conventions

### Analysis & Linting
- Uses `very_good_analysis` for strict Dart/Flutter linting
- Follow Very Good Ventures coding standards
- Maintain high code quality with comprehensive analysis rules

### Architecture Patterns
- Use BLoC pattern for state management (bloc_test available for testing)
- Implement clean architecture with separation of concerns
- Follow package-by-feature organization within the packages

### Testing
- Unit tests: Use `flutter_test` with `mocktail` for mocking
- Widget tests: Test UI components thoroughly
- Integration tests: Use `bloc_test` for BLoC testing
- Run tests with: `very_good test --coverage --test-randomize-ordering-seed random`
- Maintain high test coverage (view with lcov)

### Internationalization (i18n)
- Use `flutter_localizations` for multi-language support
- Add new strings to `/lib/l10n/arb/app_en.arb`
- Generate translations with: `flutter gen-l10n --arb-dir="lib/l10n/arb"`
- Access translations via `context.l10n` pattern

## Development Workflow

### Running the App
```bash
# Development flavor
flutter run --flavor development --target lib/main_development.dart

# Staging flavor  
flutter run --flavor staging --target lib/main_staging.dart

# Production flavor
flutter run --flavor production --target lib/main_production.dart
```

### Dependencies
- Keep dependencies in appropriate packages (api_client, app_core, app_ui)
- Use path-based dependencies for local packages
- Maintain compatibility with Flutter SDK ^3.8.0

### Code Generation
- Run `flutter run` to trigger automatic code generation
- Generate localizations when adding new translations
- Use build_runner for any additional code generation needs

## Best Practices for AI Assistance

### When Writing Code
1. **Follow Very Good Analysis rules** - Ensure all code passes linting
2. **Use existing patterns** - Follow established architecture in the codebase
3. **Test everything** - Write comprehensive tests for new functionality
4. **Package organization** - Place code in appropriate packages:
   - API calls → `api_client`
   - Business logic → `app_core`  
   - UI components → `app_ui`
5. **Internationalization** - Always use l10n for user-facing strings
6. **Type safety** - Leverage Dart's strong typing system

### When Modifying Features
- Maintain backwards compatibility across flavors
- Update tests when changing business logic
- Consider impact on all supported platforms (iOS, Android, Web, Windows)
- Follow existing naming conventions and file structure

### When Adding Dependencies
- Evaluate if the dependency belongs in the main app or a specific package
- Consider impact on app size and performance
- Ensure compatibility with current Flutter/Dart SDK version
- Update pubspec.yaml in the appropriate location

## Security & Privacy
This is a private project - be mindful of:
- Not exposing sensitive data in logs or comments
- Following secure coding practices for API communications
- Protecting user data throughout the application lifecycle