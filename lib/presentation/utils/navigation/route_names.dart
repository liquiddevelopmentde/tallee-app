/// Centralized named routes used throughout the app.
abstract final class RouteNames {
  // App lifecycle
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String mainNavigation = '/home';

  // Import
  static const String importFile = '/import';
  static const String previewMatchView = '/home/preview';

  // Games
  static const String gameView = '/home/games';
  static const String createGameView = '/home/games/create';
  static const String gameDetailView = '/home/games/{id}';
  static const String editGameView = '/home/games/{id}/edit';

  // Groups
  static const String groupView = '/home/groups';
  static const String createGroupView = '/home/groups/create';
  static const String groupDetailView = '/home/groups/{id}';
  static const String editGroupView = '/home/groups/{id}/edit';

  // Matches
  static const String matchView = '/home/matches';
  static const String createMatchView = '/home/matches/create';
  static const String chooseGameView = '/home/matches/create/game';
  static const String chooseGroupView = '/home/matches/create/group';
  static const String createTeamsView = '/home/matches/create/teams';
  static const String manageMembersView = '/home/matches/create/teams/members';
  static const String matchDetailView = '/home/matches/{id}';
  static const String editMatchView = '/home/matches/{id}/edit';
  static const String matchResultView = '/home/matches/{id}/result';
  static const String matchShareView = '/home/matches/{id}/share';
  static const String matchReceiveView = '/home/matches/receive';
  static const String associateGameView =
      '/home/matches/receive/associate-game';
  static const String associateGroupView =
      '/home/matches/receive/associate-group';
  static const String associatePlayersView =
      '/home/matches/receive/associate-players';

  // Players
  static const String playerDetailView = '/home/players/{id}';
  static const String editPlayerView = '/home/players/{id}/edit';

  // Settings
  static const String settingsView = '/home/settings';
  static const String dataManagementView = '/home/settings/data';
  static const String feedbackFormView = '/home/settings/feedback';
  static const String licensesView = '/home/settings/licenses';
  static const String licenseDetailView = '/home/settings/licenses/{id}';
  static const String privacyPolicyView = '/home/settings/privacy';

  // Statistics
  static const String statisticView = '/home/statistics';
  static const String createStatisticView = '/home/statistics/create';
  static const String chooseEnumView = '/home/statistics/create/scope';
  static const String statisticDetailView = '/home/statistics/{id}';
}
