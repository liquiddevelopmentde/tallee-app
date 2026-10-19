import 'package:material_ui/material_ui.dart';

/// Theme class that defines colors, border radius, padding, decorations, and ThemeData
class AppColors {
  const AppColors(); // Private constructor to prevent instantiation

  // ==================== Color Definitions ====================

  static const Color primaryColor = Color(0xFFEF681F);
  static const Color secondaryColor = Color(0xFFF2A981);
  static const Color backgroundColorDark = Color(0xFF0B0B0B);
  static const Color backgroundColorLight = Color(0xFFFFFFFF);
  static const Color boxColorDark = Color(0xFF101010);
  static const Color boxColorLight = Color(0xFFF7F7F7);
  static const Color boxBorderColorDark = Color(0xFF272727);
  static const Color boxBorderColorLight = Color(0xFFE0E0E0);
  static const Color onBoxColorDark = Color(0xFF181818);
  static const Color onBoxColorLight = Color(0xFFF0F0F0);
  static const Color textColorDark = Color(0xFFFFFFFF);
  static const Color textColorLight = Color(0xFF171717);
  static const Color hintColorDark = Color(0xFF888888);
  static const Color hintColorLight = Color(0xFF6B6B6B);
  static const Color errorColorDark = Color(0xFFF44336);
  static const Color errorColorLight = Color(0xFFF44336);
  static const Color successColorDark = Color(0xFF4CAF50);
  static const Color successColorLight = Color(0xFF4CAF50);
  static const Color warningColorDark = Color(0xFFFF9800);
  static const Color warningColorLight = Color(0xFFFF9800);
  static const Color navBarBackgroundColorDark = Color(0xFF131313);
  static const Color navBarBackgroundColorLight = Color(0xFFF7F7F7);
  static const Color navBarItemUnselectedColorDark = Color(0xFFBDBDBD);
  static const Color navBarItemUnselectedColorLight = Color(0xFF6B6B6B);

  static const Color redColor = Color(0xFFF44336);
  static const Color blueColor = Color(0xFF2196F3);
  static const Color greenColor = Color(0xFF4CAF50);
  static const Color yellowColor = Color(0xFFFFEB3B);
  static const Color purpleColor = Color(0xFF9C27B0);
  static const Color orangeColor = Color(0xFFFF9800);
  static const Color pinkColor = Color(0xFFE91E63);
  static const Color tealColor = Color(0xFF009688);
  static const Color blackColor = Color(0xFF000000);

  // ==================== App-Colors ====================

  static const Color red = redColor;
  static const Color blue = blueColor;
  static const Color green = greenColor;
  static const Color yellow = yellowColor;
  static const Color purple = purpleColor;
  static const Color orange = orangeColor;
  static const Color pink = pinkColor;
  static const Color teal = tealColor;

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
