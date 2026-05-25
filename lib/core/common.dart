import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
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

/// Returns [IconData] corresponding to a [Ruleset] enum value.
IconData getRulesetIcon(Ruleset ruleset) {
  switch (ruleset) {
    case Ruleset.highestScore:
      return Icons.arrow_upward;
    case Ruleset.lowestScore:
      return Icons.arrow_downward;
    case Ruleset.singleWinner:
      return Icons.emoji_events;
    case Ruleset.singleLoser:
      return Icons.sentiment_dissatisfied;
    case Ruleset.multipleWinners:
      return Icons.group;
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

String getNameCountText(Player player) {
  if (player.nameCount >= 1) {
    return ' #${player.nameCount}';
  }
  return '';
}

String getPointLabel(AppLocalizations loc, int points) {
  if (points == 1) {
    return '$points ${loc.point}';
  } else {
    return '$points ${loc.points}';
  }
}
