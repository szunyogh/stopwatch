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

      // Kis várakozás hogy a timer beinduljon
      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.isRunning, true);

      // Wait for some time to let the timer run
      await Future.delayed(const Duration(milliseconds: 50));
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      // Cleanup
      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('2. Pause button stops the timer and time does not increase further', () async {
      // Start the timer
      logic.start();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.isRunning, true);

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 50));
      final timeAfterStart = logic.state.time;
      expect(timeAfterStart.inMilliseconds, greaterThan(0));

      // Stop the timer
      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
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

      await Future.delayed(const Duration(milliseconds: 10));
      expect(logic.state.isRunning, true);

      // Reset
      logic.reset();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);
      expect(logic.state.laps, isEmpty);
      expect(logic.state.currentTime, isNull);
    });

    test('4. Multiple start calls do not create multiple timers', () async {
      // Start multiple times
      logic.start();
      await Future.delayed(const Duration(milliseconds: 10));
      logic.start();
      logic.start();
      expect(logic.state.isRunning, true);

      // Wait and measure time
      await Future.delayed(const Duration(milliseconds: 100));
      final time1 = logic.state.time.inMilliseconds;

      await Future.delayed(const Duration(milliseconds: 100));
      final time2 = logic.state.time.inMilliseconds;

      // Time should increase normally (not 3x faster)
      final difference = time2 - time1;
      expect(difference, closeTo(100, 30)); // ~100ms difference, not ~300ms

      // Cleanup
      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('5. Reset works even when timer is running', () async {
      // Start the timer
      logic.start();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(logic.state.isRunning, true);
      expect(logic.state.time.inMilliseconds, greaterThan(0));

      // Reset while running
      logic.reset();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.time, Duration.zero);
      expect(logic.state.isRunning, false);

      // Wait and verify it stays stopped
      await Future.delayed(const Duration(milliseconds: 50));
      expect(logic.state.time, Duration.zero);
    });

    test('6. addLap creates a lap entry when timer is running', () async {
      logic.start();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(logic.state.laps, isEmpty);
      expect(logic.state.currentTime, isNull);

      // Add first lap
      logic.addLap();

      // Read values immediately, not after a delay
      final lap0 = logic.state.laps.first;
      final timeAtAssert = logic.state.time;

      expect(logic.state.laps.length, 1);
      expect(lap0.order, 1);
      expect(lap0.time.inMilliseconds, greaterThan(0));

      // totalTime equals the state.time at the moment the lap was created,
      // but state.time may have increased by the time we assert
      expect(lap0.totalTime, lessThanOrEqualTo(timeAtAssert));

      // Optional: allow a small tolerance for near-equality
      expect(
        lap0.totalTime.inMilliseconds,
        closeTo(timeAtAssert.inMilliseconds, 30), // 30ms tolerance
      );

      expect(logic.state.currentTime, Duration.zero);

      // Cleanup
      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('7. addLap does nothing when timer is not running', () async {
      // Try to add lap when stopped
      expect(logic.state.isRunning, false);
      logic.addLap();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.laps, isEmpty);

      // Start, stop, then try to add lap
      logic.start();
      await Future.delayed(const Duration(milliseconds: 50));
      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));

      logic.addLap();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.laps, isEmpty);
    });

    test('8. currentTime tracks lap time correctly', () async {
      // Start the timer
      logic.start();
      await Future.delayed(const Duration(milliseconds: 100));

      // Add first lap - this resets currentTime
      logic.addLap();

      // currentTime is reset at lap creation, but a tick may happen immediately after,
      // so we allow a small tolerance instead of strict zero.
      expect(logic.state.currentTime, isNotNull);
      expect(logic.state.currentTime!.inMilliseconds, lessThan(30)); // ~0ms with tolerance

      // Wait and check currentTime increases
      await Future.delayed(const Duration(milliseconds: 100));
      expect(logic.state.currentTime!.inMilliseconds, greaterThan(50));

      final totalTime = logic.state.time;
      final currentTime = logic.state.currentTime!;

      // Total time should be greater than current lap time
      expect(totalTime.inMilliseconds, greaterThan(currentTime.inMilliseconds));

      // Cleanup
      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('9. Reset clears all laps and currentTime', () async {
      // Start timer and add some laps
      logic.start();
      await Future.delayed(const Duration(milliseconds: 50));
      logic.addLap();
      await Future.delayed(const Duration(milliseconds: 50));
      logic.addLap();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.laps.length, 2);
      expect(logic.state.currentTime, isNotNull);

      // Reset
      logic.reset();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.laps, isEmpty);
      expect(logic.state.currentTime, isNull);
      expect(logic.state.time, Duration.zero);
    });

    test('10. Lap order increments correctly', () async {
      logic.start();
      await Future.delayed(const Duration(milliseconds: 30));

      // Add 5 laps
      for (int i = 0; i < 5; i++) {
        logic.addLap();
        await Future.delayed(const Duration(milliseconds: 30));
      }

      expect(logic.state.laps.length, 5);

      for (int i = 0; i < 5; i++) {
        expect(logic.state.laps[i].order, i + 1);
      }

      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('11. First lap uses total time when no currentTime exists', () async {
      logic.start();
      await Future.delayed(const Duration(milliseconds: 100));

      final totalTimeBeforeLap = logic.state.time;

      // First lap should use state.time since currentTime is null
      logic.addLap();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logic.state.laps.length, 1);
      expect(logic.state.laps[0].time.inMilliseconds, closeTo(totalTimeBeforeLap.inMilliseconds, 20));

      logic.stop();
      await Future.delayed(const Duration(milliseconds: 10));
    });
  });
}
