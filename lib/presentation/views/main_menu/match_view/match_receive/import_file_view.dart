import 'dart:core' hide Match;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/services/match_share_service.dart';

class ImportFileView extends StatelessWidget {
  const ImportFileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Padding(
          padding: CustomTheme.standardMargin.copyWith(left: 25, right: 25),
          child: GestureDetector(
            onTap: () async {
              final (ImportResult, Match?) data = await MatchShareService()
                  .chooseFileToImport();
              if (data.$1 == ImportResult.success) {
                print(data.$2);
              } else {
                print(data.$1);
              }
            },
            child: DottedBorder(
              options: const RoundedRectDottedBorderOptions(
                radius: Radius.circular(12),
                dashPattern: [10, 5],
                strokeWidth: 3,
                color: CustomTheme.boxBorderColor,
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
                child: Column(
                  children: [
                    const Icon(Icons.file_upload, size: 50),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose Match File',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
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
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
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
              icon: Icons.cloud_download,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
