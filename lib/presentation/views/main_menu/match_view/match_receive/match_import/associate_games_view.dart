import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/match_import/associate_players_view.dart';
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
    _autoAssociateGame();
  }

  Future<void> _autoAssociateGame() async {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Associate Game'), centerTitle: true),
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
                      ? 'Game associated'
                      : 'New game will be created',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                      onTap: _showGameSelectionSheet,
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
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_box,
                                size: 35,
                                color: Colors.orange,
                              ),
                              SizedBox(height: 5),
                              Text(
                                'No matching local game found.\nA new game will be created.',
                                style: TextStyle(
                                  color: CustomTheme.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Tap to choose existing',
                                style: TextStyle(
                                  color: CustomTheme.hintColor,
                                  fontSize: 14,
                                ),
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
                      onTap: _showGameSelectionSheet,
                      isHighlighted: true,
                      badgeColor: getColorFromAppColor(associatedGame!.color),
                      borderColor: Colors.green.withAlpha(150),
                    ),
            ),
            const Spacer(),
            BottomAnimatedButton(
              buttonText: 'Confirm',
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

  Future<void> _showGameSelectionSheet() async {
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
          initialGame: associatedGame,
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
}
