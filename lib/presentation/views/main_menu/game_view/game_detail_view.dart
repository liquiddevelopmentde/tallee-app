import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/icon_constants.dart';
import 'package:tallee/core/extensions/build_context_extensions.dart';
import 'package:tallee/core/extensions/date_time_extensions.dart';
import 'package:tallee/core/extensions/snack_bar_extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/game_view/create_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail/match_detail_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/detail_tile.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/game_matches_tile.dart';

class GameDetailView extends StatefulWidget {
  /// A view that displays the profile of a game
  /// - [game]: The game to display
  /// - [onGameUpdated]: Callback invoked when a game is updated
  const GameDetailView({super.key, required this.game, this.onGameUpdated});

  final Game game;
  final VoidCallback? onGameUpdated;

  @override
  State<GameDetailView> createState() => _GameDetailViewState();
}

class _GameDetailViewState extends State<GameDetailView> {
  late final AppDatabase db;
  bool isLoading = true;

  late Game game;
  List<Match> matches = [];

  @override
  void initState() {
    super.initState();
    game = widget.game;
    db = context.read<AppDatabase>();
    loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.talleeColors.backgroundColor,
      appBar: AppBar(
        title: Text(loc.game_profile),
        actions: [
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async => handleGameDeletion(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 20,
                bottom: 100,
              ),
              children: [
                Center(
                  child: ColoredIconContainer(
                    icon: game.ruleset.icon,
                    color: game.color.colorValue(context),
                    containerSize: 55,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  game.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.talleeColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(GAME_ICON, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      game.ruleset.toLocalizedString(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (game.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      game.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.talleeColors.hintColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  '${loc.created_on} ${game.createdAt.toMediumDate(context)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.talleeColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Matches
                GameMatchesTile(
                  matches: matches,
                  isLoading: isLoading,
                  onMatchTap: openMatch,
                ),
                const SizedBox(height: 15),

                // Statistics
                DetailTile(rows: statisticRows(context)),
              ],
            ),

            Positioned(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
              child: FloatingAnimatedButton(
                text: loc.edit_game,
                icon: Icons.edit,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    adaptivePageRoute<({Game? updatedGame})>(
                      settings: const RouteSettings(
                        name: RouteNames.editGameView,
                      ),
                      builder: (context) => CreateGameView(
                        gameToEdit: game,
                        onGameChanged: loadStatistics,
                      ),
                    ),
                  );
                  final updatedGame = result?.updatedGame;
                  if (updatedGame != null && mounted) {
                    setState(() => game = updatedGame);
                    widget.onGameUpdated?.call();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The rows shown in the statistics tile, derived from [matches].
  List<(String, String)> statisticRows(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return [
      (loc.played_matches, matches.length.toString()),
      (loc.best_player, bestPlayer()),
      (
        loc.last_played,
        matches.isEmpty ? '-' : matches.first.createdAt.toMediumDate(context),
      ),
    ];
  }

  /// The players with the most MVP titles across [matches], or `-` if none.
  String bestPlayer() {
    final mvpCounts = <String, int>{};
    final playerNames = <String, String>{};

    for (final match in matches) {
      for (final player in match.mvp) {
        mvpCounts.update(player.id, (count) => count + 1, ifAbsent: () => 1);
        playerNames[player.id] = player.name;
      }
    }

    if (mvpCounts.isEmpty) return '-';

    final sortedCounts = mvpCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final highestCount = sortedCounts.first.value;

    final names =
        sortedCounts
            .where((entry) => entry.value == highestCount)
            .map((entry) => playerNames[entry.key]!)
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return names.join(', ');
  }

  /// Opens the given [match], either in the result or the detail view.
  void openMatch(Match match) {
    final isFinished = match.endedAt != null;

    Navigator.of(context).push(
      adaptivePageRoute(
        settings: RouteSettings(
          name: isFinished
              ? RouteNames.matchDetailView
              : RouteNames.matchResultView,
        ),
        builder: (context) => isFinished
            ? MatchDetailView(match: match, onMatchUpdate: loadStatistics)
            : MatchResultView(match: match, onWinnerChanged: loadStatistics),
      ),
    );
  }

  /// Loads statistics for this game
  Future<void> loadStatistics() async {
    final gameMatches = await db.matchDao.getMatchesByGame(gameId: game.id);
    if (!mounted) return;

    setState(() {
      matches = gameMatches;
      isLoading = false;
    });
  }

  Future<void> handleGameDeletion(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final dialogContent = matches.isEmpty
        ? loc.this_cannot_be_undone
        : loc.delete_game_with_matches_warning(matches.length);

    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: '${loc.delete_game}?',
        content: Text(dialogContent, overflow: TextOverflow.visible),
        actions: [
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            accent: ButtonAccent.destructive,
            text: loc.delete,
          ),
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            buttonType: ButtonType.secondary,
            text: loc.cancel,
          ),
        ],
      ),
    );
    if (confirmed == null || !confirmed) return;
    if (!context.mounted) return;

    final success = await db.gameDao.deleteGame(gameId: game.id);
    if (!context.mounted) return;
    if (!success) {
      context.showSnackBar(message: loc.error_deleting_game);
      return;
    }

    context.showSnackBar(message: loc.game_deleted);
    Navigator.of(context).pop();
    widget.onGameUpdated?.call();
  }
}
