import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tallee/data/models/statistic.dart';

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor(AppColor color) {
  switch (color) {
    case AppColor.red:
      return Colors.red;
    case AppColor.blue:
      return Colors.blue;
    case AppColor.green:
      return Colors.green;
    case AppColor.yellow:
      return const Color(0xFFF7CA28);
    case AppColor.purple:
      return Colors.purple;
    case AppColor.orange:
      return const Color(0xFFef681f);
    case AppColor.pink:
      return const Color(0xFFE91E63);
    case AppColor.teal:
      return const Color(0xFF00BCD4);
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
