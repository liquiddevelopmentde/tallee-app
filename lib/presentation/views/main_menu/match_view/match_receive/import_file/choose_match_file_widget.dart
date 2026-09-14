import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class ChooseMatchFileWidget extends StatelessWidget {
  const ChooseMatchFileWidget({required this.loc, this.lastResult, super.key});

  final AppLocalizations loc;
  final ImportResult? lastResult;

  @override
  Widget build(BuildContext context) {
    String title = loc.choose_match_file;
    String? description;
    if (lastResult != null &&
        lastResult != ImportResult.success &&
        lastResult != ImportResult.canceled) {
      title = loc.error_reading_file;
      description = translateMatchImportResultToString(lastResult!, context);
    }

    return Column(
      spacing: 20,
      key: const ValueKey('choose_match_file'),
      children: [
        const Icon(Icons.file_present, size: 50),
        Column(
          spacing: 14,
          children: [
            Column(
              spacing: 4,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.visible,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
                if (description != null)
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.visible,
                    ),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            Text(
              loc.tap_to_browse,
              style: TextStyle(
                color: CustomTheme.textColor.withAlpha(180),
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ],
        ),
      ],
    );
  }
}
