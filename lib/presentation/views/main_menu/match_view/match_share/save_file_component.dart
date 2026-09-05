import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/tiles/file_tile.dart';
import 'package:tallee/services/remote_share_service.dart';

class SaveFileComponent extends StatefulWidget {
  final Match match;

  const SaveFileComponent({required this.match, super.key});

  @override
  State<SaveFileComponent> createState() => _SaveFileComponentState();
}

class _SaveFileComponentState extends State<SaveFileComponent> {
  late String formattedMatchName;

  @override
  void initState() {
    formattedMatchName = widget.match.name.toSafeFilename();
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
        // File
        FileTile(match: widget.match),
        const Spacer(),

        // Buttons
        Row(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Save Button
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

            // Share button
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
}
