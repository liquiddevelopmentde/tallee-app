import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';

class StatisticsTile extends StatelessWidget {
  /// A tile widget that displays statistical data using horizontal bars.
  /// - [icon]: The icon displayed next to the title.
  /// - [title]: The title text displayed on the tile.
  /// - [width]: The width of the tile.
  /// - [values]: A list of tuples containing labels and their corresponding numeric values.
  /// - [itemCount]: The maximum number of items to display.
  /// - [barColor]: The color of the bars representing the values.
  const StatisticsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.width,
    required this.values,
    required this.itemCount,
    required this.barColor,
    required this.statistic,
  });

  /// The icon displayed next to the title.
  final IconData icon;

  /// The title text displayed on the tile.
  final String title;

  /// The width of the tile.
  final double width;

  /// A list of tuples containing labels and their corresponding numeric values.
  final List<(Player, num)> values;

  /// The maximum number of items to display.
  final int itemCount;

  /// The color of the bars representing the values.
  final Color barColor;

  final Statistic statistic;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return InfoTile(
      width: width,
      title: title,
      icon: icon,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Visibility(
          visible: values.isNotEmpty,
          replacement: Center(
            heightFactor: 4,
            child: Text(loc.no_data_available),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBarWidth = constraints.maxWidth * 0.65;
              return Column(
                children: [
                  // Bar chart
                  ...List.generate(min(values.length, itemCount), (index) {
                    /// The maximum wins among all players
                    final maxMatches = values.isNotEmpty ? values[0].$2 : 0;

                    /// Fraction of wins
                    final double fraction = (maxMatches > 0)
                        ? (values[index].$2 / maxMatches)
                        : 0.0;

                    /// Calculated width for current the bar
                    final double barWidth = maxBarWidth * fraction;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              // Bar
                              Container(
                                height: 24,
                                width: barWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: barColor,
                                ),
                              ),

                              // Player
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: values[index].$1.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: getNameCountText(
                                          values[index].$1,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: CustomTheme.textColor
                                              .withAlpha(150),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Value
                          Center(
                            child: Text(
                              values[index].$2 <= 1 &&
                                      values[index].$2 is double
                                  ? values[index].$2.toStringAsFixed(2)
                                  : values[index].$2.toString(),
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
                  if (statistic.selectedGames != null ||
                      statistic.selectedGroups != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Game
                          if (statistic.selectedGames != null &&
                              statistic.selectedGames!.isNotEmpty)
                            Row(
                              spacing: 8,
                              children: [
                                const Icon(
                                  RpgAwesome.clovers_card,
                                  color: CustomTheme.hintColor,
                                  size: 20,
                                ),
                                Text(
                                  getGameText(statistic.selectedGames!),
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
                          if (statistic.selectedGroups != null &&
                              statistic.selectedGroups!.isNotEmpty)
                            Row(
                              spacing: 8,
                              children: [
                                const Icon(
                                  Icons.groups,
                                  color: CustomTheme.hintColor,
                                ),
                                Text(
                                  getGroupText(statistic.selectedGroups!),
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
}
