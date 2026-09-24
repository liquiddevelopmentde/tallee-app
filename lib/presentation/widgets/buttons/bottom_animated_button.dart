import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';

class BottomAnimatedButton extends StatefulWidget {
  /// A custom animated button widget that provides a scaling and opacity effect
  /// when pressed.
  /// - [buttonText]: The text to be displayed on the button.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  /// - [buttonConstraints]: Optional constraints to control the button's size, only works if [sizeRelativeToWidth] is not provided.
  /// - [sizeRelativeToWidth]: Optional size of the button relative to the width of the screen.
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [isDestructive]: A boolean to indicate if the button represents a destructive action, affecting its styling.
  const BottomAnimatedButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.buttonConstraints,
    this.sizeRelativeToWidth,
    this.buttonType = ButtonType.primary,
    this.isDestructive = false,
    this.isEmphasized = false,
  });

  final String buttonText;
  final VoidCallback? onPressed;
  final BoxConstraints? buttonConstraints;
  final double? sizeRelativeToWidth;
  final ButtonType buttonType;
  final bool isDestructive;
  final bool isEmphasized;

  @override
  State<BottomAnimatedButton> createState() => _BottomAnimatedButtonState();
}

class _BottomAnimatedButtonState extends State<BottomAnimatedButton> {
  bool _isPressed = false;

  TextStyle get textStyle {
    late Color textColor;

    switch (widget.buttonType) {
      case ButtonType.primary:
        textColor = widget.isDestructive || widget.isEmphasized
            ? Colors.white
            : Colors.black;
        break;
      default:
        if (widget.isDestructive) {
          textColor = Colors.red;
        } else if (widget.isEmphasized) {
          textColor = CustomTheme.primaryColor;
        } else {
          textColor = Colors.white;
        }
        break;
    }

    return TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  BoxDecoration get buttonDecoration {
    if (widget.buttonType == ButtonType.primary) {
      // Primary
      return BoxDecoration(
        color: widget.isDestructive
            ? Colors.red
            : widget.isEmphasized
            ? CustomTheme.primaryColor
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      );
    } else if (widget.buttonType == ButtonType.secondary) {
      // Secondary
      return BoxDecoration(
        border: BoxBorder.all(
          color: widget.isDestructive
              ? Colors.red
              : widget.isEmphasized
              ? CustomTheme.primaryColor
              : Colors.white,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }
    // Tertiary
    return const BoxDecoration();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.selectionClick();
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedOpacity(
              opacity: _isPressed ? 0.6 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Center(
                child: Container(
                  constraints: widget.sizeRelativeToWidth == null
                      ? widget.buttonConstraints
                      : BoxConstraints(
                          minWidth:
                              MediaQuery.sizeOf(context).width *
                              widget.sizeRelativeToWidth!,
                          minHeight: 50,
                        ),
                  decoration: buttonDecoration,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.buttonText,
                    style: textStyle,
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
}
