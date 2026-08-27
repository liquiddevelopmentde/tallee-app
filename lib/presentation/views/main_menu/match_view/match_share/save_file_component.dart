import 'dart:convert';
import 'dart:core' hide Match;

import 'package:flutter/material.dart';
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
    formattedMatchName = widget.match.name.replaceAll(' ', '_');
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.file_present, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$formattedMatchName.tallee',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: CustomTheme.textColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${fileSize.toStringAsFixed(1)} KB',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CustomTheme.textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          loc.player_count(widget.match.players.length),
                          style: const TextStyle(
                            fontSize: 14,
                            color: CustomTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimatedButton(
              text: loc.save_file,
              icon: Icons.save,
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

  double calculateFileSize(Match match) {
    final jsonString = jsonEncode(match.toJson());
    return utf8.encode(jsonString).length / 1024;
  }
}
