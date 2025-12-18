// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorbotfrontend/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const TutorBotApp());
    await tester.pumpAndSettle();

    // Verify that the app initializes
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Onboarding shows when no profile exists', (WidgetTester tester) async {
    await tester.pumpWidget(const TutorBotApp());
    await tester.pumpAndSettle();

    // Wait for profile loading
    await tester.pump(const Duration(seconds: 1));
    
    // Should show onboarding
    expect(find.text('Tutor Anna'), findsWidgets);
  });
}
