import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/snack_bar_extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/core/theme/app_spacing.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_circle.dart';
import 'package:tallee/presentation/widgets/custom_showcase_widget.dart';
import 'package:tallee/presentation/widgets/dialog/selection_sheet.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';
import 'package:tallee/state/showcase_provider.dart';

class CreateGameView extends StatefulWidget {
  /// A stateful widget for creating or editing a game.
  /// - [gameToEdit] An optional game to prefill the fields
  /// - [onGameChanged] Callback to invoke when the game is created or edited
  /// - [canChangeRuleset]: Whether the user can change the ruleset of the game
  /// - [requiredRuleset]: An optional ruleset used to enforce a specific game
  /// type. This is used during match sharing to ensure the game is compatible with the shared data.
  const CreateGameView({
    super.key,
    required this.onGameChanged,
    this.gameToEdit,
    this.canChangeRuleset = true,
    this.requiredRuleset,
  });

  final VoidCallback onGameChanged;
  final Game? gameToEdit;
  final bool canChangeRuleset;

  final Ruleset? requiredRuleset;

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  late final AppDatabase db;

  late List<(Ruleset, String)> rulesets;
  late List<(AppColor, String)> colors;

  final GlobalKey createGameViewGameNameKey = GlobalKey();
  final String createGameViewGameNameIdentifier = 'create_game_view_game_name';

  final GlobalKey createGameViewGameRulesetKey = GlobalKey();
  final String createGameViewGameRulesetIdentifier =
      'create_game_view_game_ruleset';

  final GlobalKey createGameViewCreateGameKey = GlobalKey();
  final String createGameViewCreateGameIdentifier =
      'create_game_view_create_game';

  late final ShowcaseProvider showcaseProvider;

  late String selectedGroupId;
  late final List<Group> filteredGroups;

  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameDescriptionController =
      TextEditingController();

  int selectedLives = 3;
  Ruleset selectedRuleset = Ruleset.winner;

  AppColor? selectedColor;
  AppColor? lastSelectedColor;

  bool get canCreateGame => gameNameController.text.trim().isNotEmpty;

  bool get isEditMode => widget.gameToEdit != null;

  bool get hasChangedName =>
      widget.gameToEdit!.name != gameNameController.text.trim();

  bool get hasChangedRuleset => widget.gameToEdit!.ruleset != selectedRuleset;

  bool get hasChangedColor => widget.gameToEdit!.color != selectedColor;

  bool get hasChangedDescription =>
      widget.gameToEdit!.description != gameDescriptionController.text.trim();

  bool get hasChangedGame {
    if (hasChangedName) return true;
    if (hasChangedRuleset) return true;
    if (hasChangedColor) return true;
    if (hasChangedDescription) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();
    showcaseProvider = context.read<ShowcaseProvider>();

    if (widget.requiredRuleset != null) {
      selectedRuleset = widget.requiredRuleset!;
    }

    gameNameController.addListener(() => setState(() {}));
    gameDescriptionController.addListener(() => setState(() {}));

    if (isEditMode) {
      gameNameController.text = widget.gameToEdit!.name;
      gameDescriptionController.text = widget.gameToEdit!.description;
      selectedRuleset = widget.gameToEdit!.ruleset;
      selectedColor = widget.gameToEdit!.color;
    } else {
      handleShowcase(
        widgetKeys: [
          createGameViewGameNameKey,
          createGameViewGameRulesetKey,
          createGameViewCreateGameKey,
        ],
        identifiers: [
          createGameViewGameNameIdentifier,
          createGameViewGameRulesetIdentifier,
          createGameViewCreateGameIdentifier,
        ],
        showcaseProvider: showcaseProvider,
        context: context,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    rulesets = List.generate(
      Ruleset.values.length,
      (index) => (
        Ruleset.values[index],
        Ruleset.values[index].toLocalizedString(context),
      ),
    );
    colors = List.generate(
      AppColor.values.length,
      (index) => (
        AppColor.values[index],
        AppColor.values[index].toLocalizedString(context),
      ),
    );
  }

  @override
  void dispose() {
    gameNameController.dispose();
    gameDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          try {
            ShowcaseView.get().dismiss();
          } catch (_) {}
        }
      },
      child: ScaffoldMessenger(
        child: Builder(
          builder: (scaffoldContext) => Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(isEditMode ? loc.edit_game : loc.create_game),
            ),
            // Game name input field
            body: SafeArea(
              maintainBottomViewPadding: true,
              minimum: AppSpacing.pagePadding,
              child: Column(
                spacing: 10,
                children: [
                  // Game name textfield
                  CustomShowcaseWidget(
                    showcaseKey: createGameViewGameNameKey,
                    description: loc.showcase_create_game_name,
                    child: TextInputField(
                      controller: gameNameController,
                      maxLength: MAX_MATCH_NAME_LENGTH,
                      hintText: loc.game_name,
                    ),
                  ),

                  // Choose ruleset tile
                  CustomShowcaseWidget(
                    showcaseKey: createGameViewGameRulesetKey,
                    description: loc.showcase_create_game_ruleset,
                    child: ChooseTile(
                      enabled: widget.canChangeRuleset,
                      title: loc.ruleset,
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Icon(selectedRuleset.icon, size: 16),
                            Text(
                              selectedRuleset.toLocalizedString(context),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () => showRulesetSheet(loc),
                    ),
                  ),

                  // Choose color tile
                  ChooseTile(
                    title: loc.color,
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          if (selectedColor == null) ...[
                            const ColoredCircle(isRandomColor: true),
                            Text(loc.random_color, textAlign: TextAlign.right),
                          ] else ...[
                            ColoredCircle(color: selectedColor),
                            Text(
                              selectedColor!.toLocalizedString(context),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ],
                      ),
                    ),
                    onPressed: () => showColorSheet(loc),
                  ),

                  // Description input field
                  TextInputField(
                    controller: gameDescriptionController,
                    hintText: loc.description,
                    minLines: 6,
                    maxLines: 6,
                    maxLength: MAX_GAME_DESCRIPTION_LENGTH,
                    showCounterText: true,
                    textInputAction: TextInputAction.done,
                  ),

                  const Spacer(),

                  if (isEditMode)
                    // Edit game button
                    BottomAnimatedButton(
                      text: loc.save_changes,
                      onPressed: hasChangedGame && canCreateGame
                          ? saveGame
                          : null,
                    )
                  else
                    // Create game button
                    CustomShowcaseWidget(
                      showcaseKey: createGameViewCreateGameKey,
                      description: loc.showcase_create_game_button,
                      child: BottomAnimatedButton(
                        text: loc.create_game,
                        onPressed: canCreateGame
                            ? () {
                                updateShowcase();
                                saveGame();
                              }
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Marks the identifier as seen after the showcase is shown.
  void updateShowcase() {
    if (showcaseProvider.shouldShowShowcase(createGameViewGameNameIdentifier)) {
      showcaseProvider.markAsSeen(createGameViewGameNameIdentifier);
      showcaseProvider.markAsSeen(createGameViewGameRulesetIdentifier);
      showcaseProvider.markAsSeen(createGameViewCreateGameIdentifier);
    }
  }

  /// Handles saving a game or updating an existing game and shows a error
  /// message if not successfull.
  ///
  /// Returns true if all database operations are successful, false otherwise.
  Future<bool> saveGame() async {
    Game newGame;
    bool success;

    final name = gameNameController.text.trim();
    final description = gameDescriptionController.text.trim();
    final ruleset = selectedRuleset;
    final AppColor? color = selectedColor;
    final AppColor randomColor = AppColor.randomColor(
      exclude: [lastSelectedColor, if (isEditMode) widget.gameToEdit!.color],
    );

    if (isEditMode) {
      (newGame: newGame, success: success) = await handleGameUpdate(
        newName: name,
        newDesc: description,
        newRuleset: ruleset,
        newColor: color ?? randomColor,
      );
    } else {
      newGame = Game(
        name: name,
        description: description,
        ruleset: ruleset,
        color: color ?? randomColor,
      );
      success = await db.gameDao.addGame(game: newGame);
    }

    handleSaveNavigation(success, newGame);
    return success;
  }

  /// Handles navigation after saving a game.
  ///
  /// If the saving was successful, it triggers onGameChanged an pops the game.
  /// If not, it shows a snackbar
  void handleSaveNavigation(bool success, Game newGame) {
    if (success) {
      Haptics.successNotification();
      widget.onGameChanged.call();
      if (mounted) Navigator.of(context).pop((updatedGame: newGame));
    } else {
      // Error handling
      Haptics.errorNotification();
      if (mounted) {
        final loc = AppLocalizations.of(context);
        context.showSnackBar(
          message: isEditMode
              ? loc.error_editing_game
              : loc.error_creating_game,
        );
      }
    }
  }

  /// Handles updating an existing game in the database.
  /// Returns the success of the database operations an the new game.
  Future<({bool success, Game newGame})> handleGameUpdate({
    required String newName,
    required String newDesc,
    required Ruleset newRuleset,
    required AppColor newColor,
  }) async {
    final oldGame = widget.gameToEdit!;
    var success = true;

    if (hasChangedName) {
      success &= await db.gameDao.updateGameName(
        gameId: oldGame.id,
        name: newName,
      );
    }

    if (hasChangedRuleset) {
      success &= await db.gameDao.updateGameRuleset(
        gameId: oldGame.id,
        ruleset: newRuleset,
      );
    }

    if (hasChangedColor) {
      success &= await db.gameDao.updateGameColor(
        gameId: oldGame.id,
        color: newColor,
      );
    }

    if (hasChangedDescription) {
      success &= await db.gameDao.updateGameDescription(
        gameId: oldGame.id,
        description: newDesc,
      );
    }

    Game newGame = await db.gameDao.getGameById(gameId: oldGame.id);
    return (success: success, newGame: newGame);
  }

  /// Shows a bottom sheet to choose a ruleset
  void showRulesetSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext ctx) => SelectionSheet<Ruleset>(
        title: loc.ruleset,
        description: loc.choose_ruleset_description,
        values: Ruleset.values,
        selectedValue: selectedRuleset,
        leadingBuilder: (Ruleset rs) => Icon(rs.icon, size: 22),
        labelBuilder: (BuildContext ctx, Ruleset rs) =>
            rs.toLocalizedString(ctx),
        subtitleBuilder: (BuildContext ctx, Ruleset rs) =>
            rs.toLocalizedDescription(ctx),
        onValueUpdated: (Ruleset? rs) => setState(() {
          if (rs != null) selectedRuleset = rs;
        }),
      ),
    );
  }

  /// Shows a bottom sheet to choose a color
  void showColorSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext context) => SelectionSheet<AppColor?>(
        title: loc.color,
        description: loc.choose_color_description,
        values: const [null, ...AppColor.values],
        selectedValue: selectedColor,
        leadingBuilder: (AppColor? clr) => clr == null
            ? const ColoredCircle(isRandomColor: true)
            : ColoredCircle(color: clr),
        labelBuilder: (BuildContext ctx, AppColor? clr) =>
            clr == null ? loc.random_color : clr.toLocalizedString(ctx),
        onValueUpdated: (AppColor? clr) {
          if (clr == selectedColor) return;
          setState(() {
            lastSelectedColor = selectedColor;
            selectedColor = clr;
          });
        },
      ),
    );
  }
}
