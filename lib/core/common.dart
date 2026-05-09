import 'package:flutter/cupertino.dart';
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

/// Counts how many players in the match are not part of the group
/// Returns the count as a string, or an empty string if there is no group
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
