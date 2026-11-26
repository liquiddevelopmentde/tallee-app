import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';

class FloatingAnimatedButton extends StatefulWidget {
  /// A button for the main menu with an optional icon and a press animation.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  /// - [icon]: The icon of the button.
  /// - [text]: The text of the button.
  /// - [onLongPressed]: The callback to be invoked when the button is pressed longer
  /// - [compact]: Whether to use reduced padding and content sizing.
  /// - [type]: The button style.
  /// - [textColor]: Optional override for the button label color.
  const FloatingAnimatedButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.text,
    this.onLongPressed,
    this.compact = false,
    this.type = ButtonType.primary,
    this.textColor,
  });

  final void Function()? onPressed;
  final IconData? icon;
  final String? text;
  final void Function()? onLongPressed;
  final bool compact;
  final ButtonType type;
  final Color? textColor;

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
    final baseTextColor = context.talleeColors.textColor;

    final bgColor = isDisabled
        ? Color.lerp(baseTextColor, baseTextColor.contrastTextColor, 0.6)
        : baseTextColor;

    final isSecondary = widget.type == ButtonType.secondary;
    final isTertiary = widget.type == ButtonType.tertiary;
    final fgColor = isDisabled
        ? context.talleeColors.hintColor
        : isSecondary || isTertiary
        ? baseTextColor
        : baseTextColor.contrastTextColor;
    final labelColor = isDisabled
        ? context.talleeColors.hintColor
        : widget.textColor ?? fgColor;
    final borderColor = isDisabled
        ? context.talleeColors.hintColor
        : baseTextColor;
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
            color: isSecondary || isTertiary ? null : bgColor,
            border: isSecondary
                ? Border.all(color: borderColor, width: 2)
                : null,
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
              if (widget.icon != null)
                Icon(widget.icon, size: iconSize, color: fgColor),
              if (widget.text != null) ...[
                if (widget.icon != null) const SizedBox(width: 7),
                Text(
                  widget.text!,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: isTertiary ? FontWeight.w500 : FontWeight.bold,
                    color: labelColor,
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
