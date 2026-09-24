import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/share_exceptions.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/preview_match_view.dart';
import 'package:tallee/presentation/widgets/buttons/api_action_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/services/remote_share_service.dart';

class EnterTokenComponent extends StatefulWidget {
  const EnterTokenComponent({super.key});

  @override
  State<EnterTokenComponent> createState() => _EnterTokenComponentState();
}

class _EnterTokenComponentState extends State<EnterTokenComponent> {
  TextEditingController tokenInputFieldController = TextEditingController();

  late Match match;

  bool? isTokenValid;
  bool? isMatchValid;
  String errorMessage = '';

  @override
  void initState() {
    tokenInputFieldController.addListener(() {
      if (isTokenValid == false || isMatchValid == false) {
        setState(() {
          isTokenValid = null;
          isMatchValid = null;
        });
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

    const errorTextStyle = TextStyle(
      color: Colors.red,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.visible,
    );

    return Column(
      children: [
        const SizedBox(height: 50),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_download, size: 50),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        const SizedBox(height: 10),
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
            animationCurve: Curves.easeInOutCubic,
            animationDuration: const Duration(milliseconds: 100),
            onClipboardFound: (value) {
              HapticFeedback.lightImpact();
              tokenInputFieldController.text = value;
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBar(message: loc.code_pasted_from_clipboard),
              );
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              TextInputFormatter.withFunction(
                (oldValue, newValue) => TextEditingValue(
                  text: newValue.text.toUpperCase(),
                  selection: newValue.selection,
                ),
              ),
            ],
            forceErrorState: isTokenValid == false || isMatchValid == false,
            errorText: getErrorText(loc),
            errorTextStyle: errorTextStyle,
            errorBuilder: (errorText, pin) {
              return SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorText ?? '',
                    style: errorTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
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
        const Spacer(),
        ApiActionAnimatedButton(
          text: loc.import_match,
          sizeRelativeToWidth: 0.9,
          onPressed: validateToken(tokenInputFieldController.text)
              ? () async {
                  await handleApiMatchRequest(tokenInputFieldController.text);
                }
              : null,
        ),
      ],
    );
  }

  String getErrorText(AppLocalizations loc) {
    if (isTokenValid == false) return loc.invalid_token;
    if (isMatchValid == false) return errorMessage;
    return '';
  }

  Future<void> handleApiMatchRequest(String token) async {
    final loc = AppLocalizations.of(context);

    try {
      final response = await RemoteShareService().getMatchByToken(
        tokenInputFieldController.text,
      );
      isTokenValid = true;

      // If an import error occured
      if (response.result != ImportResult.success && mounted) {
        errorMessage = translateMatchImportResultToString(
          response.result,
          context,
        );
      } else {
        setState(() {
          isMatchValid = true;
          match = response.match!;
        });
        if (mounted) {
          Navigator.of(context).push(
            adaptivePageRoute(
              builder: (_) => PreviewMatchView(match: match),
              fullscreenDialog: true,
            ),
          );
        }
      }
    } catch (error) {
      if (error is NetworkException) {
        errorMessage = loc.network_error;
        setState(() => isMatchValid = false);
      } else if (error is ServerException) {
        if (error.statusCode == 404 || error.statusCode == 410) {
          setState(() => isTokenValid = false);
          errorMessage = '';
        } else {
          errorMessage = loc.server_error;
          setState(() => isMatchValid = false);
        }
      } else if (error is ParsingException) {
        errorMessage = loc.parsing_error;
        setState(() => isMatchValid = false);
      } else if (error is ImportException) {
        setState(() => isMatchValid = false);
      } else {
        errorMessage = loc.unexpected_error;
        setState(() => isMatchValid = false);
      }

      rethrow; // redirect error to button
    }
  }

  bool validateToken(String? token) {
    return token != null &&
        token.length == 6 &&
        RegExp(r'^[A-Za-z0-9]+$').hasMatch(token);
  }
}
