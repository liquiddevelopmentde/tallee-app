import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({super.key, required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return InfoTile(
      title: loc.statistics,
      leadingWidget: const Icon(Icons.bar_chart),
      content: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.talleeColors.textColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
