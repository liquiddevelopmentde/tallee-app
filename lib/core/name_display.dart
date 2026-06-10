import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';

/// Returns the player name count if greater 0 in the format " #2", otherwise an empty string
String getNameCountText(Player player) {
  if (player.nameCount >= 1) {
    return ' #${player.nameCount}';
  }
  return '';
}

/// Builds a text span that renders a player's name together with the
/// `#nameCount` suffix.
InlineSpan buildPlayerNameCountSpan(
  Player player, {
  TextStyle? mainStyle,
  TextStyle? countStyle,
}) {
  final resolvedMainStyle =
      mainStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  final resolvedCountStyle =
      countStyle ??
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: CustomTheme.textColor.withAlpha(100),
      );

  return TextSpan(
    style: const TextStyle(color: CustomTheme.textColor),
    children: [
      TextSpan(text: player.name, style: resolvedMainStyle),
      TextSpan(text: getNameCountText(player), style: resolvedCountStyle),
    ],
  );
}

/// Builds a text widget that renders a player's name together with the
/// `#nameCount` suffix.
Widget _buildPlayerNameCountWidget(
  Player player, {
  TextStyle? mainStyle,
  TextStyle? countStyle,
}) {
  return Text.rich(
    buildPlayerNameCountSpan(
      player,
      mainStyle: mainStyle,
      countStyle: countStyle,
    ),
  );
}

/// Builds a name display widget for a "Participating Unit" (Player or Team/Pair).
/// Handles teams, pairs, and individual players with consistent styling.
Widget buildUnitNameWidget(
  dynamic unit, {
  bool isTeamMatch = false,
  MainAxisAlignment rowAlignment = MainAxisAlignment.start,
  TextStyle? mainStyle,
  TextStyle? countStyle,
  bool pairIconLeft = false,
}) {
  if (unit is Team) {
    if (isTeamMatch) {
      return Text(
        unit.name,
        style:
            mainStyle ??
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CustomTheme.textColor,
            ),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return _buildPairGameNameWidget(
        unit,
        rowAlignment: rowAlignment,
        mainStyle: mainStyle,
        countStyle: countStyle,
        iconLeft: pairIconLeft,
      );
    }
  } else if (unit is Player) {
    return _buildPlayerNameCountWidget(
      unit,
      mainStyle: mainStyle,
      countStyle: countStyle,
    );
  }
  return const SizedBox.shrink();
}

/// Builds the name display used in several tiles when a pair is part of a match.
///
/// Shows either "PlayerA (count) & PlayerB (count)" with a link icon for pairs
/// or a single player's name with the count for single players.
Widget _buildPairGameNameWidget(
  Team team, {
  MainAxisAlignment rowAlignment = MainAxisAlignment.start,
  TextStyle? mainStyle,
  TextStyle? countStyle,
  bool iconLeft = false,
}) {
  final resolvedMainStyle =
      mainStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  final resolvedCountStyle =
      countStyle ??
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: CustomTheme.textColor.withAlpha(100),
      );

  final bool showIcon = team.members.length > 1;

  return Row(
    mainAxisAlignment: rowAlignment,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (iconLeft && showIcon) ...[
        const Icon(Icons.link, size: 18),
        const SizedBox(width: 5),
      ],
      if (team.members.length > 1) ...[
        RichText(
          text: TextSpan(
            style: const TextStyle(color: CustomTheme.textColor),
            children: [
              buildPlayerNameCountSpan(
                team.members[0],
                mainStyle: resolvedMainStyle,
                countStyle: resolvedCountStyle,
              ),
              TextSpan(text: ' & ', style: resolvedMainStyle),
              buildPlayerNameCountSpan(
                team.members[1],
                mainStyle: resolvedMainStyle,
                countStyle: resolvedCountStyle,
              ),
            ],
          ),
        ),
      ] else if (team.members.isNotEmpty) ...[
        _buildPlayerNameCountWidget(
          team.members.first,
          mainStyle: resolvedMainStyle,
          countStyle: resolvedCountStyle,
        ),
      ] else ...[
        Text(team.name, style: resolvedMainStyle),
      ],
      if (!iconLeft && showIcon) ...[
        const SizedBox(width: 5),
        const Icon(Icons.link, size: 18),
      ],
    ],
  );
}
