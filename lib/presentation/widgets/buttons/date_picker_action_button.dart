import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';

class DatePickerActionButton extends StatefulWidget {
  const DatePickerActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  State<DatePickerActionButton> createState() => _DatePickerActionButtonState();
}

class _DatePickerActionButtonState extends State<DatePickerActionButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final textColor = isDisabled
        ? context.talleeColors.hintColor
        : widget.isPrimary
        ? Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white
        : context.talleeColors.textColor;
    final buttonType = widget.isPrimary
        ? ButtonType.primary
        : ButtonType.secondary;
    final backgroundColor = isDisabled
        ? context.talleeColors.onBoxColor
        : widget.isPrimary
        ? AppColors.primaryColor
        : Colors.transparent;

    return IgnorePointer(
      ignoring: isDisabled,
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onPressed?.call();
        },
        child: AnimatedScale(
          scale: isPressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 100),
          child: AnimatedOpacity(
            opacity: isPressed ? 0.6 : 1,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 50),
              decoration: BoxDecoration(
                color: buttonType == ButtonType.primary
                    ? backgroundColor
                    : null,
                border: buttonType == ButtonType.secondary
                    ? Border.all(
                        color: isDisabled
                            ? context.talleeColors.hintColor
                            : context.talleeColors.textColor,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
