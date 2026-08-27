import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_games_view.dart';
import 'package:tallee/presentation/widgets/buttons/api_action_animated_button.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/services/match_share_service.dart';
import 'package:tallee/services/share_exceptions.dart';

class EnterTokenView extends StatefulWidget {
  const EnterTokenView({super.key});

  @override
  State<EnterTokenView> createState() => _EnterTokenViewState();
}

class _EnterTokenViewState extends State<EnterTokenView> {
  TextEditingController tokenInputFieldController = TextEditingController();

  late Match match;

  bool validToken = true;

  @override
  void initState() {
    tokenInputFieldController.addListener(() {
      if (!validToken) {
        setState(() => validToken = true);
      } else {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tokenInputFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final defaultPinTheme = PinTheme(
      height: 60,
      width: 45,
      textStyle: const TextStyle(
        fontSize: 35,
        color: CustomTheme.textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: CustomTheme.standardBoxDecoration,
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: CustomTheme.primaryColor),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red),
      ),
      textStyle: const TextStyle(
        fontSize: 35,
        color: Colors.red,
        fontWeight: FontWeight.w500,
      ),
    );

    final disabledPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Column(
            children: [
              const Icon(Icons.cloud_download, size: 50),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Text(
                  loc.input_token_instruction,
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
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Pinput(
              controller: tokenInputFieldController,
              length: 6,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              hapticFeedbackType: HapticFeedbackType.selectionClick,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme,
              disabledPinTheme: disabledPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: false,
              animationCurve: Curves.fastOutSlowIn,
              animationDuration: const Duration(milliseconds: 200),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                TextInputFormatter.withFunction(
                  (oldValue, newValue) => TextEditingValue(
                    text: newValue.text.toUpperCase(),
                    selection: newValue.selection,
                  ),
                ),
              ],
              forceErrorState: !validToken,
              errorText: loc.invalid_token,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ApiActionAnimatedButton(
                text: loc.import_match,
                icon: Icons.cloud_download,
                onPressed: validateToken(tokenInputFieldController.text)
                    ? () async {
                        await handleApiMatchRequest(
                          tokenInputFieldController.text,
                        );
                      }
                    : null,
              ),
              const SizedBox(width: 5),
              FloatingAnimatedButton(
                onPressed: () async {
                  ClipboardData? data = await Clipboard.getData('text/plain');
                  if (data != null && validateToken(data.text)) {
                    tokenInputFieldController.text = data.text!.toUpperCase();
                  }
                },
                icon: Icons.paste,
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              loc.share_token_format_info,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleApiMatchRequest(String token) async {
    try {
      setState(() {
        validToken = true;
      });
      final loadedMatch = await MatchShareService().getMatchByToken(
        tokenInputFieldController.text,
      );
      if (!mounted) return;

      setState(() {
        match = loadedMatch;
      });

      Navigator.of(context).push(
        adaptivePageRoute(builder: (_) => AssociateGamesView(match: match)),
      );
    } catch (error) {
      if (!mounted) return;

      final loc = AppLocalizations.of(context);
      String errorMessage;
      if (error is NetworkException) {
        errorMessage = loc.network_error;
      } else if (error is ServerException) {
        if (error.statusCode == 404 || error.statusCode == 410) {
          setState(() {
            validToken = false;
          });
          errorMessage = '';
        } else {
          errorMessage = loc.server_error(error.statusCode);
        }
      } else if (error is ParsingException) {
        errorMessage = loc.parsing_error;
      } else {
        errorMessage = loc.unexpected_error;
      }

      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(message: errorMessage));
      }

      rethrow; //error an button "weiterleiten"
    }
  }

  bool validateToken(String? token) {
    return token != null &&
        token.length == 6 &&
        RegExp(r'^[A-Za-z0-9]+$').hasMatch(token);
  }
}
