import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_spacing.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
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
  /// - [emptyAssets]: Optional assets for the empty state.
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
    this.emptyAssets,
  }) : assert(displayCount >= 0, 'displayCount must not be negative');

  final Statistic statistic;
  final List<(Player, num)> values;
  final int displayCount;
  final EdgeInsets? margin;
  final double? width;
  final bool showAllValues;
  final bool showDisplayCountHighlighting;
  final ValueChanged<String>? onStatisticChanged;
  final ({IconData icon, String title, String description})? emptyAssets;

  @override
  State<StatisticsTile> createState() => _StatisticsTileState();
}

class _StatisticsTileState extends State<StatisticsTile> {
  late bool isFavourite;
  late List<Group>? selectedGroups;
  late List<Game>? selectedGames;
  late IconData icon;

  @override
  void initState() {
    isFavourite = widget.statistic.isFavourite;
    selectedGames = widget.statistic.selectedGames;
    selectedGroups = widget.statistic.selectedGroups;
    icon = widget.statistic.type.icon;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant StatisticsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statistic != widget.statistic) {
      isFavourite = widget.statistic.isFavourite;
      selectedGames = widget.statistic.selectedGames;
      selectedGroups = widget.statistic.selectedGroups;
      icon = widget.statistic.type.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.statistic.color.colorValue(context);
    final title = widget.statistic.type.toLocalizedString(context);

    return InfoTile(
      leadingWidget: Icon(widget.emptyAssets?.icon ?? icon),
      title: title,
      trailingWidget: Visibility(
        visible: !widget.showAllValues,
        child: HapticIconButton(
          padding: EdgeInsets.zero,
          icon: isFavourite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
          onPressed: toggleFavourite,
        ),
      ),
      width:
          widget.width ??
          MediaQuery.sizeOf(context).width * AppSpacing.contentWidthFactor,
      margin: widget.margin ?? AppSpacing.tileMargin,
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
              barTextColor: widget.statistic.color.statisticBarColor(context),
            ),

            // Group & Game info
            if (hasGame || hasGroup)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
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
                          Icon(
                            GAME_ICON,
                            color: context.talleeColors.hintColor,
                            size: 20,
                          ),
                          Text(
                            getSubtitleText(
                              selectedGames!.map((g) => g.name).toList(),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.talleeColors.hintColor,
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
                          Icon(
                            GROUP_ICON,
                            color: context.talleeColors.hintColor,
                          ),
                          Text(
                            getSubtitleText(
                              selectedGroups!.map((g) => g.name).toList(),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.talleeColors.hintColor,
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

  String getSubtitleText(List<String> names) => formatNameList(names);
}
