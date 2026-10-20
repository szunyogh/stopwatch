import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/core/stopwatch_native_bridge.dart';
import 'package:stopwatch/core/stopwatch_native_state_log.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/stopwatch/stopwatch_state.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/model/stopwatch_native_state.dart';

final stopwatchLogic = NotifierProvider.autoDispose<StopwatchLogic, StopwatchState>(StopwatchLogic.new);

class StopwatchLogic extends BaseLogic<StopwatchState> {
  late ScrollController _controller;

  static const _kind = NativeKind.stopwatch;
  static const _zeroNative = StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: 0);

  late final Ticker _ticker;
  StreamSubscription<StopwatchNativeState>? _nativeEventsSub;

  final _bridge = StopwatchNativeBridge.instance;

  StopwatchNativeState _anchor = _zeroNative;

  int _anchorVersion = 0;
  Duration? _lapStartElapsed;

  bool _disposed = false;

  ScrollController get controller => _controller;

  @override
  StopwatchState build() {
    _ticker = Ticker(_onTick);
    _controller = ScrollController();

    ref.onDispose(() {
      _controller.dispose();
      _disposed = true;
      _nativeEventsSub?.cancel();
      _ticker.stop();
      _ticker.dispose();
      logger.i('[StopwatchLogic] disposed');
    });

    _init();

    return const StopwatchState();
  }

  Future<void> _init() async {
    try {
      logger.i('[StopwatchLogic] _init');

      await _loadLaps();

      if (_disposed) return;

      _initEventChannel();
      await _syncFromNative();
    } catch (error, stack) {
      logger.e('[StopwatchLogic] _init error', error: error, stackTrace: stack);
    }
  }

  Future<void> _loadLaps() async {
    try {
      final laps = await _bridge.getLaps();

      logger.i('[StopwatchLogic] _loadLaps laps: ${laps.length}');

      if (_disposed || laps.isEmpty) return;

      _lapStartElapsed = laps.last.totalTime;

      changeState((state) => state.copyWith(laps: laps));
    } catch (error, stack) {
      logger.e('[StopwatchLogic] _loadLaps error', error: error, stackTrace: stack);
    }
  }

  void _initEventChannel() {
    try {
      logger.i('[StopwatchLogic] _initEventChannel');

      _nativeEventsSub ??= _bridge
          .stateUpdates(_kind)
          .listen(
            (native) {
              if (_disposed) return;

              logger.i('[StopwatchLogic] native event: ${native.logText}');

              _setAnchor(native);
            },
            onError: (Object error, StackTrace stack) {
              logger.e('[StopwatchLogic] event stream error', error: error, stackTrace: stack);
            },
          );
    } catch (error, stack) {
      logger.e('[StopwatchLogic] _initEventChannel error', error: error, stackTrace: stack);
    }
  }

  Future<void> _syncFromNative() async {
    try {
      final versionBefore = _anchorVersion;
      final native = await _bridge.getState(_kind);

      if (_disposed) return;

      if (versionBefore != _anchorVersion) return;

      logger.i('[StopwatchLogic] _syncFromNative native: ${native.logText}');

      _setAnchor(native);
    } catch (error, stack) {
      logger.e('[StopwatchLogic] syncFromNative error', error: error, stackTrace: stack);
    }
  }

  void _setAnchor(StopwatchNativeState anchor) {
    _anchor = anchor;
    _anchorVersion++;

    final elapsed = anchor.elapsed;
    final lapStart = _lapStartElapsed;

    changeState((state) => state.copyWith(time: elapsed, isRunning: anchor.isRunning, currentTime: lapStart == null ? null : elapsed - lapStart));

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

    changeState((state) => state.copyWith(time: elapsed, currentTime: lapStart == null ? null : elapsed - lapStart));
  }

  void onTap(LapModel lap, Object tag) {
    try {
      logger.i('[StopwatchLogic] onTap');

      appRouter.push(LapDetailsRoute(lap: lap, tag: tag));
    } catch (error, stack) {
      logger.e('[StopwatchLogic] onTap error', error: error, stackTrace: stack);
    }
  }

  void start() {
    try {
      logger.i('[StopwatchLogic] start');

      if (_anchor.isRunning) return;

      final accumulatedMs = _anchor.elapsed.inMilliseconds;
      final startedAtEpochMs = DateTime.now().millisecondsSinceEpoch;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: true, startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs));

      _bridge.notifyStart(kind: _kind, startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs);
    } catch (error, stack) {
      logger.e('[StopwatchLogic] start', error: error, stackTrace: stack);
    }
  }

  void stop() {
    try {
      logger.i('[StopwatchLogic] stop');

      if (!_anchor.isRunning) return;

      final accumulatedMs = _anchor.elapsed.inMilliseconds;

      _setAnchor(StopwatchNativeState(kind: _kind, isRunning: false, startedAtEpochMs: null, accumulatedMs: accumulatedMs));

      _bridge.notifyStop(kind: _kind, accumulatedMs: accumulatedMs);
    } catch (error, stack) {
      logger.e('[StopwatchLogic] stop', error: error, stackTrace: stack);
    }
  }

  void reset() {
    try {
      logger.i('[StopwatchLogic] reset');

      _lapStartElapsed = null;

      changeState((state) => state.copyWith(laps: const [], currentTime: null));

      _setAnchor(_zeroNative);

      _bridge.notifyReset(kind: _kind);

      if (_controller.hasClients) _controller.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } catch (error, stack) {
      logger.e('[StopwatchLogic] reset', error: error, stackTrace: stack);
    }
  }

  void addLap() {
    try {
      logger.i('[StopwatchLogic] addLap');

      if (!_anchor.isRunning) return;

      final elapsed = _anchor.elapsed;
      final lapStart = _lapStartElapsed ?? Duration.zero;
      final lapElapsed = elapsed - lapStart;

      final item = LapModel(time: lapElapsed, totalTime: elapsed, order: state.laps.length + 1);

      _lapStartElapsed = elapsed;

      changeState((state) => state.copyWith(laps: [...state.laps, item], time: elapsed, currentTime: Duration.zero));

      _bridge.saveLaps(state.laps);

      final order = item.order;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomIfCovered(order));
    } catch (error, stack) {
      logger.e('[StopwatchLogic] addLap', error: error, stackTrace: stack);
    }
  }

  void _scrollToBottomIfCovered(Object tag) {
    if (!_controller.hasClients) return;
    final position = _controller.position;

    final itemContext = GlobalObjectKey(tag).currentContext;
    final itemBox = (itemContext != null && itemContext.mounted) ? itemContext.findRenderObject() : null;
    final viewportBox = position.context.notificationContext?.findRenderObject();

    var covered = true;

    if (itemBox is RenderBox && itemBox.attached && viewportBox is RenderBox) {
      final itemBottom = itemBox.localToGlobal(Offset(0, itemBox.size.height)).dy;
      final viewportBottom = viewportBox.localToGlobal(Offset(0, viewportBox.size.height)).dy;
      final barTop = viewportBottom - MediaQuery.paddingOf(itemContext!).bottom;
      covered = itemBottom > barTop;
    }

    if (!covered) return;

    position.animateTo(position.maxScrollExtent, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  void lapResetPressed() {
    if (!state.isRunning && state.time > Duration.zero) return reset();

    if (state.isRunning) return addLap();
  }

  void startStopPressed() => state.isRunning ? stop() : start();
}
