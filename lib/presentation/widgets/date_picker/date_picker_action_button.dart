import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_colors.dart';

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

  bool get isDisabled => widget.onPressed == null;

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  BoxDecoration get buttonDecoration {
    if (widget.isPrimary) {
      return BoxDecoration(
        color: isDisabled
            ? context.talleeColors.onBoxColor
            : isDarkMode
            ? Colors.white
            : Colors.black,
        borderRadius: AppColors.standardBorderRadiusAll,
      );
    }
    return BoxDecoration(
      border: Border.all(
        color: isDisabled
            ? context.talleeColors.hintColor
            : context.talleeColors.textColor,
        width: 1.5,
      ),
      borderRadius: AppColors.standardBorderRadiusAll,
    );
  }

  TextStyle get textStyle {
    late final Color textColor;
    if (isDisabled) {
      textColor = context.talleeColors.hintColor;
    } else if (widget.isPrimary) {
      textColor = isDarkMode ? Colors.black : Colors.white;
    } else {
      textColor = context.talleeColors.textColor;
    }
    return TextStyle(
      color: textColor,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
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
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            decoration: buttonDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              widget.text,
              style: textStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ),
  );
}
