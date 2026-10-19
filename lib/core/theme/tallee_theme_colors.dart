import 'package:material_ui/material_ui.dart';

class TalleeThemeColors extends ThemeExtension<TalleeThemeColors> {
  const TalleeThemeColors({
    required this.backgroundColor,
    required this.boxColor,
    required this.boxBorderColor,
    required this.onBoxColor,
    required this.textColor,
    required this.hintColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
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
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
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
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
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
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
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
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
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
