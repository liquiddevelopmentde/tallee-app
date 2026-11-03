import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class CustomDialogAction extends StatelessWidget {
  /// A custom dialog action widget that represents a button in a dialog.
  /// - [text]: The text to be displayed on the button.
  /// - [buttonType]: The type of the button, which determines its styling.
  /// - [onPressed]: Callback function that is triggered when the button is pressed.
  /// - [accent]: The accent color of the button, e.g. for destructive or emphasized actions.
  const CustomDialogAction({
    super.key,
    this.onPressed,
    required this.text,
    this.buttonType = ButtonType.primary,
    this.accent = ButtonAccent.neutral,
  });

  final String text;
  final ButtonType buttonType;
  final VoidCallback? onPressed;
  final ButtonAccent accent;

  @override
  Widget build(BuildContext context) => BottomAnimatedButton(
    onPressed: onPressed != null
        ? () {
            onPressed?.call();
          }
        : null,
    buttonText: text,
    buttonType: buttonType,
    accent: accent,
    buttonConstraints: const BoxConstraints(minWidth: 300),
  );
}
