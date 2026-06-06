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
  const TextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.showCounterText = false,
  });

  /// The controller for the text input field.
  final TextEditingController controller;

  /// Optional callback invoked when the text in the field changes.
  final ValueChanged<String>? onChanged;

  /// The hint text displayed in the text input field when it is empty.
  final String hintText;

  /// Optional parameter for maximum length of the input text.
  final int? maxLength;

  /// The maximum number of lines for the text input field.
  final int? maxLines;

  /// The minimum number of lines for the text input field.
  final int? minLines;

  /// Whether to show the counter text in the text input field.
  final bool showCounterText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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
