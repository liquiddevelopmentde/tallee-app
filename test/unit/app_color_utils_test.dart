import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/app_theme.dart';

void main() {
  group('getColorFromAppColor', () {
    testWidgets('uses optimized colors in light mode', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        AppColor.values
            .map((color) => getColorFromAppColor(color, context))
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

    testWidgets('keeps the existing palette in dark mode', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        AppColor.values
            .map((color) => getColorFromAppColor(color, context))
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
