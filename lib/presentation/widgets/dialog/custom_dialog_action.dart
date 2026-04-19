import 'package:flutter/cupertino.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';

class CustomDialogAction extends StatelessWidget {
  /// A custom dialog action widget that represents a button in a dialog.
  /// - [text]: The text to be displayed on the button.
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  const CustomDialogAction({
    super.key,
    required this.onPressed,
    required this.text,
    this.buttonType = ButtonType.primary,
  });

  final String text;

  final ButtonType buttonType;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedDialogButton(
      onPressed: onPressed,
      buttonText: text,
      buttonType: buttonType,
      buttonConstraints: const BoxConstraints(minWidth: 300),
    );
  }
}
