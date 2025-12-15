import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/model/lap.dart';

final homeLogic = NotifierProvider.autoDispose<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  @override
  HomeState build() {
    initLogger();

    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
      logger.i('[HomeLogic] disposed');
    });

    return const HomeState();
  }

  Timer? _timer;

  void start() async {
    try {
      logger.i('[HomeLogic] start');

      if (_timer?.isActive ?? false) return;

      logger.i('[HomeLogic] timer started');

      _timer ??= Timer.periodic(const Duration(milliseconds: 1), (timer) {
        final newTime = state.time + const Duration(milliseconds: 1);
        state = state.copyWith(time: newTime);
        if (state.currentTime != null) {
          final newCurrentTime = (state.currentTime ?? Duration.zero) + const Duration(milliseconds: 1);
          state = state.copyWith(currentTime: newCurrentTime);
        }
      });

      state = state.copyWith(isRunning: _timer?.isActive ?? false);
    } catch (e, stack) {
      logger.e('[HomeLogic] start', error: e, stackTrace: stack);
    }
  }

  void stop() async {
    try {
      logger.i('[HomeLogic] stop');
      _timer?.cancel();
      state = state.copyWith(isRunning: _timer?.isActive ?? false);
      _timer = null;
    } catch (e, stack) {
      logger.e('[HomeLogic] stop', error: e, stackTrace: stack);
    }
  }

  void reset() async {
    try {
      logger.i('[HomeLogic] reset');

      if (state.isRunning) stop();

      state = state.copyWith(time: Duration.zero, laps: [], currentTime: null);
    } catch (e, stack) {
      logger.e('[HomeLogic] reset', error: e, stackTrace: stack);
    }
  }

  void addLap() async {
    try {
      logger.i('[HomeLogic] addLap');

      if (!state.isRunning) return;

      logger.i('[HomeLogic] adding lap');

      final item = LapModel(
        time: state.currentTime ?? state.time,
        totalTime: state.time,
        order: state.laps.length + 1,
      );

      state = state.copyWith(laps: [...state.laps, item], currentTime: Duration.zero);
    } catch (e, stack) {
      logger.e('[HomeLogic] addLap', error: e, stackTrace: stack);
    }
  }
}
