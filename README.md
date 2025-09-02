# Companion Connect

## CI Server Connectivity App

A Flutter application that provides seamless connectivity to the Companion Intelligence Server, enabling mobile and desktop data synchronization and interaction.

## Features

- **CI Server Integration**: Direct HTTP API connectivity to Companion Intelligence Server
- **Real-time Connectivity Testing**: Health checks and status monitoring
- **Comprehensive API Support**: Full coverage of CI Server endpoints:
  - **People**: Manage contacts and user information
  - **Places**: Location and venue management
  - **Content**: Document and media handling
  - **Contact**: Communication endpoints
  - **Things**: Object and item tracking
- **Cross-platform**: Works on iOS, Android, Web, and Windows
- **Offline-aware**: Graceful handling of network connectivity issues

## API Client Usage

```dart
import 'package:api_client/api_client.dart';

// Initialize the API client
final apiClient = ApiClient(
  ciServerBaseUrl: 'https://your-ci-server.com', // Optional, defaults to official server
);

// Test connectivity
final isConnected = await apiClient.isConnectedToCiServer();
if (isConnected) {
  print('Connected to CI Server!');
}

// Use API endpoints
final people = await apiClient.getPeople(limit: 10);
final places = await apiClient.getPlaces(search: 'office');
final content = await apiClient.getContent(type: 'document');
final contacts = await apiClient.getContact(limit: 5);
final things = await apiClient.getThings(category: 'electronics');

// Create new data
await apiClient.createPerson({'name': 'John Doe', 'email': 'john@example.com'});
await apiClient.createPlace({'name': 'Office', 'address': '123 Main St'});
await apiClient.createContent({'title': 'New Doc', 'type': 'document'});
await apiClient.createContact({'name': 'Support', 'email': 'support@example.com'});
await apiClient.createThing({'name': 'Laptop', 'category': 'electronics'});
```
---

## Getting Started 🚀

This project contains 3 flavors:

- development
- staging
- production

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart

# Production
$ flutter run --flavor production --target lib/main_production.dart
```

_\*Companion Connect works on iOS, Android, Web, and Windows._

---

## Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ very_good test --coverage --test-randomize-ordering-seed random
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

## Working with Translations 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

### Adding Strings

1. To add a new localizable string, open the `app_en.arb` file at `lib/l10n/arb/app_en.arb`.

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

2. Then add a new key/value and description

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    },
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World Text"
    }
}
```

3. Use the new string

```dart
import 'package:companion_connect/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.helloWorld);
}
```

### Adding Supported Locales

Update the `CFBundleLocalizations` array in the `Info.plist` at `ios/Runner/Info.plist` to include the new locale.

```xml
    ...

    <key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
	</array>

    ...
```

### Adding Translations

1. For each supported locale, add a new ARB file in `lib/l10n/arb`.

```
├── l10n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

2. Add the translated strings to each `.arb` file:

`app_en.arb`

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

`app_es.arb`

```arb
{
    "@@locale": "es",
    "counterAppBarTitle": "Contador",
    "@counterAppBarTitle": {
        "description": "Texto mostrado en la AppBar de la página del contador"
    }
}
```

### Generating Translations

To use the latest translations changes, you will need to generate them:

1. Generate localizations for the current project:

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Alternatively, run `flutter run` and code generation will take place automatically.
 
