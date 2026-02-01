import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomAlertDialog extends StatelessWidget {
  /// A custom alert dialog widget that provides a os unspecific AlertDialog,
  /// with consistent colors, borders, and layout that match the app's custom theme.
  /// - [title]: The title text displayed at the top of the dialog.
  /// - [content]: The main content text displayed in the body of the dialog.
  /// - [actions]: A list of action widgets (typically buttons) displayed at the bottom
  ///   of the dialog. These actions are horizontally spaced around the dialog's width.
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(color: CustomTheme.textColor)),
      content: Text(
        content,
        style: const TextStyle(color: CustomTheme.textColor),
      ),
      actions: actions,
      backgroundColor: CustomTheme.boxColor,
      actionsAlignment: MainAxisAlignment.spaceAround,
      shape: RoundedRectangleBorder(
        borderRadius: CustomTheme.standardBorderRadiusAll,
        side: const BorderSide(color: CustomTheme.boxBorder),
      ),
    );
  }
}
