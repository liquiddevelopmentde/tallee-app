/// Button types used for styling the [CustomWidthButton]
/// - [ButtonType.primary]: Primary button style.
/// - [ButtonType.secondary]: Secondary button style.
/// - [ButtonType.tertiary]: Tertiary button style.
enum ButtonType { primary, secondary, tertiary }

/// Result types for import operations in the [SettingsView]
/// - [ImportResult.success]: The import operation was successful.
/// - [ImportResult.canceled]: The import operation was canceled by the user.
/// - [ImportResult.fileReadError]: There was an error reading the selected file.
/// - [ImportResult.invalidSchema]: The JSON schema of the imported data is invalid.
/// - [ImportResult.invalidData]: The JSON Schema is correct, but the data itself is invalid.
/// - [ImportResult.formatException]: A format exception occurred during import.
/// - [ImportResult.unknownException]: An exception occurred during import.
enum ImportResult {
  success,
  canceled,
  fileReadError,
  fileNotFound,
  invalidSchema,
  invalidData,
  formatException,
  unknownException,
}

/// Result types for export operations in the [SettingsView]
/// - [ExportResult.success]: The export operation was successful.
/// - [ExportResult.canceled]: The export operation was canceled by the user.
/// - [ExportResult.unknownException]: An exception occurred during export.
/// - [ExportResult.noData]: There is no data to export.
enum ExportResult { success, canceled, unknownException, noData }

/// Different rulesets available for games
/// - [Ruleset.highestScore]: The player with the highest score wins.
/// - [Ruleset.lowestScore]: The player with the lowest score wins.
/// - [Ruleset.singleWinner]: The match is won by a single player.
/// - [Ruleset.singleLoser]: The match has a single loser.
/// - [Ruleset.multipleWinners]: Multiple players can be winners.
/// - [Ruleset.placement]: The player with the highest placement wins.
enum Ruleset {
  singleWinner,
  multipleWinners,
  highestScore,
  lowestScore,
  placement,
  singleLoser,
}

/// Different colors for highlighting content
enum AppColor { red, orange, yellow, green, teal, blue, purple, pink }

enum StatisticType {
  totalMatches,
  totalWins,
  totalScore,
  totalLosses,
  averageScore,
  bestScore,
  worstScore,
  winrate,
}

enum StatisticScope { allPlayers, selectedGroups, selectedGames }

enum Timeframe {
  last7Days,
  last30Days,
  last90Days,
  last180Days,
  lastYear,
  allTime,
}
