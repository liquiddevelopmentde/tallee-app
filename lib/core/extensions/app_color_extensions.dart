import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/extensions/build_context_extensions.dart';
import 'package:tallee/core/theme/app_colors.dart';
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

  /// Returns the [Color] object corresponding to a [AppColor] enum value.
  Color colorValue(BuildContext context) {
    switch (this) {
      case AppColor.red:
        return context.talleeColors.redColor;
      case AppColor.blue:
        return context.talleeColors.blueColor;
      case AppColor.green:
        return context.talleeColors.greenColor;
      case AppColor.yellow:
        return context.talleeColors.yellowColor;
      case AppColor.purple:
        return context.talleeColors.purpleColor;
      case AppColor.orange:
        return context.talleeColors.orangeColor;
      case AppColor.pink:
        return context.talleeColors.pinkColor;
      case AppColor.teal:
        return context.talleeColors.tealColor;
    }
  }

  /// Returns the text color used on statistics bars for the current theme.
  Color statisticBarColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final useBlackText =
        !isDarkMode || this == AppColor.yellow || this == AppColor.orange;
    return useBlackText ? AppColors.textColorLight : AppColors.textColorDark;
  }
}

extension ColorExtension on Color {
  /// Returns the text color with the higher contrast to the given color.
  ///
  /// The threshold 0.179 is the relative luminance at which black and white
  /// text have the same WCAG contrast ratio.
  Color get contrastTextColor => computeLuminance() > 0.179
      ? AppColors.textColorLight
      : AppColors.textColorDark;
}
