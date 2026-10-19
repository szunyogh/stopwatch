import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/stopwatch_native_bridge.dart';
import 'package:stopwatch/core/stopwatch_native_state_log.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/timer/timer_state.dart';
import 'package:stopwatch/model/stopwatch_native_state.dart';

final timerLogic = NotifierProvider.autoDispose<TimerLogic, TimerState>(TimerLogic.new);

class TimerLogic extends BaseLogic<TimerState> {
  static const _kind = NativeKind.timer;
  static const _zeroNative = StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: 0, totalMs: 0);

  late final Ticker _ticker;
  StreamSubscription<StopwatchNativeState>? _nativeEventsSub;
  Timer? _pickDebounce;

  final _bridge = StopwatchNativeBridge.instance;

  StopwatchNativeState _anchor = _zeroNative;
  int _anchorVersion = 0;
  bool _disposed = false;

  Duration get startTime => _anchor.total;

  @override
  TimerState build() {
    _ticker = Ticker(_onTick);

    ref.onDispose(() {
      _disposed = true;
      _flushPick();
      _nativeEventsSub?.cancel();
      _ticker.stop();
      _ticker.dispose();
      logger.i('[TimerLogic] disposed');
    });

    _init();

    return const TimerState();
  }

  Future<void> _init() async {
    try {
      logger.i('[TimerLogic] _init');

      _initEventChannel();
      await _syncFromNative();
    } catch (error, stack) {
      logger.e('[TimerLogic] _init error', error: error, stackTrace: stack);
    }
  }

  void _initEventChannel() {
    try {
      _nativeEventsSub ??= _bridge
          .stateUpdates(_kind)
          .listen(
            (native) {
              if (_disposed) return;

              logger.i('[TimerLogic] native event: ${native.logText}');

              _setAnchor(native);
            },
            onError: (Object error, StackTrace stack) {
              logger.e('[TimerLogic] event stream error', error: error, stackTrace: stack);
            },
          );
    } catch (error, stack) {
      logger.e('[TimerLogic] _initEventChannel error', error: error, stackTrace: stack);
    }
  }

  Future<void> _syncFromNative() async {
    try {
      final versionBefore = _anchorVersion;
      final native = await _bridge.getState(_kind);

      if (_disposed) return;

      if (versionBefore != _anchorVersion) return;

      logger.i('[TimerLogic] _syncFromNative native: ${native.logText}');

      _setAnchor(native);
    } catch (error, stack) {
      logger.e('[TimerLogic] syncFromNative error', error: error, stackTrace: stack);
    }
  }

  void _setAnchor(StopwatchNativeState anchor) {
    if (anchor.isFinished) {
      logger.i('[TimerLogic] _setAnchor - ${_anchor.isFinished}');
      return _finish(anchor);
    }

    _anchor = anchor;
    _anchorVersion++;

    changeState((state) => state.copyWith(time: anchor.value, isRunning: anchor.isRunning));

    if (anchor.isRunning) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  void _finish(StopwatchNativeState from) {
    logger.i('[TimerLogic] finished');

    _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: from.totalMs ?? 0, totalMs: from.totalMs));
    _bridge.notifyTimerFinished();
  }

  void _onTick(Duration _) {
    if (_disposed) return;

    if (_anchor.isFinished) {
      logger.i('[TimerLogic] _onTick - ${_anchor.isFinished}');
      return _finish(_anchor);
    }

    changeState((state) => state.copyWith(time: _anchor.elapsed));
  }

  void setTime(Duration time) {
    try {
      if (_anchor.isRunning) return;

      logger.i('[TimerLogic] setTime $time');

      final ms = time.inMilliseconds;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: ms, totalMs: ms));

      _pickDebounce?.cancel();
      _pickDebounce = Timer(const Duration(milliseconds: 300), _flushPick);
    } catch (error, stack) {
      logger.e('[TimerLogic] setTime error', error: error, stackTrace: stack);
    }
  }

  void addTime() {
    try {
      if (_anchor.isRunning) return;

      logger.i('[TimerLogic] addTime');

      final ms = (_anchor.totalMs ?? 0) + 10000;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: ms, totalMs: ms));

      _bridge.notifySetTimer(totalMs: ms);
    } catch (error, stack) {
      logger.e('[TimerLogic] addTime error', error: error, stackTrace: stack);
    }
  }

  void removeTime() {
    try {
      if (_anchor.isRunning) return;

      logger.i('[TimerLogic] removeTime');

      final totalMs = _anchor.totalMs ?? 0;

      final ms = totalMs <= 10000 ? 0 : totalMs - 10000;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: ms, totalMs: ms));

      _bridge.notifySetTimer(totalMs: ms);
    } catch (error, stack) {
      logger.e('[TimerLogic] removeTime error', error: error, stackTrace: stack);
    }
  }

  void _flushPick() {
    if (_pickDebounce == null) return;

    _pickDebounce?.cancel();
    _pickDebounce = null;

    _bridge.notifySetTimer(totalMs: _anchor.totalMs ?? 0);
  }

  void start() {
    try {
      logger.i('[TimerLogic] start');

      if (_anchor.isRunning) return;

      var remainingMs = _anchor.elapsed.inMilliseconds;
      if (remainingMs <= 0) remainingMs = _anchor.total.inMilliseconds;
      if (remainingMs <= 0) return;

      _flushPick();

      final startedAtEpochMs = DateTime.now().millisecondsSinceEpoch;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: true, startedAtEpochMs: startedAtEpochMs, accumulatedMs: remainingMs, totalMs: _anchor.totalMs));

      _bridge.notifyStart(kind: _kind, startedAtEpochMs: startedAtEpochMs, accumulatedMs: remainingMs);
    } catch (error, stack) {
      logger.e('[TimerLogic] start', error: error, stackTrace: stack);
    }
  }

  void stop() {
    try {
      logger.i('[TimerLogic] stop');

      if (!_anchor.isRunning) return;

      final remainingMs = _anchor.elapsed.inMilliseconds;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: remainingMs, totalMs: _anchor.totalMs));

      _bridge.notifyStop(kind: _kind, accumulatedMs: remainingMs);
    } catch (error, stack) {
      logger.e('[TimerLogic] stop', error: error, stackTrace: stack);
    }
  }

  void reset() {
    try {
      logger.i('[TimerLogic] reset');

      if (_anchor.isRunning) return;

      final totalMs = _anchor.total.inMilliseconds;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: totalMs, totalMs: totalMs));

      _bridge.notifyReset(kind: _kind, accumulatedMs: totalMs);
    } catch (error, stack) {
      logger.e('[TimerLogic] reset', error: error, stackTrace: stack);
    }
  }

  void startStopPressed() => state.isRunning ? stop() : start();
}
