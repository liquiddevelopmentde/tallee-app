import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toLocalizedFormat(BuildContext context) {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(this);
  }

  // Returns a [DateTime] String formatted as localized yMMMd (July 10, 1996)
  String toMediumDate(BuildContext context) =>
      DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(this);

  // Returns a [DateTime] String formatted as localized yMd (7/10/1996)
  String toShortDate(BuildContext context) =>
      DateFormat.yMd(Localizations.localeOf(context).toString()).format(this);

  // Returns a [DateTime] String formatted to just the time (14:26)
  String toTime(BuildContext context) => DateFormat('HH:mm').format(this);
}
