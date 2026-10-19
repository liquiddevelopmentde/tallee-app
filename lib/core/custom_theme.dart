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
  static Brightness brightness = Brightness.dark;

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

  // ==================== Adaptive Colors ====================

  static Color backgroundColor = backgroundColorDark;
  static Color boxColor = boxColorDark;
  static Color boxBorderColor = boxBorderColorDark;
  static Color onBoxColor = onBoxColorDark;
  static Color textColor = textColorDark;
  static Color hintColor = hintColorDark;
  static Color errorColor = errorColorDark;
  static Color successColor = successColorDark;
  static Color warningColor = warningColorDark;
  static Color navBarBackgroundColor = navBarBackgroundColorDark;
  static Color navBarItemSelectedColor = primaryColor;
  static Color navBarItemUnselectedColor = navBarItemUnselectedColorDark;

  static void setColors({required bool isDarkMode}) {
    CustomTheme.isDarkMode = isDarkMode;
    brightness = isDarkMode ? Brightness.dark : Brightness.light;
    backgroundColor = isDarkMode ? backgroundColorDark : backgroundColorLight;
    boxColor = isDarkMode ? boxColorDark : boxColorLight;
    boxBorderColor = isDarkMode ? boxBorderColorDark : boxBorderColorLight;
    onBoxColor = isDarkMode ? onBoxColorDark : onBoxColorLight;
    textColor = isDarkMode ? textColorDark : textColorLight;
    hintColor = isDarkMode ? hintColorDark : hintColorLight;
    errorColor = isDarkMode ? errorColorDark : errorColorLight;
    successColor = isDarkMode ? successColorDark : successColorLight;
    warningColor = isDarkMode ? warningColorDark : warningColorLight;
    red = errorColor;
    green = successColor;
    navBarBackgroundColor = isDarkMode
        ? navBarBackgroundColorDark
        : navBarBackgroundColorLight;
    navBarItemSelectedColor = primaryColor;
    navBarItemUnselectedColor = isDarkMode
        ? navBarItemUnselectedColorDark
        : navBarItemUnselectedColorLight;
  }

  // ==================== App-Colors ====================

  static Color red = redColor;
  static Color blue = blueColor;
  static Color green = greenColor;
  static Color yellow = yellowColor;
  static Color purple = purpleColor;
  static Color orange = orangeColor;
  static Color pink = pinkColor;
  static Color teal = tealColor;

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
    backgroundColor: backgroundColor,
    actionsIconTheme: IconThemeData(color: textColor),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: textColor),
    titleTextStyle: TextStyle(
      color: textColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    ),
  );

  static TextTheme get textTheme => const TextTheme(
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
  ).apply(bodyColor: textColor, displayColor: textColor, fontFamily: 'Inter');

  static final ActionIconThemeData actionIconTheme = ActionIconThemeData(
    backButtonIconBuilder: (context) => const HapticBackButton(),
    closeButtonIconBuilder: (context) => const HapticCloseButton(),
  );

  static SearchBarThemeData get searchBarTheme => SearchBarThemeData(
    textStyle: WidgetStatePropertyAll(TextStyle(color: textColor)),
    hintStyle: WidgetStatePropertyAll(TextStyle(color: hintColor)),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  );

  static RadioThemeData get radioTheme => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryColor;
      }
      return textColor;
    }),
  );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    labelStyle: TextStyle(color: textColor),
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
      brightness: brightness,
      primary: primaryColor,
      onPrimary: textColorDark,
      secondary: secondaryColor,
      onSecondary: blackColor,
      error: errorColor,
      onError: textColorDark,
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
    extensions: [appColors],
  );

  static TalleeThemeColors get appColors => TalleeThemeColors(
    backgroundColor: backgroundColor,
    boxColor: boxColor,
    boxBorderColor: boxBorderColor,
    onBoxColor: onBoxColor,
    textColor: textColor,
    hintColor: hintColor,
    navBarBackgroundColor: navBarBackgroundColor,
    navBarItemSelectedColor: navBarItemSelectedColor,
    navBarItemUnselectedColor: navBarItemUnselectedColor,
  );
}

class TalleeThemeColors extends ThemeExtension<TalleeThemeColors> {
  const TalleeThemeColors({
    required this.backgroundColor,
    required this.boxColor,
    required this.boxBorderColor,
    required this.onBoxColor,
    required this.textColor,
    required this.hintColor,
    required this.navBarBackgroundColor,
    required this.navBarItemSelectedColor,
    required this.navBarItemUnselectedColor,
  });

  final Color backgroundColor;
  final Color boxColor;
  final Color boxBorderColor;
  final Color onBoxColor;
  final Color textColor;
  final Color hintColor;
  final Color navBarBackgroundColor;
  final Color navBarItemSelectedColor;
  final Color navBarItemUnselectedColor;

  @override
  TalleeThemeColors copyWith({
    Color? backgroundColor,
    Color? boxColor,
    Color? boxBorderColor,
    Color? onBoxColor,
    Color? textColor,
    Color? hintColor,
    Color? navBarBackgroundColor,
    Color? navBarItemSelectedColor,
    Color? navBarItemUnselectedColor,
  }) {
    return TalleeThemeColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxColor: boxColor ?? this.boxColor,
      boxBorderColor: boxBorderColor ?? this.boxBorderColor,
      onBoxColor: onBoxColor ?? this.onBoxColor,
      textColor: textColor ?? this.textColor,
      hintColor: hintColor ?? this.hintColor,
      navBarBackgroundColor:
          navBarBackgroundColor ?? this.navBarBackgroundColor,
      navBarItemSelectedColor:
          navBarItemSelectedColor ?? this.navBarItemSelectedColor,
      navBarItemUnselectedColor:
          navBarItemUnselectedColor ?? this.navBarItemUnselectedColor,
    );
  }

  @override
  TalleeThemeColors lerp(
    covariant ThemeExtension<TalleeThemeColors>? other,
    double t,
  ) {
    if (other is! TalleeThemeColors) return this;
    return TalleeThemeColors(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      boxColor: Color.lerp(boxColor, other.boxColor, t)!,
      boxBorderColor: Color.lerp(boxBorderColor, other.boxBorderColor, t)!,
      onBoxColor: Color.lerp(onBoxColor, other.onBoxColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      hintColor: Color.lerp(hintColor, other.hintColor, t)!,
      navBarBackgroundColor: Color.lerp(
        navBarBackgroundColor,
        other.navBarBackgroundColor,
        t,
      )!,
      navBarItemSelectedColor: Color.lerp(
        navBarItemSelectedColor,
        other.navBarItemSelectedColor,
        t,
      )!,
      navBarItemUnselectedColor: Color.lerp(
        navBarItemUnselectedColor,
        other.navBarItemUnselectedColor,
        t,
      )!,
    );
  }
}

extension TalleeThemeContext on BuildContext {
  TalleeThemeColors get talleeColors =>
      Theme.of(this).extension<TalleeThemeColors>()!;
}
