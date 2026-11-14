import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  // Returns a [DateTime] String formatted as localized yMMMd (July 10, 1996)
  String toMediumDate(BuildContext context) =>
      DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(this);

  // Returns a [DateTime] String formatted as localized yMd with zero-padded
  // day and month (de: 05.03.2026, en_US: 03/05/2026)
  String toShortDate(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = DateFormat.yMd(locale).pattern!
        .replaceAll(RegExp('d+'), 'dd')
        .replaceAll(RegExp('[ML]+'), 'MM');
    return DateFormat(pattern, locale).format(this);
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Number of calendar days between this date and today
  int get daysAgo {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);
    return today.difference(date).inDays;
  }

  // Returns a [DateTime] String formatted to just the time (14:26)
  String toTime(BuildContext context) => DateFormat('HH:mm').format(this);
}
