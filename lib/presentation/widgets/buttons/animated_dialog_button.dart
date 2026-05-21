import 'package:flutter/material.dart';
import 'package:tallee/core/enums.dart';

class AnimatedDialogButton extends StatefulWidget {
  /// A custom animated button widget that provides a scaling and opacity effect
  /// when pressed.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  /// - [buttonText]: The text to be displayed on the button.
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [buttonConstraints]: Optional constraints to control the button's size.
  const AnimatedDialogButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.buttonConstraints,
    this.buttonType = ButtonType.primary,
    this.isDescructive = false,
  });

  final String buttonText;

  final VoidCallback? onPressed;

  final BoxConstraints? buttonConstraints;

  final ButtonType buttonType;

  final bool isDescructive;

  @override
  State<AnimatedDialogButton> createState() => _AnimatedDialogButtonState();
}

class _AnimatedDialogButtonState extends State<AnimatedDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textStyling = _getTextStyling();
    final buttonDecoration = _getButtonDecoration();
    bool _isDisabled = widget.onPressed == null;

    return IgnorePointer(
      ignoring: _isDisabled,
      child: Opacity(
        opacity: _isDisabled ? 0.5 : 1.0,
        child: GestureDetector(
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
                  constraints: widget.buttonConstraints,
                  decoration: buttonDecoration,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
        ),
      ),
    );
  }

  TextStyle _getTextStyling() {
    late Color textColor;
    if (widget.buttonType == ButtonType.primary) {
      textColor = widget.isDescructive ? Colors.white : Colors.black;
    } else if (widget.buttonType == ButtonType.secondary) {
      textColor = widget.isDescructive ? Colors.red : Colors.white;
    } else {
      textColor = widget.isDescructive ? Colors.red : Colors.white;
    }

    return TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  BoxDecoration _getButtonDecoration() {
    if (widget.buttonType == ButtonType.primary) {
      // Primary
      return BoxDecoration(
        color: widget.isDescructive ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(12),
      );
    } else if (widget.buttonType == ButtonType.secondary) {
      // Secondary
      return BoxDecoration(
        border: BoxBorder.all(
          color: widget.isDescructive ? Colors.red : Colors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }
    // Tertiary
    return const BoxDecoration();
  }
}
