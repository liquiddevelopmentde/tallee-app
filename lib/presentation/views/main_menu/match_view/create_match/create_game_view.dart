import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/icon_utils.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dropdown/labeled_dropdown.dart';
import 'package:tallee/presentation/widgets/dropdown/labeled_section.dart';
import 'package:tallee/presentation/widgets/form_panel.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

/// A stateful widget for creating or editing a game.
/// - [gameToEdit] An optional game to prefill the fields
/// - [onGameChanged] Callback to invoke when the game is created or edited
class CreateGameView extends StatefulWidget {
  const CreateGameView({
    super.key,
    required this.onGameChanged,
    this.gameToEdit,
    this.matchCount = 0,
  });

  /// Callback to invoke when the game is created or edited
  final VoidCallback onGameChanged;

  /// An optional game to prefill the fields
  final Game? gameToEdit;

  final int matchCount;

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  /// GlobalKey for ScaffoldMessenger to show snackbars
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late final AppDatabase db;

  late ValueNotifier<Ruleset> _rulesetNotifier;
  late ValueNotifier<AppColor> _colorNotifier;

  /// Controller for the game name input field.
  final _gameNameController = TextEditingController();

  /// Controller for the game description input field.
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _gameNameController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rulesetNotifier = ValueNotifier(
      widget.gameToEdit?.ruleset ?? Ruleset.singleWinner,
    );
    _colorNotifier = ValueNotifier(widget.gameToEdit?.color ?? AppColor.orange);

    if (widget.gameToEdit != null) {
      _gameNameController.text = widget.gameToEdit!.name;
      _descriptionController.text = widget.gameToEdit!.description;
    }
  }

  @override
  void dispose() {
    _rulesetNotifier.dispose();
    _colorNotifier.dispose();
    _gameNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    final isEditing = widget.gameToEdit != null;

    return ScaffoldMessenger(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(isEditing ? loc.edit_game : loc.create_game),
          actions: [
            if (isEditMode())
              HapticIconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  if (!context.mounted) return;

                  // Build the dialog content based on match count
                  final String dialogContent = widget.matchCount > 0
                      ? loc.delete_game_with_matches_warning(widget.matchCount)
                      : loc.this_cannot_be_undone;

                  showDialog<bool>(
                    context: context,
                    builder: (context) => CustomAlertDialog(
                      title: loc.delete_game,
                      content: Text(
                        dialogContent,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 15),
                      ),
                      actions: [
                        CustomDialogAction(
                          isDestructive: true,
                          onPressed: () => Navigator.of(context).pop(true),
                          text: loc.delete,
                        ),
                        CustomDialogAction(
                          onPressed: () => Navigator.of(context).pop(false),
                          buttonType: ButtonType.secondary,
                          text: loc.cancel,
                        ),
                      ],
                    ),
                  ).then((confirmed) async {
                    if (confirmed == true && context.mounted) {
                      // Delete assocaited matches
                      if (widget.matchCount > 0) {
                        await db.matchDao.deleteMatchesByGame(
                          gameId: widget.gameToEdit!.id,
                        );
                      }

                      // Delete the targetted game
                      bool success = await db.gameDao.deleteGame(
                        gameId: widget.gameToEdit!.id,
                      );

                      if (!context.mounted) return;
                      if (success) {
                        widget.onGameChanged.call();
                        Navigator.of(
                          context,
                        ).pop((game: widget.gameToEdit, delete: true));
                      } else {
                        if (!mounted) return;
                        showSnackbar(message: loc.error_deleting_game);
                      }
                    }
                  });
                },
              ),
          ],
        ),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            children: [
              FormPanel(
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game name input field
                    LabeledSection(
                      title: loc.game_name,
                      description: loc.game_name_description,
                      control: TextInputField(
                        controller: _gameNameController,
                        maxLength: Constants.MAX_MATCH_NAME_LENGTH,
                        hintText: loc.game_name,
                        autofocus: true,
                      ),
                    ),

                    // Choose ruleset
                    if (!isEditMode())
                      LabeledDropdown<Ruleset>(
                        title: loc.ruleset,
                        description: loc.ruleset_description,
                        hintText: loc.ruleset,
                        valueListenable: _rulesetNotifier,
                        options: [
                          for (final ruleset in Ruleset.values)
                            DropdownOption(
                              value: ruleset,
                              label: translateRulesetToString(ruleset, context),
                              leading: Icon(getRulesetIcon(ruleset), size: 16),
                            ),
                        ],
                        onChanged: (ruleset) {
                          if (ruleset == null) return;
                          _rulesetNotifier.value = ruleset;
                        },
                      ),

                    // Choose color
                    LabeledDropdown<AppColor>(
                      title: loc.color,
                      description: loc.color_description,
                      hintText: loc.color,
                      valueListenable: _colorNotifier,
                      options: [
                        for (final color in AppColor.values)
                          DropdownOption(
                            value: color,
                            label: translateAppColorToString(color, context),
                            leading: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: getColorFromAppColor(color),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                      onChanged: (color) {
                        if (color == null) return;
                        _colorNotifier.value = color;
                      },
                    ),

                    // Description input field
                    LabeledSection(
                      title: loc.description,
                      description: loc.game_notes_description,
                      control: TextInputField(
                        controller: _descriptionController,
                        hintText: loc.description,
                        minLines: 6,
                        maxLines: 6,
                        maxLength: Constants.MAX_GAME_DESCRIPTION_LENGTH,
                        showCounterText: true,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Create/Edit game button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: BottomAnimatedButton(
                  buttonText: isEditing ? loc.edit_game : loc.create_game,
                  sizeRelativeToWidth: 0.95,
                  buttonType: ButtonType.primary,
                  onPressed: _gameNameController.text.trim().isNotEmpty
                      ? () async {
                          Game newGame = Game(
                            name: _gameNameController.text.trim(),
                            description: _descriptionController.text.trim(),
                            ruleset: _rulesetNotifier.value,
                            color: _colorNotifier.value,
                          );
                          if (isEditing) {
                            await handleGameUpdate(newGame);
                          } else {
                            await handleGameCreation(newGame);
                          }
                          widget.onGameChanged.call();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pop((game: newGame, delete: false));
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles updating an existing game in the database.
  ///
  /// [newGame] The updated game object.
  Future<void> handleGameUpdate(Game newGame) async {
    final oldGame = widget.gameToEdit!;

    if (oldGame.name != newGame.name) {
      await db.gameDao.updateGameName(gameId: oldGame.id, name: newGame.name);
    }

    if (oldGame.description != newGame.description) {
      await db.gameDao.updateGameDescription(
        gameId: oldGame.id,
        description: newGame.description,
      );
    }

    if (oldGame.ruleset != newGame.ruleset) {
      await db.gameDao.updateGameRuleset(
        gameId: oldGame.id,
        ruleset: newGame.ruleset,
      );
    }

    if (oldGame.color != newGame.color) {
      await db.gameDao.updateGameColor(
        gameId: oldGame.id,
        color: newGame.color,
      );
    }

    if (oldGame.icon != newGame.icon) {
      await db.gameDao.updateGameIcon(gameId: oldGame.id, icon: newGame.icon);
    }
  }

  /// Handles creating a new game in the database.
  ///
  /// [newGame] The game object to be created.
  Future<void> handleGameCreation(Game newGame) async {
    await db.gameDao.addGame(game: newGame);
  }

  /// Displays a snackbar with the given message and optional action.
  ///
  /// [message] The message to display in the snackbar.
  void showSnackbar({required String message}) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(CustomSnackBar(message: message));
    }
  }

  bool isEditMode() {
    return widget.gameToEdit != null;
  }
}
