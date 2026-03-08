import 'package:flutter/material.dart';

class MainMenuButton extends StatefulWidget {
  /// A button for the main menu with an optional icon and a press animation.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  /// - [icon]: The icon of the button.
  /// - [text]: The text of the button.
  const MainMenuButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.text,
  });

  /// The callback to be invoked when the button is pressed.
  final void Function() onPressed;

  /// The icon of the button.
  final IconData icon;

  /// The text of the button.
  final String? text;

  @override
  State<MainMenuButton> createState() => _MainMenuButtonState();
}

class _MainMenuButtonState extends State<MainMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          _animationController.forward();
        },
        onTapUp: (_) async {
          await _animationController.reverse();
          if (mounted) {
            widget.onPressed();
          }
        },
        onTapCancel: () {
          _animationController.reverse();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 26, color: Colors.black),
              if (widget.text != null) ...[
                const SizedBox(width: 7),
                Text(
                  widget.text!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
