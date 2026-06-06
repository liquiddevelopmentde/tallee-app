import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
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
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/tiles/match_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class MatchView extends StatefulWidget {
  /// A view that displays a list of matches
  const MatchView({super.key});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late final AppDatabase db;
  bool isLoading = true;

  /// Loaded matches from the database, initially filled with skeleton matches
  List<Match> matches = List.filled(
    4,
    Match(
      name: 'Skeleton match name',
      game: Game(
        name: 'Game name',
        ruleset: Ruleset.singleWinner,
        color: AppColor.blue,
        icon: '',
      ),
      group: Group(
        name: 'Group name',
        members: List.filled(5, Player(name: 'Player')),
      ),
      players: [
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(id: 'mvp_id', name: 'Player'),
      ],
      scores: {'mvp_id': ScoreEntry(score: 1)},
      endedAt: DateTime.now(),
    ),
  );

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AppSkeleton(
            enabled: isLoading,
            child: Visibility(
              visible: matches.isNotEmpty,
              replacement: Center(
                child: TopCenteredMessage(
                  icon: Icons.info,
                  title: loc.info,
                  message: loc.no_matches_created_yet,
                ),
              ),
              child: ListView.builder(
                padding: CustomTheme.listViewPadding(context),
                itemCount: matches.length,
                itemBuilder: (BuildContext context, int index) {
                  return MatchTile(
                    onPlayerEdited: loadMatches,
                    width: MediaQuery.sizeOf(context).width * 0.95,
                    onTap: () async {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (context) => MatchDetailView(
                            match: matches[index],
                            onMatchUpdate: loadMatches,
                          ),
                        ),
                      );
                    },
                    match: matches[index],
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: MainMenuButton(
              text: loc.create_match,
              icon: RpgAwesome.clovers_card,
              onPressed: () async {
                Navigator.push(
                  context,
                  adaptivePageRoute(
                    builder: (context) => CreateMatchView(
                      onWinnerChanged: loadMatches,
                      onMatchesUpdated: loadMatches,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Loads the matches from the database and sorts them by creation date.
  void loadMatches() {
    isLoading = true;
    Future.wait([
      db.matchDao.getAllMatches(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (mounted) {
        setState(() {
          final loadedMatches = results[0] as List<Match>;
          matches = [...loadedMatches]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          isLoading = false;
        });
      }
    });
  }
}
