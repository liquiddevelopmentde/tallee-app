import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/enums.dart';

class ApiActionAnimatedButton extends StatefulWidget {
  /// A button specifically designed for asynchronous requests.
  /// - [onPressed]: The async callback that triggers the API request. Pass `null` to disable the button.
  /// - [text]: The text of the button.
  /// - [buttonConstraints]: Optional constraints to control the button's size, only works if [sizeRelativeToWidth] is not provided.
  /// - [sizeRelativeToWidth]: Optional size of the button relative to the width of the screen.
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [isDestructive]: A boolean to indicate if the button represents a destructive action, affecting its styling.
  const ApiActionAnimatedButton({
    super.key,
    required this.onPressed,
    this.text,
    this.buttonConstraints,
    this.sizeRelativeToWidth,
    this.buttonType = ButtonType.primary,
    this.isDestructive = false,
  });

  /// Expects a Future to handle the API request duration. If null, the button is disabled.
  final Future<void> Function()? onPressed;

  final String? text;

  final BoxConstraints? buttonConstraints;

  final double? sizeRelativeToWidth;

  final ButtonType buttonType;

  final bool isDestructive;

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
    final isDisabled = widget.onPressed == null;

    return Center(
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: ScaleTransition(
            scale: isDisabled ? disabledScaleAnimation : scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) {
                if (isDisabled) {
                  disabledAnimationController.forward();
                } else if (buttonState == ApiButtonState.idle) {
                  animationController.forward();
                }
              },
              onTapUp: (_) {
                if (isDisabled) {
                  disabledAnimationController.reverse();
                } else {
                  handlePress();
                }
              },
              onTapCancel: () {
                if (isDisabled) {
                  disabledAnimationController.reverse();
                } else if (buttonState == ApiButtonState.idle) {
                  animationController.reverse();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: widget.sizeRelativeToWidth == null
                    ? widget.buttonConstraints
                    : BoxConstraints(
                        minWidth:
                            MediaQuery.sizeOf(context).width *
                            widget.sizeRelativeToWidth!,
                        minHeight: 50,
                      ),
                decoration: _getButtonDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    final textStyle = _getTextStyling();
    final contentColor = textStyle.color ?? Colors.black;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: buttonState == ApiButtonState.idle ? 1.0 : 0.0,
          child: Text(
            widget.text ?? '',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: buttonState == ApiButtonState.loading ? 1.0 : 0.0,
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              color: contentColor,
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

        // Fire and forget reset
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              buttonState = ApiButtonState.idle;
            });
          }
        });
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

  TextStyle _getTextStyling() {
    late Color textColor;
    if (widget.buttonType == ButtonType.primary) {
      textColor = widget.isDestructive ? Colors.white : Colors.black;
    } else if (widget.buttonType == ButtonType.secondary) {
      textColor = widget.isDestructive ? Colors.red : Colors.white;
    } else {
      textColor = widget.isDestructive ? Colors.red : Colors.white;
    }

    return TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  BoxDecoration _getButtonDecoration() {
    if (widget.buttonType == ButtonType.primary) {
      return BoxDecoration(
        color: buttonState == ApiButtonState.loading
            ? Colors.grey[200]
            : (widget.isDestructive ? Colors.red : Colors.white),
        borderRadius: BorderRadius.circular(12),
      );
    } else if (widget.buttonType == ButtonType.secondary) {
      return BoxDecoration(
        border: Border.all(
          color: widget.isDestructive ? Colors.red : Colors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }
    return const BoxDecoration();
  }
}
