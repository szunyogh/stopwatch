import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/page/lap_details.dart';
import 'package:stopwatch/ui/page/stopwatch.dart';
import 'package:stopwatch/ui/widget/analog_clock.dart';
import 'package:stopwatch/ui/widget/sliding_time_display.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await loadL10n();
  });

  String fmt(Duration d) => DurationElapsedFormatter.toElapsedTime(d);

  Finder inItem(int order, Finder matching) => find.descendant(of: lapItem(order), matching: matching);

  CustomScrollView scrollView(WidgetTester tester) => tester.widget<CustomScrollView>(find.descendant(of: find.byType(StopwatchPage), matching: find.byType(CustomScrollView)));

  List<LapModel> manyLaps(int n) => [
    for (var i = 1; i <= n; i++)
      LapModel(
        time: const Duration(seconds: 1),
        totalTime: Duration(seconds: i),
        order: i,
      ),
  ];

  group('StopwatchPage Unit Tests', () {
    group('StopwatchPage - empty state', () {
      testWidgets('1. Shows the clock and a single time display and no laps', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        expect(find.byType(StopwatchPage), findsOneWidget);
        expect(find.byType(AnalogClock), findsOneWidget);
        expect(find.byType(SlidingTimeDisplay), findsOneWidget);
        expect(displayedTimeIn(tester, StopwatchPage), Duration.zero);

        expect(lapItem(1), findsNothing);
        expect(find.text(l10n.lapTime), findsNothing);

        await unmountApp(tester);
      });

      testWidgets('2. The page does not scroll without laps', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        expect(scrollView(tester).physics, isA<NeverScrollableScrollPhysics>());

        await unmountApp(tester);
      });
    });

    group('StopwatchPage - clock and time display', () {
      testWidgets('3. The analog clock shows the same time as the display', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 100);

        final shown = displayedTimeIn(tester, StopwatchPage);
        expect(shown.inMilliseconds, greaterThan(0));
        expect(tester.widget<AnalogClock>(find.byType(AnalogClock)).elapsed, shown);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('4. Restored time is shown on both the display and the clock', (tester) async {
        setupMockNativeChannels(nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        expect(displayedTimeIn(tester, StopwatchPage), const Duration(seconds: 20));
        expect(tester.widget<AnalogClock>(find.byType(AnalogClock)).elapsed, const Duration(seconds: 20));

        await unmountApp(tester);
      });

      testWidgets('5. Reset brings both the display and the clock back to zero', (tester) async {
        setupMockNativeChannels(nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.reset));
        await tester.pump();

        expect(displayedTimeIn(tester, StopwatchPage), Duration.zero);
        expect(tester.widget<AnalogClock>(find.byType(AnalogClock)).elapsed, Duration.zero);

        await unmountApp(tester);
      });
    });

    group('StopwatchPage - current lap display', () {
      testWidgets('6. A second display with the current lap time appears after the first lap', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 50);
        expect(find.byType(SlidingTimeDisplay), findsOneWidget);

        await tester.tap(find.text(l10n.lap));
        await tester.pump();

        expect(find.byType(SlidingTimeDisplay), findsNWidgets(2));

        await waitRealTime(tester, 80);
        final total = displayedTimeIn(tester, StopwatchPage);
        final current = displayedTimeIn(tester, StopwatchPage, index: 1);
        expect(current.inMilliseconds, greaterThan(0));
        expect(current, lessThan(total));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('7. Restored laps restore the current lap time as well', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        expect(find.byType(SlidingTimeDisplay), findsNWidgets(2));
        expect(displayedTimeIn(tester, StopwatchPage), const Duration(seconds: 20));
        expect(displayedTimeIn(tester, StopwatchPage, index: 1), const Duration(seconds: 5));

        await unmountApp(tester);
      });

      testWidgets('8. Reset removes the current lap display together with the laps', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.reset));
        await tester.pump();

        expect(find.byType(SlidingTimeDisplay), findsOneWidget);
        expect(lapItem(1), findsNothing);
        expect(lapItem(2), findsNothing);

        await unmountApp(tester);
      });
    });

    group('StopwatchPage - lap list', () {
      testWidgets('9. Restored laps show order, lap time and total time', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        expect(lapItem(1), findsOneWidget);
        expect(lapItem(2), findsOneWidget);

        for (final order in [1, 2]) {
          expect(inItem(order, find.text('$order')), findsOneWidget);
          expect(inItem(order, find.text(l10n.lapTime)), findsOneWidget);
          expect(inItem(order, find.text(l10n.lapTotalTime)), findsOneWidget);
        }

        expect(inItem(1, find.text(fmt(const Duration(seconds: 5)))), findsNWidgets(2));
        expect(inItem(2, find.text(fmt(const Duration(seconds: 10)))), findsOneWidget);
        expect(inItem(2, find.text(fmt(const Duration(seconds: 15)))), findsOneWidget);

        await unmountApp(tester);
      });

      testWidgets('10. The list scrolls when there are laps', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        expect(scrollView(tester).physics, isA<BouncingScrollPhysics>());

        await unmountApp(tester);
      });

      testWidgets('11. A long list can be scrolled', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(manyLaps(30)), nativeState: nativeStateOf(accumulatedMs: 30000));
        await pumpAppReady(tester);

        final controller = scrollView(tester).controller!;
        expect(controller.offset, 0);

        await tester.drag(find.byType(StopwatchPage), const Offset(0, -600));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(controller.offset, greaterThan(0));

        await unmountApp(tester);
      });

      testWidgets('12. The last lap is not hidden behind the bottom controls when scrolled to the end', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(manyLaps(30)), nativeState: nativeStateOf(accumulatedMs: 30000));
        await pumpAppReady(tester);

        final controller = scrollView(tester).controller!;
        controller.jumpTo(controller.position.maxScrollExtent);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final buttonsTop = tester.getTopLeft(find.widgetWithText(TextButton, l10n.start)).dy;

        final built = [
          for (var i = 1; i <= 30; i++)
            if (lapItem(i).evaluate().isNotEmpty) i,
        ];
        expect(built, isNotEmpty);

        final lowestBottom = built.map((order) => tester.getRect(lapItem(order)).bottom).reduce((a, b) => a > b ? a : b);
        expect(lowestBottom, lessThanOrEqualTo(buttonsTop));

        await unmountApp(tester);
      });

      testWidgets('13. A new lap is added to the list while running', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 50);
        await tester.tap(find.text(l10n.lap));
        await tester.pump();

        expect(lapItem(3), findsOneWidget);
        expect(inItem(3, find.text('3')), findsOneWidget);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });
    });

    group('StopwatchPage - lap tap', () {
      testWidgets('14. Tapping a restored lap opens LapDetailsPage', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        expect(find.byType(LapDetailsPage), findsNothing);

        await tester.tap(lapItem(2));
        await tester.pumpAndSettle();

        expect(find.byType(LapDetailsPage), findsOneWidget);
        expect(find.descendant(of: find.byType(AppBar), matching: find.text(l10n.lapDetails)), findsOneWidget);
      });

      testWidgets('15. Returning from LapDetailsPage keeps the laps and the time', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        await tester.tap(lapItem(1));
        await tester.pumpAndSettle();
        expect(find.byType(LapDetailsPage), findsOneWidget);

        final NavigatorState navigator = tester.state(find.byType(Navigator).first);
        navigator.pop();
        await tester.pumpAndSettle();

        expect(find.byType(LapDetailsPage), findsNothing);
        expect(lapItem(1), findsOneWidget);
        expect(lapItem(2), findsOneWidget);
        expect(displayedTimeIn(tester, StopwatchPage), const Duration(seconds: 20));
      });
    });
  });
}
