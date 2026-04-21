import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/title_description_list_tile.dart';

class ChooseGameView extends StatefulWidget {
  /// A view that allows the user to choose a game from a list of available games
  /// - [games]: A list of tuples containing the game name, description and ruleset
  /// - [initialGameIndex]: The index of the initially selected game
  const ChooseGameView({
    super.key,
    required this.games,
    required this.initialGameId,
  });

  /// A list of tuples containing the game name, description and ruleset
  final List<Game> games;

  /// The id of the initially selected game
  final String initialGameId;

  @override
  State<ChooseGameView> createState() => _ChooseGameViewState();
}

class _ChooseGameViewState extends State<ChooseGameView> {
  /// Controller for the search bar
  final TextEditingController searchBarController = TextEditingController();

  /// Currently selected game index
  late String selectedGameId;

  @override
  void initState() {
    selectedGameId = widget.initialGameId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop(
              selectedGameId == ''
                  ? null
                  : widget.games.firstWhere(
                      (game) => game.id == selectedGameId,
                    ),
            );
          },
        ),
        title: Text(loc.choose_game),
      ),
      body: PopScope(
        // This fixes that the Android Back Gesture didn't return the
        // selectedGameIndex and therefore the selected Game wasn't saved
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(widget.initialGameId);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomSearchBar(
                controller: searchBarController,
                hintText: loc.game_name,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: widget.games.length,
                itemBuilder: (BuildContext context, int index) {
                  return TitleDescriptionListTile(
                    title: widget.games[index].name,
                    description: widget.games[index].description,
                    badgeText: translateRulesetToString(
                      widget.games[index].ruleset,
                      context,
                    ),
                    isHighlighted: selectedGameId == widget.games[index].id,
                    onPressed: () async {
                      setState(() {
                        if (selectedGameId != widget.games[index].id) {
                          selectedGameId = widget.games[index].id;
                        } else {
                          selectedGameId = '';
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
