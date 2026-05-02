import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game/choose_color_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game/choose_ruleset_view.dart';
import 'package:tallee/presentation/widgets/buttons/custom_width_button.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dialog/custom_dialog_action.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';

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

  /// The currently selected ruleset for the game.
  Ruleset? selectedRuleset;

  /// The index of the currently selected ruleset.
  int selectedRulesetIndex = -1;

  /// A list of available rulesets and their localized names.
  late List<(Ruleset, String)> _rulesets;

  /// The currently selected color for the game.
  GameColor? selectedColor;

  /// Controller for the game name input field.
  final _gameNameController = TextEditingController();

  /// Controller for the game description input field.
  final _descriptionController = TextEditingController();

  /// The ID of the currently selected group.
  late String selectedGroupId;

  /// A controller for the search bar input field.
  final TextEditingController controller = TextEditingController();

  /// A list of groups filtered based on the search query.
  late final List<Group> filteredGroups;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _gameNameController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rulesets = [
      (
        Ruleset.singleWinner,
        translateRulesetToString(Ruleset.singleWinner, context),
      ),
      (
        Ruleset.singleLoser,
        translateRulesetToString(Ruleset.singleLoser, context),
      ),
      (
        Ruleset.highestScore,
        translateRulesetToString(Ruleset.highestScore, context),
      ),
      (
        Ruleset.lowestScore,
        translateRulesetToString(Ruleset.lowestScore, context),
      ),
      (
        Ruleset.multipleWinners,
        translateRulesetToString(Ruleset.multipleWinners, context),
      ),
    ];

    if (widget.gameToEdit != null) {
      _gameNameController.text = widget.gameToEdit!.name;
      _descriptionController.text = widget.gameToEdit!.description;
      selectedRuleset = widget.gameToEdit!.ruleset;
      selectedColor = widget.gameToEdit!.color;

      selectedRulesetIndex = _rulesets.indexWhere(
        (r) => r.$1 == selectedRuleset,
      );
    }
  }

  @override
  void dispose() {
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
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(
          title: Text(isEditing ? loc.edit_game : loc.create_game),
          actions: [
            if (isEditMode())
              IconButton(
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
                      content: Text(dialogContent),
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
          child: Column(
            children: [
              // Game name input field
              Container(
                margin: CustomTheme.tileMargin,
                child: TextInputField(
                  controller: _gameNameController,
                  maxLength: Constants.MAX_MATCH_NAME_LENGTH,
                  hintText: loc.game_name,
                ),
              ),

              // Choose ruleset tile
              if (!isEditMode())
                ChooseTile(
                  title: loc.ruleset,
                  trailingText: selectedRuleset == null
                      ? loc.none
                      : translateRulesetToString(selectedRuleset!, context),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Ruleset?>(
                      adaptivePageRoute(
                        builder: (context) => ChooseRulesetView(
                          rulesets: _rulesets,
                          initialRulesetIndex: selectedRulesetIndex,
                        ),
                      ),
                    );
                    if (mounted) {
                      setState(() {
                        selectedRuleset = result;
                        selectedRulesetIndex = result == null
                            ? -1
                            : _rulesets.indexWhere((r) => r.$1 == result);
                      });
                    }
                  },
                ),

              // Choose color tile
              ChooseTile(
                title: loc.color,
                trailingText: selectedColor == null
                    ? loc.none
                    : translateGameColorToString(selectedColor!, context),
                onPressed: () async {
                  final result = await Navigator.of(context).push<GameColor?>(
                    adaptivePageRoute(
                      builder: (context) =>
                          ChooseColorView(initialColor: selectedColor),
                    ),
                  );
                  if (mounted) {
                    setState(() {
                      selectedColor = result;
                    });
                  }
                },
              ),

              // Description input field
              Container(
                margin: CustomTheme.tileMargin,
                child: TextInputField(
                  controller: _descriptionController,
                  hintText: loc.description,
                  minLines: 6,
                  maxLines: 6,
                  maxLength: Constants.MAX_GAME_DESCRIPTION_LENGTH,
                  showCounterText: true,
                ),
              ),

              const Spacer(),

              // Create/Edit game button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomWidthButton(
                  text: isEditing ? loc.edit_game : loc.create_game,
                  sizeRelativeToWidth: 1,
                  buttonType: ButtonType.primary,
                  onPressed:
                      _gameNameController.text.trim().isNotEmpty &&
                          selectedRulesetIndex != -1 &&
                          selectedColor != null
                      ? () async {
                          Game newGame = Game(
                            name: _gameNameController.text.trim(),
                            description: _descriptionController.text.trim(),
                            ruleset: selectedRuleset!,
                            color: selectedColor!,
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
      await db.gameDao.updateGameName(
        gameId: oldGame.id,
        newName: newGame.name,
      );
    }

    if (oldGame.description != newGame.description) {
      await db.gameDao.updateGameDescription(
        gameId: oldGame.id,
        newDescription: newGame.description,
      );
    }

    if (oldGame.ruleset != newGame.ruleset) {
      await db.gameDao.updateGameRuleset(
        gameId: oldGame.id,
        newRuleset: newGame.ruleset,
      );
    }

    if (oldGame.color != newGame.color) {
      await db.gameDao.updateGameColor(
        gameId: oldGame.id,
        newColor: newGame.color,
      );
    }

    if (oldGame.icon != newGame.icon) {
      await db.gameDao.updateGameIcon(
        gameId: oldGame.id,
        newIcon: newGame.icon,
      );
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: CustomTheme.boxColor,
        ),
      );
    }
  }

  bool isEditMode() {
    return widget.gameToEdit != null;
  }
}
