import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_teams/create_teams_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/player_selection.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';

class CreateMatchView extends StatefulWidget {
  /// A view that allows creating a new match
  /// - [onWinnerChanged]: Optional callback invoked when the winner is changed
  /// - [matchToEdit]: An optional match to prefill the fields for editing.
  /// - [onMatchUpdated]: Optional callback invoked when the match is updated (only in
  const CreateMatchView({
    super.key,
    this.onWinnerChanged,
    this.matchToEdit,
    this.onMatchUpdated,
    this.onMatchesUpdated,
  });

  final VoidCallback? onWinnerChanged;

  final VoidCallback? onMatchesUpdated;

  final void Function(Match)? onMatchUpdated;

  /// An optional match to prefill the fields for editing.
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

  List<Group> groupsList = [];
  List<Player> playerList = [];
  List<Game> gamesList = [];

  Group? selectedGroup;
  Game? selectedGame;
  bool isTeamMatch = false;
  List<Player> selectedPlayers = [];
  List<Team> selectedUnits = [];

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
      db.gameDao.getAllGames(),
    ]).then((result) async {
      groupsList = result[0] as List<Group>;
      playerList = result[1] as List<Player>;
      gamesList = (result[2] as List<Game>);

      // If a match is provided, prefill the fields
      if (isEditMode()) {
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final buttonText = isEditMode() ? loc.save_changes : loc.create_match;
    final viewTitle = isEditMode() ? loc.edit_match : loc.create_new_match;
    print(viewTitle);

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
              // Match name input field.
              Container(
                margin: CustomTheme.tileMargin,
                child: TextInputField(
                  controller: _matchNameController,
                  hintText: hintText ?? '',
                  maxLength: Constants.MAX_MATCH_NAME_LENGTH,
                ),
              ),

              // Game selection tile.
              if (!isEditMode())
                ChooseTile(
                  title: loc.game,
                  trailing: selectedGame == null
                      ? Text(loc.none_group)
                      : Text(selectedGame!.name),
                  onPressed: () async => await onChoosingGame(),
                ),

              // Group selection tile.
              if (!isEditMode() || !isMatchFinished())
                ChooseTile(
                  title: loc.group,
                  trailing: selectedGroup == null
                      ? Text(loc.none_group)
                      : Text(selectedGroup!.name),
                  onPressed: () async => onChoosingGroup(),
                ),

              if (!isEditMode())
                ChooseTile(
                  title: loc.team_match,
                  trailing: Switch.adaptive(
                    activeTrackColor: CustomTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: -15),
                    value: isTeamMatch,
                    onChanged: (value) => setState(() {
                      isTeamMatch = value;
                      // Always reset pairs to individual units when team match is active
                      // or when explicitly disabled, to ensure a clean state.
                      selectedUnits = selectedPlayers
                          .map((p) => Team(name: '', members: [p]))
                          .toList();
                    }),
                  ),
                ),

              // Player selection widget.
              if (!isEditMode() || !isMatchFinished()) ...[
                Expanded(
                  child: PlayerSelection(
                    key: ValueKey(selectedGroup?.id ?? 'no_group'),
                    initialSelectedUnits: selectedUnits,
                    pairingEnabled: !isTeamMatch,
                    onPlayerCreated: () => widget.onMatchesUpdated?.call(),
                    onChanged: (players, units) {
                      setState(() {
                        selectedPlayers = players;
                        selectedUnits = units;
                        // Do not auto-enable team match.
                        // Pairs are handled internally via selectedUnits.
                        removeGroupWhenNoMemberLeft();
                      });
                    },
                  ),
                ),
              ] else
                const Spacer(),

              // Create or save button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BottomAnimatedButton(
                  sizeRelativeToWidth: 0.95,
                  buttonType: ButtonType.primary,
                  onPressed: isSubmitButtonEnabled()
                      ? () {
                          submitButtonNavigation(context);
                        }
                      : null,
                  buttonText: buttonText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isEditMode() => widget.matchToEdit != null;

  bool isMatchFinished() => widget.matchToEdit?.endedAt != null;

  // If a match was provided to the view, this method prefills the input fields
  void prefillMatchDetails() {
    final match = widget.matchToEdit!;
    _matchNameController.text = match.name;
    selectedPlayers = match.players;
    selectedGame = match.game;
    isTeamMatch = match.isTeamMatch;

    if (match.teams != null && match.teams!.isNotEmpty) {
      selectedUnits = match.teams!;
    } else {
      selectedUnits = selectedPlayers
          .map((p) => Team(name: '', members: [p]))
          .toList();
    }

    if (match.group != null) {
      selectedGroup = match.group;
    }
  }

  Future<void> onChoosingGame() async {
    selectedGame = await Navigator.of(context).push(
      adaptivePageRoute(
        builder: (context) => ChooseGameView(
          games: gamesList,
          initialGame: selectedGame,
          onGamesUpdated: widget.onMatchesUpdated,
        ),
      ),
    );
    setState(() {
      if (selectedGame != null) {
        hintText = selectedGame!.name;
      } else {
        hintText = AppLocalizations.of(context).match_name;
      }
    });
  }

  Future<void> onChoosingGroup() async {
    final oldGroup = selectedGroup;
    final newGroup = await Navigator.of(context).push<Group?>(
      adaptivePageRoute(
        builder: (context) => ChooseGroupView(groups: groupsList),
      ),
    );

    if (newGroup?.id == oldGroup?.id) return;

    setState(() {
      final List<Player> oldMembers = oldGroup?.members ?? [];
      final List<Player> newMembers = newGroup?.members ?? [];

      // 1. Determine which players were in the old group but are NOT in the new group.
      // These players should be removed.
      final playersToRemove = oldMembers
          .where((oldM) => !newMembers.any((newM) => newM.id == oldM.id))
          .toList();

      // 2. Process current units to remove those players and dissolve broken pairs.
      final List<Team> updatedUnits = [];
      for (var unit in selectedUnits) {
        final remainingMembers = unit.members
            .where((m) => !playersToRemove.any((p) => p.id == m.id))
            .toList();

        if (remainingMembers.isEmpty) {
          // All members of this unit were removed.
          continue;
        } else if (remainingMembers.length < unit.members.length) {
          // Unit was a pair, but some members were removed -> dissolve it.
          for (var p in remainingMembers) {
            updatedUnits.add(Team(name: '', members: [p]));
          }
        } else {
          // Unit remains intact.
          updatedUnits.add(unit);
        }
      }

      // 3. Add players from the new group who aren't already selected.
      final currentPlayers = updatedUnits.expand((u) => u.members).toList();
      for (var member in newMembers) {
        if (!currentPlayers.any((p) => p.id == member.id)) {
          updatedUnits.add(Team(name: '', members: [member]));
        }
      }

      selectedGroup = newGroup;
      selectedUnits = updatedUnits;
      selectedPlayers = selectedUnits.expand((u) => u.members).toList();
      isTeamMatch = selectedUnits.any((u) => u.members.length > 1);
    });
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

  /// Determines whether the "Create Match" button should be enabled.
  ///
  /// Returns `true` if:
  /// - A game is selected AND
  /// - There are at least two participating units (teams or single players).
  bool isSubmitButtonEnabled() {
    if (selectedGame == null) return false;

    final int unitsCount = selectedUnits.isNotEmpty
        ? selectedUnits.where((u) => u.members.isNotEmpty).length
        : selectedPlayers.length;

    return unitsCount > 1;
  }

  /// Handles navigation when the create or save button is pressed.
  ///
  /// If a match is being edited, updates the match in the database.
  /// Otherwise, creates a new match and navigates to the MatchResultView.
  void submitButtonNavigation(BuildContext context) async {
    if (isEditMode()) {
      await updateMatch();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      final match = await createMatch();

      final hasPairs = selectedUnits.any((u) => u.members.length > 1);

      if (isTeamMatch && !hasPairs) {
        if (context.mounted) {
          Navigator.push(
            context,
            adaptivePageRoute(
              builder: (context) => CreateTeamsView(
                match: match,
                onWinnerChanged: widget.onWinnerChanged,
              ),
            ),
          );
        }
      } else {
        // If it has pairs, we treat it as a team match but the teams are already set
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
  }

  /// Updates the existing match in the database.
  Future<void> updateMatch() async {
    final updatedMatch = Match(
      id: widget.matchToEdit!.id,
      name: _matchNameController.text.isEmpty
          ? (hintText ?? '')
          : _matchNameController.text.trim(),
      group: selectedGroup,
      players: selectedPlayers,
      game: selectedGame!,
      createdAt: widget.matchToEdit!.createdAt,
      endedAt: widget.matchToEdit!.endedAt,
      notes: widget.matchToEdit!.notes,
    );

    if (widget.matchToEdit!.name != updatedMatch.name) {
      await db.matchDao.updateMatchName(
        matchId: widget.matchToEdit!.id,
        name: updatedMatch.name,
      );
    }

    if (widget.matchToEdit!.group?.id != updatedMatch.group?.id) {
      await db.matchDao.updateMatchGroup(
        matchId: widget.matchToEdit!.id,
        groupId: updatedMatch.group?.id,
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
      }
    }

    widget.onMatchUpdated?.call(updatedMatch);
  }

  // Creates a new match and adds it to the database.
  // Returns the created match.
  Future<Match> createMatch() async {
    final hasPairs = selectedUnits.any((u) => u.members.length > 1);

    Match match = Match(
      name: _matchNameController.text.isEmpty
          ? (hintText ?? '')
          : _matchNameController.text.trim(),
      createdAt: DateTime.now(),
      group: selectedGroup,
      players: selectedPlayers,
      isTeamMatch: isTeamMatch,
      teams: selectedUnits,
      game: selectedGame!,
    );

    // Matches with pairs or regular matches are saved directly.
    // Manual Team matches without pre-defined pairs are saved in OrganizeTeamsView
    if (!isTeamMatch || hasPairs) {
      await db.matchDao.addMatch(match: match);
    }
    return match;
  }
}
