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
