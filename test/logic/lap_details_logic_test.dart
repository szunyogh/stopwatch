import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/logic/lap_details/lap_details_logic.dart';
import 'package:stopwatch/model/lap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late LapDetailsLogic logic;

  setUp(() {
    container = ProviderContainer();
    logic = container.read(lapDetailsLogic.notifier);
  });

  tearDown(() {
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
  });
}
