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

  // Returns a [DateTime] String formatted to just the time (14:26)
  String toTime(BuildContext context) => DateFormat('HH:mm').format(this);
}
