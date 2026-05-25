import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/statistics_view/create_statistic_view.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/statistics_tile.dart';

class StatisticDetailView extends StatefulWidget {
  const StatisticDetailView({
    super.key,
    required this.statistic,
    required this.values,
    required this.icon,
    required this.barColor,
  });

  final Statistic statistic;
  final List<(Player, num)> values;
  final IconData icon;
  final Color barColor;

  @override
  State<StatisticDetailView> createState() => _StatisticDetailViewState();
}

class _StatisticDetailViewState extends State<StatisticDetailView> {
  late int displayCount;

  @override
  void initState() {
    super.initState();
    displayCount = widget.statistic.displayCount;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = translateStatisticTypeToString(
      widget.statistic.type,
      context,
    );
    const style = TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: HapticIconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => handleBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            StatisticsTile(
              icon: widget.icon,
              title: title,
              width: MediaQuery.sizeOf(context).width * 0.95,
              values: widget.values,
              barColor: widget.barColor,
              selectedGroups: widget.statistic.selectedGroups,
              selectedGames: widget.statistic.selectedGames,
            ),
            const SizedBox(height: 12),

            InfoTile(
              icon: Icons.filter_alt,
              title: loc.filter,
              content: Column(
                spacing: 12,

                children: [
                  // Scopes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.scope, style: style),
                      Text(
                        widget.statistic.scopes
                            .map(
                              (scope) => translateScopeToString(scope, context),
                            )
                            .join('\n'),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),

                  // Timeframe
                  if (widget.statistic.timeframe != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.timeframe, style: style),
                        Text(
                          translateTimeframeToString(
                            widget.statistic.timeframe!,
                            context,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),

                  // Groups
                  if (widget.statistic.selectedGroups != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.groups, style: style),
                        Text(
                          widget.statistic.selectedGroups!
                              .map((group) => group.name)
                              .join('\n'),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),

                  // Games
                  if (widget.statistic.selectedGames != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.games, style: style),
                        Text(
                          widget.statistic.selectedGames!
                              .map((game) => game.name)
                              .join('\n'),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),

                  if (widget.values.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.displayed_entries, style: style),
                        Row(
                          children: [
                            HapticIconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: displayCount <= 1
                                  ? null
                                  : () => setState(() => displayCount -= 1),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                '$displayCount',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            HapticIconButton(
                              icon: const Icon(Icons.add),
                              onPressed: displayCount >= widget.values.length
                                  ? null
                                  : () => setState(() => displayCount += 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handles saving the display count and giving it to statistics view
  Future<void> handleBack(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.statisticDao.updateDisplayCount(widget.statistic.id, displayCount);
    if (context.mounted) Navigator.of(context).pop(displayCount);
  }
}
