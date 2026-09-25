import 'package:flutter/services.dart';

class StopwatchNativeState {
  final bool isRunning;
  final int? startedAtEpochMs;
  final int accumulatedMs;

  const StopwatchNativeState({required this.isRunning, required this.startedAtEpochMs, required this.accumulatedMs});

  factory StopwatchNativeState.fromMap(Map<dynamic, dynamic> map) {
    return StopwatchNativeState(
      isRunning: map['isRunning'] as bool? ?? false,
      startedAtEpochMs: (map['startedAtEpochMs'] as num?)?.toInt(),
      accumulatedMs: (map['accumulatedMs'] as num?)?.toInt() ?? 0,
    );
  }

  Duration get elapsed {
    if (isRunning && startedAtEpochMs != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return Duration(milliseconds: accumulatedMs + (now - startedAtEpochMs!));
    }
    return Duration(milliseconds: accumulatedMs);
  }
}

class StopwatchNativeBridge {
  StopwatchNativeBridge._();
  static final StopwatchNativeBridge instance = StopwatchNativeBridge._();

  static const _methodChannel = MethodChannel('stopwatch/native');

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
