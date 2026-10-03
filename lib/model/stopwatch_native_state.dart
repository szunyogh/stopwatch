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
