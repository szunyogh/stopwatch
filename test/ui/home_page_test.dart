import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/page/home.dart';
import 'package:stopwatch/ui/page/lap_details.dart';

void setupMockNativeChannels({String lapsJson = '[]', Map<String, Object?>? nativeState}) {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(const MethodChannel('stopwatch/native'), (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getState':
        return nativeState ?? {'isRunning': false, 'startedAtEpochMs': null, 'accumulatedMs': 0};
      case 'getLaps':
        return lapsJson;
      case 'hasNotificationPermission':
      case 'requestNotificationPermission':
        return true;
      default:
        return null;
    }
  });

  messenger.setMockMethodCallHandler(const MethodChannel('stopwatch/native_events'), (_) async => null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUp(() async {
    setupMockNativeChannels();
    l10n = await AppLocalizations.delegate.load(const Locale('hu'));
  });

  void useTestScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget localizedApp({Widget? home, RouterConfig<Object>? routerConfig}) {
    if (routerConfig != null) {
      return MaterialApp.router(
        locale: const Locale('hu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: routerConfig,
      );
    }

    return MaterialApp(locale: const Locale('hu'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: home);
  }

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [appRouterProvider.overrideWith((ref) => AppRouter(ref))],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => localizedApp(home: const HomePage()),
      ),
    );
  }

  Future<void> waitRealTime(WidgetTester tester, int ms) async {
    await tester.runAsync(() async => await Future.delayed(Duration(milliseconds: ms)));
    await tester.pump();
  }

  group('HomePage Widget Tests', () {
    testWidgets('1. Initial state displays correctly', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text(l10n.start), findsOneWidget);
      expect(find.text(l10n.reset), findsOneWidget);
      expect(find.text('00:00.000'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, l10n.reset));
      expect(resetButton.onPressed, isNull);
    });

    testWidgets('2. Start button starts the timer and UI updates', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.start));
      await tester.pump();

      expect(find.text(l10n.stop), findsOneWidget);
      expect(find.text(l10n.lap), findsOneWidget);

      await waitRealTime(tester, 100);

      expect(find.text('00:00.000'), findsNothing);

      await tester.tap(find.text(l10n.stop));
      await tester.pump();
    });

    testWidgets('3. Stop button stops the timer', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.start));
      await waitRealTime(tester, 100);

      await tester.tap(find.text(l10n.stop));
      await tester.pump();

      expect(find.text(l10n.start), findsOneWidget);
    });

    testWidgets('4. Reset button resets the timer to zero', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.start));
      await waitRealTime(tester, 100);

      await tester.tap(find.text(l10n.stop));
      await tester.pump();

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, l10n.reset));
      expect(resetButton.onPressed, isNotNull);

      await tester.tap(find.text(l10n.reset));
      await tester.pump();

      expect(find.text(l10n.start), findsOneWidget);
      expect(find.text('00:00.000'), findsOneWidget);
    });

    testWidgets('5. Lap button adds laps when running', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.start));
      await waitRealTime(tester, 100);

      await tester.tap(find.text(l10n.lap));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text(l10n.lapTime), findsOneWidget);
      expect(find.text(l10n.lapTotalTime), findsOneWidget);

      await tester.tap(find.text(l10n.stop));
      await tester.pump();
    });

    testWidgets('6. Multiple laps are displayed in order', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.start));

      for (int i = 0; i < 3; i++) {
        await waitRealTime(tester, 50);
        await tester.tap(find.text(l10n.lap));
        await tester.pump();
      }

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text(l10n.lapTime), findsNWidgets(3));

      await tester.tap(find.text(l10n.stop));
      await tester.pump();
    });

    testWidgets('7. Reset clears all laps', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.start));
      await waitRealTime(tester, 50);

      await tester.tap(find.text(l10n.lap));
      await waitRealTime(tester, 50);
      await tester.tap(find.text(l10n.lap));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text(l10n.stop));
      await tester.pump();

      await tester.tap(find.text(l10n.reset));
      await tester.pump();

      expect(find.byType(ListView), findsNothing);
      expect(find.text('1'), findsNothing);
      expect(find.text('00:00.000'), findsOneWidget);
    });

    testWidgets('8. Tapping a lap navigates to LapDetailsPage', (WidgetTester tester) async {
      useTestScreen(tester);

      final container = ProviderContainer(overrides: [appRouterProvider.overrideWith((ref) => AppRouter(ref))]);
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => localizedApp(routerConfig: router.config()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.text(l10n.start));
      await waitRealTime(tester, 100);
      await tester.tap(find.text(l10n.lap));
      await tester.pump();

      await tester.tap(find.text(l10n.stop));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.byType(LapDetailsPage), findsNothing);

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(find.byType(LapDetailsPage), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text(l10n.lapDetails)), findsOneWidget);
    });

    testWidgets('9. Saved laps and time are restored on startup', (WidgetTester tester) async {
      useTestScreen(tester);

      final savedLaps = [
        LapModel(time: const Duration(seconds: 5), totalTime: const Duration(seconds: 5), order: 1),
        LapModel(time: const Duration(seconds: 10), totalTime: const Duration(seconds: 15), order: 2),
      ];

      setupMockNativeChannels(lapsJson: jsonEncode(savedLaps.map((lap) => lap.toJson()).toList()), nativeState: {'isRunning': false, 'startedAtEpochMs': null, 'accumulatedMs': 20000});

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text(DurationElapsedFormatter.toElapsedTime(const Duration(seconds: 20))), findsOneWidget);

      expect(find.text(l10n.start), findsOneWidget);
      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, l10n.reset));
      expect(resetButton.onPressed, isNotNull);
    });
  });
}
