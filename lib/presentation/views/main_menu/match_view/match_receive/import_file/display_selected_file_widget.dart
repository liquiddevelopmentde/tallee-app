import 'package:flutter/cupertino.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/file_tile.dart';

class DisplaySelectedFileWidget extends StatelessWidget {
  const DisplaySelectedFileWidget({
    required this.match,
    super.key,
    this.fileName,
  });

  final Match match;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    print('DisplaySelectedFile: match=${match.name}, fileName=$fileName');

    return Column(
      key: const ValueKey('display_selected_file'),
      children: [
        MatchFileTile(
          match: match,
          fileName: fileName,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        ),
        const SizedBox(height: 20),
        Text(
          loc.successfully_processed_file,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.visible,
          ),
          softWrap: true,
        ),
        const SizedBox(height: 5),
        Text(
          loc.tap_import_to_continue,
          style: TextStyle(
            color: CustomTheme.textColor.withAlpha(180),
            fontSize: 14,
            overflow: TextOverflow.visible,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ],
    );
  }
}
