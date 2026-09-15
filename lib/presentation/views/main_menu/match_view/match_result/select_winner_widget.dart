import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/custom_showcase_widget.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_checkbox_list_tile.dart';
import 'package:tallee/state/showcase_provider.dart';

class SelectWinnerWidget extends StatefulWidget {
  /// A list widget for the [MatchResultView] that lets the user select multiple players or teams.
  /// - [match]: The match whose players / teams are being selected.
  /// - [onPlayersSelected]: The callback invoked with the selected players whenever the selection changes.
  /// - [onTeamsSelected]: The callback invoked with the selected teams whenever the selection changes.
  const SelectWinnerWidget({
    super.key,
    required this.match,
    this.onPlayersSelected,
    this.onTeamsSelected,
  });

  final Match match;
  final void Function(List<Player>)? onPlayersSelected;
  final void Function(List<Team>)? onTeamsSelected;

  @override
  State<SelectWinnerWidget> createState() => _SelectWinnerWidgetState();
}

class _SelectWinnerWidgetState extends State<SelectWinnerWidget> {
  late List<Team> allTeams;
  List<Team> selectedTeams = [];

  late List<Player> allPlayers;
  List<Player> selectedPlayers = [];

  bool get isTeamMatch => widget.match.isTeamMatch;
  bool get useTeamLogic => widget.match.useTeamLogic;

  final GlobalKey selectWinnerWidgetListviewKey = GlobalKey();
  final String selectWinnerWidgetListviewIdentifier =
      'select_winner_widget_listview_key';

  late final ShowcaseProvider showcaseProvider;

  @override
  void initState() {
    if (useTeamLogic) {
      allTeams = widget.match.teams ?? [];
      selectedTeams = widget.match.mvt;
    } else {
      allPlayers = widget.match.players;
      selectedPlayers = widget.match.mvp;
    }

    showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);

    if (showcaseProvider.shouldShowShowcase(
      selectWinnerWidgetListviewIdentifier,
    )) {
      handleShowcase(
        widgetKeys: [selectWinnerWidgetListviewKey],
        identifiers: [selectWinnerWidgetListviewIdentifier],
        showcaseProvider: showcaseProvider,
        context: context,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showcaseProvider.completeTour();
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomShowcaseWidget(
        showcaseKey: selectWinnerWidgetListviewKey,
        identifier: selectWinnerWidgetListviewIdentifier,
        description: 'To track your winners, just select them here and click the save button below.',
        child: useTeamLogic
            ? ListView.builder(
                itemCount: allTeams.length,
                itemBuilder: (context, index) {
                  return CustomCheckboxListTile(
                    content: isTeamMatch
                        ? TeamCard(
                            team: allTeams[index],
                            showTeamMembers: false,
                            compact: true,
                          )
                        : buildUnitNameWidget(
                            allTeams[index],
                            isTeamMatch: false,
                          ),
                    value: selectedTeams.contains(allTeams[index]),
                    onChanged: (bool value) {
                      showcaseProvider.markAsSeen(
                        selectWinnerWidgetListviewIdentifier,
                      );
                      setState(() {
                        if (value) {
                          selectedTeams.add(allTeams[index]);
                        } else {
                          selectedTeams.remove(allTeams[index]);
                        }
                        widget.onTeamsSelected?.call(selectedTeams);
                      });
                    },
                  );
                },
              )
            : ListView.builder(
                itemCount: allPlayers.length,
                itemBuilder: (context, index) {
                  return CustomCheckboxListTile(
                    content: buildUnitNameWidget(
                      allPlayers[index],
                      mainStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: selectedPlayers.contains(allPlayers[index]),
                    onChanged: (bool value) {
                      showcaseProvider.markAsSeen(
                        selectWinnerWidgetListviewIdentifier,
                      );
                      setState(() {
                        if (value) {
                          selectedPlayers.add(allPlayers[index]);
                        } else {
                          selectedPlayers.remove(allPlayers[index]);
                        }
                        widget.onPlayersSelected?.call(selectedPlayers);
                      });
                    },
                  );
                },
              ),
      ),
    );
  }
}
