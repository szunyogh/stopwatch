import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/logic/timer/timer_logic.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late TimerLogic logic;
  var containerDisposed = false;

  Future<void> boot(WidgetTester tester, {Map<String, Object?>? timerState}) async {
    setupMockNativeChannels(timerNativeState: timerState ?? timerNativeStateOf(accumulatedMs: 0, totalMs: 0));

    containerDisposed = false;
    container = createTestContainer();
    addTearDown(() {
      if (!containerDisposed) container.dispose();
    });

    container.listen(timerLogic, (prev, next) {});
    logic = container.read(timerLogic.notifier);

    await settleInit(tester);
  }

  Future<void> bootWithTotal(WidgetTester tester, int totalMs) => boot(
    tester,
    timerState: timerNativeStateOf(accumulatedMs: totalMs, totalMs: totalMs),
  );

  group('TimerLogic Unit Tests', () {
    group('init', () {
      testWidgets('1. Starts at zero and asks the native side for the timer state', (tester) async {
        await boot(tester);

        expect(logic.state.time, Duration.zero);
        expect(logic.state.isRunning, false);
        expect(logic.startTime, Duration.zero);

        expect(callsOfKind('getState', 'timer'), hasLength(1));
        expect(callsOfKind('isFirstUse', 'timer'), hasLength(1));
      });

      testWidgets('2. A stopped native state is restored', (tester) async {
        await boot(tester, timerState: timerNativeStateOf(accumulatedMs: 30000, totalMs: 60000));

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(seconds: 30));
        expect(logic.startTime, const Duration(seconds: 60));
      });

      testWidgets('3. A running native state is continued', (tester) async {
        await boot(tester, timerState: timerNativeStateOf(isRunning: true, startedAtEpochMs: nowMs() - 2000, accumulatedMs: 30000, totalMs: 60000));

        expect(logic.state.isRunning, true);
        expect(logic.state.time.inMilliseconds, inInclusiveRange(20000, 28100));
        expect(logic.startTime, const Duration(seconds: 60));

        logic.stop();
        await tester.pump();
      });
    });

    group('native events', () {
      testWidgets('4. A stopped native event updates time and total', (tester) async {
        await bootWithTotal(tester, 60000);

        await emitNativeEvent(tester, timerNativeStateOf(accumulatedMs: 12000, totalMs: 20000));

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(seconds: 12));
        expect(logic.startTime, const Duration(seconds: 20));
      });

      testWidgets('5. A running native event starts the countdown', (tester) async {
        await bootWithTotal(tester, 20000);

        await emitNativeEvent(tester, timerNativeStateOf(isRunning: true, startedAtEpochMs: nowMs(), accumulatedMs: 20000, totalMs: 20000));
        expect(logic.state.isRunning, true);

        await waitRealTime(tester, 100);
        expect(logic.state.time.inMilliseconds, lessThan(20000));

        logic.stop();
        await tester.pump();
      });

      testWidgets('6. Events of the stopwatch are ignored', (tester) async {
        await bootWithTotal(tester, 60000);

        await emitNativeEvent(tester, nativeStateOf(kind: 'stopwatch', isRunning: true, startedAtEpochMs: nowMs(), accumulatedMs: 5000));

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(seconds: 60));
      });
    });

    group('setTime / addTime / removeTime', () {
      testWidgets('7. setTime updates the state immediately and notifies native after the debounce', (tester) async {
        await boot(tester);

        logic.setTime(const Duration(seconds: 30));
        logic.setTime(const Duration(minutes: 1, seconds: 30));

        expect(logic.state.time, const Duration(seconds: 90));
        expect(logic.startTime, const Duration(seconds: 90));
        expect(logic.state.isRunning, false);
        expect(callsOf('notifySetTimer'), isEmpty);

        await tester.pump(const Duration(milliseconds: 299));
        expect(callsOf('notifySetTimer'), isEmpty);

        await tester.pump(const Duration(milliseconds: 2));
        final call = callsOf('notifySetTimer').single;
        expect(argsOf(call)['totalMs'], 90000);
      });

      testWidgets('8. setTime is ignored while running', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();

        logic.setTime(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 400));

        expect(logic.startTime, const Duration(seconds: 60));
        expect(callsOf('notifySetTimer'), isEmpty);

        logic.stop();
        await tester.pump();
      });

      testWidgets('9. addTime adds 10 seconds and notifies native', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.addTime();
        await tester.pump();

        expect(logic.state.time, const Duration(seconds: 70));
        expect(logic.startTime, const Duration(seconds: 70));
        expect(argsOf(callsOf('notifySetTimer').single)['totalMs'], 70000);
      });

      testWidgets('10. removeTime removes 10 seconds and notifies native', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.removeTime();
        await tester.pump();

        expect(logic.state.time, const Duration(seconds: 50));
        expect(logic.startTime, const Duration(seconds: 50));
        expect(argsOf(callsOf('notifySetTimer').single)['totalMs'], 50000);
      });

      testWidgets('11. removeTime never goes below zero', (tester) async {
        await bootWithTotal(tester, 5000);

        logic.removeTime();
        await tester.pump();
        expect(logic.state.time, Duration.zero);

        logic.removeTime();
        await tester.pump();
        expect(logic.state.time, Duration.zero);
        expect(argsOf(callsOf('notifySetTimer').last)['totalMs'], 0);
      });

      testWidgets('12. addTime and removeTime are ignored while running', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();

        logic.addTime();
        logic.removeTime();
        await tester.pump();

        expect(logic.startTime, const Duration(seconds: 60));
        expect(callsOf('notifySetTimer'), isEmpty);

        logic.stop();
        await tester.pump();
      });
    });

    group('start / stop / reset', () {
      testWidgets('13. start runs the countdown and notifies native', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();
        expect(logic.state.isRunning, true);

        final call = callsOf('notifyStart').single;
        expect(callKind(call), 'timer');
        expect(argsOf(call)['accumulatedMs'], 60000);
        expect(argsOf(call)['startedAtEpochMs'], greaterThan(0));

        await waitRealTime(tester, 100);
        expect(logic.state.time.inMilliseconds, lessThan(60000));

        logic.stop();
        await tester.pump();
      });

      testWidgets('14. start does nothing when no time is set', (tester) async {
        await boot(tester);

        logic.start();
        await tester.pump();

        expect(logic.state.isRunning, false);
        expect(callsOf('notifyStart'), isEmpty);
      });

      testWidgets('15. Multiple start calls are ignored while already running', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        logic.start();
        logic.start();
        await tester.pump();

        expect(callsOf('notifyStart'), hasLength(1));

        logic.stop();
        await tester.pump();
      });

      testWidgets('16. start flushes a pending picked time before notifying the start', (tester) async {
        await boot(tester);

        logic.setTime(const Duration(seconds: 30));
        logic.start();
        await tester.pump();

        final methods = nativeCalls.map((call) => call.method).toList();
        expect(methods, contains('notifySetTimer'));
        expect(methods.indexOf('notifySetTimer'), lessThan(methods.indexOf('notifyStart')));
        expect(argsOf(callsOf('notifySetTimer').single)['totalMs'], 30000);

        await tester.pump(const Duration(milliseconds: 400));
        expect(callsOf('notifySetTimer'), hasLength(1));

        logic.stop();
        await tester.pump();
      });

      testWidgets('17. stop freezes the remaining time and notifies native', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();
        await waitRealTime(tester, 100);

        logic.stop();
        await tester.pump();
        expect(logic.state.isRunning, false);

        final frozen = logic.state.time;
        expect(frozen.inMilliseconds, lessThan(60000));

        await waitRealTime(tester, 60);
        expect(logic.state.time, frozen);

        final call = callsOf('notifyStop').single;
        expect(callKind(call), 'timer');
        expect(argsOf(call)['accumulatedMs'], frozen.inMilliseconds);
      });

      testWidgets('18. stop does nothing when not running', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.stop();
        await tester.pump();

        expect(callsOf('notifyStop'), isEmpty);
      });

      testWidgets('19. start after stop continues from the remaining time', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();
        await waitRealTime(tester, 100);
        logic.stop();
        await tester.pump();

        final remaining = logic.state.time;
        expect(remaining.inMilliseconds, lessThan(60000));

        logic.start();
        await tester.pump();

        final startCalls = callsOf('notifyStart').toList();
        expect(startCalls, hasLength(2));
        expect(argsOf(startCalls.last)['accumulatedMs'], remaining.inMilliseconds);

        logic.stop();
        await tester.pump();
      });

      testWidgets('20. reset restores the total time and notifies native', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();
        await waitRealTime(tester, 50);
        logic.stop();
        await tester.pump();
        expect(logic.state.time, isNot(const Duration(seconds: 60)));

        logic.reset();
        await tester.pump();

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(seconds: 60));

        final call = callsOf('notifyReset').single;
        expect(callKind(call), 'timer');
        expect(argsOf(call)['accumulatedMs'], 60000);
      });

      testWidgets('21. reset is ignored while running', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.start();
        await tester.pump();

        logic.reset();
        await tester.pump();

        expect(logic.state.isRunning, true);
        expect(callsOf('notifyReset'), isEmpty);

        logic.stop();
        await tester.pump();
      });

      testWidgets('22. startStopPressed toggles between running and stopped', (tester) async {
        await bootWithTotal(tester, 60000);

        logic.startStopPressed();
        await tester.pump();
        expect(logic.state.isRunning, true);

        logic.startStopPressed();
        await tester.pump();
        expect(logic.state.isRunning, false);
      });
    });

    group('finish', () {
      testWidgets('23. The timer finishes by itself when the time runs out', (tester) async {
        await bootWithTotal(tester, 100);

        logic.start();
        await tester.pump();
        expect(logic.state.isRunning, true);

        await waitRealTime(tester, 150);
        await tester.pump();

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(milliseconds: 100));
        expect(callsOf('notifyTimerFinished'), hasLength(1));

        await waitRealTime(tester, 50);
        expect(callsOf('notifyTimerFinished'), hasLength(1));
      });

      testWidgets('24. A native event that is already finished resets to the total time', (tester) async {
        await bootWithTotal(tester, 10000);

        await emitNativeEvent(tester, timerNativeStateOf(isRunning: true, startedAtEpochMs: nowMs() - 5000, accumulatedMs: 3000, totalMs: 10000));

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(seconds: 10));
        expect(callsOf('notifyTimerFinished'), hasLength(1));
      });

      testWidgets('25. After finishing, start runs the full time again', (tester) async {
        await bootWithTotal(tester, 10000);

        await emitNativeEvent(tester, timerNativeStateOf(isRunning: true, startedAtEpochMs: nowMs() - 5000, accumulatedMs: 3000, totalMs: 10000));
        expect(logic.state.isRunning, false);

        logic.start();
        await tester.pump();

        expect(logic.state.isRunning, true);
        expect(argsOf(callsOf('notifyStart').single)['accumulatedMs'], 10000);

        logic.stop();
        await tester.pump();
      });
    });

    group('dispose', () {
      testWidgets('26. Dispose flushes a pending picked time and cancels the debounce', (tester) async {
        await boot(tester);

        logic.setTime(const Duration(seconds: 45));
        expect(callsOf('notifySetTimer'), isEmpty);

        container.dispose();
        containerDisposed = true;
        await waitRealTime(tester, 20);

        expect(callsOf('notifySetTimer'), hasLength(1));
        expect(argsOf(callsOf('notifySetTimer').single)['totalMs'], 45000);

        await tester.pump(const Duration(milliseconds: 500));
        expect(callsOf('notifySetTimer'), hasLength(1));
      });

      testWidgets('27. Dispose without a pending picked time sends nothing', (tester) async {
        await bootWithTotal(tester, 60000);

        container.dispose();
        containerDisposed = true;
        await waitRealTime(tester, 20);

        expect(callsOf('notifySetTimer'), isEmpty);
      });
    });
  });
}
