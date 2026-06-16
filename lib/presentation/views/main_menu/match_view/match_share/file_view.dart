import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/services/match_share_service.dart';

class FileView extends StatelessWidget {
  final Match match;

  const FileView({required this.match, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
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
              Icon(Icons.file_present, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${match.name.replaceAll(' ', '_')}.tallee",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: CustomTheme.textColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "15 KB",
                          style: TextStyle(
                            fontSize: 14,
                            color: CustomTheme.textColor,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "${match.players.length} Players",
                          style: TextStyle(
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: const Text(
            'Manually share the match data in a file for full local transfer.',
            style: TextStyle(
              color: CustomTheme.textColor,
              fontSize: 14,
              overflow: TextOverflow.visible,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimatedButton(
              text: 'Save File',
              icon: Icons.save,
              onPressed: () {
                MatchShareService().saveMatchToCustomLocation(match);
              },
            ),
            SizedBox(width: 5),
            FloatingAnimatedButton(
              icon: Icons.share,
              onPressed: () {
                MatchShareService().shareMatchAsFile(match);
              },
            ),
          ],
        ),
      ],
    );
  }
}
