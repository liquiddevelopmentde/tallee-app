import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/tiles/statistics_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class StatisticsView extends StatefulWidget {
  /// A view that displays player statistics
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  List<(String, int)> winCounts = List.filled(6, ('Skeleton Player', 1));
  List<(String, int)> matchCounts = List.filled(6, ('Skeleton Player', 1));
  List<(String, double)> winRates = List.filled(6, ('Skeleton Player', 1));
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStatisticData();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: AppSkeleton(
            enabled: isLoading,
            fixLayoutBuilder: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.01),
                  Visibility(
                    visible:
                        winCounts.isEmpty &&
                        matchCounts.isEmpty &&
                        winRates.isEmpty,
                    replacement: Column(
                      children: [
                        StatisticsTile(
                          icon: Icons.sports_score,
                          title: loc.wins,
                          width: constraints.maxWidth * 0.95,
                          values: winCounts,
                          itemCount: 3,
                          barColor: Colors.green,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        StatisticsTile(
                          icon: Icons.percent,
                          title: loc.winrate,
                          width: constraints.maxWidth * 0.95,
                          values: winRates,
                          itemCount: 5,
                          barColor: Colors.orange[700]!,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        StatisticsTile(
                          icon: Icons.casino,
                          title: loc.amount_of_matches,
                          width: constraints.maxWidth * 0.95,
                          values: matchCounts,
                          itemCount: 10,
                          barColor: Colors.blue,
                        ),
                      ],
                    ),
                    child: TopCenteredMessage(
                      icon: Icons.info,
                      title: loc.info,
                      message: AppLocalizations.of(
                        context,
                      ).no_statistics_available,
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Loads matches and players from the database
  /// and calculates statistics for each player
  void loadStatisticData() {
    final db = Provider.of<AppDatabase>(context, listen: false);

    Future.wait([
      db.matchDao.getAllMatches(),
      db.playerDao.getAllPlayers(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) async {
      if (!mounted) return;
      final matches = results[0] as List<Match>;
      final players = results[1] as List<Player>;
      winCounts = _calculateWinsForAllPlayers(
        matches: matches,
        players: players,
        context: context,
      );
      matchCounts = _calculateMatchAmountsForAllPlayers(
        matches: matches,
        players: players,
        context: context,
      );
      winRates = computeWinRatePercent(wins: winCounts, matches: matchCounts);
      setState(() {
        isLoading = false;
      });
    });
  }

  /// Calculates the number of wins for each player
  /// and returns a sorted list of tuples (playerName, winCount)
  List<(String, int)> _calculateWinsForAllPlayers({
    required List<Match> matches,
    required List<Player> players,
    required BuildContext context,
  }) {
    List<(String, int)> winCounts = [];
    final loc = AppLocalizations.of(context);

    // Getting the winners
    for (var match in matches) {
      final winner = match.winner;
      if (winner != null) {
        final index = winCounts.indexWhere((entry) => entry.$1 == winner.id);
        // -1 means winner not found in winCounts
        if (index != -1) {
          final current = winCounts[index].$2;
          winCounts[index] = (winner.id, current + 1);
        } else {
          winCounts.add((winner.id, 1));
        }
      }
    }

    // Adding all players with zero wins
    for (var player in players) {
      final index = winCounts.indexWhere((entry) => entry.$1 == player.id);
      // -1 means player not found in winCounts
      if (index == -1) {
        winCounts.add((player.id, 0));
      }
    }

    // Replace player IDs with names
    for (int i = 0; i < winCounts.length; i++) {
      final playerId = winCounts[i].$1;
      final player = players.firstWhere(
        (p) => p.id == playerId,
        orElse: () => Player(id: playerId, name: loc.not_available),
      );
      winCounts[i] = (player.name, winCounts[i].$2);
    }

    winCounts.sort((a, b) => b.$2.compareTo(a.$2));

    return winCounts;
  }

  /// Calculates the number of matches played for each player
  /// and returns a sorted list of tuples (playerName, matchCount)
  List<(String, int)> _calculateMatchAmountsForAllPlayers({
    required List<Match> matches,
    required List<Player> players,
    required BuildContext context,
  }) {
    List<(String, int)> matchCounts = [];
    final loc = AppLocalizations.of(context);

    // Counting matches for each player
    for (var match in matches) {
      if (match.group != null) {
        final members = match.group!.members.map((p) => p.id).toList();
        for (var playerId in members) {
          final index = matchCounts.indexWhere((entry) => entry.$1 == playerId);
          // -1 means player not found in matchCounts
          if (index != -1) {
            final current = matchCounts[index].$2;
            matchCounts[index] = (playerId, current + 1);
          } else {
            matchCounts.add((playerId, 1));
          }
        }
      }
      if (match.players != null) {
        final members = match.players!.map((p) => p.id).toList();
        for (var playerId in members) {
          final index = matchCounts.indexWhere((entry) => entry.$1 == playerId);
          // -1 means player not found in matchCounts
          if (index != -1) {
            final current = matchCounts[index].$2;
            matchCounts[index] = (playerId, current + 1);
          } else {
            matchCounts.add((playerId, 1));
          }
        }
      }
    }

    // Adding all players with zero matches
    for (var player in players) {
      final index = matchCounts.indexWhere((entry) => entry.$1 == player.id);
      // -1 means player not found in matchCounts
      if (index == -1) {
        matchCounts.add((player.id, 0));
      }
    }

    // Replace player IDs with names
    for (int i = 0; i < matchCounts.length; i++) {
      final playerId = matchCounts[i].$1;
      final player = players.firstWhere(
        (p) => p.id == playerId,
        orElse: () => Player(id: playerId, name: loc.not_available),
      );
      matchCounts[i] = (player.name, matchCounts[i].$2);
    }

    matchCounts.sort((a, b) => b.$2.compareTo(a.$2));

    return matchCounts;
  }

  // dart
  List<(String, double)> computeWinRatePercent({
    required List<(String, int)> wins,
    required List<(String, int)> matches,
  }) {
    final Map<String, int> winsMap = {for (var e in wins) e.$1: e.$2};
    final Map<String, int> matchesMap = {for (var e in matches) e.$1: e.$2};

    // Get all unique player names
    final names = {...winsMap.keys, ...matchesMap.keys};

    // Calculate win rates
    final result = names.map((name) {
      final int w = winsMap[name] ?? 0;
      final int g = matchesMap[name] ?? 0;
      // Calculate percentage and round to 2 decimal places
      // Avoid division by zero
      final double percent = (g > 0)
          ? double.parse(((w / g)).toStringAsFixed(2))
          : 0;
      return (name, percent);
    }).toList();

    // Sort the result: first by winrate descending,
    // then by wins descending in case of a tie
    result.sort((a, b) {
      final cmp = b.$2.compareTo(a.$2);
      if (cmp != 0) return cmp;
      final wa = winsMap[a.$1] ?? 0;
      final wb = winsMap[b.$1] ?? 0;
      return wb.compareTo(wa);
    });

    return result;
  }
}
