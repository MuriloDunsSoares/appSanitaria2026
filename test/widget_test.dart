// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_sanitaria/main.dart';
import 'package:app_sanitaria/core/di/injection_container.dart' as di;

void main() {
  setUpAll(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    // Initialize Dependency Injection
    await di.setupDependencyInjection();
  });

  testWidgets('App smoke test - Login screen appears',
      (WidgetTester tester) async {

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AppSanitaria(),
      ),
    );

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that Login screen appears (looking for common login elements)
    expect(
      find.byType(TextField),
      findsWidgets, // Should find email and password fields
    );
  });
}
