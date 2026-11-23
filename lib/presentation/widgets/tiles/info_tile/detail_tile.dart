import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';

class DetailTile extends StatelessWidget {
  /// Creates a detail tile with plain text values.
  ///
  /// Each row is a `({label, value})` record. While [isLoading] is true, all
  /// values are shown as skeletons.
  DetailTile({
    super.key,
    required List<({String label, String value})> rows,
    this.isLoading = false,
  }) : rows = [
         for (final (:label, :value) in rows)
           (label: label, value: TextSpan(text: value)),
       ];

  /// Creates a detail tile whose values can be styled individually.
  ///
  /// Each row is a `({label, value})` record. While [isLoading] is true, all
  /// values are shown as skeletons.
  const DetailTile.rich({
    super.key,
    required this.rows,
    this.isLoading = false,
  });

  final List<({String label, InlineSpan value})> rows;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return InfoTile(
      title: loc.statistics,
      leadingWidget: const Icon(Icons.bar_chart),
      content: AppSkeleton(
        enabled: isLoading,
        fixLayoutBuilder: true,
        child: Column(
          children: [
            for (final (:label, :value) in rows)
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
