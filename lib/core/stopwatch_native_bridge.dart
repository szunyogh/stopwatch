import 'package:flutter/services.dart';
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

  Future<void> notifyReset() {
    return _methodChannel.invokeMethod('notifyReset');
  }
}
