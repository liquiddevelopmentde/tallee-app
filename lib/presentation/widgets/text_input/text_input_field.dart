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
  /// - [keyboardType]: Optional keyboard type, e.g. for numeric input.
  /// - [inputFormatters]: Optional input formatters applied to the field.
  /// - [autofocus]: Whether the field should autofocus. Defaults to false.
  /// - [focusNode]: Optional focus node for managing focus of the text input field.
  /// - [onSubmitted]: Optional callback invoked when the user submits the field.
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
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool showCounterText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      maxLines: maxLines,
      minLines: minLines,
      focusNode: focusNode,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: CustomTheme.onBoxColor,
        hintText: hintText,
        counter: showCounterText ? null : const SizedBox.shrink(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
