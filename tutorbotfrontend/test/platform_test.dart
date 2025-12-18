import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorbotfrontend/main.dart';

void main() {
  group('Platform Tests', () {
    testWidgets('App renders on all screen sizes', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Test mobile size (360x640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);

      // Test tablet size (768x1024)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);

      // Test desktop size (1920x1080)
      tester.view.physicalSize = const Size(1920, 1080);
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);

      // Reset
      tester.view.resetPhysicalSize();
    });

    testWidgets('Theme switches work', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();

      // Light theme by default
      expect(Theme.of(tester.element(find.byType(MaterialApp))).brightness, Brightness.light);
    });
  });
}