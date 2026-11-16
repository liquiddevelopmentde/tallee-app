import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';

class DetailTile extends StatelessWidget {
  /// Creates a detail tile with plain text values.
  ///
  /// Each row is a `({label, value, isLoading})` record; `isLoading` shows the
  /// value as a skeleton while it is still being loaded.
  DetailTile({
    super.key,
    required List<({String label, String value, bool isLoading})> rows,
  }) : rows = [
         for (final (:label, :value, :isLoading) in rows)
           (label: label, value: TextSpan(text: value), isLoading: isLoading),
       ];

  /// Creates a detail tile whose values can be styled individually.
  ///
  /// Each row is a `({label, value, isLoading})` record; `isLoading` shows the
  /// value as a skeleton while it is still being loaded.
  const DetailTile.rich({super.key, required this.rows});

  final List<({String label, InlineSpan value, bool isLoading})> rows;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return InfoTile(
      title: loc.statistics,
      leadingWidget: const Icon(Icons.bar_chart),
      content: Column(
        children: [
          for (final (:label, :value, :isLoading) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.talleeColors.textColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppSkeleton(
                      enabled: isLoading,
                      fixLayoutBuilder: true,
                      alignment: Alignment.centerRight,
                      child: Text.rich(
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
