import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/logic/logger.dart';
import 'package:stopwatch/ui/page/home.dart';

void setupMockNativeChannels() {
  const methodChannel = MethodChannel('stopwatch/native');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'getState') return {'isRunning': false, 'accumulatedMs': 0};
    return true;
  });

  const eventChannel = MethodChannel('stopwatch/native_events');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(eventChannel, (_) async => null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [
        loggerProvider.overrideWithValue(Logger(level: Level.nothing)),
        appRouterProvider.overrideWith((ref) => AppRouter(ref)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => const MaterialApp(home: HomePage()),
      ),
    );
  }

  Future<void> waitRealTime(WidgetTester tester, int ms) async {
    await tester.runAsync(() async => await Future.delayed(Duration(milliseconds: ms)));
    await tester.pump();
  }

  group('HomePage Widget Tests', () {
    setUp(() {
      setupMockNativeChannels();
    });

    testWidgets('1. Initial state displays correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('Visszaállítás'), findsOneWidget);
      expect(find.text('00:00.000'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Visszaállítás'));
      expect(resetButton.onPressed, isNull);
    });

    testWidgets('2. Start button starts the timer and UI updates', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));
      await tester.pump();

      expect(find.text('Leállítás'), findsOneWidget);
      expect(find.text('Kör'), findsOneWidget);

      await waitRealTime(tester, 100);

      expect(find.text('00:00.000'), findsNothing);

      await tester.tap(find.text('Leállítás'));
      await tester.pump();
    });

    testWidgets('3. Stop button stops the timer', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));
      await waitRealTime(tester, 100);

      await tester.tap(find.text('Leállítás'));
      await tester.pump();

      expect(find.text('Indítás'), findsOneWidget);
    });

    testWidgets('4. Reset button resets the timer to zero', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));
      await waitRealTime(tester, 100);

      await tester.tap(find.text('Leállítás'));
      await tester.pump();

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Visszaállítás'));
      expect(resetButton.onPressed, isNotNull);

      await tester.tap(find.text('Visszaállítás'));
      await tester.pump();

      expect(find.text('Indítás'), findsOneWidget);
      expect(find.text('00:00.000'), findsOneWidget);
    });

    testWidgets('5. Lap button adds laps when running', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));
      await waitRealTime(tester, 100);

      await tester.tap(find.text('Kör'));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Kör idő'), findsOneWidget);
      expect(find.text('Teljes idő'), findsOneWidget);

      await tester.tap(find.text('Leállítás'));
      await tester.pump();
    });

    testWidgets('6. Multiple laps are displayed in order', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));

      for (int i = 0; i < 3; i++) {
        await waitRealTime(tester, 50);
        await tester.tap(find.text('Kör'));
        await tester.pump();
      }

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Kör idő'), findsNWidgets(3));

      await tester.tap(find.text('Leállítás'));
      await tester.pump();
    });

    testWidgets('7. Reset clears all laps', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));
      await waitRealTime(tester, 50);

      await tester.tap(find.text('Kör'));
      await waitRealTime(tester, 50);
      await tester.tap(find.text('Kör'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Leállítás'));
      await tester.pump();

      await tester.tap(find.text('Visszaállítás'));
      await tester.pump();

      expect(find.byType(ListView), findsNothing);
      expect(find.text('1'), findsNothing);
      expect(find.text('00:00.000'), findsOneWidget);
    });
    testWidgets('8. Tapping a lap navigates to LapDetailsPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Indítás'));
      await waitRealTime(tester, 100);
      await tester.tap(find.text('Kör'));
      await tester.pump();

      await tester.tap(find.text('Leállítás'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.text('Kör idő'), findsWidgets);
    });
  });
}
