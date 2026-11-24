/// Returns the effective elapsed time of a timer in milliseconds.
///
/// For a stopped timer ([timerStartedAt] is null) this is the accumulated
/// [baseMs]. For a running timer it is [baseMs] plus the time elapsed since
/// [timerStartedAt], evaluated at [now].
int effectiveTimerMs({
  required int baseMs,
  required DateTime? timerStartedAt,
  required DateTime now,
}) {
  if (timerStartedAt == null) return baseMs;
  return baseMs + now.difference(timerStartedAt).inMilliseconds;
}

/// Folds the elapsed time since [timerStartedAt] into the accumulated [baseMs].
///
/// The elapsed slice is clamped at zero: if the system clock moved backward
/// while the timer was running, the raw difference would be negative and
/// corrupt the stored total (and win shortest-time matches).
int foldElapsedMs({
  required int baseMs,
  required DateTime? timerStartedAt,
  required DateTime now,
}) {
  if (timerStartedAt == null) return baseMs;
  final elapsed = now.difference(timerStartedAt).inMilliseconds;
  return baseMs + (elapsed < 0 ? 0 : elapsed);
}

/// Formats a duration in milliseconds always as "hh:mm:ss:ms",
/// e.g. "01:02:03:456". Unlike [formatTimer] the shape never changes so the
/// text keeps a stable width while the timer runs.
String formatTimerFull(int milliseconds) {
  final ms = milliseconds < 0 ? 0 : milliseconds;
  final hours = ms ~/ 3600000;
  final minutes = (ms % 3600000) ~/ 60000;
  final seconds = (ms % 60000) ~/ 1000;
  final millis = ms % 1000;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(hours)}:${two(minutes)}:${two(seconds)}:${millis.toString().padLeft(3, '0')}';
}

/// Formats a duration in milliseconds the way the app timer shows it.
/// - under one minute: "45s"
/// - under one hour: "1:05"
/// - one hour or more: "1:02:03"
String formatTimer(int milliseconds) {
  final totalSeconds = (milliseconds < 0 ? 0 : milliseconds) ~/ 1000;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  if (minutes > 0) {
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  return '${seconds}s';
}
