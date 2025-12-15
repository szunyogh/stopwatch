import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
import 'package:stopwatch/logic/home/home_state.dart';

void main() {
  late ProviderContainer container;
  late HomeLogic logic;
  late ProviderSubscription<HomeState> sub;

  setUp(() {
    container = ProviderContainer();

    sub = container.listen<HomeState>(
      homeLogic,
      (prev, next) {},
    );

    logic = container.read(homeLogic.notifier);
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  group('HomeLogic Tests', () {
    test('Start button starts the timer and time increases', () async {
      // Initial state
      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);

      // Start the timer
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait for some time to let the timer run
      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.time, greaterThan(Duration.zero));
    });

    test('Pause button stops the timer and time does not increase further', () async {
      // Start the timer
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 10));
      final timeAfterStart = logic.state.time;
      expect(timeAfterStart, greaterThan(Duration.zero));

      // Stop the timer
      logic.stop();
      expect(logic.state.isRunning, false);

      // Wait again and check time hasn't changed
      final timeAfterStop = logic.state.time;
      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.time, timeAfterStop);
    });

    test('Reset button sets time to zero and stops the timer', () async {
      // Start the timer
      logic.start();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.time, greaterThan(Duration.zero));
      expect(logic.state.isRunning, true);

      // Reset
      logic.reset();
      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);
    });

    test('Multiple start calls do not create multiple timers', () async {
      // Start multiple times
      logic.start();
      logic.start();
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait and check time increases normally
      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.time, greaterThan(Duration.zero));

      // Stop and check
      logic.stop();
      expect(logic.state.isRunning, false);
    });
  });
}
