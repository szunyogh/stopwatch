import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/model/stopwatch_native_state.dart';

class StopwatchNativeBridge {
  StopwatchNativeBridge._();
  static final StopwatchNativeBridge instance = StopwatchNativeBridge._();

  static const _methodChannel = MethodChannel('stopwatch/native');
  static const _eventChannel = EventChannel('stopwatch/native_events');

  Stream<StopwatchNativeState> get stateUpdates => _eventChannel.receiveBroadcastStream().map((event) => StopwatchNativeState.fromMap(event as Map));

  Future<bool> hasNotificationPermission() async {
    final result = await _methodChannel.invokeMethod<bool>('hasNotificationPermission');
    return result ?? false;
  }

  Future<bool> requestNotificationPermission() async {
    final result = await _methodChannel.invokeMethod<bool>('requestNotificationPermission');
    return result ?? false;
  }

  Future<StopwatchNativeState> getState() async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getState');
    return StopwatchNativeState.fromMap(result ?? const {});
  }

  Future<void> notifyStart({required int startedAtEpochMs, required int accumulatedMs}) {
    return _methodChannel.invokeMethod('notifyStart', {'startedAtEpochMs': startedAtEpochMs, 'accumulatedMs': accumulatedMs});
  }

  Future<void> notifyStop({required int accumulatedMs}) {
    return _methodChannel.invokeMethod('notifyStop', {'accumulatedMs': accumulatedMs});
  }

  Future<void> notifyReset() => _methodChannel.invokeMethod('notifyReset');

  Future<List<LapModel>> getLaps() async {
    final raw = await _methodChannel.invokeMethod<String>('getLaps');

    if (raw == null || raw.isEmpty) return const [];

    final list = jsonDecode(raw) as List<dynamic>;

    final laps = list.map((item) => LapModel.fromJson(item as Map<String, dynamic>)).toList();

    return laps;
  }

  Future<void> saveLaps(List<LapModel> laps) {
    final json = jsonEncode(laps.map((lap) => lap.toJson()).toList());

    return _methodChannel.invokeMethod('saveLaps', {'laps': json});
  }
}
