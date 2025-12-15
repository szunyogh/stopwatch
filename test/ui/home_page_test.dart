import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/ui/page/home.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('4. Button interactions and UI responds correctly', (WidgetTester tester) async {
      // STEP 1: Setup screen size for ScreenUtil
      // ScreenUtil needs a proper screen size to calculate responsive values
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      // STEP 2: Build the widget tree
      // We wrap everything in ProviderScope (for Riverpod) and ScreenUtilInit
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return const MaterialApp(
                home: HomePage(),
              );
            },
          ),
        ),
      );

      // STEP 3: Wait for all animations and async operations to complete
      await tester.pumpAndSettle();

      // STEP 4: Verify initial state
      // The UI should show "Indítás" (Start) and "Visszaállítás" (Reset) buttons
      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('Visszaállítás'), findsOneWidget);

      // STEP 5: Get the initial time display
      // We find the first Text widget which displays the time
      final initialTimeWidget = tester.widget<Text>(
        find.byType(Text).first,
      );
      final initialTime = initialTimeWidget.data!;

      // STEP 6: Simulate tapping the Start button
      await tester.tap(find.text('Indítás'));
      // pumpAndSettle waits for all frames to settle (animations, rebuilds)
      await tester.pumpAndSettle();

      // STEP 7: Verify UI changed to "Leállítás" (Stop)
      expect(find.text('Leállítás'), findsOneWidget);

      // STEP 8: Wait for the timer to run and time to increase
      // pump() with duration advances time and triggers rebuilds
      await tester.pump(const Duration(milliseconds: 100));

      // STEP 9: Verify time has increased
      final runningTimeWidget = tester.widget<Text>(
        find.byType(Text).first,
      );
      expect(runningTimeWidget.data, isNot(equals(initialTime)));

      // STEP 10: Tap the Stop button
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();

      // STEP 11: Verify button changed back to "Indítás"
      expect(find.text('Indítás'), findsOneWidget);

      // STEP 12: Verify Reset button is enabled
      // When stopped and time > 0, reset should be enabled (onPressed != null)
      final resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNotNull);

      // STEP 13: Tap Reset button
      await tester.tap(find.text('Visszaállítás'));
      await tester.pumpAndSettle();

      // STEP 14: Verify time is back to initial value
      final resetTimeWidget = tester.widget<Text>(
        find.byType(Text).first,
      );
      expect(resetTimeWidget.data, equals(initialTime));
    });

    testWidgets('5. Reset button is disabled when time is 0 or running', (WidgetTester tester) async {
      // Setup
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return const MaterialApp(
                home: HomePage(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TEST 1: Initially (time = 0), reset should be disabled
      var resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNull); // null = disabled

      // TEST 2: Start the timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 50));

      // While running, reset should be disabled
      resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNull); // disabled while running

      // TEST 3: Stop the timer
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();

      // After stopping (time > 0 and not running), reset should be enabled
      resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNotNull); // enabled when stopped with time > 0
    });
  });
}
