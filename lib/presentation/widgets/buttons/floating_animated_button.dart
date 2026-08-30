import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingAnimatedButton extends StatefulWidget {
  /// A button for the main menu with an optional icon and a press animation.
  /// - [onPressed]: The callback to be invoked when the button is pressed.
  /// - [icon]: The icon of the button.
  /// - [text]: The text of the button.
  const FloatingAnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.text,
    this.onLongPressed,
  });

  /// The callback to be invoked when the button is pressed.
  final void Function()? onPressed;

  /// The icon of the button.
  final IconData icon;

  /// The text of the button.
  final String? text;

  final void Function()? onLongPressed;

  @override
  State<FloatingAnimatedButton> createState() => _FloatingAnimatedButtonState();
}

class _FloatingAnimatedButtonState extends State<FloatingAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _disabledAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _disabledScaleAnimation;

  /// How long the button needs to be pressed to register it as long press
  Timer? _longPressTimer;

  /// How much time between two onLongPressed calls
  Timer? _repeatTimer;

  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _disabledAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _disabledScaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _disabledAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.onPressed == null
          ? _disabledScaleAnimation
          : _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onPressed == null) {
            _disabledAnimationController.forward();
          } else {
            _animationController.forward();
            if (widget.onLongPressed != null) {
              _longPressTimer = Timer(
                const Duration(milliseconds: 400),
                () async {
                  _isLongPressing = true;
                  widget.onLongPressed?.call();
                  HapticFeedback.heavyImpact();
                  _repeatTimer = Timer.periodic(
                    const Duration(milliseconds: 250),
                    (_) async {
                      widget.onLongPressed?.call();
                      HapticFeedback.heavyImpact();
                    },
                  );
                },
              );
            }
          }
        },
        onTapUp: (_) async {
          if (widget.onPressed == null) {
            _disabledAnimationController.reverse();
          } else {
            _cancelTimers();
            if (mounted && !_isLongPressing) {
              HapticFeedback.selectionClick();
              widget.onPressed?.call();
            }
            _isLongPressing = false;
            await Future.delayed(const Duration(milliseconds: 100));
            await _animationController.reverse();
          }
        },
        onTapCancel: () {
          _isLongPressing = false;
          _cancelTimers();
          _animationController.reverse();
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
    _cancelTimers();
    _animationController.dispose();
    _disabledAnimationController.dispose();
    super.dispose();
  }

  void _cancelTimers() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }
}
