import 'dart:core' hide Match;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_games_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/import_file/choose_match_file_widget.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/import_file/display_selected_file_widget.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/services/remote_share_service.dart';

class ImportFileCard extends StatefulWidget {
  const ImportFileCard({super.key, this.initialFilePath});

  final String? initialFilePath;

  @override
  State<ImportFileCard> createState() => _ImportFileCardState();
}

class _ImportFileCardState extends State<ImportFileCard> {
  bool successfulImport = false;
  ImportResult? lastResult;
  String? fileName;

  Color dottedBorderColor = CustomTheme.boxBorderColor;

  late ({ImportResult result, Match? match, String filePath}) data;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null) {
      loadInitialFile();
    }
  }

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
              HapticFeedback.selectionClick();
              data = await RemoteShareService().chooseFileToImport();
              processFile(data);
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
                      ? ChooseMatchFileWidget(loc: loc, lastResult: lastResult)
                      : DisplaySelectedFileWidget(
                          match: data.match!,
                          fileName: fileName,
                        ),
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
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BottomAnimatedButton(
              buttonText: loc.import_match,
              sizeRelativeToWidth: 0.9,
              onPressed: successfulImport
                  ? () {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (_) =>
                              AssociateGamesView(match: data.match!),
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

  /// Loads a file if [initialFilePath] was provided
  Future<void> loadInitialFile() async {
    final data = await RemoteShareService().loadMatchFromFile(
      widget.initialFilePath!,
    );
    processFile(data);
  }

  void processFile(dynamic data) {
    lastResult = data.result;
    if (data.result == ImportResult.success) {
      HapticFeedback.successNotification();
      setState(() {
        successfulImport = true;
        dottedBorderColor = Colors.green;
      });
    } else {
      HapticFeedback.errorNotification();
      successfulImport = false;

      setState(() {
        if (data.result != ImportResult.canceled) {
          dottedBorderColor = Colors.red;
        } else {
          dottedBorderColor = CustomTheme.boxBorderColor;
        }
      });
    }
    final path = data.filePath;
    fileName = path.split('/').last;
  }
}
