import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/statistic.dart';

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor({required AppColor color}) {
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
  return getColorFromAppColor(color: getRandomAppColor());
}

// Returns a AppColor enum value based on the provided team [index].
AppColor getTeamColor({required int index}) {
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
Color getStatisticColor({required Statistic statistic}) {
  final seed = statistic.id.hashCode;
  final appColors = AppColor.values
      .map((clr) => getColorFromAppColor(color: clr))
      .toList();
  return appColors[seed.abs() % appColors.length];
}
