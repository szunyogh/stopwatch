import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/core/stopwatch_native_state.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/model/lap.dart';

final homeLogic = NotifierProvider.autoDispose<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  Ticker? _ticker;
  Stopwatch? _stopwatch;

  Duration? _lapStartElapsed;
  StreamSubscription<StopwatchNativeState>? _nativeSub;

  final _bridge = StopwatchNativeBridge.instance;

  @override
  HomeState build() {
    initLogger();

    _syncFromNative();

    _nativeSub = _bridge.onNativeStateChanged.listen(_applyNativeState);

    ref.onDispose(() {
      clear();
      _nativeSub?.cancel();
      _stopwatch = null;
      logger.i('[HomeLogic] disposed');
    });

    return const HomeState();
  }

  Future<void> syncFromNative() => _syncFromNative();

  Future<void> _syncFromNative() async {
    try {
      final native = await _bridge.getState();
      _applyNativeState(native);
    } catch (error, stack) {
      logger.e('[HomeLogic] syncFromNative error', error: error, stackTrace: stack);
    }
  }

  void _applyNativeState(StopwatchNativeState native) {
    if (native.isRunning) {
      _adoptRunningState(startedAtEpochMs: native.startedAtEpochMs!, accumulatedMs: native.accumulatedMs);
    } else {
      _adoptStoppedState(accumulatedMs: native.accumulatedMs);
    }
  }

  void _adoptRunningState({required int startedAtEpochMs, required int accumulatedMs}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedNow = Duration(milliseconds: accumulatedMs + (now - startedAtEpochMs));

    clear();

    _stopwatch = Stopwatch()..start();
    final localStartOffset = elapsedNow;

    _ticker = Ticker((_) {
      final elapsed = localStartOffset + _stopwatch!.elapsed;
      state = state.copyWith(time: elapsed, currentTime: null);
    })..start();

    state = state.copyWith(time: elapsedNow, isRunning: true);
  }

  void _adoptStoppedState({required int accumulatedMs}) {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _stopwatch?.stop();

    state = state.copyWith(time: Duration(milliseconds: accumulatedMs), isRunning: false);
  }

  void clear() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;

    _stopwatch?.stop();
    _stopwatch?.reset();

    _lapStartElapsed = null;
  }

  void onTap(LapModel lap, Object tag) {
    try {
      logger.i('[HomeLogic] onTap');

      appRouter.push(LapDetailsRoute(lap: lap, tag: tag));
    } catch (error, stack) {
      logger.e('[HomeLogic] onTap error', error: error, stackTrace: stack);
    }
  }

  void start() {
    try {
      logger.i('[HomeLogic] start');

      if (state.isRunning) return;

      final accumulatedMs = state.time.inMilliseconds;
      final startedAtEpochMs = DateTime.now().millisecondsSinceEpoch;

      _stopwatch ??= Stopwatch();
      _stopwatch?.start();

      _ticker ??= Ticker((_) {
        final elapsed = Duration(milliseconds: accumulatedMs) + _stopwatch!.elapsed;

        final lapStart = _lapStartElapsed;
        final lapElapsed = (lapStart == null) ? null : (elapsed - lapStart);

        state = state.copyWith(time: elapsed, currentTime: lapElapsed);
      });

      _ticker?.start();

      state = state.copyWith(isRunning: true);

      _bridge.notifyStart(startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs);
    } catch (error, stack) {
      logger.e('[HomeLogic] start', error: error, stackTrace: stack);
    }
  }

  void stop() {
    try {
      logger.i('[HomeLogic] stop');

      _stopwatch?.stop();
      _ticker?.stop();

      state = state.copyWith(isRunning: false);

      _bridge.notifyStop(accumulatedMs: state.time.inMilliseconds);
    } catch (error, stack) {
      logger.e('[HomeLogic] stop', error: error, stackTrace: stack);
    }
  }

  void reset() {
    try {
      logger.i('[HomeLogic] reset');

      clear();

      state = state.copyWith(time: Duration.zero, currentTime: null, laps: const [], isRunning: false);

      _bridge.notifyReset();
    } catch (error, stack) {
      logger.e('[HomeLogic] reset', error: error, stackTrace: stack);
    }
  }

  void addLap() {
    try {
      logger.i('[HomeLogic] addLap');

      if (!state.isRunning) return;

      final elapsed = state.time;
      final lapStart = _lapStartElapsed ?? Duration.zero;
      final lapElapsed = elapsed - lapStart;

      final item = LapModel(time: lapElapsed, totalTime: elapsed, order: state.laps.length + 1);

      _lapStartElapsed = elapsed;

      state = state.copyWith(laps: [...state.laps, item], currentTime: Duration.zero);
    } catch (error, stack) {
      logger.e('[HomeLogic] addLap', error: error, stackTrace: stack);
    }
  }

  void lapResetPressed() {
    if (state.time > Duration.zero && !state.isRunning) return reset();

    if (state.isRunning) return addLap();
  }

  void startStopPressed() => state.isRunning ? stop() : start();
}
