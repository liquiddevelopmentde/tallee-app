import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/value_constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

class EditPlayerView extends StatefulWidget {
  const EditPlayerView({
    super.key,
    required this.playerToEdit,
    this.onPlayerChanged,
  });

  final Player playerToEdit;
  final VoidCallback? onPlayerChanged;

  @override
  State<EditPlayerView> createState() => _EditPlayerViewState();
}

class _EditPlayerViewState extends State<EditPlayerView> {
  late final AppDatabase db;
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final playerNameController = TextEditingController();
  final playerDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);

    playerNameController.text = widget.playerToEdit.name;
    playerNameController.addListener(() => setState(() {}));

    playerDescriptionController.text = widget.playerToEdit.description;
    playerDescriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    playerNameController.dispose();
    playerDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(title: Text(loc.edit_player)),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: CustomTheme.standardMargin,
                child: TextInputField(
                  controller: playerNameController,
                  hintText: loc.player_name,
                  maxLength: MAX_PLAYER_NAME_LENGTH,
                ),
              ),
              Container(
                margin: CustomTheme.standardMargin,
                child: TextInputField(
                  controller: playerDescriptionController,
                  hintText: loc.description,
                  maxLength: MAX_PLAYER_DESCRIPTION_LENGTH,
                  minLines: 8,
                  maxLines: 8,
                  showCounterText: true,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BottomAnimatedButton(
                  sizeRelativeToWidth: 0.95,
                  buttonText: loc.save_changes,
                  buttonType: ButtonType.primary,
                  onPressed: enableSaveButton ? savePlayer : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get enableSaveButton =>
      !isNameInputEmpty && (hasNameChanged || hasDescriptionChanged);

  bool get hasNameChanged =>
      widget.playerToEdit.name != playerNameController.text.trim();

  bool get hasDescriptionChanged =>
      widget.playerToEdit.description !=
      playerDescriptionController.text.trim();

  bool get isNameInputEmpty => playerNameController.text.trim().isEmpty;

  Future<void> savePlayer() async {
    final loc = AppLocalizations.of(context);
    late bool success;
    Player? updatedPlayer;

    final result = await editPlayer();
    success = result.$1;
    updatedPlayer = result.$2;

    if (!mounted) return;

    if (success) {
      HapticFeedback.successNotification();
      widget.onPlayerChanged?.call();
      if (mounted) {
        Navigator.pop(context, updatedPlayer);
      }
    } else {
      if (mounted) {
        HapticFeedback.errorNotification();
      }
      showSnackbar(message: loc.error_editing_player);
    }
  }

  /// Handles editing an existing player and returns whether the operation was successful.
  Future<(bool, Player)> editPlayer() async {
    final newName = playerNameController.text.trim();
    final newDescription = playerDescriptionController.text.trim();

    Player updatedPlayer = widget.playerToEdit.copyWith(
      name: newName,
      description: newDescription,
    );

    bool success = true;

    if (newName != widget.playerToEdit.name) {
      success &= await db.playerDao.updatePlayerName(
        playerId: widget.playerToEdit.id,
        name: updatedPlayer.name,
      );
    }

    if (newDescription != widget.playerToEdit.description) {
      success &= await db.playerDao.updatePlayerDescription(
        playerId: widget.playerToEdit.id,
        description: updatedPlayer.description,
      );
    }

    return (success, updatedPlayer);
  }

  /// Displays a snackbar with the given message and optional action.
  ///
  /// [message] The message to display in the snackbar.
  void showSnackbar({required String message}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(CustomSnackBar(message: message));
    }
  }
}
