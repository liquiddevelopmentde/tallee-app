import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

extension AppColorExtension on AppColor {
  /// Translates a [AppColor] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case AppColor.red:
        return loc.color_red;
      case AppColor.blue:
        return loc.color_blue;
      case AppColor.green:
        return loc.color_green;
      case AppColor.yellow:
        return loc.color_yellow;
      case AppColor.purple:
        return loc.color_purple;
      case AppColor.orange:
        return loc.color_orange;
      case AppColor.pink:
        return loc.color_pink;
      case AppColor.teal:
        return loc.color_teal;
    }
  }
}
