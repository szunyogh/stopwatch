import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/logic/stopwatch/stopwatch_logic.dart';
import 'package:stopwatch/logic/stopwatch/stopwatch_state.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late StopwatchLogic logic;
  late ProviderSubscription<StopwatchState> sub;

  setUp(() {
    setupMockNativeChannels();

    container = createTestContainer();

    sub = container.listen<StopwatchState>(stopwatchLogic, (prev, next) {});
    logic = container.read(stopwatchLogic.notifier);
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  Future<void> settleInit(WidgetTester tester) => waitRealTime(tester, 20);

  Future<ProviderContainer> createRestored(WidgetTester tester, {String lapsJson = '[]', Map<String, Object?>? native}) async {
    setupMockNativeChannels(lapsJson: lapsJson, nativeState: native);

    final restored = createTestContainer();
    addTearDown(restored.dispose);
    restored.listen<StopwatchState>(stopwatchLogic, (prev, next) {});

    await waitRealTime(tester, 20);
    return restored;
  }

  group('StopwatchLogic Unit Tests', () {
    testWidgets('1. Start button starts the timer and time increases', (tester) async {
      await settleInit(tester);

      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);

      logic.start();
      await tester.pump();
      expect(logic.state.isRunning, true);

      await waitRealTime(tester, 50);
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      final startCall = callsOf('notifyStart').single;
      expect(argsOf(startCall)['accumulatedMs'], 0);
      expect(argsOf(startCall)['startedAtEpochMs'], greaterThan(0));

      logic.stop();
    });

    testWidgets('2. Pause button stops the timer and time does not increase further', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      logic.stop();
      await tester.pump();
      expect(logic.state.isRunning, false);

      final timeAfterStop = logic.state.time;
      expect(timeAfterStop.inMilliseconds, greaterThan(0));

      await waitRealTime(tester, 50);
      expect(logic.state.time, timeAfterStop);

      final stopCall = callsOf('notifyStop').single;
      expect(argsOf(stopCall)['accumulatedMs'], timeAfterStop.inMilliseconds);
    });

    testWidgets('3. Reset button sets time to zero and stops the timer', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      logic.reset();
      await tester.pump();

      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);
      expect(logic.state.laps, isEmpty);
      expect(logic.state.currentTime, isNull);
      expect(callsOf('notifyReset'), hasLength(1));
    });

    testWidgets('4. Multiple start calls are ignored while already running', (tester) async {
      await settleInit(tester);

      logic.start();
      logic.start();
      logic.start();
      await tester.pump();
      expect(logic.state.isRunning, true);

      expect(callsOf('notifyStart'), hasLength(1));

      await waitRealTime(tester, 100);
      final time1 = logic.state.time.inMilliseconds;

      await waitRealTime(tester, 100);
      final time2 = logic.state.time.inMilliseconds;

      final difference = time2 - time1;
      expect(difference, closeTo(100, 60));

      logic.stop();
    });

    testWidgets('5. addLap creates a lap entry when timer is running', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 100);

      logic.addLap();

      expect(logic.state.currentTime, Duration.zero);
      expect(logic.state.laps.length, 1);

      final lap0 = logic.state.laps.first;
      expect(lap0.order, 1);
      expect(lap0.time.inMilliseconds, greaterThan(0));
      expect(lap0.totalTime, lap0.time);

      await tester.pump();
      expect(logic.state.currentTime, isNotNull);
      expect(logic.state.currentTime!.inMilliseconds, lessThan(50));

      final saved = jsonDecode(argsOf(callsOf('saveLaps').single)['laps'] as String) as List<dynamic>;
      expect(saved, hasLength(1));

      logic.stop();
    });

    testWidgets('6. addLap does nothing when timer is not running', (tester) async {
      await settleInit(tester);

      logic.addLap();
      await tester.pump();
      expect(logic.state.laps, isEmpty);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      logic.stop();
      await tester.pump();

      logic.addLap();
      await tester.pump();
      expect(logic.state.laps, isEmpty);
      expect(callsOf('saveLaps'), isEmpty);
    });

    testWidgets('7. currentTime tracks lap time correctly', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 100);

      logic.addLap();
      expect(logic.state.currentTime, Duration.zero);

      await waitRealTime(tester, 100);
      expect(logic.state.currentTime!.inMilliseconds, greaterThan(50));
      expect(logic.state.time.inMilliseconds, greaterThan(logic.state.currentTime!.inMilliseconds));

      logic.stop();
    });

    testWidgets('8. Lap order increments correctly', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();

      for (int i = 0; i < 5; i++) {
        await waitRealTime(tester, 30);
        logic.addLap();
      }
      await tester.pump();

      expect(logic.state.laps.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(logic.state.laps[i].order, i + 1);
      }

      logic.stop();
    });

    testWidgets('9. Reset clears laps and the current lap time', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);

      logic.addLap();
      await waitRealTime(tester, 50);

      logic.stop();
      await tester.pump();

      expect(logic.state.laps, hasLength(1));
      expect(logic.state.currentTime, isNotNull);

      logic.reset();
      await tester.pump();

      expect(logic.state.laps, isEmpty);
      expect(logic.state.time, Duration.zero);
      expect(logic.state.currentTime, isNull);
    });

    testWidgets('10. lapResetPressed adds a lap while running and resets while stopped', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);

      logic.lapResetPressed();
      expect(logic.state.laps, hasLength(1));

      logic.stop();
      await tester.pump();
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      logic.lapResetPressed();
      await tester.pump();
      expect(logic.state.time, Duration.zero);
      expect(logic.state.laps, isEmpty);
    });

    testWidgets('11. startStopPressed toggles between running and stopped', (tester) async {
      await settleInit(tester);

      logic.startStopPressed();
      await tester.pump();
      expect(logic.state.isRunning, true);

      logic.startStopPressed();
      await tester.pump();
      expect(logic.state.isRunning, false);
    });

    testWidgets('12. Saved laps and the stopped native state are restored on init', (tester) async {
      await settleInit(tester);

      final restored = await createRestored(tester, lapsJson: lapsToJson(testLaps), native: nativeStateOf(accumulatedMs: 20000));

      final state = restored.read(stopwatchLogic);
      expect(state.laps.map((lap) => lap.order), [1, 2]);
      expect(state.isRunning, false);
      expect(state.time, const Duration(seconds: 20));
      expect(state.currentTime, const Duration(seconds: 5));
    });

    testWidgets('13. A native state that is already running is continued on init', (tester) async {
      await settleInit(tester);

      final startedAt = DateTime.now().millisecondsSinceEpoch - 5000;

      final restored = await createRestored(tester, native: nativeStateOf(isRunning: true, startedAtEpochMs: startedAt, accumulatedMs: 1000));

      final state = restored.read(stopwatchLogic);
      expect(state.isRunning, true);
      expect(state.time.inMilliseconds, greaterThanOrEqualTo(6000));

      restored.read(stopwatchLogic.notifier).stop();
      await tester.pump();
    });

    testWidgets('14. stop and reset-less calls are ignored when not applicable', (tester) async {
      await settleInit(tester);

      logic.stop();
      logic.lapResetPressed();
      await tester.pump();

      expect(callsOf('notifyStop'), isEmpty);
      expect(callsOf('notifyReset'), isEmpty);
      expect(logic.state.time, Duration.zero);
    });

    testWidgets('15. Starting again after a stop continues from the accumulated time', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      logic.stop();
      await tester.pump();

      final firstRun = logic.state.time;
      expect(firstRun.inMilliseconds, greaterThan(0));

      logic.start();
      await tester.pump();

      expect(argsOf(callsOf('notifyStart').last)['accumulatedMs'], firstRun.inMilliseconds);

      await waitRealTime(tester, 50);
      expect(logic.state.time, greaterThan(firstRun));

      logic.stop();
    });

    testWidgets('16. Lap times are relative to the previous lap and all laps are saved', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();

      await waitRealTime(tester, 60);
      logic.addLap();
      await waitRealTime(tester, 60);
      logic.addLap();
      await tester.pump();

      final laps = logic.state.laps;
      expect(laps.map((lap) => lap.order), [1, 2]);
      expect(laps[1].totalTime, greaterThan(laps[0].totalTime));
      expect(laps[1].time, laps[1].totalTime - laps[0].totalTime);

      final saved = jsonDecode(argsOf(callsOf('saveLaps').last)['laps'] as String) as List<dynamic>;
      expect(saved, hasLength(2));

      logic.stop();
    });

    testWidgets('17. After a reset the first lap starts from zero again', (tester) async {
      await settleInit(tester);

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      logic.addLap();
      logic.stop();
      await tester.pump();

      logic.reset();
      await tester.pump();

      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      logic.addLap();

      final lap = logic.state.laps.single;
      expect(lap.order, 1);
      expect(lap.time, lap.totalTime);

      logic.stop();
    });

    testWidgets('18. A new lap after a restore continues the order and the lap time', (tester) async {
      await settleInit(tester);

      final restored = await createRestored(tester, lapsJson: lapsToJson(testLaps), native: nativeStateOf(accumulatedMs: 20000));
      final restoredLogic = restored.read(stopwatchLogic.notifier);

      restoredLogic.start();
      await tester.pump();
      await waitRealTime(tester, 50);
      restoredLogic.addLap();

      final lap = restored.read(stopwatchLogic).laps.last;
      expect(lap.order, 3);
      expect(lap.totalTime.inMilliseconds, greaterThanOrEqualTo(20000));
      expect(lap.time, lap.totalTime - const Duration(seconds: 15));

      restoredLogic.stop();
    });

    group('native events', () {
      testWidgets('19. A running native event starts the ticker, a stopped one freezes the time', (tester) async {
        await settleInit(tester);

        final startedAt = DateTime.now().millisecondsSinceEpoch - 2000;
        await emitNativeEvent(tester, nativeStateOf(kind: 'stopwatch', isRunning: true, startedAtEpochMs: startedAt, accumulatedMs: 0));

        expect(logic.state.isRunning, true);
        expect(logic.state.time.inMilliseconds, greaterThanOrEqualTo(2000));

        await emitNativeEvent(tester, nativeStateOf(kind: 'stopwatch', accumulatedMs: 3000));

        expect(logic.state.isRunning, false);
        expect(logic.state.time, const Duration(seconds: 3));
      });
    });
  });
}
