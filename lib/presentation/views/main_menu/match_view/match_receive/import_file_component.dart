import 'dart:convert';
import 'dart:core' hide Match;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_games_view.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/services/remote_share_service.dart';

class ImportFileComponent extends StatefulWidget {
  const ImportFileComponent({super.key});

  @override
  State<ImportFileComponent> createState() => _ImportFileComponentState();
}

class _ImportFileComponentState extends State<ImportFileComponent> {
  bool successfulImport = false;

  Color dottedBorderColor = CustomTheme.boxBorderColor;

  late (ImportResult, Match?, String) data;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 50),
        Padding(
          padding: CustomTheme.standardMargin.copyWith(left: 25, right: 25),
          child: GestureDetector(
            onTap: () async {
              data = await RemoteShareService().chooseFileToImport();
              if (data.$1 == ImportResult.success) {
                setState(() {
                  successfulImport = true;
                  dottedBorderColor = Colors.green;
                });
              } else {
                successfulImport = false;
                if (data.$1 != ImportResult.canceled) {
                  setState(() {
                    dottedBorderColor = Colors.red;
                  });
                } else {
                  setState(() {
                    dottedBorderColor = CustomTheme.boxBorderColor;
                  });
                }
              }
            },
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: const Radius.circular(12),
                dashPattern: [10, 5],
                strokeWidth: 3,
                color: dottedBorderColor,
              ),
              child: Container(
                width: MediaQuery.widthOf(context) * 0.9,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.boxColor,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation.drive(
                              Tween<double>(
                                begin: 0.95,
                                end: 1.0,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                            ),
                            child: child,
                          ),
                        );
                      },
                  child: !successfulImport
                      ? chooseMatchFile(loc)
                      : displaySelectedFile(loc, data.$3, data.$2!),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            loc.import_file_instruction,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CustomTheme.textColor.withAlpha(225),
              fontSize: 14,
            ),
            softWrap: true,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimatedButton(
              text: loc.import_match,
              icon: Icons.file_download,
              onPressed: successfulImport
                  ? () {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (_) => AssociateGamesView(match: data.$2!),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget chooseMatchFile(AppLocalizations loc) {
    return Column(
      key: const ValueKey('choose_match_file'),
      children: [
        const Icon(Icons.file_present, size: 50),
        const SizedBox(height: 20),
        Text(
          loc.choose_match_file,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.visible,
          ),
          softWrap: true,
        ),
        const SizedBox(height: 5),
        Text(
          loc.tap_to_browse,
          style: TextStyle(
            color: CustomTheme.textColor.withAlpha(180),
            fontSize: 16,
            overflow: TextOverflow.visible,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ],
    );
  }

  Widget displaySelectedFile(
    AppLocalizations loc,
    String filename,
    Match match,
  ) {
    return Column(
      key: const ValueKey('display_selected_file'),
      children: [
        fileTile(loc, filename, match),
        const SizedBox(height: 20),
        Text(
          loc.successfully_processed_file,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.visible,
          ),
          softWrap: true,
        ),
        const SizedBox(height: 5),
        Text(
          loc.tap_import_to_continue,
          style: TextStyle(
            color: CustomTheme.textColor.withAlpha(180),
            fontSize: 16,
            overflow: TextOverflow.visible,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ],
    );
  }

  Widget fileTile(AppLocalizations loc, String filename, Match match) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.onBoxColor,
        border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
        borderRadius: CustomTheme.standardBorderRadiusAll,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                  '${match.name.replaceAll('.tallee', '').replaceAll(' ', '_')}.tallee',
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
                      '${calculateFileSize(match).toStringAsFixed(1)} KB',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CustomTheme.textColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loc.player_count(
                        match.players.isNotEmpty
                            ? match.players.length
                            : match.teams!.length,
                      ),
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
    );
  }

  double calculateFileSize(Match match) {
    final jsonString = jsonEncode(match.toJson());
    return utf8.encode(jsonString).length / 1024;
  }
}
