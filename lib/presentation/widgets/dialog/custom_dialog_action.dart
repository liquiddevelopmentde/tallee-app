import 'package:flutter/cupertino.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/presentation/widgets/dialog/animated_dialog_button.dart';

class CustomDialogAction extends StatelessWidget {
  const CustomDialogAction({
    super.key,
    required this.onPressed,
    required this.text,
    this.buttonType = ButtonType.primary,
  });

  // The text displaed on the button
  final String text;

  // The type of the button, which determines its styling
  final ButtonType buttonType;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedDialogButton(
      onPressed: onPressed,
      text: text,
      buttonType: buttonType,
    );
  }
}
