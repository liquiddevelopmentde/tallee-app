import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/tiles/settings_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';
import 'package:tallee/services/data_transfer_service.dart';
import 'package:tallee/state/data_refresh_provider.dart';

/// A page shown when the app is opened by a `.tallee` file.
///
/// It parses the file, shows how many entities it contains and lets the user
/// confirm or reject the import. On completion it pops itself and reports the
/// outcome through a snackbar shown via [messengerKey].
class ImportFileView extends StatefulWidget {
  const ImportFileView({
    super.key,
    required this.filePath,
    required this.messengerKey,
  });

  final String filePath;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  @override
  State<ImportFileView> createState() => _ImportFileViewState();
}

class _ImportFileViewState extends State<ImportFileView> {
  bool isLoading = true;
  String? jsonString;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    const style = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: CustomTheme.backgroundColor,
        title: Text(loc.import_data),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 4),
                    child: Text(
                      '${loc.import_preview_description}:',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CustomTheme.hintColor,
                      ),
                    ),
                  ),
                  AppSkeleton(
                    enabled: isLoading,
                    child: Column(
                      spacing: 10,
                      children: [
                        // Playes
                        SettingsListTile(
                          icon: Icons.person_rounded,
                          title: loc.players,
                          suffixWidget: Text(
                            '${countOf('players')}',
                            style: style,
                          ),
                          expandedContent: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: getPlayersFromData
                                  .map((player) => PlayerTile(player: player))
                                  .toList(),
                            ),
                          ),
                        ),

                        // Groups
                        SettingsListTile(
                          icon: Icons.group_rounded,
                          title: loc.groups,
                          suffixWidget: Text(
                            '${countOf('groups')}',
                            style: style,
                          ),
                          expandedContent: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: getGroupsFromData
                                  .map(
                                    (group) => TextIconListTile(
                                      text: group.name,
                                      description:
                                          '${memberCountForGroup(group.id).toString()} ${loc.members}',
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                        // Games
                        SettingsListTile(
                          icon: Icons.casino_rounded,
                          title: loc.games,
                          suffixWidget: Text(
                            '${countOf('games')}',
                            style: style,
                          ),
                          expandedContent: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: getGamesFromData
                                  .map(
                                    (game) => GameLabel(
                                      title: game.name,
                                      description: translateRulesetToString(
                                        game.ruleset,
                                        context,
                                      ),
                                      color: game.color,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                        // Matches
                        SettingsListTile(
                          icon: Icons.gamepad_rounded,
                          title: loc.matches,
                          suffixWidget: Text(
                            '${countOf('matches')}',
                            style: style,
                          ),
                          expandedContent: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Column(
                              spacing: 10,
                              children: getMatchesFromData()
                                  .map(
                                    (match) => TextIconListTile(
                                      text: match.name,
                                      description: getGameNameForMatch(
                                        match.id,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                        // Statistics
                        SettingsListTile(
                          icon: Icons.bar_chart_rounded,
                          title: loc.statistics,
                          suffixWidget: Text(
                            '${countOf('statistics')}',
                            style: style,
                          ),
                          expandedContent: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: getStatisticsFromData
                                  .map(
                                    (statistic) => TextIconListTile(
                                      text: translateStatisticTypeToString(
                                        statistic.type,
                                        context,
                                      ),
                                      description: statistic.scopes
                                          .map(
                                            (scope) => translateScopeToString(
                                              scope,
                                              context,
                                            ),
                                          )
                                          .join(', '),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BottomAnimatedButton(
                  buttonText: loc.confirm,
                  sizeRelativeToWidth: 0.95,
                  onPressed: jsonString == null ? null : confirmImport,
                ),
                BottomAnimatedButton(
                  buttonText: loc.cancel,
                  buttonType: ButtonType.secondary,
                  sizeRelativeToWidth: 0.95,
                  onPressed: cancelImport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get isJsonStringEmpty => jsonString == null || jsonString!.isEmpty;

  /// Returns the count of [key] in the json string
  int countOf(String key) {
    if (isJsonStringEmpty) return 0;

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    return (decoded[key] as List<dynamic>?)?.length ?? 0;
  }

  List<Player> get getPlayersFromData {
    if (isJsonStringEmpty) return [];

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    return (decoded['players'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Player.fromJson)
            .toList() ??
        [];
  }

  /// Returns all groups from the imported file
  List<Group> get getGroupsFromData {
    if (isJsonStringEmpty) return [];
    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    return (decoded['groups'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Group.fromJson)
            .toList() ??
        [];
  }

  /// Returns the amount of memberIds for a group with the given [groupId].
  int memberCountForGroup(String groupId) {
    if (isJsonStringEmpty) return 0;

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    final groups = decoded['groups'] as List<dynamic>?;
    if (groups == null) return 0;

    final group = groups.whereType<Map<String, dynamic>>().firstWhere(
      (g) => g['id'] == groupId,
      orElse: () => <String, dynamic>{},
    );

    final members = group['memberIds'];
    return members.length ?? 0;
  }

  List<Game> get getGamesFromData {
    if (isJsonStringEmpty) return [];

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    return (decoded['games'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Game.fromJson)
            .toList() ??
        [];
  }

  List<Statistic> get getStatisticsFromData {
    if (isJsonStringEmpty) return [];

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    return (decoded['statistics'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Statistic.fromJson)
            .toList() ??
        [];
  }

  List<Match> getMatchesFromData() {
    if (isJsonStringEmpty) return [];

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    return (decoded['matches'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Match.fromJson)
            .toList() ??
        [];
  }

  String getGameNameForMatch(String matchId) {
    if (isJsonStringEmpty) return '';

    final decoded = json.decode(jsonString!) as Map<String, dynamic>;
    final matches = decoded['matches'] as List<dynamic>?;
    if (matches == null) return '';

    final match = matches.whereType<Map<String, dynamic>>().firstWhere(
      (m) => m['id'] == matchId,
      orElse: () => <String, dynamic>{},
    );

    final gameId = match['gameId'];
    if (gameId == null) return '';

    final games = decoded['games'] as List<dynamic>?;
    if (games == null) return '';

    final game = games.whereType<Map<String, dynamic>>().firstWhere(
      (g) => g['id'] == gameId,
      orElse: () => <String, dynamic>{},
    );

    return game['name'] ?? '';
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final result = await DataTransferService.getDataFromPath(widget.filePath);

    if (!mounted) return;

    if (result.$1 != ImportResult.success || result.$2 == null) {
      finishImport(importResult: result.$1);
      return;
    }

    setState(() {
      jsonString = result.$2;
      isLoading = false;
    });
  }

  Future<void> confirmImport() async {
    final jsonString = this.jsonString;
    if (jsonString == null) return;

    final db = Provider.of<AppDatabase>(context, listen: false);
    final result = await DataTransferService.commitImport(db, jsonString);

    if (!mounted) return;
    finishImport(importResult: result);
  }

  Future<void> cancelImport() async {
    finishImport(importResult: ImportResult.canceled);
  }

  /// Pops the page and shows a snackbar describing [importResult].
  Future<void> finishImport({required ImportResult importResult}) async {
    if (!mounted) return;

    final message = translateImportResultToString(importResult, context);

    if (importResult == ImportResult.success) {
      Provider.of<DataRefreshProvider>(context, listen: false).refresh();
    }

    Navigator.of(context).maybePop();

    if (importResult == ImportResult.success) {
      await HapticFeedback.successNotification();
    } else if (importResult != ImportResult.canceled) {
      await HapticFeedback.errorNotification();
    }

    final messenger = widget.messengerKey.currentState;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(CustomSnackBar(message: message));
  }
}
