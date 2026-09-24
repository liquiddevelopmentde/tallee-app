import 'package:flutter/cupertino.dart';
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
    this.isEmphasized = false,
  });

  final String text;
  final ButtonType buttonType;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return BottomAnimatedButton(
      onPressed: onPressed != null
          ? () {
              onPressed?.call();
            }
          : null,
      buttonText: text,
      buttonType: buttonType,
      isDestructive: isDestructive,
      isEmphasized: isEmphasized,
      buttonConstraints: const BoxConstraints(minWidth: 300),
    );
  }
}
