import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/custom_radio_list_tile.dart';

class MatchResultView extends StatefulWidget {
  /// A view that allows selecting and saving the winner of a match
  /// [match]: The match for which the winner is to be selected
  /// [onWinnerChanged]: Optional callback invoked when the winner is changed
  const MatchResultView({super.key, required this.match, this.onWinnerChanged});

  /// The match for which the winner is to be selected
  final Match match;

  /// Optional callback invoked when the winner is changed
  final VoidCallback? onWinnerChanged;

  @override
  State<MatchResultView> createState() => _MatchResultViewState();
}

class _MatchResultViewState extends State<MatchResultView> {
  late final AppDatabase db;

  /// List of all players who participated in the match
  late final List<Player> allPlayers;

  /// Currently selected winner player
  Player? _selectedPlayer;

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    allPlayers = getAllPlayers(widget.match);
    if (widget.match.winner != null) {
      _selectedPlayer = allPlayers.firstWhere(
        (p) => p.id == widget.match.winner!.id,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onWinnerChanged?.call();
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.match.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.boxColor,
                  border: Border.all(color: CustomTheme.boxBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.select_winner,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: RadioGroup<Player>(
                        groupValue: _selectedPlayer,
                        onChanged: (Player? value) async {
                          setState(() {
                            _selectedPlayer = value;
                          });
                          await _handleWinnerSaving();
                        },
                        child: ListView.builder(
                          itemCount: allPlayers.length,
                          itemBuilder: (context, index) {
                            return CustomRadioListTile(
                              text: allPlayers[index].name,
                              value: allPlayers[index],
                              onContainerTap: (value) async {
                                setState(() {
                                  // Check if the already selected player is the same as the newly tapped player.
                                  if (_selectedPlayer == value) {
                                    // If yes deselected the player by setting it to null.
                                    _selectedPlayer = null;
                                  } else {
                                    // If no assign the newly tapped player to the selected player.
                                    (_selectedPlayer = value);
                                  }
                                });
                                await _handleWinnerSaving();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles saving or removing the winner in the database
  /// based on the current selection.
  Future<void> _handleWinnerSaving() async {
    if (_selectedPlayer == null) {
      await db.matchDao.removeWinner(matchId: widget.match.id);
    } else {
      await db.matchDao.setWinner(
        matchId: widget.match.id,
        winnerId: _selectedPlayer!.id,
      );
    }
    widget.onWinnerChanged?.call();
  }

  /// Retrieves all players associated with the given [match].
  /// This includes players directly assigned to the match
  /// as well as members of the group (if any).
  /// The returned list is sorted alphabetically by player name.
  List<Player> getAllPlayers(Match match) {
    List<Player> players = [];

    if (match.group == null && match.players != null) {
      players = [...match.players!];
    } else if (match.group != null && match.players != null) {
      players = [...match.players!, ...match.group!.members];
    } else {
      players = [...match.group!.members];
    }

    players.sort((a, b) => a.name.compareTo(b.name));
    return players;
  }
}
