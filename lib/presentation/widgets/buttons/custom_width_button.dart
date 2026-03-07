import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';

class CustomWidthButton extends StatelessWidget {
  /// A custom button widget that is designed to have a width relative to the screen size.
  /// It supports three types of buttons: primary, secondary, and text buttons.
  /// - [text]: The text to display on the button.
  /// - [buttonType]: The type of button to display. Defaults to [ButtonType.primary].
  /// - [sizeRelativeToWidth]: The size of the button relative to the width of the screen.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  const CustomWidthButton({
    super.key,
    required this.text,
    this.buttonType = ButtonType.primary,
    required this.sizeRelativeToWidth,
    this.onPressed,
  });

  /// The text to display on the button.
  final String text;

  /// The size of the button relative to the width of the screen.
  final double sizeRelativeToWidth;

  /// The callback to be invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// The type of button to display. Depends on the enum [ButtonType].
  final ButtonType buttonType;

  @override
  Widget build(BuildContext context) {
    final Color buttonBackgroundColor;
    final Color disabledBackgroundColor;
    final Color borderSideColor;
    final Color textcolor;
    final Color disabledTextColor;

    if (buttonType == ButtonType.primary) {
      textcolor = Colors.white;
      disabledTextColor = Color.lerp(textcolor, Colors.black, 0.5)!;
      buttonBackgroundColor = CustomTheme.primaryColor;
      disabledBackgroundColor = Color.lerp(
        buttonBackgroundColor,
        Colors.black,
        0.5,
      )!;

      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textcolor,
          disabledForegroundColor: disabledTextColor,
          backgroundColor: buttonBackgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          animationDuration: const Duration(),
          minimumSize: Size(
            MediaQuery.sizeOf(context).width * sizeRelativeToWidth,
            60,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
        ),
      );
    } else if (buttonType == ButtonType.secondary) {
      textcolor = CustomTheme.primaryColor;
      disabledTextColor = Color.lerp(textcolor, Colors.black, 0.5)!;
      buttonBackgroundColor = Colors.transparent;
      disabledBackgroundColor = Colors.transparent;
      borderSideColor = onPressed != null
          ? CustomTheme.primaryColor
          : Color.lerp(CustomTheme.primaryColor, Colors.black, 0.5)!;

      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textcolor,
          disabledForegroundColor: disabledTextColor,
          backgroundColor: buttonBackgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          animationDuration: const Duration(),
          minimumSize: Size(
            MediaQuery.sizeOf(context).width * sizeRelativeToWidth,
            60,
          ),
          side: BorderSide(color: borderSideColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
        ),
      );
    } else {
      textcolor = CustomTheme.primaryColor;
      disabledTextColor = Color.lerp(
        CustomTheme.primaryColor,
        Colors.black,
        0.5,
      )!;
      buttonBackgroundColor = Colors.transparent;
      disabledBackgroundColor = Colors.transparent;

      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textcolor,
          disabledForegroundColor: disabledTextColor,
          backgroundColor: buttonBackgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          animationDuration: const Duration(),
          minimumSize: Size(
            MediaQuery.sizeOf(context).width * sizeRelativeToWidth,
            60,
          ),
          side: const BorderSide(style: BorderStyle.none),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
        ),
      );
    }
  }
}
