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
    required this.skeletonFromColor,
    required this.skeletonToColor,
    required this.redColor,
    required this.orangeColor,
    required this.yellowColor,
    required this.greenColor,
    required this.tealColor,
    required this.blueColor,
    required this.purpleColor,
    required this.pinkColor,
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
  final Color skeletonFromColor;
  final Color skeletonToColor;
  final Color redColor;
  final Color orangeColor;
  final Color yellowColor;
  final Color greenColor;
  final Color tealColor;
  final Color blueColor;
  final Color purpleColor;
  final Color pinkColor;

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
    Color? skeletonFromColor,
    Color? skeletonToColor,
    Color? redColor,
    Color? orangeColor,
    Color? yellowColor,
    Color? greenColor,
    Color? tealColor,
    Color? blueColor,
    Color? purpleColor,
    Color? pinkColor,
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
      skeletonFromColor: skeletonFromColor ?? this.skeletonFromColor,
      skeletonToColor: skeletonToColor ?? this.skeletonToColor,
      redColor: redColor ?? this.redColor,
      orangeColor: orangeColor ?? this.orangeColor,
      yellowColor: yellowColor ?? this.yellowColor,
      greenColor: greenColor ?? this.greenColor,
      tealColor: tealColor ?? this.tealColor,
      blueColor: blueColor ?? this.blueColor,
      purpleColor: purpleColor ?? this.purpleColor,
      pinkColor: pinkColor ?? this.pinkColor,
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
      skeletonFromColor: Color.lerp(
        skeletonFromColor,
        other.skeletonFromColor,
        t,
      )!,
      skeletonToColor: Color.lerp(skeletonToColor, other.skeletonToColor, t)!,
      redColor: Color.lerp(redColor, other.redColor, t)!,
      orangeColor: Color.lerp(orangeColor, other.orangeColor, t)!,
      yellowColor: Color.lerp(yellowColor, other.yellowColor, t)!,
      greenColor: Color.lerp(greenColor, other.greenColor, t)!,
      tealColor: Color.lerp(tealColor, other.tealColor, t)!,
      blueColor: Color.lerp(blueColor, other.blueColor, t)!,
      purpleColor: Color.lerp(purpleColor, other.purpleColor, t)!,
      pinkColor: Color.lerp(pinkColor, other.pinkColor, t)!,
    );
  }
}
