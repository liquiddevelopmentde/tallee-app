import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/extensions/build_context_extensions.dart';
import 'package:tallee/core/extensions/date_time_extensions.dart';
import 'package:tallee/core/extensions/snack_bar_extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';

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

  @override
  void initState() {
    game = widget.game;
    db = context.read<AppDatabase>();
    super.initState();
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleGameDeletion(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: '${loc.delete_game}?',
        content: Text(
          loc.delete_game_warning_details,
          overflow: TextOverflow.visible,
        ),
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
