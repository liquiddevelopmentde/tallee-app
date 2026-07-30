import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';

class StatisticsTile extends StatefulWidget {
  /// A tile widget that displays statistical data using horizontal bars.
  /// - [icon]: The icon displayed next to the title.
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
    final loc = AppLocalizations.of(context);
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
            Visibility(
              visible:
                  widget.values.isNotEmpty &&
                  widget.values.any((entry) => entry.$2 != 0),

              // No data available message
              replacement: Center(
                heightFactor: 4,
                child: Text(loc.no_data_available),
              ),

              // Bar chart
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxBarWidth = constraints.maxWidth * 0.8;

                  // If displayCount wasnt provided, take all values
                  final valuesShown = widget.showAllValues
                      ? widget.values.length
                      : min(widget.values.length, widget.displayCount);
                  final displayValues = widget.values
                      .take(valuesShown)
                      .toList();
                  // Maximum to scale bars
                  final maxVal = displayValues.isNotEmpty
                      ? displayValues.fold<num>(
                          0,
                          (currentMax, entry) =>
                              entry.$2 > currentMax ? entry.$2 : currentMax,
                        )
                      : 0;

                  return Column(
                    children: [
                      // Bars
                      ...List.generate(valuesShown, (index) {
                        /// Fraction of wins
                        final double fraction = (maxVal > 0)
                            ? (displayValues[index].$2 / maxVal)
                            : 0.0;

                        /// Calculated width for current the bar
                        final double barWidth = (maxBarWidth * fraction).clamp(
                          0.0,
                          maxBarWidth,
                        );

                        /// Whether this entry is part of the "overflow" that exceeds the display count
                        final isOverflowEntry = index >= widget.displayCount;

                        /// Whether to apply highlighting for entries that exceed the display count
                        final isHighlightedOverflow =
                            isOverflowEntry &&
                            widget.showDisplayCountHighlighting;

                        /// Adjust bar color for highlighted overflow entries
                        final barClr = isHighlightedOverflow
                            ? barColor.withAlpha(120)
                            : barColor;

                        const textLeftPadding = 4.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: maxBarWidth,
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: [
                                    // Bar
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      curve: Curves.easeInOut,
                                      height: 24,
                                      width: barWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: barClr,
                                      ),
                                    ),

                                    // Player
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: textLeftPadding,
                                      ),
                                      child: playerText(
                                        context: context,
                                        player: displayValues[index].$1,
                                        barColor: barColor,
                                        barWidth: barWidth,
                                        textLeftPadding: textLeftPadding,
                                        isHighlightedOverflow:
                                            isHighlightedOverflow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),

                              // Value
                              Center(
                                child: Text(
                                  formatValue(displayValues[index].$2),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
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
                            RpgAwesome.clovers_card,
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
                          const Icon(
                            Icons.groups,
                            color: CustomTheme.hintColor,
                          ),
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
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.statisticDao.updateIsFavourite(
      widget.statistic.id,
      updatedIsFavourite,
    );
    setState(() {
      isFavourite = updatedIsFavourite;
    });
    widget.onStatisticChanged?.call(widget.statistic.id);
  }

  String formatValue(num value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    } else {
      return value.toString();
    }
  }

  Widget playerText({
    required BuildContext context,
    required Player player,
    required Color barColor,
    required double barWidth,
    required double textLeftPadding,
    required bool isHighlightedOverflow,
  }) {
    final textAlpha = isHighlightedOverflow ? 150 : 255;
    final baseStyle = DefaultTextStyle.of(context).style;

    if (barColor != getColorFromAppColor(AppColor.yellow)) {
      return RichText(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        text: buildPlayerNameCountSpan(
          player,
          style: baseStyle,
          mainStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomTheme.textColor.withAlpha(textAlpha),
          ),
          countStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CustomTheme.textColor.withAlpha(
              isHighlightedOverflow ? 170 : 150,
            ),
          ),
        ),
      );
    }

    final insideTextColor = const Color(0xFF101010).withAlpha(textAlpha);
    final outsideTextColor = CustomTheme.textColor.withAlpha(textAlpha);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) {
        final coveredTextWidth = (barWidth - textLeftPadding).clamp(
          0.0,
          rect.width,
        );
        final splitStop = rect.width > 0
            ? (coveredTextWidth / rect.width).clamp(0.0, 1.0)
            : 0.0;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            insideTextColor,
            insideTextColor,
            outsideTextColor,
            outsideTextColor,
          ],
          stops: [0.0, splitStop, splitStop, 1.0],
        ).createShader(rect);
      },
      child: RichText(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        text: buildPlayerNameCountSpan(
          player,
          style: baseStyle,
          mainStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          countStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
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
