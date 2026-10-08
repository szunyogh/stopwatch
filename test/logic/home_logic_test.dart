import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/model/lap.dart';

final List<MethodCall> nativeCalls = [];

Iterable<MethodCall> callsOf(String method) => nativeCalls.where((call) => call.method == method);

void setupMockNativeChannels({String lapsJson = '[]', Map<String, Object?>? nativeState}) {
  nativeCalls.clear();

  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(const MethodChannel('stopwatch/native'), (MethodCall methodCall) async {
    nativeCalls.add(methodCall);

    switch (methodCall.method) {
      case 'hasNotificationPermission':
      case 'requestNotificationPermission':
        return true;
      case 'getState':
        return nativeState ?? {'isRunning': false, 'startedAtEpochMs': null, 'accumulatedMs': 0};
      case 'getLaps':
        return lapsJson;
      default:
        return null;
    }
  });

  messenger.setMockMethodCallHandler(const MethodChannel('stopwatch/native_events'), (_) async => null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late HomeLogic logic;
  late ProviderSubscription<HomeState> sub;

  ProviderContainer createContainer() => ProviderContainer(overrides: [appRouterProvider.overrideWith((ref) => AppRouter(ref))]);

  setUp(() {
    setupMockNativeChannels();

    container = createContainer();

    sub = container.listen<HomeState>(homeLogic, (prev, next) {});
    logic = container.read(homeLogic.notifier);
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  group('HomeLogic Unit Tests', () {
    Future<void> waitRealTime(WidgetTester tester, int ms) async {
      await tester.runAsync(() async => await Future.delayed(Duration(milliseconds: ms)));
      await tester.pump();
    }

    Future<void> settleInit(WidgetTester tester) => waitRealTime(tester, 20);

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
      expect((startCall.arguments as Map)['accumulatedMs'], 0);
      expect((startCall.arguments as Map)['startedAtEpochMs'], greaterThan(0));

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
      expect((stopCall.arguments as Map)['accumulatedMs'], timeAfterStop.inMilliseconds);
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
      expect(difference, closeTo(100, 50));

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

      final saved = jsonDecode(callsOf('saveLaps').single.arguments['laps'] as String) as List<dynamic>;
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
      await settleInit(tester); // a setUp-ban létrehozott logika _init()-je ne keveredjen a mock cseréjével

      final savedLaps = [
        LapModel(time: const Duration(seconds: 5), totalTime: const Duration(seconds: 5), order: 1),
        LapModel(time: const Duration(seconds: 10), totalTime: const Duration(seconds: 15), order: 2),
      ];

      setupMockNativeChannels(lapsJson: jsonEncode(savedLaps.map((lap) => lap.toJson()).toList()), nativeState: {'isRunning': false, 'startedAtEpochMs': null, 'accumulatedMs': 20000});

      final restoredContainer = createContainer();
      addTearDown(restoredContainer.dispose);
      restoredContainer.listen<HomeState>(homeLogic, (prev, next) {});

      await waitRealTime(tester, 20);

      final state = restoredContainer.read(homeLogic);
      expect(state.laps.map((lap) => lap.order), [1, 2]);
      expect(state.isRunning, false);
      expect(state.time, const Duration(seconds: 20));
      expect(state.currentTime, const Duration(seconds: 5));
    });

    testWidgets('13. A native state that is already running is continued on init', (tester) async {
      await settleInit(tester);

      final startedAt = DateTime.now().millisecondsSinceEpoch - 5000;

      setupMockNativeChannels(nativeState: {'isRunning': true, 'startedAtEpochMs': startedAt, 'accumulatedMs': 1000});

      final restoredContainer = createContainer();
      addTearDown(restoredContainer.dispose);
      restoredContainer.listen<HomeState>(homeLogic, (prev, next) {});

      await waitRealTime(tester, 20);

      final state = restoredContainer.read(homeLogic);
      expect(state.isRunning, true);
      expect(state.time.inMilliseconds, greaterThanOrEqualTo(6000));

      restoredContainer.read(homeLogic.notifier).stop();
      await tester.pump();
    });
  });
}
