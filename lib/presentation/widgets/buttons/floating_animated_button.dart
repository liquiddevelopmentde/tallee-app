import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingAnimatedButton extends StatefulWidget {
  /// A button for the main menu with an optional icon and a press animation.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  /// - [icon]: The icon of the button.
  /// - [text]: The text of the button.
  /// - [onLongPressed]: The callback to be invoked when the button is pressed longer
  /// - [showAddBadge]: Whether to show a plus badge on the top right corner on the icon
  const FloatingAnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.text,
    this.onLongPressed,
    this.showAddBadge = false,
  });

  final void Function()? onPressed;
  final IconData icon;
  final String? text;
  final void Function()? onLongPressed;
  final bool showAddBadge;

  @override
  State<FloatingAnimatedButton> createState() => _FloatingAnimatedButtonState();
}

class _FloatingAnimatedButtonState extends State<FloatingAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController disabledAnimationController;
  late Animation<double> scaleAnimation;
  late Animation<double> disabledScaleAnimation;

  /// How long the button needs to be pressed to register it as long press
  Timer? longPressTimer;

  /// How much time between two onLongPressed calls
  Timer? repeatTimer;

  bool isLongPressing = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    disabledAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    disabledScaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: disabledAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(FloatingAnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null || widget.onLongPressed == null) {
      cancelTimers();
      isLongPressing = false;
    }
  }

  @override
  void dispose() {
    cancelTimers();
    animationController.dispose();
    disabledAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.onPressed == null ? disabledScaleAnimation : scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onPressed == null) {
            disabledAnimationController.forward();
          } else {
            animationController.forward();
            if (widget.onLongPressed != null) {
              longPressTimer = Timer(const Duration(milliseconds: 400), () {
                HapticFeedback.heavyImpact();
                isLongPressing = true;
                widget.onLongPressed?.call();
                repeatTimer = Timer.periodic(
                  const Duration(milliseconds: 250),
                  (_) {
                    HapticFeedback.heavyImpact();
                    widget.onLongPressed?.call();
                  },
                );
              });
            }
          }
        },
        onTapUp: (_) async {
          cancelTimers();
          if (widget.onPressed == null) {
            disabledAnimationController.reverse();
          } else {
            if (mounted && !isLongPressing) {
              HapticFeedback.selectionClick();
              widget.onPressed?.call();
            }
            isLongPressing = false;
            await Future.delayed(const Duration(milliseconds: 100));
            await animationController.reverse();
          }
        },
        onTapCancel: () {
          isLongPressing = false;
          cancelTimers();
          animationController.reverse();
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.onPressed == null ? Colors.grey : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildIcon(),
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

  Widget buildIcon() {
    final icon = Icon(widget.icon, size: 26, color: Colors.black);

    if (!widget.showAddBadge) return icon;

    final backgroundColor = widget.onPressed == null
        ? Colors.grey
        : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -5,
          right: -6,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_circle,
              size: 15,
              color: Colors.black,
              weight: 200,
            ),
          ),
        ),
      ],
    );
  }

  void cancelTimers() {
    longPressTimer?.cancel();
    longPressTimer = null;
    repeatTimer?.cancel();
    repeatTimer = null;
  }
}
