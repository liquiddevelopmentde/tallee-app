import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

class FeedbackFormView extends StatefulWidget {
  const FeedbackFormView({super.key, this.associatedEventId});

  final SentryId? associatedEventId;

  @override
  State<FeedbackFormView> createState() => _FeedbackFormViewState();
}

class _FeedbackFormViewState extends State<FeedbackFormView> {
  final messageController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();

  final messageFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final nameFocusNode = FocusNode();

  bool isSubmitting = false;
  bool emailTouched = false;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        setState(() {
          emailTouched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    emailController.dispose();
    nameController.dispose();
    messageFocusNode.dispose();
    emailFocusNode.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final emailText = emailController.text.trim();
    final isEmailFormatValid = isEmailValid;
    final showEmailError =
        emailTouched && emailText.isNotEmpty && !isEmailFormatValid;
    final canSubmit =
        messageController.text.trim().isNotEmpty &&
        isEmailFormatValid &&
        !isSubmitting;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(title: Text(loc.send_feedback)),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: CustomTheme.standardMargin,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 50,
                        color: CustomTheme.primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loc.feedback_info_text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CustomTheme.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextInputField(
                        controller: messageController,
                        focusNode: messageFocusNode,
                        hintText: loc.feedback_hint,
                        maxLines: 5,
                        minLines: 4,
                        maxLength: MAX_FEEDBACK_MESSAGE_LENGTH,
                        showCounterText: true,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => emailFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      TextInputField(
                        controller: emailController,
                        focusNode: emailFocusNode,
                        hintText: loc.email_optional,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => nameFocusNode.requestFocus(),
                      ),
                      if (showEmailError)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              loc.invalid_email,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextInputField(
                        controller: nameController,
                        focusNode: nameFocusNode,
                        hintText: loc.name_optional,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          nameFocusNode.unfocus();
                          if (canSubmit) {
                            submit(loc);
                          }
                        },
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      BottomAnimatedButton(
                        sizeRelativeToWidth: 0.95,
                        buttonText: isSubmitting
                            ? loc.sending
                            : loc.send_feedback,
                        buttonType: ButtonType.primary,
                        onPressed: canSubmit ? () => submit(loc) : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool get isEmailValid {
    final email = emailController.text.trim();
    if (email.isEmpty) return true;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  Future<void> submit(AppLocalizations loc) async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty || !isEmailValid || isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final emailText = emailController.text.trim();
      final nameText = nameController.text.trim();

      final email = emailText.isEmpty ? 'No email provided' : emailText;
      final name = nameText.isEmpty ? 'Anonymous' : nameText;

      SentryId targetEventId;

      if (widget.associatedEventId != null) {
        targetEventId = widget.associatedEventId!;
      } else {
        final previewText = messageText.replaceAll('\n', ' ').trim();
        final title = previewText.length > 40
            ? '${previewText.substring(0, 40)}...'
            : previewText;

        targetEventId = await Sentry.captureMessage(
          'Feedback: $title',
          level: SentryLevel.info,
          withScope: (scope) {
            scope.fingerprint = [
              DateTime.now().microsecondsSinceEpoch.toString(),
            ];
          },
        );
      }

      final userFeedback = SentryFeedback(
        message: messageText,
        contactEmail: email,
        name: name,
        associatedEventId: targetEventId,
      );

      await Sentry.captureFeedback(userFeedback);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(CustomSnackBar(message: loc.error_sending_feedback));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
}
