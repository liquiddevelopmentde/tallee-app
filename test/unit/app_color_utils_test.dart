import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';

void main() {
  group('getColorFromAppColor', () {
    test('uses optimized colors in light mode', () {
      expect(
        AppColor.values
            .map(
              (color) =>
                  getColorFromAppColor(color, brightness: Brightness.light),
            )
            .toList(),
        [
          AppColors.redColorLight,
          AppColors.orangeColorLight,
          AppColors.yellowColorLight,
          AppColors.greenColorLight,
          AppColors.tealColorLight,
          AppColors.blueColorLight,
          AppColors.purpleColorLight,
          AppColors.pinkColorLight,
        ],
      );
    });

    test('keeps the existing palette in dark mode', () {
      expect(
        AppColor.values
            .map(
              (color) =>
                  getColorFromAppColor(color, brightness: Brightness.dark),
            )
            .toList(),
        [
          AppColors.redColorDark,
          AppColors.orangeColorDark,
          AppColors.yellowColorDark,
          AppColors.greenColorDark,
          AppColors.tealColorDark,
          AppColors.blueColorDark,
          AppColors.purpleColorDark,
          AppColors.pinkColorDark,
        ],
      );
    });
  });
}
