import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/custom_width_button.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_checkbox_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_radio_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/live_edit_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/score_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';

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

  bool isLiveEditMode = false;

  late final Ruleset ruleset;

  /// List of all players who participated in the match
  late final List<Player> allPlayers;

  /// List of text controllers for score entry, one for each player
  late final List<TextEditingController> controller;

  /// Flag to indicate if the save button should be enabled
  late bool canSave;

  /// Currently selected player (single winner / looser)
  Player? _selectedPlayer;

  /// Currently selected players (multiple winners)
  final Set<Player> _selectedPlayers = {};

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    ruleset = widget.match.game.ruleset;
    canSave = !rulesetSupportsScoreEntry();

    allPlayers = widget.match.players;
    allPlayers.sort((a, b) => a.name.compareTo(b.name));

    controller = List.generate(
      allPlayers.length,
      (index) => TextEditingController()..addListener(() => onTextEnter()),
    );

    // Prefill fields
    if (widget.match.mvp.isNotEmpty) {
      if (rulesetSupportsPlayerSelection()) {
        if (ruleset == Ruleset.multipleWinners) {
          for (int i = 0; i < allPlayers.length; i++) {
            if (widget.match.scores[allPlayers[i].id]?.score == 1) {
              _selectedPlayers.add(allPlayers[i]);
            }
          }
        } else {
          _selectedPlayer = allPlayers.firstWhere(
            (p) => p.id == widget.match.mvp.first.id,
          );
        }
      } else if (rulesetSupportsScoreEntry()) {
        for (int i = 0; i < allPlayers.length; i++) {
          final scoreList = widget.match.scores[allPlayers[i].id];
          final score = scoreList?.score ?? 0;
          controller[i].text = score.toString();
        }
      } else if (rulesetSupportsDragBehaviour()) {
        allPlayers.sort((a, b) {
          final scoreA = widget.match.scores[a.id]?.score ?? 0;
          final scoreB = widget.match.scores[b.id]?.score ?? 0;
          return scoreB.compareTo(scoreA);
        });
      }
      super.initState();
    }
  }

  @override
  void dispose() {
    for (final c in controller) {
      c.dispose();
    }
    super.dispose();
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
            Navigator.of(context).pop(_selectedPlayer);
          },
        ),
        title: Text(widget.match.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLiveEditMode
                  // Live Edit Mode
                  ? ListView.builder(
                      itemCount: allPlayers.length,
                      itemBuilder: (context, index) {
                        return LiveEditListTile(
                          title: allPlayers[index].name,
                          onChanged: (value) {
                            setState(() {
                              controller[index].text = value.toString();
                            });
                          },
                          value: int.tryParse(controller[index].text) ?? 0,
                        );
                      },
                    )
                  // Normal Container
                  : Container(
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
                        border: Border.all(color: CustomTheme.boxBorderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTitleForRuleset(loc),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Show player selection
                          if (rulesetSupportsPlayerSelection())
                            Expanded(
                              child: ruleset == Ruleset.multipleWinners
                                  // Multiple winners
                                  ? ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: allPlayers.length,
                                      itemBuilder: (context, index) {
                                        return CustomCheckboxListTile(
                                          text: allPlayers[index].name,
                                          value: _selectedPlayers.contains(
                                            allPlayers[index],
                                          ),
                                          onChanged: (bool value) {
                                            setState(() {
                                              if (value) {
                                                _selectedPlayers.add(
                                                  allPlayers[index],
                                                );
                                              } else {
                                                _selectedPlayers.remove(
                                                  allPlayers[index],
                                                );
                                              }
                                            });
                                          },
                                        );
                                      },
                                    )
                                  // Single winner / looser
                                  : RadioGroup<Player>(
                                      groupValue: _selectedPlayer,
                                      onChanged: (Player? value) async {
                                        setState(() {
                                          _selectedPlayer = value;
                                        });
                                      },
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
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
                                            },
                                          );
                                        },
                                      ),
                                    ),
                            ),

                          // Show score entry
                          if (rulesetSupportsScoreEntry())
                            Expanded(
                              child: ListView.separated(
                                itemCount: allPlayers.length,
                                itemBuilder: (context, index) {
                                  return ScoreListTile(
                                    text: allPlayers[index].name,
                                    controller: controller[index],
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Divider(indent: 20),
                                      );
                                    },
                              ),
                            ),

                          // Show draggable placement list
                          if (rulesetSupportsDragBehaviour())
                            Expanded(
                              child: Row(
                                children: [
                                  // Placement indicators
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Column(
                                      children: [
                                        for (
                                          int i = 0;
                                          i < allPlayers.length;
                                          i++
                                        )
                                          Container(
                                            alignment: Alignment.center,
                                            height: 60,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    CustomTheme.boxBorderColor,
                                                borderRadius: CustomTheme
                                                    .standardBorderRadiusAll,
                                              ),
                                              alignment: Alignment.center,
                                              height: 50,
                                              width: 50,
                                              child: Text(
                                                ' #${i + 1} ',
                                                style: const TextStyle(
                                                  color: CustomTheme.textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Drag list
                                  Expanded(
                                    child: ReorderableListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      proxyDecorator: (child, index, animation) {
                                        return AnimatedBuilder(
                                          animation: animation,
                                          child: child,
                                          builder: (context, child) {
                                            final alpha =
                                                (Curves.easeInOut.transform(
                                                          animation.value,
                                                        ) *
                                                        40)
                                                    .toInt();
                                            return Stack(
                                              children: [
                                                child!,
                                                Positioned.fill(
                                                  left: 4,
                                                  top: 4,
                                                  right: 4,
                                                  bottom: 4,
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withAlpha(alpha),
                                                      borderRadius: CustomTheme
                                                          .standardBorderRadiusAll,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onReorder: (int oldIndex, int newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final Player item = allPlayers
                                              .removeAt(oldIndex);
                                          allPlayers.insert(newIndex, item);
                                        });
                                      },
                                      itemCount: allPlayers.length,
                                      itemBuilder: (context, index) {
                                        return TextIconListTile(
                                          key: ValueKey(allPlayers[index].id),
                                          text: allPlayers[index].name,
                                          icon: Icons.drag_handle,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            if (rulesetSupportsScoreEntry())
            // Button to switch to live edit mode
            ...[
              CustomWidthButton(
                text: isLiveEditMode ? loc.exit_view : loc.live_edit_mode,
                sizeRelativeToWidth: 0.95,
                buttonType: ButtonType.secondary,
                onPressed: () => setState(() {
                  isLiveEditMode = !isLiveEditMode;
                }),
              ),
              const SizedBox(height: 10),
            ],

            // Save Changes Button
            CustomWidthButton(
              text: loc.save_changes,
              sizeRelativeToWidth: 0.95,
              onPressed: canSave
                  ? () async {
                      final ending = DateTime.now();
                      await db.matchDao.updateMatchEndedAt(
                        matchId: widget.match.id,
                        endedAt: ending,
                      );
                      await _handleSaving();
                      if (!context.mounted) return;
                      Navigator.of(context).pop(_selectedPlayer);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Updated [canSave] everytime a text is entered in one of the score entry fields.
  void onTextEnter() {
    if (rulesetSupportsScoreEntry()) {
      setState(() {
        canSave = controller.every((c) => c.text.isNotEmpty);
      });
    }
  }

  /// Handles saving or removing the winner in the database
  /// based on the current selection.
  Future<void> _handleSaving() async {
    if (ruleset == Ruleset.singleWinner) {
      await _handleWinner();
    } else if (ruleset == Ruleset.singleLoser) {
      await _handleLoser();
    } else if (ruleset == Ruleset.lowestScore ||
        ruleset == Ruleset.highestScore) {
      await _handleScores();
    } else if (ruleset == Ruleset.placement) {
      await _handlePlacement();
    } else if (ruleset == Ruleset.multipleWinners) {
      await _handleWinners();
    }

    widget.onWinnerChanged?.call();
  }

  /// Handles saving or removing the (single) winner in the database.
  Future<bool> _handleWinner() async {
    if (_selectedPlayer == null) {
      return await db.scoreEntryDao.removeWinner(matchId: widget.match.id);
    } else {
      return await db.scoreEntryDao.setWinner(
        matchId: widget.match.id,
        playerId: _selectedPlayer!.id,
      );
    }
  }

  /// Handles saving the (multiple) winners to the database.
  Future<bool> _handleWinners() async {
    if (_selectedPlayers.isEmpty) {
      return await db.scoreEntryDao.removeWinner(matchId: widget.match.id);
    } else {
      return await db.scoreEntryDao.setWinners(
        matchId: widget.match.id,
        winners: allPlayers.where((p) => _selectedPlayers.contains(p)).toList(),
      );
    }
  }

  /// Handles saving or removing the loser in the database.
  Future<bool> _handleLoser() async {
    if (_selectedPlayer == null) {
      return await db.scoreEntryDao.removeLoser(matchId: widget.match.id);
    } else {
      return await db.scoreEntryDao.setLoser(
        matchId: widget.match.id,
        playerId: _selectedPlayer!.id,
      );
    }
  }

  /// Handles saving the scores for each player in the database.
  Future<void> _handleScores() async {
    for (int i = 0; i < allPlayers.length; i++) {
      var text = controller[i].text;
      if (text.isEmpty) {
        text = '0';
      }
      final score = int.parse(text);
      await db.scoreEntryDao.addScore(
        matchId: widget.match.id,
        playerId: allPlayers[i].id,
        entry: ScoreEntry(roundNumber: 0, score: score, change: 0),
      );
    }
  }

  /// Handles saving the placement for each player in the database.
  Future<void> _handlePlacement() async {
    await db.scoreEntryDao.setPlacements(
      matchId: widget.match.id,
      players: allPlayers,
    );
  }

  String getTitleForRuleset(AppLocalizations loc) {
    switch (ruleset) {
      case Ruleset.singleWinner:
        return loc.select_winner;
      case Ruleset.singleLoser:
        return loc.select_loser;
      case Ruleset.placement:
        return loc.drag_to_set_placement;
      case Ruleset.multipleWinners:
        return loc.select_winners;
      default:
        return loc.enter_points;
    }
  }

  bool rulesetSupportsPlayerSelection() {
    return ruleset == Ruleset.singleWinner ||
        ruleset == Ruleset.singleLoser ||
        ruleset == Ruleset.multipleWinners;
  }

  bool rulesetSupportsScoreEntry() {
    return ruleset == Ruleset.lowestScore || ruleset == Ruleset.highestScore;
  }

  bool rulesetSupportsDragBehaviour() {
    return ruleset == Ruleset.placement;
  }
}
