import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';

class StatisticsTile extends StatelessWidget {
  /// A tile widget that displays statistical data using horizontal bars.
  /// - [icon]: The icon displayed next to the title.
  /// - [title]: The title text displayed on the tile.
  /// - [width]: The width of the tile.
  /// - [values]: A list of tuples containing labels and their corresponding numeric values.
  /// - [barColor]: The color of the bars representing the values.
  const StatisticsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.values,
    required this.barColor,
    required this.displayCount,
    this.width,
    this.selectedGroups,
    this.selectedGames,
    this.showAllValues = false,
    this.showDisplayCountHighlighting = false,
  });

  /// The icon displayed next to the title.
  final IconData icon;

  /// The title text displayed on the tile.
  final String title;

  /// The width of the tile.
  final double? width;

  /// A list of tuples containing labels and their corresponding numeric values.
  final List<(Player, num)> values;

  /// The color of the bars representing the values.
  final Color barColor;

  // statistic data
  final int displayCount;
  final List<Group>? selectedGroups;
  final List<Game>? selectedGames;

  final bool showAllValues;
  final bool showDisplayCountHighlighting;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return InfoTile(
      width: width ?? MediaQuery.sizeOf(context).width * 0.95,
      title: title,
      icon: icon,
      margin: CustomTheme.tileMargin,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Visibility(
          visible: values.isNotEmpty,

          // No data avaiable message
          replacement: Center(
            heightFactor: 4,
            child: Text(loc.no_data_available),
          ),

          // Bar chart
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBarWidth = constraints.maxWidth * 0.8;

              // If displayCount wasnt provided, take all values
              final valuesShown = showAllValues
                  ? values.length
                  : min(values.length, displayCount);
              final displayValues = values.take(valuesShown).toList();
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

                    final isOverflowEntry = index >= displayCount;
                    final isHighlightedOverflow =
                        isOverflowEntry && showDisplayCountHighlighting;
                    final barClr = isHighlightedOverflow
                        ? barColor.withAlpha(150)
                        : barColor;

                    var textClr = barColor.computeLuminance() > 0.5
                        ? const Color(0xFF101010)
                        : CustomTheme.textColor;
                    textClr = textClr.withAlpha(
                      isHighlightedOverflow ? 220 : 255,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                                  duration: const Duration(milliseconds: 150),
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
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: RichText(
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                          text: displayValues[index].$1.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textClr,
                                          ),
                                        ),
                                        TextSpan(
                                          text: getNameCountText(
                                            displayValues[index].$1,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (barColor ==
                                                            getColorFromAppColor(
                                                              AppColor.yellow,
                                                            )
                                                        ? const Color(
                                                            0xFF101010,
                                                          )
                                                        : CustomTheme.textColor)
                                                    .withAlpha(150),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Value
                          Center(
                            child: Text(
                              displayValues[index].$2 <= 1 &&
                                      displayValues[index].$2 is double
                                  ? displayValues[index].$2.toStringAsFixed(2)
                                  : displayValues[index].$2.toString(),
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

                  // Group & Game info
                  if (hasGame || hasGroup)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          // Game
                          if (hasGame)
                            Row(
                              spacing: 8,
                              children: [
                                const Icon(
                                  RpgAwesome.clovers_card,
                                  color: CustomTheme.hintColor,
                                  size: 20,
                                ),
                                Text(
                                  getGameText(selectedGames!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: CustomTheme.hintColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          if (hasGroup && hasGame) const SizedBox(width: 20),

                          // Group
                          if (hasGroup)
                            Row(
                              spacing: 8,
                              children: [
                                const Icon(
                                  Icons.groups,
                                  color: CustomTheme.hintColor,
                                ),
                                Text(
                                  getGroupText(selectedGroups!),
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
              );
            },
          ),
        ),
      ),
    );
  }

  String getGroupText(List<Group> groups) {
    var text = groups[0].name;
    if (groups.length > 1) {
      return '$text + ${groups.length - 1}';
    }
    return text;
  }

  String getGameText(List<Game> games) {
    var text = games[0].name;
    if (games.length > 1) {
      return '$text + ${games.length - 1}';
    }
    return text;
  }

  bool get hasGroup => selectedGroups != null && selectedGroups!.isNotEmpty;

  bool get hasGame => selectedGames != null && selectedGames!.isNotEmpty;
}
