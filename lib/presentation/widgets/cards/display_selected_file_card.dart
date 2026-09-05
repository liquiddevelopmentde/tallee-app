import 'package:flutter/cupertino.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/file_tile.dart';

class DisplaySelectedFile extends StatelessWidget {
  const DisplaySelectedFile({required this.match, super.key});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      key: const ValueKey('display_selected_file'),
      children: [
        FileTile(
          match: match,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        ),
        const SizedBox(height: 20),
        Text(
          loc.successfully_processed_file,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
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
