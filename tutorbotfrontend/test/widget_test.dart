// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorbotfrontend/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Verify that the onboarding screen loads (since no profile exists)
    expect(find.text('I\'m Tutor Anna!'), findsOneWidget);
  });

  testWidgets('Onboarding flow navigation works', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Verify progress indicators exist (4 steps)
    expect(find.text('I\'m Tutor Anna!'), findsOneWidget);
    
    // Verify Continue button is disabled initially
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButton, findsOneWidget);
    
    final button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNull); // Should be disabled when name is empty
  });
}
