import 'dart:core' hide Match;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_games_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/cards/display_selected_file_card.dart';
import 'package:tallee/services/remote_share_service.dart';

class ImportFileComponent extends StatefulWidget {
  const ImportFileComponent({super.key, this.initialFilePath});

  final String? initialFilePath;

  @override
  State<ImportFileComponent> createState() => _ImportFileComponentState();
}

class _ImportFileComponentState extends State<ImportFileComponent> {
  bool successfulImport = false;
  ImportResult? lastResult;

  Color dottedBorderColor = CustomTheme.boxBorderColor;

  late (ImportResult, Match?, String) data;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null) {
      loadInitialFile();
    }
  }

  Future<void> loadInitialFile() async {
    final result = await RemoteShareService().loadMatchFromFile(
      widget.initialFilePath!,
    );
    if (mounted) {
      setState(() {
        data = result;
        lastResult = data.$1;
        if (data.$1 == ImportResult.success) {
          HapticFeedback.successNotification();
          successfulImport = true;
          dottedBorderColor = Colors.green;
        } else {
          HapticFeedback.errorNotification();
          successfulImport = false;
          dottedBorderColor = Colors.red;
        }
      });
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
              lastResult = data.$1;
              if (data.$1 == ImportResult.success) {
                HapticFeedback.successNotification();
                setState(() {
                  successfulImport = true;
                  dottedBorderColor = Colors.green;
                });
              } else {
                HapticFeedback.errorNotification();
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
                      ? ChooseMatchFile(loc: loc, lastResult: lastResult)
                      : DisplaySelectedFile(match: data.$2!),
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
}

class ChooseMatchFile extends StatelessWidget {
  const ChooseMatchFile({required this.loc, this.lastResult, super.key});

  final AppLocalizations loc;
  final ImportResult? lastResult;

  @override
  Widget build(BuildContext context) {
    String title = loc.choose_match_file;
    if (lastResult != null &&
        lastResult != ImportResult.success &&
        lastResult != ImportResult.canceled) {
      title = translateMatchImportResultToString(lastResult!, context);
    }

    return Column(
      key: const ValueKey('choose_match_file'),
      children: [
        const Icon(Icons.file_present, size: 50),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.visible,
          ),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          loc.tap_to_browse,
          style: TextStyle(
            color: CustomTheme.textColor.withAlpha(180),
            fontSize: 14,
            overflow: TextOverflow.visible,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ],
    );
  }
}
