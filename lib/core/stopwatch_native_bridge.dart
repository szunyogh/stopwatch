import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/model/stopwatch_native_state.dart';

class StopwatchNativeBridge {
  StopwatchNativeBridge._();

  static final StopwatchNativeBridge instance = StopwatchNativeBridge._();

  static const _methodChannel = MethodChannel('stopwatch/native');
  static const _eventChannel = EventChannel('stopwatch/native_events');

  late final Stream<StopwatchNativeState> _updates = _eventChannel.receiveBroadcastStream().map((event) => StopwatchNativeState.fromMap(event as Map));
  Stream<StopwatchNativeState> stateUpdates(NativeKind kind) => _updates.where((state) => state.kind == kind);

  Future<NativeKind?> consumePendingTab() async {
    if (!Platform.isAndroid) return null;

    final raw = await _methodChannel.invokeMethod<String>('consumePendingTab');
    return raw == null ? null : NativeKind.fromName(raw);
  }

  Future<bool> canUseFullScreenIntent() async {
    if (!Platform.isAndroid) return true;

    return await _methodChannel.invokeMethod<bool>('canUseFullScreenIntent') ?? true;
  }

  Future<void> openFullScreenIntentSettings() async {
    if (!Platform.isAndroid) return;

    await _methodChannel.invokeMethod('openFullScreenIntentSettings');
  }

  Future<void> notifyTimerFinished() => _methodChannel.invokeMethod('notifyTimerFinished', {'kind': NativeKind.timer.name});

  Future<bool> hasNotificationPermission() async {
    final result = await _methodChannel.invokeMethod<bool>('hasNotificationPermission');
    return result ?? false;
  }

  Future<bool> requestNotificationPermission() async {
    final result = await _methodChannel.invokeMethod<bool>('requestNotificationPermission');
    return result ?? false;
  }

  Future<StopwatchNativeState> getState(NativeKind kind) async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getState', {'kind': kind.name});
    return StopwatchNativeState.fromMap({'kind': kind.name, ...?result});
  }

  Future<bool> isFirstUse(NativeKind kind) async {
    final result = await _methodChannel.invokeMethod<bool>('isFirstUse', {'kind': kind.name});
    return result ?? false;
  }

  Future<void> notifyStart({required NativeKind kind, required int startedAtEpochMs, required int accumulatedMs}) {
    return _methodChannel.invokeMethod('notifyStart', {'kind': kind.name, 'startedAtEpochMs': startedAtEpochMs, 'accumulatedMs': accumulatedMs});
  }

  Future<void> notifyStop({required NativeKind kind, required int accumulatedMs}) {
    return _methodChannel.invokeMethod('notifyStop', {'kind': kind.name, 'accumulatedMs': accumulatedMs});
  }

  Future<void> notifyReset({required NativeKind kind, int accumulatedMs = 0}) {
    return _methodChannel.invokeMethod('notifyReset', {'kind': kind.name, 'accumulatedMs': accumulatedMs});
  }

  Future<void> notifySetTimer({required int totalMs}) {
    return _methodChannel.invokeMethod('notifySetTimer', {'kind': NativeKind.timer.name, 'totalMs': totalMs});
  }

  Future<List<LapModel>> getLaps() async {
    final raw = await _methodChannel.invokeMethod<String>('getLaps');

    if (raw == null || raw.isEmpty) return const [];

    final list = jsonDecode(raw) as List<dynamic>;

    return list.map((item) => LapModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveLaps(List<LapModel> laps) {
    final json = jsonEncode(laps.map((lap) => lap.toJson()).toList());

    return _methodChannel.invokeMethod('saveLaps', {'laps': json});
  }
}
