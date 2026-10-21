import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/ui/page/home.dart';
import 'package:stopwatch/ui/page/lap_details.dart';
import 'package:stopwatch/ui/page/stopwatch.dart';
import 'package:stopwatch/ui/page/timer.dart';
import 'package:stopwatch/ui/widget/sliding_time_display.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await loadL10n();
  });

  group('HomePage Unit Tests', () {
    group('HomePage - stopwatch tab', () {
      testWidgets('1. Initial state displays correctly', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        expect(find.byType(HomePage), findsOneWidget);
        expect(find.text(l10n.start), findsOneWidget);
        expect(find.text(l10n.reset), findsOneWidget);
        expect(find.text(l10n.stopwatch), findsOneWidget);
        expect(find.text(l10n.timer), findsOneWidget);

        expect(displayedTime(tester), Duration.zero);
        expect(lapItem(1), findsNothing);

        expect(textButton(tester, l10n.reset).onPressed, isNull);
        expect(textButton(tester, l10n.start).onPressed, isNotNull);

        await unmountApp(tester);
      });

      testWidgets('2. Start button starts the stopwatch and the UI updates', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await tester.pump();

        expect(find.text(l10n.stop), findsOneWidget);
        expect(find.text(l10n.lap), findsOneWidget);

        await waitRealTime(tester, 100);
        expect(displayedTime(tester).inMilliseconds, greaterThan(0));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('3. Stop button stops the stopwatch', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 100);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();

        expect(find.text(l10n.start), findsOneWidget);

        final stoppedAt = displayedTime(tester);
        await waitRealTime(tester, 60);
        expect(displayedTime(tester), stoppedAt);

        await unmountApp(tester);
      });

      testWidgets('4. Reset button resets the stopwatch to zero', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 100);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();

        expect(textButton(tester, l10n.reset).onPressed, isNotNull);

        await tester.tap(find.text(l10n.reset));
        await tester.pump();

        expect(find.text(l10n.start), findsOneWidget);
        expect(displayedTime(tester), Duration.zero);
        expect(textButton(tester, l10n.reset).onPressed, isNull);

        await unmountApp(tester);
      });

      testWidgets('5. Lap button adds a lap while running', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 100);

        await tester.tap(find.text(l10n.lap));
        await tester.pump();

        expect(lapItem(1), findsOneWidget);
        expect(find.text(l10n.lapTime), findsOneWidget);
        expect(find.text(l10n.lapTotalTime), findsOneWidget);
        expect(find.byType(SlidingTimeDisplay), findsNWidgets(2));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('6. Multiple laps are displayed', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));

        for (int i = 0; i < 3; i++) {
          await waitRealTime(tester, 50);
          await tester.tap(find.text(l10n.lap));
          await tester.pump();
        }

        expect(lapItem(1), findsOneWidget);
        expect(lapItem(2), findsOneWidget);
        expect(lapItem(3), findsOneWidget);
        expect(find.text(l10n.lapTime), findsNWidgets(3));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('7. Reset clears all laps', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 50);

        await tester.tap(find.text(l10n.lap));
        await waitRealTime(tester, 50);
        await tester.tap(find.text(l10n.lap));
        await tester.pump();

        expect(lapItem(1), findsOneWidget);
        expect(lapItem(2), findsOneWidget);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();

        await tester.tap(find.text(l10n.reset));
        await tester.pump();

        expect(lapItem(1), findsNothing);
        expect(lapItem(2), findsNothing);
        expect(find.text(l10n.lapTime), findsNothing);
        expect(displayedTime(tester), Duration.zero);

        await unmountApp(tester);
      });

      testWidgets('8. Tapping a lap navigates to LapDetailsPage', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        expect(find.byType(HomePage), findsOneWidget);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 100);
        await tester.tap(find.text(l10n.lap));
        await tester.pump();

        await tester.tap(find.text(l10n.stop));
        await tester.pump();

        expect(lapItem(1), findsOneWidget);
        expect(find.byType(LapDetailsPage), findsNothing);

        await tester.tap(lapItem(1));
        await tester.pumpAndSettle();

        expect(find.byType(LapDetailsPage), findsOneWidget);
        expect(find.descendant(of: find.byType(AppBar), matching: find.text(l10n.lapDetails)), findsOneWidget);
      });

      testWidgets('9. Saved laps and time are restored on startup', (tester) async {
        setupMockNativeChannels(lapsJson: lapsToJson(testLaps), nativeState: nativeStateOf(accumulatedMs: 20000));
        await pumpAppReady(tester);

        expect(lapItem(1), findsOneWidget);
        expect(lapItem(2), findsOneWidget);
        expect(displayedTime(tester), const Duration(seconds: 20));
        expect(find.text(DurationElapsedFormatter.toElapsedTime(const Duration(seconds: 5))), findsWidgets);

        expect(find.text(l10n.start), findsOneWidget);
        expect(textButton(tester, l10n.reset).onPressed, isNotNull);

        await unmountApp(tester);
      });

      testWidgets('10. A stopwatch that is already running natively is continued on startup', (tester) async {
        setupMockNativeChannels(nativeState: nativeStateOf(isRunning: true, startedAtEpochMs: nowMs() - 5000, accumulatedMs: 1000));
        await pumpAppReady(tester);

        expect(find.text(l10n.stop), findsOneWidget);
        expect(find.text(l10n.lap), findsOneWidget);
        expect(displayedTime(tester).inMilliseconds, greaterThanOrEqualTo(6000));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });
    });

    group('HomePage - tab navigation', () {
      testWidgets('11. Tapping the timer tab shows the timer page and its buttons', (tester) async {
        setupMockNativeChannels();
        final container = await pumpAppReady(tester);

        expect(activeTab(container), 0);

        await openTab(tester, l10n.timer);

        expect(activeTab(container), 1);
        expect(find.byType(TimerPage), findsOneWidget);

        expect(find.text(l10n.lap), findsNothing);
        expect(find.text(l10n.start), findsOneWidget);
        expect(textButton(tester, l10n.reset).onPressed, isNull);

        await unmountApp(tester);
      });

      testWidgets('12. Tapping the stopwatch tab returns to the stopwatch page', (tester) async {
        setupMockNativeChannels();
        final container = await pumpAppReady(tester);

        await openTab(tester, l10n.timer);
        expect(activeTab(container), 1);

        await openTab(tester, l10n.stopwatch);
        expect(activeTab(container), 0);
        expect(find.byType(StopwatchPage), findsOneWidget);

        await unmountApp(tester);
      });

      testWidgets('13. A running stopwatch keeps running while the timer tab is open', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 50);
        final before = displayedTime(tester);

        await openTab(tester, l10n.timer);
        await waitRealTime(tester, 100);

        await openTab(tester, l10n.stopwatch);
        await waitRealTime(tester, 20);

        expect(find.text(l10n.stop), findsOneWidget);
        expect(displayedTimeIn(tester, StopwatchPage).inMilliseconds, greaterThan(before.inMilliseconds + 100));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('14. The bottom buttons belong to the active tab', (tester) async {
        setupMockNativeChannels();
        await pumpAppReady(tester);

        await tester.tap(find.text(l10n.start));
        await tester.pump();
        expect(find.text(l10n.lap), findsOneWidget);

        await openTab(tester, l10n.timer);
        expect(find.text(l10n.lap), findsNothing);
        expect(find.text(l10n.stop), findsNothing);
        expect(find.text(l10n.start), findsOneWidget);

        await openTab(tester, l10n.stopwatch);
        expect(find.text(l10n.lap), findsOneWidget);
        expect(find.text(l10n.stop), findsOneWidget);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });
    });
  });
}
