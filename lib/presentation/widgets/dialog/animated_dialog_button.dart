import 'package:flutter/material.dart';
import 'package:tallee/core/enums.dart';

class AnimatedDialogButton extends StatefulWidget {
  /// A custom animated button widget that provides a scaling and opacity effect
  /// when pressed.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  /// - [buttonText]: The text to be displayed on the button.
  /// - [buttonType]: The type of the button, which determines its styling.
  const AnimatedDialogButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.constraints,
    this.buttonType = ButtonType.primary,
  });

  final BoxConstraints? constraints;

  final ButtonType buttonType;

  final String buttonText;

  final VoidCallback onPressed;

  @override
  State<AnimatedDialogButton> createState() => _AnimatedDialogButtonState();
}

class _AnimatedDialogButtonState extends State<AnimatedDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textStyling = TextStyle(
      color: widget.buttonType == ButtonType.primary
          ? Colors.black
          : Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final buttonDecoration = widget.buttonType == ButtonType.primary
        // Primary
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          )
        : widget.buttonType == ButtonType.secondary
        // Secondary
        ? BoxDecoration(
            border: BoxBorder.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          )
        // Tertiary
        : const BoxDecoration();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: Container(
              constraints: widget.constraints,
              decoration: buttonDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.buttonText,
                style: textStyling,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
