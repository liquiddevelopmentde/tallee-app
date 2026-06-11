import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';

class CustomDialogAction extends StatelessWidget {
  /// A custom dialog action widget that represents a button in a dialog.
  /// - [text]: The text to be displayed on the button.
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  const CustomDialogAction({
    super.key,
    this.onPressed,
    required this.text,
    this.buttonType = ButtonType.primary,
    this.isDestructive = false,
  });

  final String text;

  final ButtonType buttonType;

  final VoidCallback? onPressed;

  final bool isDestructive;
  @override
  Widget build(BuildContext context) {
    return BottomAnimatedButton(
      onPressed: onPressed != null
          ? () async {
              await HapticFeedback.selectionClick();
              onPressed?.call();
            }
          : null,
      buttonText: text,
      buttonType: buttonType,
      isDescructive: isDestructive,
      buttonConstraints: const BoxConstraints(minWidth: 300),
    );
  }
}
