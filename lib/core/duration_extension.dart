extension DurationElapsedFormatter on Duration {
  String toElapsedTime() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    final milliseconds = inMilliseconds % 1000;

    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    final mmm = milliseconds.toString().padLeft(3, '0');

    return '$mm:$ss.$mmm';
  }
}
