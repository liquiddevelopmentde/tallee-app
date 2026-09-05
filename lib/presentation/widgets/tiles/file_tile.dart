import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class FileTile extends StatelessWidget {
  const FileTile({required this.match, this.margin, super.key});

  final Match match;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final fileSize = calculateFileSize(match);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.onBoxColor,
        border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
        borderRadius: CustomTheme.standardBorderRadiusAll,
      ),
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.file_present, size: 36),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Filename
                    Expanded(
                      child: Text(
                        '${match.name.toSafeFilename()}.tallee',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.textColor,
                        ),
                      ),
                    ),

                    // Filesize
                    Text(
                      '${fileSize.toStringAsFixed(1)} KB',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CustomTheme.textColor,
                      ),
                    ),
                  ],
                ),

                // Content
                Wrap(
                  spacing: 4,
                  children: getContentAsStrings(loc)
                      .map(
                        (item) => Text(
                          item,
                          style: const TextStyle(color: CustomTheme.hintColor),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the individual content items of the match, e.g.:
  /// ["1 Game,", "3 players,", "2 Pairs,", "1 Group"]
  List<String> getContentAsStrings(AppLocalizations loc) {
    final items = <String>[];

    // Game
    items.add('1 ${loc.game}');

    // Players
    items.add(loc.player_count(match.players.length));

    // Teams & Pairs
    final isTeamMatch = match.isTeamMatch;
    final teams = match.teams ?? [];
    if (isTeamMatch) {
      items.add('${teams.length} ${loc.teams}');
    } else if (teams.isNotEmpty) {
      final pairAmount = teams.where((t) => t.members.length > 1).length;
      if (pairAmount > 0) items.add('$pairAmount ${loc.pair(pairAmount)}');
    }

    // Group
    if (match.group != null) items.add('1 ${loc.group}');

    // Add "," at every string except the last
    for (int i = 0; i < items.length - 1; i++) {
      items[i] = '${items[i]},';
    }

    return items;
  }

  double calculateFileSize(Match match) {
    final jsonString = jsonEncode(match.toJson());
    return utf8.encode(jsonString).length / 1024;
  }
}
