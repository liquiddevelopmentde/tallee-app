import 'dart:convert';
import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/services/remote_share_service.dart';

class SaveFileComponent extends StatefulWidget {
  final Match match;

  const SaveFileComponent({required this.match, super.key});

  @override
  State<SaveFileComponent> createState() => _SaveFileComponentState();
}

class _SaveFileComponentState extends State<SaveFileComponent> {
  late String formattedMatchName;
  late double fileSize;

  @override
  void initState() {
    formattedMatchName = widget.match.name.toSafeFilename();
    fileSize = calculateFileSize(widget.match);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 50),
        Column(
          children: [
            const Icon(Icons.file_download, size: 50),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                loc.file_share_instruction,
                style: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 16,
                  overflow: TextOverflow.visible,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                            '$formattedMatchName.tallee',
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
                      runSpacing: 2,
                      children: getContentAsStrings(loc)
                          .map(
                            (item) => Text(
                              item,
                              style: const TextStyle(
                                color: CustomTheme.hintColor,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimatedButton(
              text: loc.save_file,
              icon: Icons.folder,
              onPressed: () {
                RemoteShareService().saveMatchToCustomLocation(
                  widget.match,
                  dialogTitle: loc.choose_where_to_save,
                );
              },
            ),
            const SizedBox(width: 5),
            FloatingAnimatedButton(
              icon: Icons.share,
              onPressed: () {
                RemoteShareService().shareMatchAsFile(
                  widget.match,
                  text: loc.here_is_shared_match(widget.match.name),
                  title: loc.share_match_title,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Returns the individual content items of the match, e.g.:
  /// ["1 Game,", "3 players,", "2 Pairs,", "1 Group"]
  List<String> getContentAsStrings(AppLocalizations loc) {
    final items = <String>[];

    // Game
    items.add('1 ${loc.game}');

    // Players
    items.add(loc.player_count(widget.match.players.length));

    // Teams & Pairs
    final isTeamMatch = widget.match.isTeamMatch;
    final teams = widget.match.teams ?? [];
    if (isTeamMatch) {
      items.add('${teams.length} ${loc.teams}');
    } else if (teams.isNotEmpty) {
      final pairAmount = teams.where((t) => t.members.length > 1).length;
      if (pairAmount > 0) items.add('$pairAmount ${loc.pair(pairAmount)}');
    }

    // Group
    if (widget.match.group != null) items.add('1 ${loc.group}');

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
