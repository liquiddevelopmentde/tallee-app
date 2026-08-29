import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dropdown/labeled_section.dart';
import 'package:tallee/presentation/widgets/form_panel.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

/// A view that allows creating a new player.
class CreatePlayerView extends StatefulWidget {
  const CreatePlayerView({super.key});

  @override
  State<CreatePlayerView> createState() => _CreatePlayerViewState();
}

class _CreatePlayerViewState extends State<CreatePlayerView> {
  /// GlobalKey for ScaffoldMessenger to show snackbars
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late final AppDatabase db;

  /// Controller for the player name input field.
  final _nameController = TextEditingController();

  /// Controller for the player description input field.
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(title: Text(loc.create_player)),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            children: [
              FormPanel(
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledSection(
                      title: loc.player_name,
                      description: loc.player_name_description,
                      control: TextInputField(
                        controller: _nameController,
                        hintText: loc.player_name,
                        maxLength: Constants.MAX_PLAYER_NAME_LENGTH,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                      ),
                    ),
                    LabeledSection(
                      title: loc.description,
                      description: loc.player_description_hint,
                      control: TextInputField(
                        controller: _descriptionController,
                        hintText: loc.description,
                        minLines: 4,
                        maxLines: 4,
                        maxLength: Constants.MAX_PLAYER_DESCRIPTION_LENGTH,
                        showCounterText: true,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: BottomAnimatedButton(
                  buttonText: loc.create_player,
                  sizeRelativeToWidth: 0.95,
                  buttonType: ButtonType.primary,
                  onPressed: _nameController.text.trim().isEmpty
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          final success = await db.playerDao.addPlayer(
                            player: Player(
                              name: name,
                              description: _descriptionController.text.trim(),
                            ),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            unawaited(HapticFeedback.successNotification());
                            Navigator.pop(context);
                          } else {
                            unawaited(HapticFeedback.errorNotification());
                            showSnackbar(
                              message: loc.could_not_add_player(name),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays a snackbar with the given [message].
  void showSnackbar({required String message}) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(CustomSnackBar(message: message));
    }
  }
}
