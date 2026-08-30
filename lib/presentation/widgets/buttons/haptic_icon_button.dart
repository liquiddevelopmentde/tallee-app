import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticIconButton extends StatefulWidget {
  const HapticIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.padding,
    this.margin,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  State<StatefulWidget> createState() => _HapticIconButtonState();
}

class _HapticIconButtonState extends State<HapticIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.6,
      upperBound: 1.0,
      value: 1.0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: FadeTransition(
        opacity: controller,
        child: GestureDetector(
          onTapDown: isEnabled ? (_) => handleTapDown() : null,
          onTapUp: isEnabled ? (_) => handleRelease() : null,
          onTapCancel: isEnabled ? () => handleRelease() : null,
          onTap: isEnabled
              ? () {
                  HapticFeedback.selectionClick();
                  widget.onPressed!.call();
                }
              : null,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(8.0),
            margin: widget.margin,
            child: widget.icon,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleTapDown() {
    controller.reverse();
  }

  Future<void> handleRelease() async {
    await controller.reverse();
    await controller.forward();
  }
}
