import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/logic/logger.dart';

void setupMockNativeChannels() {
  const methodChannel = MethodChannel('stopwatch/native');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'hasNotificationPermission':
      case 'requestNotificationPermission':
        return true;
      case 'getState':
        return {'isRunning': false, 'startedAtEpochMs': null, 'accumulatedMs': 0};
      case 'notifyStart':
      case 'notifyStop':
      case 'notifyReset':
        return null;
      default:
        return null;
    }
  });

  const eventChannel = MethodChannel('stopwatch/native_events');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(eventChannel, (MethodCall methodCall) async {
    return null;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late HomeLogic logic;
  late ProviderSubscription<HomeState> sub;

  setUp(() {
    setupMockNativeChannels();

    container = ProviderContainer(
      overrides: [
        loggerProvider.overrideWithValue(Logger(level: Level.nothing)),
        appRouterProvider.overrideWith((ref) => AppRouter(ref)),
      ],
    );

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

    testWidgets('1. Start button starts the timer and time increases', (tester) async {
      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);

      logic.start();
      await tester.pump();
      expect(logic.state.isRunning, true);

      await waitRealTime(tester, 50);
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      logic.stop();
    });

    testWidgets('2. Pause button stops the timer and time does not increase further', (tester) async {
      logic.start();
      await tester.pump();
      await waitRealTime(tester, 50);

      final timeAfterStart = logic.state.time;
      expect(timeAfterStart.inMilliseconds, greaterThan(0));

      logic.stop();
      await tester.pump();
      expect(logic.state.isRunning, false);

      await waitRealTime(tester, 50);
      expect(logic.state.time, timeAfterStart);
    });

    testWidgets('3. Reset button sets time to zero and stops the timer', (tester) async {
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
    });

    testWidgets('4. Multiple start calls do not create multiple timers', (tester) async {
      logic.start();
      logic.start();
      logic.start();
      await tester.pump();
      expect(logic.state.isRunning, true);

      await waitRealTime(tester, 100);
      final time1 = logic.state.time.inMilliseconds;

      await waitRealTime(tester, 100);
      final time2 = logic.state.time.inMilliseconds;

      final difference = time2 - time1;
      expect(difference, closeTo(100, 50));

      logic.stop();
    });

    testWidgets('5. addLap creates a lap entry when timer is running', (tester) async {
      logic.start();
      await tester.pump();
      await waitRealTime(tester, 100);

      logic.addLap();
      await tester.pump();

      expect(logic.state.laps.length, 1);
      final lap0 = logic.state.laps.first;

      expect(lap0.order, 1);
      expect(lap0.time.inMilliseconds, greaterThan(0));

      expect(logic.state.currentTime, isNotNull);
      expect(logic.state.currentTime!.inMilliseconds, lessThan(30));

      logic.stop();
    });

    testWidgets('6. addLap does nothing when timer is not running', (tester) async {
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
    });

    testWidgets('7. currentTime tracks lap time correctly', (tester) async {
      logic.start();
      await tester.pump();
      await waitRealTime(tester, 100);

      logic.addLap();
      await tester.pump();

      expect(logic.state.currentTime, isNotNull);
      expect(logic.state.currentTime!.inMilliseconds, lessThan(30));

      await waitRealTime(tester, 100);
      expect(logic.state.currentTime!.inMilliseconds, greaterThan(50));
      expect(logic.state.time.inMilliseconds, greaterThan(logic.state.currentTime!.inMilliseconds));

      logic.stop();
    });

    testWidgets('8. Lap order increments correctly', (tester) async {
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
  });
}
