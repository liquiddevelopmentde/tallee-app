import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/match_result_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/match_share_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/widgets/match_profile_body.dart';
import 'package:tallee/presentation/views/main_menu/player_view/player_detail_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu_button.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

class MatchDetailView extends StatefulWidget {
  /// A view that displays the profile of a match
  /// - [match]: The match to display
  /// - [onMatchUpdate]: Callback to refresh the match list
  const MatchDetailView({
    super.key,
    required this.match,
    required this.onMatchUpdate,
  });

  /// The match to display
  final Match match;

  /// Callback to refresh the match list
  final VoidCallback onMatchUpdate;

  @override
  State<MatchDetailView> createState() => _MatchDetailViewState();
}

class _MatchDetailViewState extends State<MatchDetailView> {
  late final AppDatabase db;

  late Match match;

  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    match = widget.match;
    nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.match_profile),
        actions: [
          PullDownMenuButton(
            items: [
              PullDownMenuTile(
                icon: Icons.copy,
                label: loc.duplicate,
                onTap: duplicateMatch,
              ),
              PullDownMenuTile(
                icon: Icons.share,
                label: loc.share,
                onTap: shareMatch,
              ),
              PullDownMenuTile(
                icon: Icons.delete,
                label: loc.delete,
                isDestructive: true,
                onTap: confirmDeleteMatch,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            MatchProfileBody(
              match: match,
              onPlayerTap: (player) {
                Navigator.of(context).pushReplacement(
                  adaptivePageRoute(
                    settings: const RouteSettings(
                      name: RouteNames.playerDetailView,
                    ),
                    builder: (context) => PlayerDetailView(
                      player: player,
                      onPlayerUpdated: widget.onMatchUpdate,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
              child: Row(
                spacing: 8,
                children: [
                  FloatingAnimatedButton(
                    icon: Icons.edit,
                    onPressed: () => editMatchNavigation(loc),
                  ),
                  FloatingAnimatedButton(
                    text: loc.enter_results,
                    icon: Icons.emoji_events,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        adaptivePageRoute(
                          settings: const RouteSettings(
                            name: RouteNames.matchResultView,
                          ),
                          fullscreenDialog: true,
                          builder: (context) => MatchResultView(
                            match: match,
                            onWinnerChanged: () async {
                              widget.onMatchUpdate.call();
                              await updateScoresForCurrentMatch();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void duplicateMatch() {
    Navigator.of(context).push(
      adaptivePageRoute(
        settings: const RouteSettings(name: RouteNames.createMatchView),
        builder: (context) => CreateMatchView(
          matchToPrefill: templateMatch,
          onWinnerChanged: widget.onMatchUpdate,
          onMatchesUpdated: widget.onMatchUpdate,
        ),
      ),
    );
  }

  void shareMatch() {
    final loc = AppLocalizations.of(context);
    if (match.endedAt != null) {
      Navigator.of(context).push(
        adaptivePageRoute(
          builder: (context) => MatchShareView(match: match),
          fullscreenDialog: true,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(message: loc.match_not_ended_share_warning),
      );
    }
  }

  void confirmDeleteMatch() {
    final loc = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: '${loc.delete_match}?',
        content: Text(
          loc.this_cannot_be_undone,
          overflow: TextOverflow.visible,
        ),
        actions: [
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            text: loc.delete,
          ),
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            buttonType: ButtonType.secondary,
            text: loc.cancel,
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != null && confirmed && mounted) {
        await db.matchDao.deleteMatch(matchId: match.id);
        if (!mounted) return;
        Navigator.pop(context);
        widget.onMatchUpdate.call();
      }
    });
  }

  /// Returns a copy of the current match without the previous match ID and
  /// scores, used as a template for duplicating a match.
  Match get templateMatch => Match(
    name: widget.match.name,
    game: widget.match.game,
    players: widget.match.players,
    group: widget.match.group,
    isTeamMatch: widget.match.isTeamMatch,
    notes: widget.match.notes,
    teams: widget.match.teams
        ?.map((t) => Team(name: t.name, color: t.color, members: t.members))
        .toList(),
  );

  /// Callback for when the match is updated in the edit view,
  /// updates the match in this view
  void onMatchUpdated(Match editedMatch) {
    setState(() {
      match = editedMatch;
    });
    widget.onMatchUpdate.call();
  }

  Future<void> updateScoresForCurrentMatch() async {
    final match = await db.matchDao.getMatchById(matchId: this.match.id);
    setState(() {
      this.match = match;
    });
  }

  bool isConfirmButtonEnabled() => nameController.text.trim().isNotEmpty;

  /// Navigates to the edit match view if the match hasnt ended yet, otherwise
  /// shows a dialog to only edit the name
  void editMatchNavigation(AppLocalizations loc) {
    // Match hasnt ended yet, allow editing
    if (match.endedAt == null) {
      Navigator.push(
        context,
        adaptivePageRoute(
          settings: const RouteSettings(name: RouteNames.createMatchView),
          fullscreenDialog: true,
          builder: (context) => CreateMatchView(
            matchToPrefill: match,
            editMode: true,
            onMatchUpdated: onMatchUpdated,
          ),
        ),
      );
    } else {
      // Match has ended, only allow name change
      nameController.text = match.name;
      showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return CustomAlertDialog(
              title: loc.edit_name,
              content: TextInputField(
                maxLength: MAX_MATCH_NAME_LENGTH,
                controller: nameController,
                hintText: loc.set_name,
                onChanged: (_) => setDialogState(() {}),
              ),
              actions: [
                CustomDialogAction(
                  onPressed: isConfirmButtonEnabled()
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  text: loc.confirm,
                ),
                CustomDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  buttonType: ButtonType.secondary,
                  text: loc.cancel,
                ),
              ],
            );
          },
        ),
      ).then((confirmed) async {
        if (confirmed != null && confirmed && context.mounted) {
          final newName = nameController.text.trim();

          if (newName != match.name) {
            await db.matchDao.updateMatchName(matchId: match.id, name: newName);
            onMatchUpdated(match.copyWith(name: newName));
          }
        }
      });
    }
  }
}
