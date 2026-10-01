import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/statistic.dart';

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor(AppColor color) {
  switch (color) {
    case AppColor.red:
      return CustomTheme.red;
    case AppColor.blue:
      return CustomTheme.blue;
    case AppColor.green:
      return CustomTheme.green;
    case AppColor.yellow:
      return CustomTheme.yellow;
    case AppColor.purple:
      return CustomTheme.purple;
    case AppColor.orange:
      return CustomTheme.orange;
    case AppColor.pink:
      return CustomTheme.pink;
    case AppColor.teal:
      return CustomTheme.teal;
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
