# CI-Server API Client

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

<<<<<<< HEAD
A Dart API client for the CI-Server backend, providing access to people, places, content, contact, and things endpoints.

## Features

- ✅ Full CRUD operations for all CI-Server endpoints
- ✅ Type-safe models for all data structures
- ✅ Built-in error handling with descriptive exceptions
- ✅ File upload support for content
- ✅ Clean, maintainable code without code generation dependencies

## Endpoints Supported

- **People** - Manage person records
- **Places** - Location and venue data
- **Content** - File and media content management
- **Contact** - Contact information management  
- **Things** - IoT devices and object data

## Usage

```dart
import 'package:api_client/api_client.dart';

// Initialize the client
final apiClient = ApiClient(baseUrl: 'https://your-ci-server.com/api');

// Fetch people
final people = await apiClient.getPeople();

// Create a new person
final person = Person(
  id: 'new-id',
  name: 'John Doe',
  email: 'john@example.com',
);
final createdPerson = await apiClient.createPerson(person);

// Upload content
final content = await apiClient.uploadContent(
  '/path/to/file.jpg',
  {'title': 'My Photo', 'category': 'image'},
);
```

## Installation 💻

**❗ In order to start using Api Client you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `flutter pub add`:

```sh
dart pub add api_client
```

## Features 🚀

- **CI-Server Integration**: Complete API client for all CI-Server endpoints (people, places, content, contact, things)
- **Type Safety**: Full Dart type safety with comprehensive error handling
- **Cross-platform Support**: Works on iOS, Android, Web, and Desktop platforms
- **File Upload Support**: Native file sync and upload capabilities

## Usage 📖

### Basic Setup

```dart
import 'package:api_client/api_client.dart';

// Create an instance
final apiClient = ApiClient(
  baseUrl: 'https://your-ci-server.com',
);
```

### CI-Server API Operations

```dart
// People API
final people = await apiClient.getPeople();
final person = await apiClient.createPerson(Person(
  name: 'John Doe',
  email: 'john@example.com',
));

// Places API
final places = await apiClient.getPlaces();
final place = await apiClient.createPlace(Place(
  name: 'Office',
  address: '123 Main St',
));

// Content API - File Upload
final uploadResult = await apiClient.uploadContent(
  filePath: '/path/to/file.pdf',
  fileName: 'document.pdf',
  contentType: 'application/pdf',
);

// Contact API
final contacts = await apiClient.getContacts();

// Things API (IoT devices)
final things = await apiClient.getThings();
```

---

## Continuous Integration 🤖

Api Client comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
