/// Centralized named routes used throughout the app.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String importFile = '/import';

  static const String groupView = '/home/groups';
  static const String createGroupView = '/home/groups/create';
  static const String groupDetailView = '/home/groups/{id}';

  static const String matchView = '/home/matches';
  static const String createMatchView = '/home/matches/create';
  static const String chooseGameView = '/home/matches/create/game';
  static const String chooseGroupView = '/home/matches/create/group';
  static const String createGameView = '/home/matches/create/newGame';
  static const String createTeamsView = '/home/matches/create/teams';
  static const String manageMembersView = '/home/matches/create/teams/members';
  static const String matchDetailView = '/home/matches/{id}';
  static const String matchResultView = '/home/matches/{id}/result';

  static const String playerDetailView = '/home/players/{id}';

  static const String statisticView = '/home/statistics';
  static const String createStatisticView = '/home/statistics/create';
  static const String chooseEnumView = '/home/statistics/create/scope';
  static const String statisticDetailView = '/home/statistics/{id}';

  static const String settingsView = '/home/settings';
  static const String licensesView = '/home/settings/licenses';
  static const String licenseDetailView = '/home/settings/licenses/{id}';
}
