import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class AnimatedDialogButton extends StatefulWidget {
  /// A custom animated button widget that provides a scaling and opacity effect
  /// when pressed.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  /// - [child]: The child widget to be displayed inside the button, typically a text or icon.
  const AnimatedDialogButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  /// Callback function that is triggered when the button is pressed.
  final VoidCallback onPressed;

  /// The child widget to be displayed inside the button, typically a text or icon.
  final Widget child;

  @override
  State<AnimatedDialogButton> createState() => _AnimatedDialogButtonState();
}

class _AnimatedDialogButtonState extends State<AnimatedDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
          child: Container(
            decoration: CustomTheme.standardBoxDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
