import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';

/// A custom text button widget.
/// - [onPressed]: Callback invoked when the button is pressed.
/// - [text]: The text displayed on the button.
/// - [style]: Optional style for the text.
class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
  });

  final VoidCallback? onPressed;

  final String text;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed!.call();
            }
          : null,
      child: Text(
        text,
        style: style ?? const TextStyle(color: CustomTheme.textColor),
      ),
    );
  }
}
