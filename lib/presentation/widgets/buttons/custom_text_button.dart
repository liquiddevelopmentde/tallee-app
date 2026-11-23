import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';

/// A custom text button widget.
/// - [onPressed]: Callback invoked when the button is pressed.
/// - [text]: The text displayed on the button.
/// - [style]: Optional style for the text.
class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
  });

  final VoidCallback? onPressed;

  final String text;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed != null
        ? () {
            Haptics.lightImpact();
            onPressed!.call();
          }
        : null,
    child: Text(
      text,
      style: style ?? TextStyle(color: context.talleeColors.textColor),
    ),
  );
}
