class DurationElapsedFormatter {
  DurationElapsedFormatter._();

  static String toElapsedTime(Duration? duration) {
    if (duration == null) return '';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;

    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    final mmm = milliseconds.toString().padLeft(3, '0');

    return '$hh:$mm:$ss.$mmm';
  }
}
