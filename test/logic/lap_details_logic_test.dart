import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/logic/lap_details/lap_details_logic.dart';
import 'package:stopwatch/logic/lap_details/lap_details_state.dart';
import 'package:stopwatch/model/lap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late ProviderSubscription<LapDetailsState> sub;
  late LapDetailsLogic logic;

  setUp(() {
    container = ProviderContainer();

    sub = container.listen<LapDetailsState>(lapDetailsLogic, (prev, next) {});
    logic = container.read(lapDetailsLogic.notifier);
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  group('LapDetailsLogic Unit Tests', () {
    test('1. LapDetailsLogic initializes with given lap model correctly', () {
      expect(logic.state.lap, isNull);

      final testLap = LapModel(time: const Duration(seconds: 5), totalTime: const Duration(seconds: 15), order: 1);

      logic.initalize(testLap);

      expect(logic.state.lap, equals(testLap));
      expect(logic.state.lap?.order, 1);
      expect(logic.state.lap?.time.inSeconds, 5);
      expect(logic.state.lap?.totalTime.inSeconds, 15);
    });

    test('2. initalize replaces the previously stored lap', () {
      final first = LapModel(time: const Duration(seconds: 5), totalTime: const Duration(seconds: 5), order: 1);
      final second = LapModel(time: const Duration(seconds: 7), totalTime: const Duration(seconds: 12), order: 2);

      logic.initalize(first);
      logic.initalize(second);

      expect(logic.state.lap, equals(second));
      expect(logic.state.lap?.order, 2);
    });

    test('3. initalize notifies listeners with the new lap', () {
      final states = <LapDetailsState>[];
      container.listen<LapDetailsState>(lapDetailsLogic, (prev, next) => states.add(next));

      final testLap = LapModel(time: const Duration(seconds: 5), totalTime: const Duration(seconds: 15), order: 1);

      logic.initalize(testLap);

      expect(states, hasLength(1));
      expect(states.single.lap, equals(testLap));
    });
  });
}
