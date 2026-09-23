import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/lap_details/lap_details_state.dart';
import 'package:stopwatch/model/lap.dart';

final lapDetailsLogic = NotifierProvider.autoDispose<LapDetailsLogic, LapDetailsState>(LapDetailsLogic.new);

class LapDetailsLogic extends BaseLogic<LapDetailsState> {
  @override
  LapDetailsState build() {
    initLogger();

    ref.onDispose(() => logger.i('[LapDetailsLogic] disposed'));

    return const LapDetailsState();
  }

  void initalize(LapModel lap) {
    try {
      logger.i('[LapDetailsLogic] initalize');

      changeState((current) => current.copyWith(lap: lap));
    } catch (error, stack) {
      logger.e('[LapDetailsLogic] initalize error', error: error, stackTrace: stack);
    }
  }
}
