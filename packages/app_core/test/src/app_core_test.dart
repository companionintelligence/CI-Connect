// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppCore', () {
    test('can be instantiated', () {
      expect(AppCore(), isNotNull);
    });
  });
}
