import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/app_spacing.dart';

class BottomAnimatedButton extends StatefulWidget {
  /// A custom animated button widget that provides a scaling and opacity effect
  /// when pressed.
  /// - [buttonText]: The text to be displayed on the button.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  /// - [buttonConstraints]: Optional constraints to control the button's size. Mutually exclusive with [sizeRelativeToWidth].
  /// - [sizeRelativeToWidth]: Minimum width of the button relative to the screen width. Defaults to [AppSpacing.contentWidthFactor].
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [accent]: The accent color of the button, e.g. for destructive or emphasized actions.
  const BottomAnimatedButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.buttonConstraints,
    this.sizeRelativeToWidth,
    this.buttonType = ButtonType.primary,
    this.accent = ButtonAccent.neutral,
  }) : assert(
         sizeRelativeToWidth == null || buttonConstraints == null,
         'sizeRelativeToWidth and buttonConstraints can\'t be simultaneously set',
       ),
       assert(
         sizeRelativeToWidth == null ||
             (sizeRelativeToWidth > 0 && sizeRelativeToWidth <= 1),
         'sizeRelativeToWidth must be 0 < size <= 1',
       );

  final String buttonText;
  final VoidCallback? onPressed;
  final BoxConstraints? buttonConstraints;
  final double? sizeRelativeToWidth;
  final ButtonType buttonType;
  final ButtonAccent accent;

  @override
  State<BottomAnimatedButton> createState() => _BottomAnimatedButtonState();
}

class _BottomAnimatedButtonState extends State<BottomAnimatedButton> {
  bool isPressed = false;

  bool get isDisabled => widget.onPressed == null;

  bool get isDestructive => widget.accent == ButtonAccent.destructive;

  bool get isEmphasized => widget.accent == ButtonAccent.emphasized;

  BoxDecoration get buttonDecoration {
    if (widget.buttonType == ButtonType.primary) {
      // Primary
      return BoxDecoration(
        color: widget.onPressed == null
            ? context.talleeColors.onBoxColor
            : isDestructive
            ? context.talleeColors.errorColor
            : isEmphasized
            ? AppColors.primaryColor
            : context.isDarkMode
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(12),
      );
    } else if (widget.buttonType == ButtonType.secondary) {
      // Secondary
      return BoxDecoration(
        border: BoxBorder.all(
          color: widget.onPressed == null
              ? context.talleeColors.hintColor
              : isDestructive
              ? context.talleeColors.errorColor
              : isEmphasized
              ? AppColors.primaryColor
              : context.talleeColors.textColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }
    // Tertiary
    return const BoxDecoration();
  }

  TextStyle get textStyle {
    late Color textColor;

    if (widget.onPressed == null) {
      return TextStyle(
        color: context.talleeColors.hintColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
    }

    switch (widget.buttonType) {
      case ButtonType.primary:
        textColor = isDestructive || isEmphasized
            ? Colors.white
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white;
        break;
      default:
        if (isDestructive) {
          textColor = context.talleeColors.errorColor;
        } else if (isEmphasized) {
          textColor = AppColors.primaryColor;
        } else {
          textColor = context.talleeColors.textColor;
        }
        break;
    }

    return TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
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
        Haptics.selectionClick();
        if (!isDisabled) {
          widget.onPressed!();
        }
      },
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: isPressed ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: Container(
              constraints:
                  widget.buttonConstraints ??
                  BoxConstraints(
                    minWidth:
                        MediaQuery.sizeOf(context).width *
                        (widget.sizeRelativeToWidth ??
                            AppSpacing.contentWidthFactor),
                    minHeight: 50,
                  ),
              decoration: buttonDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.buttonText,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
