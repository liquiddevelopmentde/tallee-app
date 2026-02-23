import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
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
  const CreateMatchView({super.key, this.onWinnerChanged, this.match});

  /// Optional callback invoked when the winner is changed
  final VoidCallback? onWinnerChanged;

  /// An optional match to prefill the fields
  final Match? match;

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
  List<Player> filteredPlayerList = [];

  /// The currently selected group
  Group? selectedGroup;

  /// The index of the currently selected group in [groupsList] to mark it in
  /// the [ChooseGroupView]
  String selectedGroupId = '';

  /// The index of the currently selected game in [games] to mark it in
  /// the [ChooseGameView]
  int selectedGameIndex = -1;

  /// The currently selected players
  List<Player>? selectedPlayers;

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
      setState(() {
        filteredPlayerList = List.from(playerList);
      });
    });

    // If a match is provided, prefill the fields
    if (widget.match != null) {
      final match = widget.match!;
      _matchNameController.text = match.name;
      selectedGroup = match.group;
      selectedGroupId = match.group?.id ?? '';
      selectedPlayers = match.players ?? [];
      if (selectedGroup != null) {
        filteredPlayerList = playerList
            .where((p) => !selectedGroup!.members.any((m) => m.id == p.id))
            .toList();
      }
    }
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
    ('Example Game 1', 'This is a description', Ruleset.leastPoints),
    ('Example Game 2', '', Ruleset.singleWinner),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final buttonText = widget.match != null
        ? loc.save_changes
        : loc.create_match;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(title: Text(loc.create_new_match)),
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
                  selectedGroup = await Navigator.of(context).push(
                    adaptivePageRoute(
                      builder: (context) => ChooseGroupView(
                        groups: groupsList,
                        initialGroupId: selectedGroupId,
                      ),
                    ),
                  );
                  selectedGroupId = selectedGroup?.id ?? '';
                  if (selectedGroup != null) {
                    filteredPlayerList = playerList
                        .where(
                          (p) =>
                              !selectedGroup!.members.any((m) => m.id == p.id),
                        )
                        .toList();
                  } else {
                    filteredPlayerList = List.from(playerList);
                  }
                  setState(() {});
                },
              ),
              Expanded(
                child: PlayerSelection(
                  key: ValueKey(selectedGroup?.id ?? 'no_group'),
                  initialSelectedPlayers: selectedPlayers ?? [],
                  availablePlayers: filteredPlayerList,
                  onChanged: (value) {
                    setState(() {
                      selectedPlayers = value;
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
    return (selectedGroup != null ||
        (selectedPlayers != null && selectedPlayers!.length > 1));
  }

  void buttonNavigation(BuildContext context) async {
    if (widget.match != null) {
      // TODO: Implement updating match logic here
      Navigator.pop(context);
    } else {
      Match match = Match(
        name: _matchNameController.text.isEmpty
            ? (hintText ?? '')
            : _matchNameController.text.trim(),
        createdAt: DateTime.now(),
        group: selectedGroup,
        players: selectedPlayers,
      );
      await db.matchDao.addMatch(match: match);
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
