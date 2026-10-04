import 'dart:async';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/core/stopwatch_native_bridge.dart';
import 'package:stopwatch/core/stopwatch_native_state_log.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/model/stopwatch_native_state.dart';

final homeLogic = NotifierProvider.autoDispose<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  static const _zeroNative = StopwatchNativeState(isRunning: false, startedAtEpochMs: null, accumulatedMs: 0);

  late final Ticker _ticker;
  StreamSubscription<StopwatchNativeState>? _nativeEventsSub;

  final _bridge = StopwatchNativeBridge.instance;

  StopwatchNativeState _anchor = _zeroNative;

  int _anchorVersion = 0;
  Duration? _lapStartElapsed;

  bool _disposed = false;

  @override
  HomeState build() {
    initLogger();

    _ticker = Ticker(_onTick);

    ref.onDispose(() {
      _disposed = true;
      _nativeEventsSub?.cancel();
      _ticker.stop();
      _ticker.dispose();
      logger.i('[HomeLogic] disposed');
    });

    _init();

    return const HomeState();
  }

  Future<void> _init() async {
    try {
      logger.i('[HomeLogic] _init');

      await _loadLaps();

      if (_disposed) return;

      _initEventChannel();
      await _syncFromNative();

      if (_disposed || !Platform.isAndroid) return;

      final hasPermission = await _bridge.hasNotificationPermission();

      logger.i('[HomeLogic] _init hasPermission: $hasPermission');

      if (!hasPermission) await _bridge.requestNotificationPermission();
    } catch (error, stack) {
      logger.e('[HomeLogic] _init error', error: error, stackTrace: stack);
    }
  }

  Future<void> _loadLaps() async {
    try {
      final laps = await _bridge.getLaps();

      logger.i('[HomeLogic] _loadLaps laps: ${laps.length}');

      if (_disposed || laps.isEmpty) return;

      _lapStartElapsed = laps.last.totalTime;

      state = state.copyWith(laps: laps);
    } catch (error, stack) {
      logger.e('[HomeLogic] _loadLaps error', error: error, stackTrace: stack);
    }
  }

  void _initEventChannel() {
    try {
      logger.i('[HomeLogic] _initEventChannel');

      _nativeEventsSub ??= _bridge.stateUpdates.listen(
        (native) {
          if (_disposed) return;

          logger.i('[HomeLogic] native event: ${native.logText}');

          _setAnchor(native);
        },
        onError: (Object error, StackTrace stack) {
          logger.e('[HomeLogic] event stream error', error: error, stackTrace: stack);
        },
      );
    } catch (error, stack) {
      logger.e('[HomeLogic] _initEventChannel error', error: error, stackTrace: stack);
    }
  }

  Future<void> _syncFromNative() async {
    try {
      final versionBefore = _anchorVersion;
      final native = await _bridge.getState();

      if (_disposed) return;

      if (versionBefore != _anchorVersion) return;

      logger.i('[HomeLogic] _syncFromNative native: ${native.logText}');

      _setAnchor(native);
    } catch (error, stack) {
      logger.e('[HomeLogic] syncFromNative error', error: error, stackTrace: stack);
    }
  }

  void _setAnchor(StopwatchNativeState anchor) {
    _anchor = anchor;
    _anchorVersion++;

    final elapsed = anchor.elapsed;
    final lapStart = _lapStartElapsed;

    state = state.copyWith(time: elapsed, isRunning: anchor.isRunning, currentTime: lapStart == null ? null : elapsed - lapStart);

    if (anchor.isRunning) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  void _onTick(Duration _) {
    if (_disposed) return;

    final elapsed = _anchor.elapsed;
    final lapStart = _lapStartElapsed;

    state = state.copyWith(time: elapsed, currentTime: lapStart == null ? null : elapsed - lapStart);
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

      if (_anchor.isRunning) return;

      final accumulatedMs = _anchor.elapsed.inMilliseconds;
      final startedAtEpochMs = DateTime.now().millisecondsSinceEpoch;

      _setAnchor(StopwatchNativeState(isRunning: true, startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs));

      _bridge.notifyStart(startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs);
    } catch (error, stack) {
      logger.e('[HomeLogic] start', error: error, stackTrace: stack);
    }
  }

  void stop() {
    try {
      logger.i('[HomeLogic] stop');

      if (!_anchor.isRunning) return;

      final accumulatedMs = _anchor.elapsed.inMilliseconds;

      _setAnchor(StopwatchNativeState(isRunning: false, startedAtEpochMs: null, accumulatedMs: accumulatedMs));

      _bridge.notifyStop(accumulatedMs: accumulatedMs);
    } catch (error, stack) {
      logger.e('[HomeLogic] stop', error: error, stackTrace: stack);
    }
  }

  void reset() {
    try {
      logger.i('[HomeLogic] reset');

      _lapStartElapsed = null;

      state = state.copyWith(laps: const [], currentTime: null);

      _setAnchor(_zeroNative);

      _bridge.notifyReset();
    } catch (error, stack) {
      logger.e('[HomeLogic] reset', error: error, stackTrace: stack);
    }
  }

  void addLap() {
    try {
      logger.i('[HomeLogic] addLap');

      if (!_anchor.isRunning) return;

      final elapsed = _anchor.elapsed;
      final lapStart = _lapStartElapsed ?? Duration.zero;
      final lapElapsed = elapsed - lapStart;

      final item = LapModel(time: lapElapsed, totalTime: elapsed, order: state.laps.length + 1);

      _lapStartElapsed = elapsed;

      state = state.copyWith(laps: [...state.laps, item], time: elapsed, currentTime: Duration.zero);

      _bridge.saveLaps(state.laps);
    } catch (error, stack) {
      logger.e('[HomeLogic] addLap', error: error, stackTrace: stack);
    }
  }

  void lapResetPressed() {
    if (!state.isRunning && state.time > Duration.zero) return reset();

    if (state.isRunning) return addLap();
  }

  void startStopPressed() => state.isRunning ? stop() : start();
}
