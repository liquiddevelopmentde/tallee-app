import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/icon_utils.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

/// A tile that displays a game, following the same card style as the match
/// and group tiles: a leading colored icon container, the game name with its
/// ruleset below, and a trailing chevron.
class GameTile extends StatelessWidget {
  const GameTile({
    super.key,
    required this.game,
    this.isHighlighted = false,
    this.onTap,
    this.onLongPress,
  });

  /// The game data to be displayed.
  final Game game;

  /// Whether the tile should be highlighted.
  final bool isHighlighted;

  /// Callback function to be executed when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback function to be executed when the tile is long-pressed.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final gameColor = getColorFromAppColor(game.color);

    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        onTap?.call();
      },
      onLongPress: () async {
        await HapticFeedback.heavyImpact();
        onLongPress?.call();
      },
      child: AnimatedContainer(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.all(12),
        decoration: isHighlighted
            ? CustomTheme.highlightedBoxDecoration.copyWith(
                border: Border.all(
                  color: gameColor,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              )
            : CustomTheme.standardBoxDecoration,
        duration: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColoredIconContainer(
                  icon: getRulesetIcon(game.ruleset),
                  color: gameColor,
                  containerSize: 44,
                  iconSize: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        translateRulesetToString(game.ruleset, context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomTheme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: CustomTheme.hintColor,
                ),
              ],
            ),
            if (game.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(game.description, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}