import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/game.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/custom_width_button.dart';
import 'package:tallee/presentation/widgets/player_selection.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';

class CreateMatchView extends StatefulWidget {
  /// A view that allows creating a new match
  /// [onWinnerChanged]: Optional callback invoked when the winner is changed
  const CreateMatchView({
    super.key,
    this.onWinnerChanged,
    this.matchToEdit,
    this.onMatchUpdated,
  });

  /// Optional callback invoked when the winner is changed
  final VoidCallback? onWinnerChanged;

  /// Optional callback invoked when the match is updated
  final void Function(Match)? onMatchUpdated;

  /// An optional match to prefill the fields
  final Match? matchToEdit;

  @override
  State<CreateMatchView> createState() => _CreateMatchViewState();
}

class _CreateMatchViewState extends State<CreateMatchView> {
  late final AppDatabase db;

  /// Controller for the match name input field
  final TextEditingController _matchNameController = TextEditingController();

  /// Hint text for the match name input field
  String? hintText;

  /// List of all groups from the database
  List<Group> groupsList = [];

  /// List of all players from the database
  List<Player> playerList = [];

  /// List of players filtered based on the selected group
  /// If a group is selected, this list contains all players from [playerList]
  /// who are not members of the selected group. If no group is selected,
  /// this list is identical to [playerList].
  /*List<Player> filteredPlayerList = [];*/

  /// The currently selected group
  Group? selectedGroup;

  /// The index of the currently selected game in [games] to mark it in
  /// the [ChooseGameView]
  int selectedGameIndex = -1;

  /// The currently selected players
  List<Player> selectedPlayers = [];

  /// GlobalKey for ScaffoldMessenger to show snackbars
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _matchNameController.addListener(() {
      setState(() {});
    });

    db = Provider.of<AppDatabase>(context, listen: false);

    Future.wait([
      db.groupDao.getAllGroups(),
      db.playerDao.getAllPlayers(),
    ]).then((result) async {
      groupsList = result[0] as List<Group>;
      playerList = result[1] as List<Player>;

      // If a match is provided, prefill the fields
      if (widget.matchToEdit != null) {
        prefillMatchDetails();
      }
    });
  }

  @override
  void dispose() {
    _matchNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context);
    hintText ??= loc.match_name;
  }

  List<(String, String, Ruleset)> games = [
    ('Example Game 1', 'This is a description', Ruleset.lowestScore),
    ('Example Game 2', '', Ruleset.singleWinner),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final buttonText = widget.matchToEdit != null
        ? loc.save_changes
        : loc.create_match;
    final viewTitle = widget.matchToEdit != null
        ? loc.edit_match
        : loc.create_new_match;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(title: Text(viewTitle)),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: CustomTheme.tileMargin,
                child: TextInputField(
                  controller: _matchNameController,
                  hintText: hintText ?? '',
                  maxLength: Constants.MAX_MATCH_NAME_LENGTH,
                ),
              ),
              ChooseTile(
                title: loc.game,
                trailingText: selectedGameIndex == -1
                    ? loc.none
                    : games[selectedGameIndex].$1,
                onPressed: () async {
                  selectedGameIndex = await Navigator.of(context).push(
                    adaptivePageRoute(
                      builder: (context) => ChooseGameView(
                        games: games,
                        initialGameIndex: selectedGameIndex,
                      ),
                    ),
                  );
                  setState(() {
                    if (selectedGameIndex != -1) {
                      hintText = games[selectedGameIndex].$1;
                    } else {
                      hintText = loc.match_name;
                    }
                  });
                },
              ),
              ChooseTile(
                title: loc.group,
                trailingText: selectedGroup == null
                    ? loc.none_group
                    : selectedGroup!.name,
                onPressed: () async {
                  // Remove all players from the previously selected group from
                  // the selected players list, in case the user deselects the
                  // group or selects a different group.
                  selectedPlayers.removeWhere(
                    (player) =>
                        selectedGroup?.members.any(
                          (member) => member.id == player.id,
                        ) ??
                        false,
                  );

                  selectedGroup = await Navigator.of(context).push(
                    adaptivePageRoute(
                      builder: (context) => ChooseGroupView(
                        groups: groupsList,
                        initialGroupId: selectedGroup?.id ?? '',
                      ),
                    ),
                  );

                  setState(() {
                    if (selectedGroup != null) {
                      setState(() {
                        selectedPlayers += [...selectedGroup!.members];
                      });
                    }
                  });
                },
              ),
              Expanded(
                child: PlayerSelection(
                  key: ValueKey(selectedGroup?.id ?? 'no_group'),
                  initialSelectedPlayers: selectedPlayers,
                  onChanged: (value) {
                    setState(() {
                      selectedPlayers = value;
                      removeGroupWhenNoMemberLeft();
                    });
                  },
                ),
              ),
              CustomWidthButton(
                text: buttonText,
                sizeRelativeToWidth: 0.95,
                buttonType: ButtonType.primary,
                onPressed: _enableCreateGameButton()
                    ? () {
                        buttonNavigation(context);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines whether the "Create Match" button should be enabled.
  ///
  /// Returns `true` if:
  /// - A ruleset is selected AND
  /// - Either a group is selected OR at least 2 players are selected
  bool _enableCreateGameButton() {
    return (selectedGroup != null || (selectedPlayers.length > 1));
  }

  // If a match was provied to the view, it updates the match in the database
  // and navigates back to the previous screen.
  // If no match was provided, it creates a new match in the database and
  // navigates to the MatchResultView for the newly created match.
  void buttonNavigation(BuildContext context) async {
    if (widget.matchToEdit != null) {
      await updateMatch();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      final match = await createMatch();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          adaptivePageRoute(
            fullscreenDialog: true,
            builder: (context) => MatchResultView(
              match: match,
              onWinnerChanged: widget.onWinnerChanged,
            ),
          ),
        );
      }
    }
  }

  /// Updates attributes of the existing match in the database based on the
  /// changes made in the edit view.
  Future<void> updateMatch() async {
    //TODO: Remove when Games implemented
    final tempGame = await getTemporaryGame();

    final updatedMatch = Match(
      id: widget.matchToEdit!.id,
      name: _matchNameController.text.isEmpty
          ? (hintText ?? '')
          : _matchNameController.text.trim(),
      group: selectedGroup,
      players: selectedPlayers,
      game: tempGame,
      winner: widget.matchToEdit!.winner,
      createdAt: widget.matchToEdit!.createdAt,
      endedAt: widget.matchToEdit!.endedAt,
      notes: widget.matchToEdit!.notes,
    );

    if (widget.matchToEdit!.name != updatedMatch.name) {
      await db.matchDao.updateMatchName(
        matchId: widget.matchToEdit!.id,
        newName: updatedMatch.name,
      );
    }

    if (widget.matchToEdit!.group?.id != updatedMatch.group?.id) {
      await db.matchDao.updateMatchGroup(
        matchId: widget.matchToEdit!.id,
        newGroupId: updatedMatch.group?.id,
      );
    }

    // Add players who are in updatedMatch but not in the original match
    for (var player in updatedMatch.players) {
      if (!widget.matchToEdit!.players.any((p) => p.id == player.id)) {
        await db.playerMatchDao.addPlayerToMatch(
          matchId: widget.matchToEdit!.id,
          playerId: player.id,
        );
      }
    }

    // Remove players who are in the original match but not in updatedMatch
    for (var player in widget.matchToEdit!.players) {
      if (!updatedMatch.players.any((p) => p.id == player.id)) {
        await db.playerMatchDao.removePlayerFromMatch(
          matchId: widget.matchToEdit!.id,
          playerId: player.id,
        );
        if (widget.matchToEdit!.winner?.id == player.id) {
          updatedMatch.winner = null;
        }
      }
    }

    widget.onMatchUpdated?.call(updatedMatch);
  }

  // Creates a new match and adds it to the database.
  // Returns the created match.
  Future<Match> createMatch() async {
    final tempGame = await getTemporaryGame();

    Match match = Match(
      name: _matchNameController.text.isEmpty
          ? (hintText ?? '')
          : _matchNameController.text.trim(),
      createdAt: DateTime.now(),
      group: selectedGroup,
      players: selectedPlayers,
      game: tempGame,
    );
    await db.matchDao.addMatch(match: match);
    return match;
  }

  // TODO: Remove when games fully implemented
  Future<Game> getTemporaryGame() async {
    Game? game;

    // No game is selected
    if (selectedGameIndex == -1) {
      // Use the first game as default if none selected
      final selectedGame = games[0];
      game = Game(
        name: selectedGame.$1,
        description: selectedGame.$2,
        ruleset: selectedGame.$3,
        color: GameColor.blue,
        icon: '',
      );
    } else {
      // Use the selected game from the list
      final selectedGame = games[selectedGameIndex];
      game = Game(
        name: selectedGame.$1,
        description: selectedGame.$2,
        ruleset: selectedGame.$3,
        color: GameColor.blue,
        icon: '',
      );
    }
    // Add the game to the database if it doesn't exist
    await db.gameDao.addGame(game: game);
    return game;
  }

  // If a match was provided to the view, this method prefills the input fields
  void prefillMatchDetails() {
    final match = widget.matchToEdit!;
    _matchNameController.text = match.name;
    selectedPlayers = match.players;

    if (match.group != null) {
      selectedGroup = match.group;
    }
  }

  // If none of the selected players are from the currently selected group,
  // the group is also deselected.
  Future<void> removeGroupWhenNoMemberLeft() async {
    if (selectedGroup == null) return;

    if (!selectedPlayers.any(
      (player) =>
          selectedGroup!.members.any((member) => member.id == player.id),
    )) {
      setState(() {
        selectedGroup = null;
      });
    }
  }
}
