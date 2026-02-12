import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/model/lap.dart';

final homeLogic = NotifierProvider.autoDispose<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  Timer? _timer;
  Stopwatch? _stopwatch;

  Duration? _lapStartElapsed;

  @override
  HomeState build() {
    initLogger();

    ref.onDispose(() {
      clear();
      _stopwatch = null;
      logger.i('[HomeLogic] disposed');
    });

    return const HomeState();
  }

  void clear() {
    _timer?.cancel();
    _timer = null;

    _stopwatch?.stop();
    _stopwatch?.reset();

    _lapStartElapsed = null;
  }

  void start() {
    try {
      logger.i('[HomeLogic] start');

      if (state.isRunning) return;

      _stopwatch ??= Stopwatch();

      _stopwatch!.start();

      _timer ??= Timer.periodic(const Duration(milliseconds: 32), (_) {
        final elapsed = _stopwatch!.elapsed;

        final lapStart = _lapStartElapsed;
        final lapElapsed = (lapStart == null) ? null : (elapsed - lapStart);

        state = state.copyWith(time: elapsed, currentTime: lapElapsed, isRunning: true);
      });

      state = state.copyWith(isRunning: true);
    } catch (e, stack) {
      logger.e('[HomeLogic] start', error: e, stackTrace: stack);
    }
  }

  void stop() {
    try {
      logger.i('[HomeLogic] stop');

      _stopwatch?.stop();
      _timer?.cancel();
      _timer = null;

      state = state.copyWith(isRunning: false);
    } catch (e, stack) {
      logger.e('[HomeLogic] stop', error: e, stackTrace: stack);
    }
  }

  void reset() {
    try {
      logger.i('[HomeLogic] reset');

      clear();

      state = state.copyWith(time: Duration.zero, currentTime: null, laps: const [], isRunning: false);
    } catch (e, stack) {
      logger.e('[HomeLogic] reset', error: e, stackTrace: stack);
    }
  }

  void addLap() {
    try {
      logger.i('[HomeLogic] addLap');

      if (!state.isRunning) return;

      final sw = _stopwatch;
      if (sw == null) return;

      final elapsed = sw.elapsed;
      final lapStart = _lapStartElapsed ?? Duration.zero;
      final lapElapsed = elapsed - lapStart;

      final item = LapModel(time: lapElapsed, totalTime: elapsed, order: state.laps.length + 1);

      _lapStartElapsed = elapsed;

      state = state.copyWith(laps: [...state.laps, item], currentTime: Duration.zero);
    } catch (e, stack) {
      logger.e('[HomeLogic] addLap', error: e, stackTrace: stack);
    }
  }
}
