import 'package:stopwatch/model/stopwatch_native_state.dart';

extension StopwatchNativeStateLog on StopwatchNativeState {
  String get logText {
    final started = startedAtEpochMs;

    return 'isRunning: $isRunning, accumulated: ${_fmtDuration(accumulatedMs)}, startedAt: ${started == null ? '-' : _fmtClock(started)}, elapsed: ${_fmtDuration(elapsed.inMilliseconds)}';
  }

  /// 75123 ms -> 01:15.123
  String _fmtDuration(int ms) {
    final d = Duration(milliseconds: ms);

    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds % 1000).toString().padLeft(3, '0');

    return '$minutes:$seconds.$millis';
  }

  /// epoch ms -> helyi idő, 14:03:27.512
  String _fmtClock(int epochMs) {
    final t = DateTime.fromMillisecondsSinceEpoch(epochMs);

    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    final ms = t.millisecond.toString().padLeft(3, '0');

    return '$h:$m:$s.$ms';
  }
}
