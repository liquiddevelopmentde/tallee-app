import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';

class FloatingAnimatedButton extends StatefulWidget {
  /// A button for the main menu with an optional icon and a press animation.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  /// - [icon]: The icon of the button.
  /// - [text]: The text of the button.
  /// - [onLongPressed]: The callback to be invoked when the button is pressed longer
  /// - [compact]: Whether to use reduced padding and content sizing.
  const FloatingAnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.text,
    this.onLongPressed,
    this.compact = false,
  });

  final void Function()? onPressed;
  final IconData icon;
  final String? text;
  final void Function()? onLongPressed;
  final bool compact;

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
    final isDisabled = widget.onPressed == null;
    final textColor = context.talleeColors.textColor;

    final bgColor = isDisabled
        ? Color.lerp(textColor, textColor.contrastTextColor, 0.6)
        : textColor;

    final fgColor = textColor.contrastTextColor;
    final iconSize = widget.compact ? 20.0 : 26.0;
    final horizontalPadding = widget.compact ? 14.0 : 20.0;
    final verticalPadding = widget.compact ? 10.0 : 14.0;
    final textSize = widget.compact ? 16.0 : 18.0;

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
                Haptics.heavyImpact();
                isLongPressing = true;
                widget.onLongPressed?.call();
                repeatTimer = Timer.periodic(
                  const Duration(milliseconds: 250),
                  (_) {
                    Haptics.heavyImpact();
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
              Haptics.selectionClick();
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
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: iconSize, color: fgColor),
              if (widget.text != null) ...[
                const SizedBox(width: 7),
                Text(
                  widget.text!,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    color: fgColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void cancelTimers() {
    longPressTimer?.cancel();
    longPressTimer = null;
    repeatTimer?.cancel();
    repeatTimer = null;
  }
}
