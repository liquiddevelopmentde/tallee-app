import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/pair_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class MatchProfileBody extends StatelessWidget {
  const MatchProfileBody({
    super.key,
    required this.match,
    this.isPreview = false,
    this.onPlayerTap,
    this.onEdit,
    this.onEnterResults,
    this.onConfirm,
    this.onCancel,
  });

  final Match match;
  final bool isPreview;
  final void Function(Player)? onPlayerTap;

  final VoidCallback? onEdit;
  final VoidCallback? onEnterResults;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  bool get useTeamLogic => match.useTeamLogic;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final content = ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 20,
        bottom: isPreview ? 20 : 100,
      ),
      children: [
        // Icon
        const Center(
          child: ColoredIconContainer(icon: MATCH_ICON, containerSize: 55),
        ),
        const SizedBox(height: 10),

        // Match Name
        Text(
          match.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: CustomTheme.textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        const SizedBox(height: 5),

        // Creation Date
        Text(
          '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(match.createdAt)}',
          style: const TextStyle(fontSize: 12, color: CustomTheme.textColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // Group Name
        if (match.group != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(GROUP_ICON),
              const SizedBox(width: 8),
              Text(
                '${match.group!.name}${getExtraPlayerCount(match)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],

        const SizedBox(height: 15),

        // Teams or Players
        if (useTeamLogic) ...[
          // Teams or Pairs
          InfoTile(
            title: match.isTeamMatch ? loc.teams : loc.players,
            leadingWidget: Icon(
              match.isTeamMatch ? Icons.scoreboard : Icons.people,
            ),
            horizontalAlignment: CrossAxisAlignment.start,
            content: match.teams != null && match.teams!.isNotEmpty
                ? match.isTeamMatch
                      ? Column(
                          children: (match.teams ?? []).map((team) {
                            return TeamCard(team: team);
                          }).toList(),
                        )
                      : Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 12,
                          runSpacing: 8,
                          children: (match.teams ?? []).map((team) {
                            if (team.members.length > 1) {
                              return PairTile(pair: team);
                            } else {
                              final player = team.members.first;
                              return PlayerTile(
                                player: player,
                                onTileTap: onPlayerTap != null
                                    ? () => onPlayerTap!(player)
                                    : null,
                              );
                            }
                          }).toList(),
                        )
                : Text(
                    match.isTeamMatch
                        ? loc.no_teams_available
                        : loc.no_players_available,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomTheme.textColor,
                    ),
                  ),
          ),
        ] else ...[
          // Players
          InfoTile(
            title: loc.players,
            leadingWidget: const Icon(Icons.people),
            horizontalAlignment: CrossAxisAlignment.start,
            content: match.players.isNotEmpty
                ? Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 8,
                    children: match.players.map((player) {
                      return PlayerTile(
                        player: player,
                        onTileTap: onPlayerTap != null
                            ? () => onPlayerTap!(player)
                            : null,
                      );
                    }).toList(),
                  )
                : Text(
                    loc.no_players_available,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomTheme.textColor,
                    ),
                  ),
          ),
        ],

        const SizedBox(height: 15),

        // Game
        InfoTile(
          title: loc.game,
          leadingWidget: const Icon(GAME_ICON),
          horizontalAlignment: CrossAxisAlignment.start,
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: GameLabel(
              title: match.game.name,
              description: translateRulesetToString(
                match.game.ruleset,
                context,
              ),
              color: match.game.color,
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Results
        InfoTile(
          title: loc.results,
          leadingWidget: const Icon(Icons.emoji_events),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: getResultWidget(context, loc),
          ),
        ),

        if (isPreview) ...[
          const SizedBox(height: 15),
          InfoTile(
            title: loc.group_members,
            leadingWidget: const Icon(GROUP_ICON),
            horizontalAlignment: CrossAxisAlignment.start,
            content: match.players.isNotEmpty
                ? Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 8,
                    children: match.players.map((player) {
                      return PlayerTile(player: player);
                    }).toList(),
                  )
                : Text(
                    loc.no_players_available,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomTheme.textColor,
                    ),
                  ),
          ),
        ],
      ],
    );

    if (isPreview) {
      return Column(
        children: [
          Expanded(child: content),
          BottomAnimatedButton(
            buttonText: loc.import_match,
            sizeRelativeToWidth: 0.95,
            onPressed: onConfirm,
          ),
          BottomAnimatedButton(
            buttonText: loc.cancel,
            sizeRelativeToWidth: 0.95,
            buttonType: ButtonType.secondary,
            onPressed: onCancel,
          ),
        ],
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          content,
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: Row(
              spacing: 8,
              children: [
                FloatingAnimatedButton(icon: Icons.edit, onPressed: onEdit),
                FloatingAnimatedButton(
                  text: loc.enter_results,
                  icon: Icons.emoji_events,
                  onPressed: onEnterResults,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  /// Returns the widget to be displayed in the result [InfoTile]
  Widget getResultWidget(BuildContext context, AppLocalizations loc) {
    if (isSingleRowResult()) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: getSingleResultRow(loc),
      );
    } else {
      return getMultiResultRows(context, loc);
    }
  }

  List<Widget> getSingleResultRow(AppLocalizations loc) {
    final ruleset = match.game.ruleset;
    if (match.mvp.isNotEmpty || match.mvt.isNotEmpty) {
      final label = ruleset == Ruleset.loser ? loc.loser : loc.winner;
      return [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: CustomTheme.textColor),
        ),
        const SizedBox(width: 20),
        Expanded(child: buildWinnerNameWidget()),
      ];
    } else {
      return [
        Text(
          loc.no_results_entered_yet,
          style: const TextStyle(fontSize: 14, color: CustomTheme.textColor),
        ),
      ];
    }
  }

  Widget buildWinnerNameWidget() {
    final mvtTeams = match.mvt;
    final mvpPlayers = match.mvp;
    const winnerStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: CustomTheme.primaryColor,
    );

    if (useTeamLogic) {
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          for (var i = 0; i < mvtTeams.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildUnitNameWidget(
                  mvtTeams[i],
                  isTeamMatch: match.isTeamMatch,
                  mainStyle: winnerStyle,
                ),
                if (i != mvtTeams.length - 1) const Text(','),
              ],
            ),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < mvpPlayers.length; i++) ...[
            if (i > 0) const TextSpan(text: ', '),
            buildPlayerNameCountSpan(mvpPlayers[i], mainStyle: winnerStyle),
          ],
        ],
      ),
      textAlign: TextAlign.end,
      overflow: TextOverflow.visible,
    );
  }

  Widget getMultiResultRows(BuildContext context, AppLocalizations loc) {
    List<(Widget, int)> scores = getSortedScores();
    bool hasMatchEnded = match.endedAt != null;

    return Column(
      children: [
        for (var i = 0; i < scores.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: scores[i].$1),
              hasMatchEnded
                  ? getResultValueText(context, loc, i, scores[i].$2)
                  : const Text('-'),
            ],
          ),
      ],
    );
  }

  List<(Widget, int)> getSortedScores() {
    List<(Widget, int)> namedScores = [];
    if (useTeamLogic) {
      final teams = match.teams ?? [];
      for (var team in teams) {
        Widget nameWidget = buildUnitNameWidget(
          team,
          isTeamMatch: match.isTeamMatch,
          countStyle: const TextStyle(color: CustomTheme.hintColor),
        );
        namedScores.add((nameWidget, team.score ?? 0));
      }
    } else {
      final scores = match.scores;
      final players = List<Player>.from(match.players)
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      for (var player in players) {
        int score = scores[player.id]?.score ?? 0;
        namedScores.add((
          buildUnitNameWidget(
            player,
            countStyle: const TextStyle(color: CustomTheme.hintColor),
          ),
          score,
        ));
      }
    }

    final ruleset = match.game.ruleset;
    if (ruleset == Ruleset.highestScore ||
        ruleset == Ruleset.placement ||
        ruleset == Ruleset.lives) {
      namedScores.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (ruleset == Ruleset.lowestScore) {
      namedScores.sort((a, b) => a.$2.compareTo(b.$2));
    }
    return namedScores;
  }

  Widget getResultValueText(
    BuildContext context,
    AppLocalizations loc,
    int index,
    int score,
  ) {
    final ruleset = match.game.ruleset;
    if (ruleset == Ruleset.placement) {
      return Text(
        getPlacementText(context, index + 1),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: getPlacementTextcolor(index),
        ),
      );
    } else if (ruleset == Ruleset.lives) {
      return Text(
        getLifeLabel(loc, score),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: score > 0 ? CustomTheme.primaryColor : CustomTheme.hintColor,
        ),
      );
    } else {
      return Text(
        getPointLabel(loc, score),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CustomTheme.primaryColor,
        ),
      );
    }
  }

  Color getPlacementTextcolor(int placement) {
    switch (placement) {
      case 0:
        return const Color(0xFFFFBF00);
      case 1:
        return const Color(0xBBFFFFFF);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return CustomTheme.textColor;
    }
  }

  bool isSingleRowResult() {
    return match.game.ruleset == Ruleset.winner ||
        match.game.ruleset == Ruleset.loser;
  }

  String getPlacementText(BuildContext context, int rank) {
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'de') return '$rank. ${loc.place}';
    return '${_ordinalEn(rank)} ${loc.place}';
  }

  String _ordinalEn(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
