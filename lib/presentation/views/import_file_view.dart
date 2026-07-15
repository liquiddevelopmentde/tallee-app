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
                                    (game) => TextIconListTile(
                                      text: game.name,
                                      description: translateRulesetToString(
                                        game.ruleset,
                                        context,
                                      ),
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
                                      description:
                                          '${getGameNameForMatch(match.id)}, ${getPlayerCountForMatch(match.id).toString()} ${loc.players}',
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

  /// Returns the decoded json data
  Map<String, dynamic> get decodedData => isJsonStringEmpty
      ? const {}
      : json.decode(jsonString!) as Map<String, dynamic>;

  /// Returns the raw map entries stored under [key].
  List<Map<String, dynamic>> rawKeyList(String key) =>
      (decodedData[key] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .toList() ??
      const [];

  /// Maps the entries under [key] into typed models via [fromJson].
  List<T> listOf<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
      rawKeyList(key).map(fromJson).toList();

  /// Finds the entry under [key] whose id equals [id], or an empty map.
  Map<String, dynamic> findEntryByKeyAndId(String key, Object? id) =>
      rawKeyList(key).firstWhere((e) => e['id'] == id, orElse: () => const {});

  /// Returns the count of [key] in the json string
  int countOf(String key) => (decodedData[key] as List<dynamic>?)?.length ?? 0;

  List<Player> get getPlayersFromData => listOf('players', Player.fromJson);

  /// Returns all groups from the imported file
  List<Group> get getGroupsFromData => listOf('groups', Group.fromJson);

  /// Returns the amount of memberIds for a group with the given [groupId].
  int memberCountForGroup(String groupId) =>
      (findEntryByKeyAndId('groups', groupId)['memberIds'] as List<dynamic>?)
          ?.length ??
      0;

  List<Game> get getGamesFromData => listOf('games', Game.fromJson);

  List<Statistic> get getStatisticsFromData =>
      listOf('statistics', Statistic.fromJson);

  List<Match> getMatchesFromData() => listOf('matches', Match.fromJson);

  int getPlayerCountForMatch(String matchId) =>
      (findEntryByKeyAndId('matches', matchId)['playerIds'] as List<dynamic>?)
          ?.length ??
      0;

  String getGameNameForMatch(String matchId) {
    final gameId = findEntryByKeyAndId('matches', matchId)['gameId'];
    if (gameId == null) return '';
    return findEntryByKeyAndId('games', gameId)['name'] as String? ?? '';
  }

  /// Loads the import data from the file path and updates the loading/state values.
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

  /// Imports the data to the database
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
