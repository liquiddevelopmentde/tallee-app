import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_teams/create_teams_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_adaptive_switch.dart';
import 'package:tallee/presentation/widgets/player_selection.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';

class CreateMatchView extends StatefulWidget {
  /// A view that allows creating a new match
  /// - [onWinnerChanged]: Optional callback invoked when the winner is changed
  /// - [editMode]: a bool which sets the view to edit mode
  /// - [matchToPrefill]: An optional match to prefill the fields
  /// - [onMatchUpdated]: Optional callback invoked when the match is updated
  const CreateMatchView({
    super.key,
    this.onWinnerChanged,
    this.editMode = false,
    this.matchToPrefill,
    this.onMatchUpdated,
    this.onMatchesUpdated,
  });

  final VoidCallback? onWinnerChanged;

  final VoidCallback? onMatchesUpdated;

  final void Function(Match)? onMatchUpdated;

  /// An optional match to prefill the fields for editing.
  final bool editMode;

  /// An optional match to prefill the fields for creating a match with the same settings
  final Match? matchToPrefill;

  @override
  State<CreateMatchView> createState() => _CreateMatchViewState();
}

class _CreateMatchViewState extends State<CreateMatchView> {
  late final AppDatabase db;

  /// Controller for the match name input field
  final TextEditingController matchNameController = TextEditingController();

  /// Hint text for the match name input field
  String? hintText;

  List<Group> groups = [];
  List<Player> players = [];
  List<Game> games = [];

  Group? selectedGroup;
  DateTime? selectedCreationDate;
  Game? selectedGame;
  bool isTeamMatch = false;
  List<Player> selectedPlayers = [];
  List<Team> selectedUnits = [];

  /// GlobalKey for ScaffoldMessenger to show snackbars
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    matchNameController.addListener(() {
      setState(() {});
    });

    loadData();
  }

  @override
  void dispose() {
    matchNameController.dispose();
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
    final buttonText = widget.editMode ? loc.save_changes : loc.create_match;
    final viewTitle = widget.editMode ? loc.edit_match : loc.create_new_match;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(title: Text(viewTitle)),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Match name input field.
              Container(
                margin: CustomTheme.tileMargin,
                child: TextInputField(
                  controller: matchNameController,
                  hintText: hintText ?? '',
                  maxLength: Constants.MAX_MATCH_NAME_LENGTH,
                ),
              ),

              // Game selection tile.
              if (!widget.editMode)
                ChooseTile(
                  title: loc.game,
                  trailing: selectedGame == null
                      ? Text(loc.none_group)
                      : Text(selectedGame!.name),
                  onPressed: () async => await onChoosingGame(),
                ),

              // Group selection tile.
              ChooseTile(
                title: loc.group,
                trailing: selectedGroup == null
                    ? Text(loc.none_group)
                    : Text(selectedGroup!.name),
                onPressed: () async => onChoosingGroup(),
              ),

              // Creation date selection tile.
              if (widget.editMode)
                ChooseTile(
                  title: loc.creation_date,
                  trailing: selectedCreationDate == null
                      ? Text(loc.today)
                      : Text(
                          DateFormat.yMMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(selectedCreationDate!),
                        ),
                  onPressed: () async => onCreationDateSelection(),
                ),

              // Team match switch
              if (!widget.editMode)
                ChooseTile(
                  title: loc.team_match,
                  trailing: CustomAdaptiveSwitch(
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

              // Create or save button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BottomAnimatedButton(
                  sizeRelativeToWidth: 0.95,
                  buttonType: ButtonType.primary,
                  onPressed: isSubmitButtonEnabled()
                      ? () => submitButtonNavigation(context)
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

  void loadData() {
    db = Provider.of<AppDatabase>(context, listen: false);

    Future.wait([
      db.groupDao.getAllGroups(),
      db.playerDao.getAllPlayers(),
      db.gameDao.getAllGames(),
    ]).then((result) async {
      groups = result[0] as List<Group>
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      players = result[1] as List<Player>
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      games = (result[2] as List<Game>)
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

      // If a match is provided, prefill the fields
      if (widget.matchToPrefill != null) {
        prefillMatchDetails();
      }
    });
  }

  // If a match was provided to the view, this method prefills the input fields
  void prefillMatchDetails() {
    final Match match = widget.matchToPrefill!;

    setState(() {
      matchNameController.text = match.name;
      selectedPlayers = match.players;
      selectedGame = match.game;
      isTeamMatch = match.isTeamMatch;

      selectedCreationDate = nullIfToday(match.createdAt);

      if (match.teams != null &&
          match.teams!.isNotEmpty &&
          !match.isTeamMatch) {
        selectedUnits = match.teams!;
      } else {
        selectedUnits = selectedPlayers
            .map((p) => Team(name: '', members: [p]))
            .toList();
      }

      if (match.group != null) {
        selectedGroup = match.group;
      }
    });
  }

  Future<void> onChoosingGame() async {
    selectedGame = await Navigator.of(context).push(
      adaptivePageRoute(
        builder: (context) => ChooseGameView(
          games: games,
          initialGames: [?selectedGame],
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
        builder: (context) =>
            ChooseGroupView(groups: groups, initialGroups: [?oldGroup]),
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
      isTeamMatch |= selectedUnits.any((u) => u.members.length > 1);
    });
  }

  Future<void> onCreationDateSelection() async {
    await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: CustomTheme.primaryColor,
              onPrimary: CustomTheme.textColor,
              surface: CustomTheme.boxColor,
              onSurface: CustomTheme.textColor,
            ),
          ),
          child: Dialog(
            backgroundColor: CustomTheme.boxColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: CustomTheme.boxBorderColor),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 450,
              child: SfDateRangePicker(
                backgroundColor: CustomTheme.boxColor,
                showNavigationArrow: true,
                initialSelectedDate: selectedCreationDate ?? clock.now(),
                maxDate: clock.now(),
                headerStyle: const DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.transparent,
                  textStyle: TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                monthCellStyle: const DateRangePickerMonthCellStyle(
                  textStyle: TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 16,
                  ),
                  todayTextStyle: TextStyle(
                    color: CustomTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  leadingDatesTextStyle: TextStyle(
                    color: CustomTheme.hintColor,
                    fontSize: 16,
                  ),
                  trailingDatesTextStyle: TextStyle(
                    color: CustomTheme.hintColor,
                    fontSize: 16,
                  ),
                ),
                yearCellStyle: const DateRangePickerYearCellStyle(
                  textStyle: TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 16,
                  ),
                  todayTextStyle: TextStyle(
                    color: CustomTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: TextStyle(
                      color: CustomTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  firstDayOfWeek: 1,
                ),
                selectionMode: DateRangePickerSelectionMode.single,
                selectionColor: CustomTheme.primaryColor,
                selectionTextStyle: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                showActionButtons: true,
                onSubmit: (value) {
                  if (value is DateTime) {
                    setState(() {
                      selectedCreationDate = nullIfToday(value);
                    });
                    Navigator.pop(context);
                  }
                },
                onCancel: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      },
    );
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
    if (widget.editMode) {
      await updateMatch();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      final match = await createMatch();
      widget.onMatchesUpdated?.call();

      final hasPairs = selectedUnits.any((u) => u.members.length > 1);

      if (isTeamMatch && !hasPairs) {
        if (context.mounted) {
          Navigator.push(
            context,
            adaptivePageRoute(
              builder: (context) => CreateTeamsView(
                match: match,
                previousMatch: widget.matchToPrefill,
                onWinnerChanged: widget.onWinnerChanged,
              ),
            ),
          );
        }
      } else {
        // If it has pairs, we treat it as a team match but the teams are already set
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            adaptivePageRoute(
              fullscreenDialog: true,
              builder: (context) => MatchResultView(
                match: match,
                onWinnerChanged: widget.onWinnerChanged,
              ),
            ),
            (route) => route.isFirst,
          );
        }
      }
    }
  }

  /// Updates the existing match in the database.
  Future<void> updateMatch() async {
    final originalMatch = widget.matchToPrefill!;
    final newCreatedAt = selectedCreationDate ?? originalMatch.createdAt;
    DateTime? newEndedAt = originalMatch.endedAt;

    if (newEndedAt != null && newEndedAt.isBefore(newCreatedAt)) {
      newEndedAt = newCreatedAt;
    }

    final updatedMatch = Match(
      id: originalMatch.id,
      name: matchNameController.text.isEmpty
          ? (hintText ?? '')
          : matchNameController.text.trim(),
      group: selectedGroup,
      players: selectedPlayers,
      game: selectedGame!,
      createdAt: newCreatedAt,
      endedAt: newEndedAt,
      notes: originalMatch.notes,
    );

    if (originalMatch.name != updatedMatch.name) {
      await db.matchDao.updateMatchName(
        matchId: originalMatch.id,
        name: updatedMatch.name,
      );
    }

    if (originalMatch.group?.id != updatedMatch.group?.id) {
      await db.matchDao.updateMatchGroup(
        matchId: originalMatch.id,
        groupId: updatedMatch.group?.id,
      );
    }

    if (originalMatch.createdAt != updatedMatch.createdAt) {
      await db.matchDao.updateMatchCreatedAt(
        matchId: originalMatch.id,
        createdAt: updatedMatch.createdAt,
      );
    }

    if (originalMatch.endedAt != updatedMatch.endedAt) {
      await db.matchDao.updateMatchEndedAt(
        matchId: originalMatch.id,
        endedAt: updatedMatch.endedAt!,
      );
    }

    // Add players who are in updatedMatch but not in the original match
    for (var player in updatedMatch.players) {
      if (!widget.matchToPrefill!.players.any((p) => p.id == player.id)) {
        await db.playerMatchDao.addPlayerToMatch(
          matchId: widget.matchToPrefill!.id,
          playerId: player.id,
        );
      }
    }

    // Remove players who are in the original match but not in updatedMatch
    for (var player in widget.matchToPrefill!.players) {
      if (!updatedMatch.players.any((p) => p.id == player.id)) {
        await db.playerMatchDao.removePlayerFromMatch(
          matchId: widget.matchToPrefill!.id,
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
    final effectivePairs = hasPairs ? selectedUnits : null;
    final effectiveTitle = matchNameController.text.isEmpty
        ? (hintText ?? '')
        : matchNameController.text.trim();

    Match match = Match(
      name: effectiveTitle,
      createdAt: selectedCreationDate,
      group: selectedGroup,
      players: selectedPlayers,
      isTeamMatch: isTeamMatch,
      teams: effectivePairs,
      game: selectedGame!,
    );

    // Matches with pairs or regular matches are saved directly.
    // Manual Team matches without pre-defined pairs are saved in OrganizeTeamsView
    if (!isTeamMatch || hasPairs) {
      await db.matchDao.addMatch(match: match);
    }
    return match;
  }

  /// Returns true if the given [date] is today.
  bool isToday(DateTime date) {
    final now = clock.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns null if the given [date] is today, otherwise returns the date.
  DateTime? nullIfToday(DateTime date) => isToday(date) ? null : date;
}
