import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor(
  AppColor color, {
  Brightness brightness = Brightness.dark,
}) {
  final isLightMode = brightness == Brightness.light;
  switch (color) {
    case AppColor.red:
      return isLightMode ? AppColors.redColorLight : AppColors.redColorDark;
    case AppColor.blue:
      return isLightMode ? AppColors.blueColorLight : AppColors.blueColorDark;
    case AppColor.green:
      return isLightMode ? AppColors.greenColorLight : AppColors.greenColorDark;
    case AppColor.yellow:
      return isLightMode
          ? AppColors.yellowColorLight
          : AppColors.yellowColorDark;
    case AppColor.purple:
      return isLightMode
          ? AppColors.purpleColorLight
          : AppColors.purpleColorDark;
    case AppColor.orange:
      return isLightMode
          ? AppColors.orangeColorLight
          : AppColors.orangeColorDark;
    case AppColor.pink:
      return isLightMode ? AppColors.pinkColorLight : AppColors.pinkColorDark;
    case AppColor.teal:
      return isLightMode ? AppColors.tealColorLight : AppColors.tealColorDark;
  }
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
