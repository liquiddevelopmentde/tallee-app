import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor(AppColor color, BuildContext context) {
  switch (color) {
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
Color getStatisticsBarTextColor(AppColor color, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final useBlackText = !isDarkMode || color == AppColor.yellow;
  return useBlackText ? AppColors.textColorLight : AppColors.textColorDark;
}

/// Returns a random color from the app colors.
AppColor getRandomAppColor() {
  const appColors = AppColor.values;
  return appColors[Random().nextInt(appColors.length)];
}

// Returns a AppColor enum value based on the provided team [index].
AppColor getTeamColor(int index) {
  final colors = [
    AppColor.red,
    AppColor.blue,
    AppColor.green,
    AppColor.yellow,
    AppColor.purple,
    AppColor.orange,
    AppColor.pink,
    AppColor.teal,
  ];
  return colors[index % colors.length];
}

extension ColorContrast on Color {
  /// Returns the text color with the higher contrast to the given color.
  ///
  /// The threshold 0.179 is the relative luminance at which black and white
  /// text have the same WCAG contrast ratio.
  Color get contrastTextColor => computeLuminance() > 0.179
      ? AppColors.textColorLight
      : AppColors.textColorDark;
}
