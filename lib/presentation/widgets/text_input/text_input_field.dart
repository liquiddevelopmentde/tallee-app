import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

class TextInputField extends StatelessWidget {
  /// A custom text input field widget that encapsulates a [TextField] with specific styling.
  /// - [controller]: The controller for the text input field.
  /// - [onChanged]: Optional callback invoked when the text in the field changes.
  /// - [hintText]: The hint text displayed in the text input field when it is empty
  /// - [maxLength]: Optional parameter for maximum length of the input text.
  /// - [maxLines]: The maximum number of lines for the text input field. Defaults to 1.
  /// - [minLines]: The minimum number of lines for the text input field. Defaults to 1.
  /// - [showCounterText]: Whether to show the counter text in the text input field. Defaults to false.
  /// - [textInputAction]: Optional action button shown on the keyboard.
  const TextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.showCounterText = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool showCounterText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: textInputAction,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: CustomTheme.boxColor,
        hintText: hintText,
        counterText: showCounterText ? null : '',
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: CustomTheme.boxBorderColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: CustomTheme.boxBorderColor),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
