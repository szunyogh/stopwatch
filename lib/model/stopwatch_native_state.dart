enum NativeKind {
  stopwatch,
  timer;

  static NativeKind fromName(Object? name) => NativeKind.values.firstWhere((k) => k.name == name, orElse: () => NativeKind.stopwatch);
}

class StopwatchNativeState {
  final NativeKind kind;
  final bool isRunning;
  final int? startedAtEpochMs;

  final int accumulatedMs;

  final int? totalMs;

  const StopwatchNativeState({required this.kind, required this.isRunning, required this.startedAtEpochMs, required this.accumulatedMs, this.totalMs});

  factory StopwatchNativeState.fromMap(Map<dynamic, dynamic> map) {
    return StopwatchNativeState(
      kind: NativeKind.fromName(map['kind']),
      isRunning: map['isRunning'] as bool? ?? false,
      startedAtEpochMs: (map['startedAtEpochMs'] as num?)?.toInt(),
      accumulatedMs: (map['accumulatedMs'] as num?)?.toInt() ?? 0,
      totalMs: (map['totalMs'] as num?)?.toInt(),
    );
  }

  Duration get value {
    final running = isRunning && startedAtEpochMs != null;
    final sinceStart = running ? DateTime.now().millisecondsSinceEpoch - startedAtEpochMs! : 0;

    if (kind == NativeKind.timer) {
      final left = accumulatedMs - sinceStart;
      return Duration(milliseconds: left < 0 ? 0 : left);
    }
    return Duration(milliseconds: accumulatedMs + sinceStart);
  }

  Duration get elapsed => value;

  Duration get total => Duration(milliseconds: totalMs ?? 0);

  int? get endAtEpochMs => kind == NativeKind.timer && isRunning && startedAtEpochMs != null ? startedAtEpochMs! + accumulatedMs : null;

  bool get isFinished => kind == NativeKind.timer && isRunning && value == Duration.zero;
}
