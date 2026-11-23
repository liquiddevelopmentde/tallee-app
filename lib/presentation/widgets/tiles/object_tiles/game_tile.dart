import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/core/theme/app_spacing.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

class GameTile extends StatelessWidget {
  /// A list tile widget that displays a title and description, with optional highlighting and badge.
  /// - [game]: The game object displayed on the tile.
  /// - [gameCount]: How many matches use this game.
  /// - [onTap]: The callback invoked when the tile is tapped.
  /// - [isHighlighted]: A boolean to determine if the tile should be highlighted.
  /// - [borderColor]: Optional color for the highlight border. If null gamecolor is used.
  const GameTile({
    super.key,
    required this.game,
    this.gameCount,
    this.onTap,
    this.isHighlighted = false,
    this.borderColor,
  });

  final Game game;
  final int? gameCount;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final title = game.name;
    final description = game.description;
    final ruleset = game.ruleset.toLocalizedString(context);
    final gameColor = game.color.colorValue(context);
    final highlightBorderColor = borderColor ?? gameColor;

    return GestureDetector(
      onTap: () {
        Haptics.selectionClick();
        if (onTap != null) {
          onTap!.call();
        }
      },
      child: AnimatedContainer(
        margin: AppSpacing.tileMargin,
        padding: AppSpacing.tilePadding,
        decoration: !isHighlighted
            ? context.standardBoxDecoration
            : context.highlightedBoxDecoration.copyWith(
                border: Border.all(
                  color: highlightBorderColor.withValues(alpha: 0.9),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
        duration: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Icon
                ColoredIconContainer(
                  icon: game.ruleset.icon,
                  color: gameColor,
                  margin: EdgeInsets.zero,
                ),

                // Text content
                Expanded(
                  child: Row(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Ruleset
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            // Ruleset
                            Text(
                              ruleset,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.talleeColors.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Gamecount
                      if (gameCount != null)
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              MATCH_ICON,
                              color: context.talleeColors.hintColor,
                              size: 22,
                            ),
                            Text(
                              gameCount.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.talleeColors.hintColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Description
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                // Padding to keep the visual start correct
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 2.5),
            ],
          ],
        ),
      ),
    );
  }
}
