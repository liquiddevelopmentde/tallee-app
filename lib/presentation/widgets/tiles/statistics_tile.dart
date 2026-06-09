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
    this.margin,
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

  final EdgeInsets? margin;

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
      margin: margin ?? CustomTheme.tileMargin,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Visibility(
              visible:
                  values.isNotEmpty && values.any((entry) => entry.$2 != 0),

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
                        final isOverflowEntry = index >= displayCount;

                        /// Whether to apply highlighting for entries that exceed the display count
                        final isHighlightedOverflow =
                            isOverflowEntry && showDisplayCountHighlighting;

                        /// Adjust bar color for highlighted overflow entries
                        final barClr = isHighlightedOverflow
                            ? barColor.withAlpha(120)
                            : barColor;

                        const textLeftPadding = 4.0;

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
    final nameCountText = getNameCountText(player);
    final textAlpha = isHighlightedOverflow ? 150 : 255;

    if (barColor != getColorFromAppColor(AppColor.yellow)) {
      return RichText(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CustomTheme.textColor.withAlpha(textAlpha),
              ),
            ),
            TextSpan(
              text: nameCountText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CustomTheme.textColor.withAlpha(
                  isHighlightedOverflow ? 170 : 150,
                ),
              ),
            ),
          ],
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
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: player.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: nameCountText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
