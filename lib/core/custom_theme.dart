import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:material_ui/material_ui.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_back_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_close_button.dart';

extension ThemeDataToFlutter on ThemeData {
  flutter_material.ThemeData toFlutterThemeData() {
    return flutter_material.ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      dividerColor: dividerColor,
      cardColor: cardColor,
      colorScheme: flutter_material.ColorScheme(
        brightness: colorScheme.brightness,
        primary: colorScheme.primary,
        onPrimary: colorScheme.onPrimary,
        secondary: colorScheme.secondary,
        onSecondary: colorScheme.onSecondary,
        error: colorScheme.error,
        onError: colorScheme.onError,
        surface: colorScheme.surface,
        onSurface: colorScheme.onSurface,
        surfaceContainerHighest: colorScheme.surfaceContainerHighest,
      ),
      textTheme: flutter_material.TextTheme(
        bodyMedium: textTheme.bodyMedium,
        headlineSmall: textTheme.headlineSmall,
        titleLarge: textTheme.titleLarge,
        titleMedium: textTheme.titleMedium,
        bodyLarge: textTheme.bodyLarge,
      ),
    );
  }
}

/// Theme class that defines colors, border radius, padding, decorations, and ThemeData
class CustomTheme {
  CustomTheme._(); // Private constructor to prevent instantiation

  static bool isDarkMode = true;

  // ==================== Colors ====================

  /// Primary color of the app theme
  static const Color primaryColor = Color(0xFFef681f);

  /// Secondary color of the app theme
  static const Color secondaryColor = Color(0xFFf2a981);

  /// Background color of the app theme
  static Color backgroundColor = const Color(0xFF0B0B0B);

  /// Default color for boxes and containers
  static Color boxColor = const Color(0xFF101010);

  /// Default border color for boxes and containers
  static Color boxBorderColor = const Color(0xFF272727);

  /// Color for boxes and containers displayed on boxes
  static Color onBoxColor = const Color(0xFF181818);

  /// Text color used throughout the app
  static Color textColor = const Color(0xFFFFFFFF);

  /// Text color used throughout the app
  static Color hintColor = const Color(0xFF888888);

  /// Background color for the navigation bar
  static Color navBarBackgroundColor = const Color(0xFF131313);

  /// Selected color for the [NavbarItem]
  static Color navBarItemSelectedColor = primaryColor.withGreen(100);

  /// Unselected color for the [NavbarItem]
  static Color navBarItemUnselectedColor = Colors.grey.shade400;

  static void setColors({required bool dark}) {
    isDarkMode = dark;
    backgroundColor = dark ? const Color(0xFF0B0B0B) : const Color(0xFFF7F7F7);
    boxColor = dark ? const Color(0xFF101010) : Colors.white;
    boxBorderColor = dark ? const Color(0xFF272727) : const Color(0xFFE0E0E0);
    onBoxColor = dark ? const Color(0xFF181818) : const Color(0xFFF0F0F0);
    textColor = dark ? Colors.white : const Color(0xFF171717);
    hintColor = dark ? const Color(0xFF888888) : const Color(0xFF6B6B6B);
    navBarBackgroundColor = dark ? const Color(0xFF131313) : Colors.white;
    navBarItemUnselectedColor = dark
        ? Colors.grey.shade400
        : Colors.grey.shade700;
  }

  // ==================== App-Colors ====================

  static Color red = Colors.red;
  static Color blue = Colors.blue;
  static Color green = Colors.green;
  static Color yellow = const Color(0xFFF7CA28);
  static Color purple = Colors.purple;
  static Color orange = const Color(0xFFef681f);
  static Color pink = const Color(0xFFE91E63);
  static Color teal = const Color(0xFF00BCD4);

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

  // ==================== Decorations ====================
  static BoxDecoration get standardBoxDecoration => BoxDecoration(
    color: boxColor,
    border: Border.all(color: boxBorderColor),
    borderRadius: standardBorderRadiusAll,
  );

  static BoxDecoration get highlightedBoxDecoration => BoxDecoration(
    color: boxColor,
    border: Border.all(
      color: textColor,
      width: 2,
      strokeAlign: BorderSide.strokeAlignCenter,
    ),
    borderRadius: standardBorderRadiusAll,
  );

  // ==================== Component Themes ====================
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: isDarkMode ? backgroundColor : const Color(0xFFF7F7F7),
    actionsIconTheme: IconThemeData(
      color: isDarkMode ? textColor : const Color(0xFF171717),
    ),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: isDarkMode ? textColor : const Color(0xFF171717),
    ),
    titleTextStyle: TextStyle(
      color: isDarkMode ? textColor : const Color(0xFF171717),
      fontSize: 20,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    ),
  );

  static TextTheme get textTheme =>
      const TextTheme(
        displayLarge: TextStyle(overflow: TextOverflow.ellipsis),
        displayMedium: TextStyle(overflow: TextOverflow.ellipsis),
        displaySmall: TextStyle(overflow: TextOverflow.ellipsis),
        headlineLarge: TextStyle(overflow: TextOverflow.ellipsis),
        headlineMedium: TextStyle(overflow: TextOverflow.ellipsis),
        headlineSmall: TextStyle(overflow: TextOverflow.ellipsis),
        titleLarge: TextStyle(overflow: TextOverflow.ellipsis),
        titleMedium: TextStyle(overflow: TextOverflow.ellipsis),
        titleSmall: TextStyle(overflow: TextOverflow.ellipsis),
        bodyLarge: TextStyle(overflow: TextOverflow.ellipsis),
        bodyMedium: TextStyle(overflow: TextOverflow.ellipsis),
        bodySmall: TextStyle(overflow: TextOverflow.ellipsis),
        labelLarge: TextStyle(overflow: TextOverflow.ellipsis),
        labelMedium: TextStyle(overflow: TextOverflow.ellipsis),
        labelSmall: TextStyle(overflow: TextOverflow.ellipsis),
      ).apply(
        bodyColor: isDarkMode ? textColor : const Color(0xFF171717),
        displayColor: isDarkMode ? textColor : const Color(0xFF171717),
        fontFamily: 'Inter',
      );

  static final ActionIconThemeData actionIconTheme = ActionIconThemeData(
    backButtonIconBuilder: (context) => const HapticBackButton(),
    closeButtonIconBuilder: (context) => const HapticCloseButton(),
  );

  static SearchBarThemeData get searchBarTheme => SearchBarThemeData(
    textStyle: WidgetStatePropertyAll(
      TextStyle(color: isDarkMode ? textColor : const Color(0xFF171717)),
    ),
    hintStyle: WidgetStatePropertyAll(TextStyle(color: hintColor)),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  );

  static RadioThemeData get radioTheme => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryColor;
      }
      return isDarkMode ? textColor : const Color(0xFF171717);
    }),
  );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    labelStyle: TextStyle(
      color: isDarkMode ? textColor : const Color(0xFF171717),
    ),
    hintStyle: TextStyle(color: hintColor),
  );

  static final IconButtonThemeData iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      overlayColor: Colors.transparent,
      highlightColor: Colors.transparent,
    ),
  );

  static final TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      overlayColor: Colors.transparent,
    ),
  );

  static final ElevatedButtonThemeData elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
        ),
      );

  static final OutlinedButtonThemeData outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
        ),
      );

  static final FilledButtonThemeData filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      overlayColor: Colors.transparent,
    ),
  );

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,

    // Global splash, focus, hover, and highlight overrides
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,

    // Global tooltip override to prevent default long-tap popups
    tooltipTheme: const TooltipThemeData(
      triggerMode: TooltipTriggerMode.manual,
    ),

    // Page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),

    // Color Scheme
    colorScheme: ColorScheme(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      surface: backgroundColor,
      onSurface: textColor,
    ),

    // Sub-themes
    appBarTheme: appBarTheme,
    textTheme: textTheme,
    actionIconTheme: actionIconTheme,
    searchBarTheme: searchBarTheme,
    radioTheme: radioTheme,
    inputDecorationTheme: inputDecorationTheme,
    iconButtonTheme: iconButtonTheme,
    textButtonTheme: textButtonTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    filledButtonTheme: filledButtonTheme,
  );
}
