import 'package:material_ui/material_ui.dart';

/// Theme class that defines colors, border radius, padding, decorations, and ThemeData
class AppColors {
  const AppColors(); // Private constructor to prevent instantiation

  // ==================== Color Definitions ====================

  static const Color primaryColor = Color(0xFFEF681F);
  static const Color secondaryColor = Color(0xFFF2A981);

  // ==== Dark colors ====

  /* Surfaces */

  static const Color backgroundColorDark = Color(0xFF0B0B0B);
  static const Color boxColorDark = Color(0xFF101010);
  static const Color boxBorderColorDark = Color(0xFF272727);
  static const Color onBoxColorDark = Color(0xFF181818);
  static const Color textColorDark = Color(0xFFFFFFFF);
  static const Color hintColorDark = Color(0xFF888888);
  static const Color errorColorDark = redColorDark;
  static const Color successColorDark = greenColorDark;
  static const Color warningColorDark = orangeColorDark;
  static const Color navBarBackgroundColorDark = Color(0xFF131313);
  static const Color navBarItemUnselectedColorDark = Color(0xFFBDBDBD);
  static const Color skeletonFromColorDark = Color(0xFF424242);
  static const Color skeletonToColorDark = Color(0xFF616161);

  /* Palette */

  static const Color redColorDark = Color(0xFFF44336);
  static const Color blueColorDark = Color(0xFF2196F3);
  static const Color greenColorDark = Color(0xFF4CAF50);
  static const Color yellowColorDark = Color(0xFFFFEB3B);
  static const Color purpleColorDark = Color(0xFF9C27B0);
  static const Color orangeColorDark = Color(0xFFFF9800);
  static const Color pinkColorDark = Color(0xFFE91E63);
  static const Color tealColorDark = Color(0xFF009688);

  // ==== Light colors ====

  /* Surfaces */

  static const Color backgroundColorLight = Color(0xFFFFFFFF);
  static const Color boxColorLight = Color(0xFFF7F7F7);
  static const Color boxBorderColorLight = Color(0xFFE0E0E0);
  static const Color onBoxColorLight = Color(0xFFF0F0F0);
  static const Color textColorLight = Color(0xFF171717);
  static const Color hintColorLight = Color(0xFF6B6B6B);
  static const Color errorColorLight = redColorLight;
  static const Color successColorLight = greenColorLight;
  static const Color warningColorLight = orangeColorLight;
  static const Color navBarBackgroundColorLight = Color(0xFFF7F7F7);
  static const Color navBarItemUnselectedColorLight = Color(0xFF6B6B6B);
  static const Color skeletonFromColorLight = Color(0xFFD0D0D0);
  static const Color skeletonToColorLight = Color(0xFFE0E0E0);

  /* Palette */

  static const Color redColorLight = Color(0xFFE86A6A);
  static const Color blueColorLight = Color(0xFF64B5F6);
  static const Color greenColorLight = Color(0xFF81C784);
  static const Color yellowColorLight = Color(0xFFFFD54F);
  static const Color purpleColorLight = Color(0xFFBA68C8);
  static const Color orangeColorLight = Color(0xFFFFB74D);
  static const Color pinkColorLight = Color(0xFFF06292);
  static const Color tealColorLight = Color(0xFF4DB6AC);
  static const Color blackColor = Color(0xFF000000);

  // ==================== Border Radius ====================
  static const double standardBorderRadius = 12.0;
  static BorderRadius get standardBorderRadiusAll =>
      BorderRadius.circular(standardBorderRadius);

  // ==================== Padding & Margins ====================
  static const EdgeInsets standardMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const EdgeInsets tileMargin = EdgeInsets.only(
    left: 12,
    right: 12,
    bottom: 10,
  );

  static EdgeInsets listViewPadding(BuildContext context) =>
      EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom + 190);

  static const EdgeInsets filterRowPadding = EdgeInsets.only(
    bottom: 10,
    left: 12,
  );
}
