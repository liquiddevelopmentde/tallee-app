import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/tallee_theme_colors.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_back_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_close_button.dart';

extension ThemeDataToFlutter on ThemeData {
  flutter_material.ThemeData toFlutterThemeData() {
    return flutter_material.ThemeData(
      brightness: brightness,
      primaryColor: AppColors.primaryColor,
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

// ==================== Component Themes ====================

final ActionIconThemeData actionIconTheme = ActionIconThemeData(
  backButtonIconBuilder: (context) => const HapticBackButton(),
  closeButtonIconBuilder: (context) => const HapticCloseButton(),
);

final IconButtonThemeData iconButtonTheme = IconButtonThemeData(
  style: IconButton.styleFrom(
    splashFactory: NoSplash.splashFactory,
    overlayColor: Colors.transparent,
    highlightColor: Colors.transparent,
  ),
);

final TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    splashFactory: NoSplash.splashFactory,
    overlayColor: Colors.transparent,
  ),
);

final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    splashFactory: NoSplash.splashFactory,
    overlayColor: Colors.transparent,
  ),
);

final OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    splashFactory: NoSplash.splashFactory,
    overlayColor: Colors.transparent,
  ),
);

final FilledButtonThemeData filledButtonTheme = FilledButtonThemeData(
  style: FilledButton.styleFrom(
    splashFactory: NoSplash.splashFactory,
    overlayColor: Colors.transparent,
  ),
);

final ThemeData _lightTheme = _createThemeData(isDarkMode: false);
final ThemeData _darkTheme = _createThemeData(isDarkMode: true);

ThemeData _createThemeData({required bool isDarkMode}) {
  final palette = _ThemePalette(isDarkMode: isDarkMode);
  final brightness = isDarkMode ? Brightness.dark : Brightness.light;
  final textTheme =
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
        bodyColor: palette.textColor,
        displayColor: palette.textColor,
        fontFamily: 'Inter',
      );
  final appBarTheme = AppBarTheme(
    backgroundColor: palette.backgroundColor,
    actionsIconTheme: IconThemeData(color: palette.textColor),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: palette.textColor),
    titleTextStyle: TextStyle(
      color: palette.textColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    ),
  );
  final searchBarTheme = SearchBarThemeData(
    textStyle: WidgetStatePropertyAll(TextStyle(color: palette.textColor)),
    hintStyle: WidgetStatePropertyAll(TextStyle(color: palette.hintColor)),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  );
  final radioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      return states.contains(WidgetState.selected)
          ? AppColors.primaryColor
          : palette.textColor;
    }),
  );
  final inputDecorationTheme = InputDecorationTheme(
    labelStyle: TextStyle(color: palette.textColor),
    hintStyle: TextStyle(color: palette.hintColor),
  );
  return _buildThemeData(
    brightness: brightness,
    palette: palette,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    searchBarTheme: searchBarTheme,
    radioTheme: radioTheme,
    inputDecorationTheme: inputDecorationTheme,
  );
}

ThemeData _buildThemeData({
  required Brightness brightness,
  required _ThemePalette palette,
  required TextTheme textTheme,
  required AppBarTheme appBarTheme,
  required SearchBarThemeData searchBarTheme,
  required RadioThemeData radioTheme,
  required InputDecorationTheme inputDecorationTheme,
}) => ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: palette.backgroundColor,
  primaryColor: AppColors.primaryColor,

  // Global splash, focus, hover, and highlight overrides
  splashFactory: NoSplash.splashFactory,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
  focusColor: Colors.transparent,

  // Global tooltip override to prevent default long-tap popups
  tooltipTheme: const TooltipThemeData(triggerMode: TooltipTriggerMode.manual),

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
    primary: AppColors.primaryColor,
    onPrimary: AppColors.textColorDark,
    secondary: AppColors.secondaryColor,
    onSecondary: AppColors.blackColor,
    error: palette.errorColor,
    onError: AppColors.textColorDark,
    surface: palette.backgroundColor,
    onSurface: palette.textColor,
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
  extensions: [palette.toThemeColors()],
);

class _ThemePalette {
  _ThemePalette({required bool isDarkMode})
    : backgroundColor = isDarkMode
          ? AppColors.backgroundColorDark
          : AppColors.backgroundColorLight,
      boxColor = isDarkMode ? AppColors.boxColorDark : AppColors.boxColorLight,
      boxBorderColor = isDarkMode
          ? AppColors.boxBorderColorDark
          : AppColors.boxBorderColorLight,
      onBoxColor = isDarkMode
          ? AppColors.onBoxColorDark
          : AppColors.onBoxColorLight,
      textColor = isDarkMode
          ? AppColors.textColorDark
          : AppColors.textColorLight,
      hintColor = isDarkMode
          ? AppColors.hintColorDark
          : AppColors.hintColorLight,
      errorColor = isDarkMode
          ? AppColors.errorColorDark
          : AppColors.errorColorLight,
      successColor = isDarkMode
          ? AppColors.successColorDark
          : AppColors.successColorLight,
      warningColor = isDarkMode
          ? AppColors.warningColorDark
          : AppColors.warningColorLight,
      navBarBackgroundColor = isDarkMode
          ? AppColors.navBarBackgroundColorDark
          : AppColors.navBarBackgroundColorLight,
      navBarItemUnselectedColor = isDarkMode
          ? AppColors.navBarItemUnselectedColorDark
          : AppColors.navBarItemUnselectedColorLight,
      skeletonFromColor = isDarkMode
          ? AppColors.skeletonFromColorDark
          : AppColors.skeletonFromColorLight,
      skeletonToColor = isDarkMode
          ? AppColors.skeletonToColorDark
          : AppColors.skeletonToColorLight;

  final Color backgroundColor;
  final Color boxColor;
  final Color boxBorderColor;
  final Color onBoxColor;
  final Color textColor;
  final Color hintColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color navBarBackgroundColor;
  final Color navBarItemUnselectedColor;
  final Color skeletonFromColor;
  final Color skeletonToColor;

  TalleeThemeColors toThemeColors() => TalleeThemeColors(
    backgroundColor: backgroundColor,
    boxColor: boxColor,
    boxBorderColor: boxBorderColor,
    onBoxColor: onBoxColor,
    textColor: textColor,
    hintColor: hintColor,
    errorColor: errorColor,
    successColor: successColor,
    warningColor: warningColor,
    navBarBackgroundColor: navBarBackgroundColor,
    navBarItemSelectedColor: AppColors.primaryColor,
    navBarItemUnselectedColor: navBarItemUnselectedColor,
    skeletonFromColor: skeletonFromColor,
    skeletonToColor: skeletonToColor,
  );
}

final ThemeData lightTheme = _lightTheme;
final ThemeData darkTheme = _darkTheme;
