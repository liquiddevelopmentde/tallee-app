import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/icon_utils.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
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

  late List<(Ruleset, String)> _rulesets;
  late List<(AppColor, String)> _colors;

  Ruleset? selectedRuleset = Ruleset.singleWinner;
  AppColor? selectedColor = AppColor.orange;

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
    _rulesets = List.generate(
      Ruleset.values.length,
      (index) => (
        Ruleset.values[index],
        translateRulesetToString(Ruleset.values[index], context),
      ),
    );
    _colors = List.generate(
      AppColor.values.length,
      (index) => (
        AppColor.values[index],
        translateAppColorToString(AppColor.values[index], context),
      ),
    );

    if (widget.gameToEdit != null) {
      _gameNameController.text = widget.gameToEdit!.name;
      _descriptionController.text = widget.gameToEdit!.description;
      selectedRuleset = widget.gameToEdit!.ruleset;
      selectedColor = widget.gameToEdit!.color;
      selectedRuleset = widget.gameToEdit!.ruleset;
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
                  trailing: getRulesetDropdown(loc),
                ),

              // Choose color tile
              ChooseTile(title: loc.color, trailing: getColorDropdown(loc)),

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
                child: BottomAnimatedButton(
                  buttonText: isEditing ? loc.edit_game : loc.create_game,
                  sizeRelativeToWidth: 0.95,
                  buttonType: ButtonType.primary,
                  onPressed:
                      _gameNameController.text.trim().isNotEmpty &&
                          selectedRuleset != null &&
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

  Widget getRulesetDropdown(AppLocalizations loc) {
    return CustomPopup(
      showArrow: true,
      arrowColor: CustomTheme.boxBorderColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      barrierColor: Colors.transparent,
      contentDecoration: CustomTheme.standardBoxDecoration,
      onBeforePopup: () async {
        await HapticFeedback.selectionClick();
      },
      onAfterPopup: () async {
        await HapticFeedback.selectionClick();
      },
      content: StatefulBuilder(
        builder: (context, setPopupState) => SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              _rulesets.length,
              (index) => GestureDetector(
                onTap: () async {
                  await HapticFeedback.selectionClick();
                  setState(() {
                    selectedRuleset = _rulesets[index].$1;
                  });
                  setPopupState(() {});
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: selectedRuleset == _rulesets[index].$1
                            ? CustomTheme.textColor.withAlpha(20)
                            : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Row(
                          spacing: 8,
                          children: [
                            Icon(getRulesetIcon(_rulesets[index].$1), size: 16),
                            Text(
                              _rulesets[index].$2,
                              style: const TextStyle(
                                color: CustomTheme.textColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index < _rulesets.length - 1)
                      const Divider(indent: 15, endIndent: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(getRulesetIcon(selectedRuleset!), size: 16),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              translateRulesetToString(selectedRuleset!, context),
              textAlign: TextAlign.right,
            ),
          ),
          Transform.rotate(
            angle: pi / 2,
            child: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }

  Widget getColorDropdown(AppLocalizations loc) {
    return CustomPopup(
      showArrow: true,
      arrowColor: CustomTheme.boxBorderColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      barrierColor: Colors.transparent,
      contentDecoration: CustomTheme.standardBoxDecoration,
      onBeforePopup: () async {
        await HapticFeedback.selectionClick();
      },
      onAfterPopup: () async {
        await HapticFeedback.selectionClick();
      },
      content: StatefulBuilder(
        builder: (context, setPopupState) => SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              _colors.length,
              (index) => GestureDetector(
                onTap: () async {
                  await HapticFeedback.selectionClick();
                  setState(() {
                    selectedColor = _colors[index].$1;
                  });
                  setPopupState(() {});
                },
                child: Column(
                  children: [
                    // Selected Highlighting
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: selectedColor == _colors[index].$1
                            ? CustomTheme.textColor.withAlpha(20)
                            : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          spacing: 8,
                          children: selectedColor == null
                              ? [Text(loc.none)]
                              : [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(left: 12),
                                    decoration: BoxDecoration(
                                      color: getColorFromAppColor(
                                        _colors[index].$1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    _colors[index].$2,
                                    style: const TextStyle(
                                      color: CustomTheme.textColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ),
                    if (index < _colors.length - 1)
                      const Divider(indent: 15, endIndent: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          // Selected Color
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: getColorFromAppColor(selectedColor!),
              shape: BoxShape.circle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(translateAppColorToString(selectedColor!, context)),
          ),
          Transform.rotate(
            angle: pi / 2,
            child: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
