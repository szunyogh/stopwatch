import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/timer/timer_state.dart';

final timerLogic = NotifierProvider.autoDispose<TimerLogic, TimerState>(TimerLogic.new);

class TimerLogic extends BaseLogic<TimerState> {
  late final Ticker _ticker;
  late final Stopwatch _stopwatch;

  Duration _startTime = Duration.zero;

  Duration get startTime => _startTime;

  @override
  TimerState build() {
    _ticker = Ticker(_onTick);
    _stopwatch = Stopwatch();

    ref.onDispose(() {
      _ticker.stop();
      _ticker.dispose();
      _stopwatch.stop();
      logger.i('[TimerLogic] disposed');
    });

    _init();

    return const TimerState();
  }

  Future<void> _init() async {
    try {
      logger.i('[TimerLogic] _init');
    } catch (error, stack) {
      logger.e('[TimerLogic] _init error', error: error, stackTrace: stack);
    }
  }

  void setTime(Duration time) => _startTime = time;

  void _onTick(Duration _) {
    final time = _startTime - _stopwatch.elapsed;

    if (time.inSeconds <= 0) return stop();

    changeState((state) => state.copyWith(time: _startTime - _stopwatch.elapsed));
  }

  void start() {
    try {
      logger.i('[TimerLogic] start');
      if (state.isRunning) return;

      changeState((state) => state.copyWith(time: _startTime, isRunning: true));
      _stopwatch.start();
      _ticker.start();
    } catch (error, stack) {
      logger.e('[TimerLogic] start', error: error, stackTrace: stack);
    }
  }

  void stop() {
    try {
      logger.i('[TimerLogic] stop');
      if (!state.isRunning) return;

      _stopwatch.stop();
      _ticker.stop();
      changeState((state) => state.copyWith(isRunning: false));
    } catch (error, stack) {
      logger.e('[TimerLogic] stop', error: error, stackTrace: stack);
    }
  }

  void reset() {
    try {
      logger.i('[TimerLogic] reset');
      if (state.isRunning) return;

      _stopwatch.reset();
      changeState((state) => state.copyWith(time: _startTime, isRunning: false));
    } catch (error, stack) {
      logger.e('[TimerLogic] reset', error: error, stackTrace: stack);
    }
  }

  void startStopPressed() => state.isRunning ? stop() : start();
}
