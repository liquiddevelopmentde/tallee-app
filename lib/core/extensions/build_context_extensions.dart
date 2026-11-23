import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/tallee_theme_colors.dart';

export '../theme/tallee_theme_colors.dart';

extension BuildContextExtension on BuildContext {
  TalleeThemeColors get talleeColors =>
      Theme.of(this).extension<TalleeThemeColors>()!;

  BoxDecoration get standardBoxDecoration => BoxDecoration(
    color: talleeColors.boxColor,
    border: Border.all(color: talleeColors.boxBorderColor),
    borderRadius: AppColors.standardBorderRadiusAll,
  );

  BoxDecoration get highlightedBoxDecoration => BoxDecoration(
    color: talleeColors.boxColor,
    border: Border.all(
      color: talleeColors.textColor,
      width: 2,
      strokeAlign: BorderSide.strokeAlignCenter,
    ),
    borderRadius: AppColors.standardBorderRadiusAll,
  );

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
