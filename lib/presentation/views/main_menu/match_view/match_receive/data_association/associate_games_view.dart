import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_players_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/game_tile.dart';

class AssociateGamesView extends StatefulWidget {
  const AssociateGamesView({required this.match, super.key});

  final Match match;

  @override
  State<AssociateGamesView> createState() => _AssociateGamesViewState();
}

class _AssociateGamesViewState extends State<AssociateGamesView> {
  Game? associatedGame;

  @override
  void initState() {
    super.initState();
    autoAssociateGame();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(loc.associate_game), centerTitle: true),
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: CustomTheme.standardMargin,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                child: Text(
                  associatedGame != null
                      ? loc.game_associated
                      : loc.new_group_will_be_created,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    overflow: TextOverflow.visible,
                  ),
                  softWrap: true,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GameTile(
              title: widget.match.game.name,
              description: widget.match.game.description,
              subtitle: translateRulesetToString(
                widget.match.game.ruleset,
                context,
              ),
              badgeColor: getColorFromAppColor(widget.match.game.color),
            ),
            const Icon(Icons.arrow_downward, size: 30),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[...previousChildren, ?currentChild],
                    );
                  },
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: associatedGame == null
                  ? GestureDetector(
                      onTap: showGameSelectionSheet,
                      child: Container(
                        key: const ValueKey('no_association'),
                        margin: CustomTheme.tileMargin,
                        height: 120,
                        decoration: CustomTheme.standardBoxDecoration.copyWith(
                          border: Border.all(
                            color: Colors.orange.withAlpha(150),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_box,
                                size: 35,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                loc.no_matching_local_game_found,
                                style: const TextStyle(
                                  color: CustomTheme.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.visible,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                              Text(
                                loc.tap_to_choose_existing,
                                style: const TextStyle(
                                  color: CustomTheme.hintColor,
                                  fontSize: 14,
                                  overflow: TextOverflow.visible,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : GameTile(
                      key: ValueKey(associatedGame!.id),
                      title: associatedGame!.name,
                      description: associatedGame!.description,
                      subtitle: translateRulesetToString(
                        associatedGame!.ruleset,
                        context,
                      ),
                      onTap: showGameSelectionSheet,
                      isHighlighted: true,
                      badgeColor: getColorFromAppColor(associatedGame!.color),
                      borderColor: Colors.green.withAlpha(150),
                    ),
            ),
            const Spacer(),
            BottomAnimatedButton(
              buttonText: loc.confirm,
              sizeRelativeToWidth: 0.95,
              onPressed: () {
                Navigator.of(context).push(
                  adaptivePageRoute(
                    builder: (context) => AssociatePlayersView(
                      match: widget.match,
                      associatedGame: associatedGame,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showGameSelectionSheet() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final allGames = await db.gameDao.getAllGames();

    // Filter games by ruleset
    final filteredGames = allGames
        .where((g) => g.ruleset == widget.match.game.ruleset)
        .toList();

    if (!mounted) return;

    final selected = await Navigator.push<Game>(
      context,
      adaptivePageRoute(
        builder: (context) => ChooseGameView(
          games: filteredGames,
          initialGames: [?associatedGame],
          requiredRuleset: widget.match.game.ruleset,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        associatedGame = selected;
      });
    }
  }

  Future<void> autoAssociateGame() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final allGames = await db.gameDao.getAllGames();

    if (!mounted) return;

    final importedGame = widget.match.game;
    final match = allGames.where((localGame) {
      return localGame.name.toLowerCase() == importedGame.name.toLowerCase() &&
          localGame.ruleset == importedGame.ruleset;
    }).firstOrNull;

    if (match != null) {
      setState(() {
        associatedGame = match;
      });
    }
  }
}
