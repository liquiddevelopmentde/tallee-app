import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/enums.dart';

class ApiActionAnimatedButton extends StatefulWidget {
  /// A button specifically designed for asynchronous requests.
  /// - [onPressed]: The async callback that triggers the API request. Pass `null` to disable the button.
  /// - [icon]: The initial icon of the button.
  /// - [text]: The initial text of the button.
  const ApiActionAnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.text,
  });

  /// Expects a Future to handle the API request duration. If null, the button is disabled.
  final Future<void> Function()? onPressed;

  final IconData icon;
  final String? text;

  @override
  State<ApiActionAnimatedButton> createState() =>
      ApiActionAnimatedButtonState();
}

class ApiActionAnimatedButtonState extends State<ApiActionAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController disabledAnimationController;

  late Animation<double> scaleAnimation;
  late Animation<double> disabledScaleAnimation;

  ApiButtonState buttonState = ApiButtonState.idle;

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
  void dispose() {
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
          } else if (buttonState == ApiButtonState.idle) {
            animationController.forward();
          }
        },
        onTapUp: (_) {
          if (widget.onPressed == null) {
            disabledAnimationController.reverse();
          } else {
            handlePress();
          }
        },
        onTapCancel: () {
          if (widget.onPressed == null) {
            disabledAnimationController.reverse();
          } else if (buttonState == ApiButtonState.idle) {
            animationController.reverse();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: buttonState == ApiButtonState.idle ? 1.0 : 0.0,
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

        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: buttonState == ApiButtonState.loading ? 1.0 : 0.0,
          child: const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2.5,
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: buttonState == ApiButtonState.success ? 1.0 : 0.0,
          child: const Icon(Icons.check, size: 26, color: Colors.green),
        ),

        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: buttonState == ApiButtonState.error ? 1.0 : 0.0,
          child: const Icon(Icons.close, size: 26, color: Colors.red),
        ),
      ],
    );
  }

  Future<void> handlePress() async {
    if (widget.onPressed == null) return;
    if (buttonState != ApiButtonState.idle) return;

    await HapticFeedback.selectionClick();
    animationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    animationController.reverse();

    setState(() {
      buttonState = ApiButtonState.loading;
    });

    try {
      await widget.onPressed!();

      if (mounted) {
        setState(() {
          buttonState = ApiButtonState.success;
        });
        await HapticFeedback.heavyImpact();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            buttonState = ApiButtonState.idle;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          buttonState = ApiButtonState.error;
        });

        await HapticFeedback.heavyImpact();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            buttonState = ApiButtonState.idle;
          });
        }
      }
    }
  }

  Color getBackgroundColor() {
    if (widget.onPressed == null) return Colors.grey;
    if (buttonState == ApiButtonState.loading) return Colors.grey[200]!;
    return Colors.white;
  }
}
