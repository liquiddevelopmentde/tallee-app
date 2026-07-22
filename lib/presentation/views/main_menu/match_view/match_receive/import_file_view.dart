import 'dart:convert';
import 'dart:core' hide Match;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/match_import/associate_players_view.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/services/match_share_service.dart';

class ImportFileView extends StatefulWidget {
  const ImportFileView({super.key});

  @override
  State<ImportFileView> createState() => _ImportFileViewState();
}

class _ImportFileViewState extends State<ImportFileView> {
  bool successfulImport = false;

  Color dottedBorderColor = CustomTheme.boxBorderColor;

  late (ImportResult, Match?, String) data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Padding(
          padding: CustomTheme.standardMargin.copyWith(left: 25, right: 25),
          child: GestureDetector(
            onTap: () async {
              data = await MatchShareService().chooseFileToImport();
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
                      ? chooseMatchFile()
                      : displaySelectedFile(data.$3, data.$2!),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Select a match file (.tallee) exported from Tallee match share to import the data.',
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CustomTheme.textColor.withAlpha(225),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimatedButton(
              text: 'Import match',
              icon: Icons.file_download,
              onPressed: successfulImport
                  ? () {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (_) => AssociatePlayersView(match: data.$2!),
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

  Widget chooseMatchFile() {
    return Column(
      key: const ValueKey('choose_match_file'),
      children: [
        const Icon(Icons.file_present, size: 50),
        const SizedBox(height: 20),
        const Text(
          'Choose Match File',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Text(
          'Tap to browse',
          style: TextStyle(
            color: CustomTheme.textColor.withAlpha(180),
            fontSize: 16,
            overflow: TextOverflow.visible,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget displaySelectedFile(String filename, Match match) {
    return Column(
      key: const ValueKey('display_selected_file'),
      children: [
        fileTile(filename, match),
        const SizedBox(height: 20),
        const Text(
          'Successfully processed file',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Text(
          'Tap import match, to continue',
          style: TextStyle(
            color: CustomTheme.textColor.withAlpha(180),
            fontSize: 16,
            overflow: TextOverflow.visible,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget fileTile(String filename, Match match) {
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
                      '${match.players.isNotEmpty ? match.players.length : match.teams!.length} Players',
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
