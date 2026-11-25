import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/core/theme/app_spacing.dart';

class ApiActionAnimatedButton extends StatefulWidget {
  /// A button specifically designed for asynchronous requests.
  /// - [onPressed]: The callback that triggers the action. Pass `null` to disable the button.
  /// - [status]: The current state of the button, controlled by the parent.
  /// - [text]: The text of the button.
  /// - [buttonConstraints]: Optional constraints to control the button's size. Mutually exclusive with [sizeRelativeToWidth].
  /// - [sizeRelativeToWidth]: Minimum width of the button relative to the screen width. Defaults to [AppSpacing.contentWidthFactor].
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [isDestructive]: A boolean to indicate if the button represents a destructive action, affecting its styling.
  const ApiActionAnimatedButton({
    super.key,
    required this.onPressed,
    required this.status,
    this.text,
    this.buttonConstraints,
    this.sizeRelativeToWidth,
    this.buttonType = ButtonType.primary,
    this.isDestructive = false,
  }) : assert(
         sizeRelativeToWidth == null || buttonConstraints == null,
         'sizeRelativeToWidth and buttonConstraints can\'t be simultaneously set',
       ),
       assert(
         sizeRelativeToWidth == null ||
             (sizeRelativeToWidth > 0 && sizeRelativeToWidth <= 1),
         'sizeRelativeToWidth must be 0 < size <= 1',
       );

  final VoidCallback? onPressed;
  final ApiButtonState status;
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

  bool isPressing = false;

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
  void didUpdateWidget(covariant ApiActionAnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status &&
        (widget.status == ApiButtonState.success ||
            widget.status == ApiButtonState.error)) {
      Haptics.heavyImpact();
    }
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
    final isBlocked = isDisabled || widget.status != ApiButtonState.idle;

    return Center(
      child: IgnorePointer(
        ignoring: isBlocked,
        child: Opacity(
          opacity: 1.0,
          child: ScaleTransition(
            scale: isDisabled ? disabledScaleAnimation : scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) {
                if (isDisabled) {
                  disabledAnimationController.forward();
                } else if (widget.status == ApiButtonState.idle &&
                    !isPressing) {
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
                } else if (widget.status == ApiButtonState.idle) {
                  animationController.reverse();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints:
                    widget.buttonConstraints ??
                    BoxConstraints(
                      minWidth:
                          MediaQuery.sizeOf(context).width *
                          (widget.sizeRelativeToWidth ??
                              AppSpacing.contentWidthFactor),
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
          opacity: widget.status == ApiButtonState.idle ? 1.0 : 0.0,
          child: Text(
            widget.text ?? '',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.status == ApiButtonState.loading ? 1.0 : 0.0,
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
          opacity: widget.status == ApiButtonState.success ? 1.0 : 0.0,
          child: Icon(
            Icons.check,
            size: 26,
            color: context.talleeColors.successColor,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.status == ApiButtonState.error ? 1.0 : 0.0,
          child: Icon(
            Icons.close,
            size: 26,
            color: context.talleeColors.errorColor,
          ),
        ),
      ],
    );
  }

  Future<void> handlePress() async {
    if (widget.onPressed == null ||
        widget.status != ApiButtonState.idle ||
        isPressing) {
      return;
    }

    isPressing = true;
    Haptics.selectionClick();
    animationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    animationController.reverse();
    widget.onPressed!.call();
    isPressing = false;
  }

  TextStyle _getTextStyling() {
    late Color textColor;
    if (widget.onPressed == null) {
      return TextStyle(
        color: context.talleeColors.hintColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
    }
    if (widget.buttonType == ButtonType.primary) {
      textColor = widget.isDestructive
          ? Colors.white
          : context.isDarkMode
          ? Colors.black
          : Colors.white;
    } else if (widget.buttonType == ButtonType.secondary) {
      textColor = widget.isDestructive
          ? context.talleeColors.errorColor
          : context.talleeColors.textColor;
    } else {
      textColor = widget.isDestructive
          ? context.talleeColors.errorColor
          : context.talleeColors.textColor;
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
        color: widget.status == ApiButtonState.loading
            ? context.talleeColors.onBoxColor
            : widget.onPressed == null
            ? context.talleeColors.onBoxColor
            : widget.isDestructive
            ? context.talleeColors.errorColor
            : context.isDarkMode
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(12),
      );
    } else if (widget.buttonType == ButtonType.secondary) {
      return BoxDecoration(
        border: Border.all(
          color: widget.onPressed == null
              ? context.talleeColors.hintColor
              : widget.isDestructive
              ? context.talleeColors.errorColor
              : context.talleeColors.textColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }
    return const BoxDecoration();
  }
}
