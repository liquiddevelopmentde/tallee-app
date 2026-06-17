import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ApiButtonState { idle, loading, success, error }

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
      _ApiActionAnimatedButtonState();
}

class _ApiActionAnimatedButtonState extends State<ApiActionAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _disabledAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _disabledScaleAnimation;

  ApiButtonState _buttonState = ApiButtonState.idle;

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

  Future<void> _handlePress() async {
    if (widget.onPressed == null) return;
    if (_buttonState != ApiButtonState.idle) return;

    await HapticFeedback.selectionClick();
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _animationController.reverse();

    setState(() {
      _buttonState = ApiButtonState.loading;
    });

    try {
      await widget.onPressed!();

      if (mounted) {
        setState(() {
          _buttonState = ApiButtonState.success;
        });
        await HapticFeedback.heavyImpact();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _buttonState = ApiButtonState.idle;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _buttonState = ApiButtonState.error;
        });

        await HapticFeedback.heavyImpact();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _buttonState = ApiButtonState.idle;
          });
        }
      }
    }
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null) return Colors.grey;
    if (_buttonState == ApiButtonState.loading) return Colors.grey[200]!;
    return Colors.white;
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
          } else if (_buttonState == ApiButtonState.idle) {
            _animationController.forward();
          }
        },
        onTapUp: (_) {
          if (widget.onPressed == null) {
            _disabledAnimationController.reverse();
          } else {
            _handlePress();
          }
        },
        onTapCancel: () {
          if (widget.onPressed == null) {
            _disabledAnimationController.reverse();
          } else if (_buttonState == ApiButtonState.idle) {
            _animationController.reverse();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _buttonState == ApiButtonState.idle ? 1.0 : 0.0,
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
          opacity: _buttonState == ApiButtonState.loading ? 1.0 : 0.0,
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
          opacity: _buttonState == ApiButtonState.success ? 1.0 : 0.0,
          child: const Icon(Icons.check, size: 26, color: Colors.green),
        ),

        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _buttonState == ApiButtonState.error ? 1.0 : 0.0,
          child: const Icon(Icons.close, size: 26, color: Colors.red),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disabledAnimationController.dispose();
    super.dispose();
  }
}
