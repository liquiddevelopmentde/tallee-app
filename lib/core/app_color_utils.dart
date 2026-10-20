import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/data/models/statistic.dart';

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

/// Returns a random color from the app colors.
Color getRandomAppColorValue() {
  return getColorFromAppColor(getRandomAppColor());
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

/// Returns a color from the palette based on the statistic's ID as random seed.
Color getStatisticColor(Statistic stat) {
  final seed = stat.id.hashCode;
  final appColors = AppColor.values
      .map((c) => getColorFromAppColor(c))
      .toList();
  return appColors[seed.abs() % appColors.length];
}
