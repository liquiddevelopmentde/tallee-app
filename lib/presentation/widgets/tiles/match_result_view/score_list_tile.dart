import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class ScoreListTile extends StatelessWidget {
  /// A custom list tile widget that has a text field for inputting a score.
  /// - [text]: The leading text to be displayed.
  /// - [controller]: The controller for the text field to input the score.
  const ScoreListTile({
    super.key,
    required this.text,
    required this.controller,
  });

  /// The text to display next to the radio button.
  final String text;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: CustomTheme.boxColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: 100,
            height: 40,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              maxLength: 5,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return isValidScoreInput(newValue.text) ? newValue : oldValue;
                }),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CustomTheme.textColor,
              ),
              cursorColor: CustomTheme.textColor,
              decoration: InputDecoration(
                hintText: loc.points,
                counterText: '',
                filled: true,
                fillColor: CustomTheme.onBoxColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: CustomTheme.textColor.withAlpha(250),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: CustomTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Validates the input for the score text field.
  bool isValidScoreInput(String text) {
    if (text.isEmpty || text == '-') {
      return true;
    }

    final isNegative = text.startsWith('-');
    final digits = isNegative ? text.substring(1) : text;

    if (digits.isEmpty || digits.length > 4) {
      return false;
    }

    // CHeck if all characters are digits 0 <= x <= 9
    return digits.codeUnits.every((unit) => unit >= 48 && unit <= 57);
  }
}
