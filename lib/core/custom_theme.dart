import 'package:flutter/material.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_back_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_close_button.dart';

/// Theme class that defines colors, border radius, padding, and decorations
class CustomTheme {
  CustomTheme._(); // Private constructor to prevent instantiation

  // ==================== Colors ====================

  /// Primary color of the app theme
  static const Color primaryColor = Color(0xFFef681f);

  /// Secondary color of the app theme
  static const Color secondaryColor = Color(0xFFf2a981);

  /// Background color of the app theme
  static const Color backgroundColor = Color(0xFF0B0B0B);

  /// Default color for boxes and containers
  static const Color boxColor = Color(0xFF101010);

  /// Default border color for boxes and containers
  static const Color boxBorderColor = Color(0xFF272727);

  /// Color for boxes and containers displayed on boxes
  static const Color onBoxColor = Color(0xFF181818);

  /// Text color used throughout the app
  static const Color textColor = Color(0xFFFFFFFF);

  /// Text color used throughout the app
  static const Color hintColor = Color(0xFF888888);

  /// Background color for the navigation bar
  static const Color navBarBackgroundColor = Color(0xFF131313);

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
    vertical: 6,
  );
  static const EdgeInsets tileMargin = EdgeInsets.only(
    left: 12,
    right: 12,
    bottom: 10,
  );

  // ==================== Decorations ====================
  static BoxDecoration standardBoxDecoration = BoxDecoration(
    color: boxColor,
    border: Border.all(color: boxBorderColor),
    borderRadius: standardBorderRadiusAll,
  );

  static BoxDecoration highlightedBoxDecoration = BoxDecoration(
    color: boxColor,
    border: Border.all(
      color: textColor,
      width: 2,
      strokeAlign: BorderSide.strokeAlignCenter,
    ),
    borderRadius: standardBorderRadiusAll,
  );

  // ==================== Component Themes ====================
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

  static final ActionIconThemeData actionIconTheme = ActionIconThemeData(
    backButtonIconBuilder: (context) => const HapticBackButton(),
    closeButtonIconBuilder: (context) => const HapticCloseButton(),
  );

  static const SearchBarThemeData searchBarTheme = SearchBarThemeData(
    textStyle: WidgetStatePropertyAll(TextStyle(color: textColor)),
    hintStyle: WidgetStatePropertyAll(TextStyle(color: hintColor)),
  );

  static final RadioThemeData radioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryColor;
      }
      return textColor;
    }),
  );

  static const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    labelStyle: TextStyle(color: textColor),
    hintStyle: TextStyle(color: hintColor),
  );
}
