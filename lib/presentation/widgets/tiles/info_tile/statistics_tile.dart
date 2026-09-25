import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/charts/bar_chart.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';

class StatisticsTile extends StatefulWidget {
  /// A tile widget that displays statistical data using horizontal bars.
  /// - [values]: A list of tuples containing labels and their corresponding numeric values.
  /// - [displayCount]:  The number of top values to display in the bar chart.
  /// - [margin]: Optional margin for the tile.
  /// - [width]: Optional width of the tile.
  /// - [showAllValues]: Whether to show all values or limit to [displayCount].
  /// - [showDisplayCountHighlighting]: Whether to highlight entries that exceed the display count.
  const StatisticsTile({
    super.key,
    required this.statistic,
    required this.values,
    required this.displayCount,
    this.margin,
    this.width,
    this.showAllValues = false,
    this.showDisplayCountHighlighting = false,
    this.onStatisticChanged,
  });

  final Statistic statistic;
  final List<(Player, num)> values;
  final int displayCount;
  final EdgeInsets? margin;
  final double? width;
  final bool showAllValues;
  final bool showDisplayCountHighlighting;
  final ValueChanged<String>? onStatisticChanged;

  @override
  State<StatisticsTile> createState() => _StatisticsTileState();
}

class _StatisticsTileState extends State<StatisticsTile> {
  late bool isFavourite;
  late Color barColor;
  late List<Group>? selectedGroups;
  late List<Game>? selectedGames;
  late IconData icon;

  @override
  void initState() {
    isFavourite = widget.statistic.isFavourite;
    barColor = getColorFromAppColor(widget.statistic.color);
    selectedGames = widget.statistic.selectedGames;
    selectedGroups = widget.statistic.selectedGroups;
    icon = getStatisticIcon(type: widget.statistic.type);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant StatisticsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statistic != widget.statistic) {
      isFavourite = widget.statistic.isFavourite;
      barColor = getColorFromAppColor(widget.statistic.color);
      selectedGames = widget.statistic.selectedGames;
      selectedGroups = widget.statistic.selectedGroups;
      icon = getStatisticIcon(type: widget.statistic.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = translateStatisticTypeToString(
      widget.statistic.type,
      context,
    );

    return InfoTile(
      leadingWidget: Icon(icon),
      title: title,
      trailingWidget: Visibility(
        // Only show in statistic view
        visible: !widget.showAllValues,
        child: HapticIconButton(
          padding: EdgeInsets.zero,
          icon: isFavourite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
          onPressed: () => toggleFavourite(),
        ),
      ),
      width: widget.width ?? MediaQuery.sizeOf(context).width * 0.95,
      margin: widget.margin ?? CustomTheme.tileMargin,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // Chart
            BarChart(
              values: widget.values,
              showAllValues: widget.showAllValues,
              displayCount: widget.displayCount,
              showDisplayCountHighlighting: widget.showDisplayCountHighlighting,
              barColor: barColor,
            ),

            // Group & Game info
            if (hasGame || hasGroup)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 30,
                  runSpacing: 4,
                  children: [
                    // Game
                    if (hasGame)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          const Icon(
                            GAME_ICON,
                            color: CustomTheme.hintColor,
                            size: 20,
                          ),
                          Text(
                            getSubtitleText(
                              selectedGames!.map((g) => g.name).toList(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    // Group
                    if (hasGroup)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          const Icon(GROUP_ICON, color: CustomTheme.hintColor),
                          Text(
                            getSubtitleText(
                              selectedGroups!.map((g) => g.name).toList(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
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

  Future<void> toggleFavourite() async {
    final updatedIsFavourite = !isFavourite;
    final db = context.read<AppDatabase>();
    await db.statisticDao.updateIsFavourite(
      widget.statistic.id,
      updatedIsFavourite,
    );
    setState(() {
      isFavourite = updatedIsFavourite;
    });
    widget.onStatisticChanged?.call(widget.statistic.id);
  }

  bool get hasGroup => selectedGroups != null && selectedGroups!.isNotEmpty;

  bool get hasGame => selectedGames != null && selectedGames!.isNotEmpty;

  String getSubtitleText(List<String> names) {
    const maxChars = 40;
    var result = '';
    for (var i = 0; i < names.length; i++) {
      final separator = i == 0 ? '' : ', ';
      final candidate = '$result$separator${names[i]}';
      final remaining = names.length - i - 1;
      final suffix = remaining > 0 ? ' +$remaining' : '';
      if (candidate.length + suffix.length > maxChars && i > 0) {
        return '$result +${names.length - i}';
      }
      result = candidate;
    }
    return result;
  }
}
