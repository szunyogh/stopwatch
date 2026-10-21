import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/ui/page/timer.dart';

import '../helpers/test_helpers.dart';

final _addButton = find.byIcon(Icons.add_circle_outline_rounded);
final _removeButton = find.byIcon(Icons.remove_circle_outline_rounded);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await loadL10n();
  });

  Future<ProviderContainer> pumpTimerTab(WidgetTester tester, {Map<String, Object?>? timerState, Set<String> firstUseKinds = const {}}) async {
    setupMockNativeChannels(timerNativeState: timerState ?? timerNativeStateOf(accumulatedMs: 30000, totalMs: 30000), firstUseKinds: firstUseKinds);

    final container = await pumpAppReady(tester);
    await openTab(tester, l10n.timer);
    await settleInit(tester);
    await tester.pump();

    return container;
  }

  Duration shownTime(WidgetTester tester) => displayedTimeIn(tester, TimerPage);

  group('TimerPage Unit Tests', () {
    group('TimerPage - display', () {
      testWidgets('1. Shows the native time and the initial button states', (tester) async {
        await pumpTimerTab(tester);

        expect(shownTime(tester), const Duration(seconds: 30));
        expect(_addButton, findsOneWidget);
        expect(_removeButton, findsOneWidget);

        expect(textButton(tester, l10n.start).onPressed, isNotNull);
        expect(textButton(tester, l10n.reset).onPressed, isNull);

        await unmountApp(tester);
      });

      testWidgets('2. The time can be picked only while the timer is stopped', (tester) async {
        await pumpTimerTab(tester);

        expect(timeDisplayIn(tester, TimerPage).onPicked, isNotNull);

        await tester.tap(find.text(l10n.start));
        await tester.pump();
        expect(timeDisplayIn(tester, TimerPage).onPicked, isNull);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        expect(timeDisplayIn(tester, TimerPage).onPicked, isNotNull);

        await unmountApp(tester);
      });

      testWidgets('3. A native event updates the displayed time', (tester) async {
        await pumpTimerTab(tester);

        await emitNativeEvent(tester, timerNativeStateOf(accumulatedMs: 20000, totalMs: 20000));

        expect(shownTime(tester), const Duration(seconds: 20));

        await unmountApp(tester);
      });
    });

    group('TimerPage - add / remove time', () {
      testWidgets('4. Plus button adds 10 seconds', (tester) async {
        await pumpTimerTab(tester);

        await tester.tap(_addButton);
        await tester.pump();

        expect(shownTime(tester), const Duration(seconds: 40));
        expect(argsOf(callsOf('notifySetTimer').last)['totalMs'], 40000);

        await unmountApp(tester);
      });

      testWidgets('5. Minus button removes 10 seconds', (tester) async {
        await pumpTimerTab(tester);

        await tester.tap(_removeButton);
        await tester.pump();

        expect(shownTime(tester), const Duration(seconds: 20));
        expect(argsOf(callsOf('notifySetTimer').last)['totalMs'], 20000);

        await unmountApp(tester);
      });

      testWidgets('6. Minus button never goes below zero', (tester) async {
        await pumpTimerTab(tester, timerState: timerNativeStateOf(accumulatedMs: 5000, totalMs: 5000));

        await tester.tap(_removeButton);
        await tester.pump();

        expect(shownTime(tester), Duration.zero);

        await unmountApp(tester);
      });

      testWidgets('7. Changing the time keeps Reset disabled (time equals the total)', (tester) async {
        await pumpTimerTab(tester);

        await tester.tap(_addButton);
        await tester.pump();

        expect(textButton(tester, l10n.reset).onPressed, isNull);

        await unmountApp(tester);
      });
    });

    group('TimerPage - start / stop / reset', () {
      testWidgets('8. Start counts down, Stop freezes the time, Reset restores it', (tester) async {
        await pumpTimerTab(tester);

        await tester.tap(find.text(l10n.start));
        await tester.pump();

        expect(find.text(l10n.stop), findsOneWidget);
        expect(callsOfKind('notifyStart', 'timer'), hasLength(1));

        await waitRealTime(tester, 100);
        expect(shownTime(tester).inMilliseconds, lessThan(30000));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();

        expect(find.text(l10n.start), findsOneWidget);
        expect(callsOfKind('notifyStop', 'timer'), hasLength(1));

        final frozen = shownTime(tester);
        await waitRealTime(tester, 60);
        expect(shownTime(tester), frozen);

        expect(textButton(tester, l10n.reset).onPressed, isNotNull);

        await tester.tap(find.text(l10n.reset));
        await tester.pump();

        expect(shownTime(tester), const Duration(seconds: 30));
        expect(textButton(tester, l10n.reset).onPressed, isNull);
        expect(argsOf(callsOfKind('notifyReset', 'timer').single)['accumulatedMs'], 30000);

        await unmountApp(tester);
      });

      testWidgets('9. Reset is disabled while the timer is running', (tester) async {
        await pumpTimerTab(tester);

        await tester.tap(find.text(l10n.start));
        await waitRealTime(tester, 50);

        expect(textButton(tester, l10n.reset).onPressed, isNull);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });

      testWidgets('10. Start with no time set does nothing', (tester) async {
        await pumpTimerTab(tester, timerState: timerNativeStateOf(accumulatedMs: 0, totalMs: 0));

        await tester.tap(find.text(l10n.start));
        await tester.pump();

        expect(find.text(l10n.start), findsOneWidget);
        expect(callsOf('notifyStart'), isEmpty);

        await unmountApp(tester);
      });

      testWidgets('11. A running native timer is continued when the app starts', (tester) async {
        await pumpTimerTab(tester, timerState: timerNativeStateOf(isRunning: true, startedAtEpochMs: nowMs() - 2000, accumulatedMs: 30000, totalMs: 30000));

        expect(find.text(l10n.stop), findsOneWidget);
        expect(shownTime(tester).inMilliseconds, inInclusiveRange(20000, 28100));

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await unmountApp(tester);
      });
    });

    group('TimerPage - plus/minus animation', () {
      testWidgets('12. The plus and minus buttons slide away while running and come back after stopping', (tester) async {
        await pumpTimerTab(tester);

        await tester.tap(find.text(l10n.start));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(_addButton, findsNothing);
        expect(_removeButton, findsNothing);

        await tester.tap(find.text(l10n.stop));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(_addButton, findsOneWidget);
        expect(_removeButton, findsOneWidget);

        await unmountApp(tester);
      });
    });

    group('TimerPage - finish', () {
      testWidgets('13. The timer finishes, shows the total time again and notifies native', (tester) async {
        await pumpTimerTab(tester, timerState: timerNativeStateOf(accumulatedMs: 100, totalMs: 100));

        await tester.tap(find.text(l10n.start));
        await tester.pump();

        await waitRealTime(tester, 150);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(l10n.start), findsOneWidget);
        expect(shownTime(tester), const Duration(milliseconds: 100));
        expect(callsOf('notifyTimerFinished'), hasLength(1));

        expect(_addButton, findsOneWidget);
        expect(_removeButton, findsOneWidget);

        await unmountApp(tester);
      });

      testWidgets('14. A native finish event resets the display to the total time', (tester) async {
        await pumpTimerTab(tester, timerState: timerNativeStateOf(accumulatedMs: 10000, totalMs: 10000));

        await emitNativeEvent(tester, timerNativeStateOf(isRunning: true, startedAtEpochMs: nowMs() - 5000, accumulatedMs: 3000, totalMs: 10000));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(l10n.start), findsOneWidget);
        expect(shownTime(tester), const Duration(seconds: 10));
        expect(callsOf('notifyTimerFinished'), hasLength(1));

        await unmountApp(tester);
      });
    });

    group('TimerPage - first use tip', () {
      testWidgets('15. Shows the tip dialog on the first use of the timer', (tester) async {
        final container = await pumpTimerTab(tester, firstUseKinds: {'timer'});
        await tester.pump(const Duration(milliseconds: 300));

        expect(container.read(appRouterProvider).topRoute.name, TimerTipDialog.name);

        await unmountApp(tester);
      });

      testWidgets('16. Does not show the tip dialog when it was already seen', (tester) async {
        final container = await pumpTimerTab(tester);
        await tester.pump(const Duration(milliseconds: 300));

        expect(container.read(appRouterProvider).topRoute.name, isNot(TimerTipDialog.name));

        await unmountApp(tester);
      });
    });
  });
}
