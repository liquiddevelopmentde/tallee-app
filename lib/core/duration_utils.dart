/// Returns the effective elapsed time of a timer in milliseconds.
///
/// For a stopped timer ([timerStartedAt] is null) this is just the accumulated
/// [baseMs]. For a running timer it is [baseMs] plus the wall-clock time since
/// [timerStartedAt], evaluated at [now].
int effectiveTimerMs({
  required int baseMs,
  required DateTime? timerStartedAt,
  required DateTime now,
}) {
  if (timerStartedAt == null) return baseMs;
  return baseMs + now.difference(timerStartedAt).inMilliseconds;
}

/// Formats a duration given in milliseconds according to the app timer
/// * under one minute -> "45s"
/// * under one hour -> "1:05"
/// * one hour or more -> "1:02:03"
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
