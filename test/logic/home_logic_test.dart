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

  group('HomeLogic Unit Tests', () {
    test('1. Start button starts the timer and time increases', () async {
      // Initial state
      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);

      // Start the timer
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait for some time to let the timer run
      await Future.delayed(const Duration(milliseconds: 50));
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      // Cleanup
      logic.stop();
    });

    test('2. Pause button stops the timer and time does not increase further', () async {
      // Start the timer
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 50));
      final timeAfterStart = logic.state.time;
      expect(timeAfterStart.inMilliseconds, greaterThan(0));

      // Stop the timer
      logic.stop();
      expect(logic.state.isRunning, false);

      // Wait again and check time hasn't changed
      final timeAfterStop = logic.state.time;
      await Future.delayed(const Duration(milliseconds: 50));
      expect(logic.state.time, timeAfterStop);
    });

    test('3. Reset button sets time to zero and stops the timer', () async {
      // Start the timer
      logic.start();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(logic.state.time.inMilliseconds, greaterThan(0));
      expect(logic.state.isRunning, true);

      // Reset
      logic.reset();
      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);
    });

    test('4. Multiple start calls do not create multiple timers', () async {
      // Start multiple times
      logic.start();
      logic.start();
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait and measure time
      await Future.delayed(const Duration(milliseconds: 50));
      final time1 = logic.state.time.inMilliseconds;

      await Future.delayed(const Duration(milliseconds: 50));
      final time2 = logic.state.time.inMilliseconds;

      // Time should increase normally (not 3x faster)
      final difference = time2 - time1;
      expect(difference, closeTo(50, 20)); // ~50ms difference, not ~150ms

      // Cleanup
      logic.stop();
    });

    test('5. Reset works even when timer is running', () async {
      // Start the timer
      logic.start();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(logic.state.isRunning, true);
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      // Reset while running
      logic.reset();

      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);

      // Wait and verify it stays stopped
      await Future.delayed(const Duration(milliseconds: 50));
      expect(logic.state.time, Duration.zero);
    });
  });
}
