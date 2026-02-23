import 'dart:math';

import 'package:flutter/material.dart';
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
  });

  /// The icon displayed next to the title.
  final IconData icon;

  /// The title text displayed on the tile.
  final String title;

  /// The width of the tile.
  final double width;

  /// A list of tuples containing labels and their corresponding numeric values.
  final List<(String, num)> values;

  /// The maximum number of items to display.
  final int itemCount;

  /// The color of the bars representing the values.
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return InfoTile(
      width: width,
      title: title,
      icon: icon,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                children: List.generate(min(values.length, itemCount), (index) {
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
                            Container(
                              height: 24,
                              width: barWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: barColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                values[index].$1,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            values[index].$2 <= 1 && values[index].$2 is double
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
              );
            },
          ),
        ),
      ),
    );
  }
}
