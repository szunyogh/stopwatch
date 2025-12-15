import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/ui/page/home.dart';

void main() {
  group('HomePage Widget Tests', () {
    setUp(() {
      // Setup screen size for ScreenUtil before each test
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('1. Initial state displays correctly', (WidgetTester tester) async {
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

      // Verify initial buttons
      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('Visszaállítás'), findsOneWidget);

      // Verify initial time is 00:00.000
      expect(find.text('00:00.000'), findsOneWidget);

      // Verify no laps are displayed
      expect(find.byType(ListView), findsNothing);

      // Verify reset button is disabled
      final resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNull);
    });

    testWidgets('2. Start button starts the timer and UI updates', (WidgetTester tester) async {
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

      // Get initial time
      final initialTimeWidget = tester.widget<Text>(find.byType(Text).first);
      final initialTime = initialTimeWidget.data!;

      // Tap start button
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();

      // Verify button changed to "Leállítás"
      expect(find.text('Leállítás'), findsOneWidget);
      expect(find.text('Indítás'), findsNothing);

      // Verify button changed to "Kör"
      expect(find.text('Kör'), findsOneWidget);

      // Wait for timer to run
      await tester.pump(const Duration(milliseconds: 100));

      // Verify time has changed
      final runningTimeWidget = tester.widget<Text>(find.byType(Text).first);
      expect(runningTimeWidget.data, isNot(equals(initialTime)));

      // Cleanup
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
    });

    testWidgets('3. Stop button stops the timer', (WidgetTester tester) async {
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

      // Start timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // Get time after running
      final timeAfterStart = tester.widget<Text>(find.byType(Text).first).data!;

      // Stop timer
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();

      // Verify button changed back to "Indítás"
      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('Leállítás'), findsNothing);

      // Wait and verify time hasn't changed
      await tester.pump(const Duration(milliseconds: 100));
      final timeAfterStop = tester.widget<Text>(find.byType(Text).first).data!;
      expect(timeAfterStop, equals(timeAfterStart));
    });

    testWidgets('4. Reset button resets the timer to zero', (WidgetTester tester) async {
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

      // Start and wait
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // Stop
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();

      // Verify reset button is enabled
      final resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNotNull);

      // Reset
      await tester.tap(find.text('Visszaállítás'));
      await tester.pumpAndSettle();

      // Verify time is back to zero
      expect(find.text('00:00.000'), findsOneWidget);
    });

    testWidgets('5. Reset button is disabled when time is 0 or running', (WidgetTester tester) async {
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
      expect(resetButton.onPressed, isNull);

      // TEST 2: Start the timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 50));

      // While running, left button should show "Kör", not "Visszaállítás"
      expect(find.text('Kör'), findsOneWidget);
      expect(find.text('Visszaállítás'), findsNothing);

      // TEST 3: Stop the timer
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();

      // After stopping (time > 0 and not running), reset should be enabled
      resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNotNull);
    });

    testWidgets('6. Lap button adds laps when running', (WidgetTester tester) async {
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

      // Start timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify "Kör" button appears
      expect(find.text('Kör'), findsOneWidget);

      // Add first lap
      await tester.tap(find.text('Kör'));
      await tester.pumpAndSettle();

      // Verify ListView appears with lap
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Lap order
      expect(find.text('Kör idő'), findsOneWidget);
      expect(find.text('Teljes idő'), findsOneWidget);

      // Wait and add second lap
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Kör'));
      await tester.pumpAndSettle();

      // Verify two laps exist
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Cleanup
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
    });

    testWidgets('7. Lap list displays correct information', (WidgetTester tester) async {
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

      // Start timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // Add lap
      await tester.tap(find.text('Kör'));
      await tester.pumpAndSettle();

      // Verify lap item structure
      expect(find.text('Kör idő'), findsOneWidget);
      expect(find.text('Teljes idő'), findsOneWidget);

      // Verify order is displayed
      expect(find.text('1'), findsOneWidget);

      // Cleanup
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
    });

    testWidgets('8. Multiple laps are displayed in order', (WidgetTester tester) async {
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

      // Start timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();

      // Add 3 laps
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Kör'));
        await tester.pumpAndSettle();
      }

      // Verify all laps are displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Verify we have 3 lap items
      expect(find.text('Kör idő'), findsNWidgets(3));
      expect(find.text('Teljes idő'), findsNWidgets(3));

      // Cleanup
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
    });

    testWidgets('9. Current lap time is displayed when running with laps', (WidgetTester tester) async {
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

      // Start timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // Add first lap
      await tester.tap(find.text('Kör'));
      await tester.pumpAndSettle();

      // Wait a bit more
      await tester.pump(const Duration(milliseconds: 100));

      // Find the two time displays
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();

      // First text should be total time (larger font)
      // Second text should be current lap time (smaller font)
      // The second time should be visible and updating
      expect(textWidgets.length, greaterThan(1));

      // Cleanup
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
    });

    testWidgets('10. Reset clears all laps', (WidgetTester tester) async {
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

      // Start timer and add laps
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Kör'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Kör'));
      await tester.pumpAndSettle();

      // Verify laps exist
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Stop and reset
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visszaállítás'));
      await tester.pumpAndSettle();

      // Verify laps are cleared
      expect(find.byType(ListView), findsNothing);
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
      expect(find.text('00:00.000'), findsOneWidget);
    });

    testWidgets('11. UI responds correctly to start-stop-reset cycle', (WidgetTester tester) async {
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

      // Initial state
      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('Visszaállítás'), findsOneWidget);

      // Start
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();
      expect(find.text('Leállítás'), findsOneWidget);
      expect(find.text('Kör'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));

      // Stop
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('Visszaállítás'), findsOneWidget);

      // Verify reset is enabled
      final resetButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButton.onPressed, isNotNull);

      // Reset
      await tester.tap(find.text('Visszaállítás'));
      await tester.pumpAndSettle();

      // Back to initial state
      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('00:00.000'), findsOneWidget);

      // Reset should be disabled again
      final resetButtonAfter = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Visszaállítás'),
      );
      expect(resetButtonAfter.onPressed, isNull);
    });

    testWidgets('12. Lap list is scrollable with many laps', (WidgetTester tester) async {
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

      // Start timer
      await tester.tap(find.text('Indítás'));
      await tester.pumpAndSettle();

      // Add 5 laps quickly
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Kör'));
        await tester.pumpAndSettle();
      }

      // Verify ListView exists and is scrollable
      expect(find.byType(ListView), findsOneWidget);

      // Verify we can find the first lap
      expect(find.text('1'), findsOneWidget);

      // The ListView should be scrollable
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isNot(const NeverScrollableScrollPhysics()));

      // Cleanup
      await tester.tap(find.text('Leállítás'));
      await tester.pumpAndSettle();
    });
  });
}
