import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

/// Translates a [Ruleset] enum value to its corresponding localized string.
String translateRulesetToString(Ruleset ruleset, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (ruleset) {
    case Ruleset.highestScore:
      return loc.highest_score;
    case Ruleset.lowestScore:
      return loc.lowest_score;
    case Ruleset.singleWinner:
      return loc.single_winner;
    case Ruleset.singleLoser:
      return loc.single_loser;
    case Ruleset.multipleWinners:
      return loc.multiple_winners;
    case Ruleset.placement:
      return loc.placement;
  }
}

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor(AppColor color) {
  switch (color) {
    case AppColor.red:
      return Colors.red;
    case AppColor.blue:
      return Colors.blue;
    case AppColor.green:
      return Colors.green;
    case AppColor.yellow:
      return const Color(0xFFF7CA28);
    case AppColor.purple:
      return Colors.purple;
    case AppColor.orange:
      return const Color(0xFFef681f);
    case AppColor.pink:
      return const Color(0xFFE91E63);
    case AppColor.teal:
      return const Color(0xFF00BCD4);
  }
}

// Returns a AppColor enum value based on the provided team [index].
AppColor getTeamColor(int index) {
  final colors = [
    AppColor.red,
    AppColor.blue,
    AppColor.green,
    AppColor.yellow,
    AppColor.purple,
    AppColor.orange,
    AppColor.pink,
    AppColor.teal,
  ];
  return colors[index % colors.length];
}

/// Translates a [AppColor] enum value to its corresponding localized string.
String translateAppColorToString(AppColor color, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (color) {
    case AppColor.red:
      return loc.color_red;
    case AppColor.blue:
      return loc.color_blue;
    case AppColor.green:
      return loc.color_green;
    case AppColor.yellow:
      return loc.color_yellow;
    //return const Color(0xFFF7CA28);
    case AppColor.purple:
      return loc.color_purple;
    case AppColor.orange:
      return loc.color_orange;
    case AppColor.pink:
      return loc.color_pink;
    case AppColor.teal:
      return loc.color_teal;
  }
}

/// Returns [IconData] corresponding to a [Ruleset] enum value.
IconData getRulesetIcon(Ruleset ruleset) {
  switch (ruleset) {
    case Ruleset.highestScore:
      return Icons.arrow_upward;
    case Ruleset.lowestScore:
      return Icons.arrow_downward;
    case Ruleset.singleWinner:
    case Ruleset.multipleWinners:
      return Icons.emoji_events;
    case Ruleset.singleLoser:
      return Icons.sentiment_dissatisfied;
    case Ruleset.placement:
      return RpgAwesome.podium;
  }
}

/// Counts how many players in the [match] are not part of the group
///
/// Returns the text you append after the group name, e.g. " + 5" or an empty
/// string if there are no extra players
String getExtraPlayerCount(Match match) {
  int count = 0;

  if (match.group == null) {
    return '';
  }

  final groupMembers = match.group!.members;
  final players = match.players;

  for (var player in players) {
    if (!groupMembers.any((member) => member.id == player.id)) {
      count++;
    }
  }

  if (count == 0) {
    return '';
  }
  return ' + ${count.toString()}';
}

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

/// Returns the correct singular or plural form of "point(s)" based on the [points] value.
String getPointLabel(AppLocalizations loc, int points) {
  if (points == 1) {
    return '$points ${loc.point}';
  } else {
    return '$points ${loc.points}';
  }
}

/// Builds a name display widget for a "Participating Unit" (Player or Team/Pair).
/// Handles teams, pairs, and individual players with consistent styling.
Widget buildUnitNameWidget(
  dynamic unit, {
  bool isTeamMatch = false,
  MainAxisAlignment rowAlignment = MainAxisAlignment.start,
  TextStyle? mainStyle,
  TextStyle? countStyle,
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
      return _buildPairgameNameWidget(
        unit,
        rowAlignment: rowAlignment,
        mainStyle: mainStyle,
        countStyle: countStyle,
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
Widget _buildPairgameNameWidget(
  Team team, {
  MainAxisAlignment rowAlignment = MainAxisAlignment.start,
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

  return Row(
    mainAxisAlignment: rowAlignment,
    mainAxisSize: MainAxisSize.min,
    children: [
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
        const SizedBox(width: 5),
        const Icon(Icons.link, size: 18),
      ] else if (team.members.isNotEmpty) ...[
        _buildPlayerNameCountWidget(
          team.members.first,
          mainStyle: resolvedMainStyle,
          countStyle: resolvedCountStyle,
        ),
      ] else ...[
        Text(team.name, style: resolvedMainStyle),
      ],
    ],
  );
}
