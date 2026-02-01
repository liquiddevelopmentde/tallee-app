import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

class TextInputField extends StatelessWidget {
  /// A custom text input field widget that encapsulates a [TextField] with specific styling.
  /// - [controller]: The controller for the text input field.
  /// - [onChanged]: Optional callback invoked when the text in the field changes.
  /// - [hintText]: The hint text displayed in the text input field when it is empty
  /// - [maxLength]: Optional parameter for maximum length of the input text.
  const TextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.maxLength,
  });

  /// The controller for the text input field.
  final TextEditingController controller;

  /// Optional callback invoked when the text in the field changes.
  final ValueChanged<String>? onChanged;

  /// The hint text displayed in the text input field when it is empty.
  final String hintText;

  /// Optional parameter for maximum length of the input text.
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      decoration: InputDecoration(
        filled: true,
        fillColor: CustomTheme.boxColor,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 18),
        // Hides the character counter
        counterText: '',
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: CustomTheme.boxBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: CustomTheme.boxBorder),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
