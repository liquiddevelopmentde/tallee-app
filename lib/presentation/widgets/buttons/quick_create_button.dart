import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class QuickCreateButton extends StatefulWidget {
  /// A button widget designed for quick creating matches in the [HomeView]
  /// - [text]: The text to display on the button.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  const QuickCreateButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  /// The text to display on the button.
  final String text;

  /// The callback to be invoked when the button is pressed.
  final VoidCallback? onPressed;

  @override
  State<QuickCreateButton> createState() => _QuickCreateButtonState();
}

class _QuickCreateButtonState extends State<QuickCreateButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(140, 45),
        backgroundColor: CustomTheme.primaryColor.withAlpha(200).withBlue(40),
        shape: RoundedRectangleBorder(
          borderRadius: CustomTheme.standardBorderRadiusAll,
        ),
      ),
      child: Text(
        widget.text,
        style: const TextStyle(
          color: CustomTheme.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
