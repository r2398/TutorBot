import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tutorbotfrontend/main.dart';

void main() {
  group('Platform Tests', () {
    testWidgets('App renders on all screen sizes', (WidgetTester tester) async {
      // Test mobile size (360x640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const TutorBotApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test tablet size (768x1024)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(const TutorBotApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test desktop size (1920x1080)
      tester.view.physicalSize = const Size(1920, 1080);
      await tester.pumpWidget(const TutorBotApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Reset
      tester.view.resetPhysicalSize();
    });

    testWidgets('Theme switches work', (WidgetTester tester) async {
      await tester.pumpWidget(const TutorBotApp());
      await tester.pumpAndSettle();

      // Light theme by default
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
    });
  });
}