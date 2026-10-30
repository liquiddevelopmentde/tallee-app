import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

export 'custom_dialog_action.dart';

class CustomAlertDialog extends StatelessWidget {
  /// A custom alert dialog widget that provides a os unspecific AlertDialog,
  /// with consistent colors, borders, and layout that match the app's custom theme.
  /// - [title]: The title text displayed at the top of the dialog.
  /// - [content]: The main content text displayed in the body of the dialog.
  /// - [actions]: A list of action widgets (typically buttons) displayed at the bottom
  ///   of the dialog. These actions are horizontally spaced around the dialog's width.
  /// - [showCloseButton]: Whether to show a close (X) button in the top right corner.
  /// - [closeButtonColor]: Optional custom color for the close button.
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.showCloseButton = false,
    this.closeButtonColor,
  }) : assert(
         closeButtonColor == null || showCloseButton,
         'closeButtonColor requires showCloseButton to be true',
       );

  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showCloseButton;
  final Color? closeButtonColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: showCloseButton
          ? const EdgeInsets.only(left: 24.0, top: 12.0, right: 12.0)
          : null,
      title: showCloseButton
          ? Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.talleeColors.textColor,
                      ),
                    ),
                  ),
                  HapticCloseButton(color: closeButtonColor),
                ],
              ),
            )
          : Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.talleeColors.textColor,
              ),
            ),
      content: content,
      actions: actions,
      backgroundColor: context.talleeColors.boxColor,
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: AppColors.standardBorderRadiusAll,
        side: BorderSide(color: context.talleeColors.boxBorderColor),
      ),
    );
  }
}
