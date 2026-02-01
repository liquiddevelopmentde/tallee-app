import 'package:flutter/material.dart';

/// Theme class that defines colors, border radius, padding, and decorations
class CustomTheme {
  CustomTheme._(); // Private constructor to prevent instantiation

  // ==================== Colors ====================

  /// Primary color of the app theme
  static const Color primaryColor = Color(0xFFef681f);

  /// Secondary color of the app theme
  static const Color secondaryColor = Color(0xFFf2a981);

  /// Background color of the app theme
  static const backgroundColor = Color(0xFF0B0B0B);

  /// Default color for boxes and containers
  static const Color boxColor = Color(0xFF101010);

  /// Default border color for boxes and containers
  static const Color boxBorder = Color(0xFF272727);

  /// Color for boxes and containers displayed on boxes
  static const Color onBoxColor = Color(0xFF181818);

  /// Text color used throughout the app
  static const Color textColor = Color(0xFFFFFFFF);

  /// Selected color for the [NavbarItem]
  static Color navBarItemSelectedColor = primaryColor.withGreen(100);

  /// Unselected color for the [NavbarItem]
  static Color navBarItemUnselectedColor = Colors.grey.shade400;

  // ==================== Border Radius ====================
  static const double standardBorderRadius = 12.0;
  static BorderRadius get standardBorderRadiusAll =>
      BorderRadius.circular(standardBorderRadius);

  // ==================== Padding & Margins ====================
  static const EdgeInsets standardMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets tileMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 5,
  );

  // ==================== Decorations ====================
  static BoxDecoration standardBoxDecoration = BoxDecoration(
    color: boxColor,
    border: Border.all(color: boxBorder),
    borderRadius: standardBorderRadiusAll,
  );

  static BoxDecoration highlightedBoxDecoration = BoxDecoration(
    color: boxColor,
    border: Border.all(color: primaryColor),
    borderRadius: standardBorderRadiusAll,
    boxShadow: [BoxShadow(color: primaryColor.withAlpha(120), blurRadius: 12)],
  );

  // ==================== App Bar Theme ====================
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: backgroundColor,
    foregroundColor: textColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: textColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    ),
    iconTheme: IconThemeData(color: textColor),
  );
}
