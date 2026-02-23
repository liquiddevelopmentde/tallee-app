import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/quick_create_button.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/match_tile.dart';
import 'package:tallee/presentation/widgets/tiles/quick_info_tile.dart';

class HomeView extends StatefulWidget {
  /// The main home view of the application, displaying quick info,
  /// recent matches, and quick create options.
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isLoading = true;

  /// Amount of matches in the database
  int matchCount = 0;

  /// Amount of groups in the database
  int groupCount = 0;

  /// Loaded recent matches from the database
  List<Match> loadedRecentMatches = [];

  /// Recent matches to display, initially filled with skeleton matches
  List<Match> recentMatches = List.filled(
    2,
    Match(
      name: 'Skeleton Match',
      group: Group(
        name: 'Skeleton Group',
        members: [
          Player(name: 'Skeleton Player 1'),
          Player(name: 'Skeleton Player 2'),
        ],
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    loadHomeViewData();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AppSkeleton(
          fixLayoutBuilder: true,
          enabled: isLoading,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QuickInfoTile(
                      width: constraints.maxWidth * 0.45,
                      height: constraints.maxHeight * 0.15,
                      title: loc.matches,
                      icon: Icons.groups_rounded,
                      value: matchCount,
                    ),
                    SizedBox(width: constraints.maxWidth * 0.05),
                    QuickInfoTile(
                      width: constraints.maxWidth * 0.45,
                      height: constraints.maxHeight * 0.15,
                      title: loc.groups,
                      icon: Icons.groups_rounded,
                      value: groupCount,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: InfoTile(
                    width: constraints.maxWidth * 0.95,
                    title: loc.recent_matches,
                    icon: Icons.history_rounded,
                    content: Column(
                      children: [
                        if (recentMatches.isNotEmpty)
                          for (Match match in recentMatches)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: MatchTile(
                                compact: true,
                                width: constraints.maxWidth * 0.9,
                                match: match,
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    adaptivePageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) =>
                                          MatchResultView(match: match),
                                    ),
                                  );
                                  await updatedWinnerinRecentMatches(match.id);
                                },
                              ),
                            )
                        else
                          Center(
                            heightFactor: 5,
                            child: Text(loc.no_recent_matches_available),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.zero,
                  child: InfoTile(
                    width: constraints.maxWidth * 0.95,
                    title: loc.quick_create,
                    icon: Icons.add_box_rounded,
                    content: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            QuickCreateButton(
                              text: 'Category 1',
                              onPressed: () {},
                            ),
                            QuickCreateButton(
                              text: 'Category 2',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            QuickCreateButton(
                              text: 'Category 3',
                              onPressed: () {},
                            ),
                            QuickCreateButton(
                              text: 'Category 4',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            QuickCreateButton(
                              text: 'Category 5',
                              onPressed: () {},
                            ),
                            QuickCreateButton(
                              text: 'Category 6',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Loads the data for the HomeView from the database.
  /// This includes the match count, group count, and recent matches.
  Future<void> loadHomeViewData() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    Future.wait([
      db.matchDao.getMatchCount(),
      db.groupDao.getGroupCount(),
      db.matchDao.getAllMatches(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      matchCount = results[0] as int;
      groupCount = results[1] as int;
      loadedRecentMatches = results[2] as List<Match>;
      recentMatches =
          (loadedRecentMatches
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
              .take(2)
              .toList();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  /// Updates the winner information for a specific match in the recent matches list.
  Future<void> updatedWinnerinRecentMatches(String matchId) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final winner = await db.matchDao.getWinner(matchId: matchId);
    final matchIndex = recentMatches.indexWhere((match) => match.id == matchId);
    if (matchIndex != -1) {
      setState(() {
        recentMatches[matchIndex].winner = winner;
      });
    }
  }
}
