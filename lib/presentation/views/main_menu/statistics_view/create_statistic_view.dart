import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';

class CreateStatisticView extends StatefulWidget {
  const CreateStatisticView({super.key, required this.onStatisticCreated});

  final void Function() onStatisticCreated;

  @override
  State<CreateStatisticView> createState() => _CreateStatisticViewState();
}

class _CreateStatisticViewState extends State<CreateStatisticView> {
  bool isLoading = false;

  /* Data loaded from the database */
  List<Player> players = [];
  List<Game> games = [];
  List<Group> groups = [];

  /* User selections */
  StatisticType? selectedType;
  List<StatisticScope> selectedScope = [];
  List<Game> selectedGames = [];
  List<Player> selectedPlayers = [];
  List<Group> selectedGroups = [];
  Timeframe? selectedTimeframe;

  @override
  void initState() {
    loadAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);

    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(title: Text(loc.create_statistic)),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Classifier title
                  Padding(
                    padding: const EdgeInsetsGeometry.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.classifier,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: CustomTheme.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'description',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: CustomTheme.textColor,
                            fontSize: 12,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),

                  // Classifier selection
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: CustomDropdown<StatisticType>(
                      closedHeaderPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      listItemBuilder:
                          (context, item, isSelected, onItemSelect) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                translateStatisticTypeToString(item, context),
                                style: itemStyle,
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: CustomTheme.textColor,
                                ),
                            ],
                          ),
                      headerBuilder: (context, selectedType, enabled) => Text(
                        translateStatisticTypeToString(selectedType, context),
                        style: headerStyle,
                      ),
                      hintText: loc.select_a_classifier,
                      items: StatisticType.values,
                      decoration: decoration,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Scope title
                  Padding(
                    padding: const EdgeInsetsGeometry.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.scope,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: CustomTheme.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'description',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: CustomTheme.textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scope selection
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: CustomDropdown<StatisticScope>.multiSelect(
                      closedHeaderPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      hintText: loc.select_a_scope,
                      items: StatisticScope.values,
                      decoration: decoration,
                      listItemBuilder:
                          (context, scope, isSelected, onItemSelect) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                translateScopeToString(scope, context),
                                style: itemStyle,
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: CustomTheme.textColor,
                                ),
                            ],
                          ),
                      headerListBuilder: (context, selectedItems, enabled) =>
                          Text(
                            selectedItems
                                .map((s) => translateScopeToString(s, context))
                                .join(', '),
                            style: headerStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                      onListChanged: (List<StatisticScope> values) {
                        setState(() {
                          selectedScope = values;
                        });
                      },
                    ),
                  ),

                  if (selectedScope.contains(StatisticScope.selectedGames)) ...[
                    const SizedBox(height: 10),

                    // games title
                    Padding(
                      padding: const EdgeInsetsGeometry.only(left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.games,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            loc.select_the_filtered_games,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // game selection
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: CustomDropdown<Game>.multiSelect(
                        enabled: !isLoading,
                        disabledDecoration: disabledDecoration,
                        closedHeaderPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        hintText: isLoading ? loc.loading : loc.select_a_game,
                        items: games,
                        decoration: decoration,
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Name
                                    Text(item.name, style: itemStyle),
                                    const SizedBox(width: 12),

                                    // Ruleset
                                    Text(
                                      translateRulesetToString(
                                        item.ruleset,
                                        context,
                                      ),
                                      style: hintStyle.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),

                                // Check icon
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: CustomTheme.textColor,
                                  ),
                              ],
                            ),
                        headerListBuilder: (context, selectedItems, enabled) =>
                            Text(
                              selectedItems.map((g) => g.name).join(', '),
                              style: const TextStyle(
                                color: CustomTheme.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        onListChanged: (List<Game> values) {
                          setState(() {
                            selectedGames = values;
                          });
                        },
                      ),
                    ),
                  ],

                  if (selectedScope.contains(
                    StatisticScope.selectedGroups,
                  )) ...[
                    const SizedBox(height: 10),

                    // groups title
                    Padding(
                      padding: const EdgeInsetsGeometry.only(left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.groups,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            loc.select_the_filtered_groups,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // groups selection
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: CustomDropdown<Group>.multiSelect(
                        enabled: !isLoading,
                        disabledDecoration: disabledDecoration,
                        closedHeaderPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        hintText: isLoading ? loc.loading : loc.select_a_group,
                        items: groups,
                        decoration: decoration,
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Name
                                    Text(item.name, style: itemStyle),
                                    const SizedBox(width: 12),

                                    // Ruleset
                                    Text(
                                      ' ${item.members.length.toString()} ${loc.members}',
                                      style: hintStyle.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: CustomTheme.textColor,
                                  ),
                              ],
                            ),
                        headerListBuilder: (context, selectedItems, enabled) =>
                            Text(
                              selectedItems.map((g) => g.name).join(', '),
                              style: headerStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                        onListChanged: (List<Group> groups) {
                          setState(() {
                            selectedGroups = groups;
                          });
                        },
                      ),
                    ),
                  ],

                  if (selectedScope.contains(StatisticScope.timeframe)) ...[
                    const SizedBox(height: 10),

                    // timeframe title
                    Padding(
                      padding: const EdgeInsetsGeometry.only(left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.timeframe,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            loc.select_the_filtered_timeframe,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // groups selection
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: CustomDropdown<Timeframe>(
                        enabled: !isLoading,
                        excludeSelected: false,
                        disabledDecoration: disabledDecoration,
                        closedHeaderPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        hintText: isLoading
                            ? loc.loading
                            : loc.select_a_timeframe,
                        items: Timeframe.values,
                        decoration: decoration,
                        listItemBuilder:
                            (context, timeframe, isSelected, onItemSelect) =>
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      translateTimeframeToString(
                                        timeframe,
                                        context,
                                      ),
                                      style: itemStyle,
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check,
                                        color: CustomTheme.textColor,
                                      ),
                                  ],
                                ),
                        headerBuilder: (context, selectedTimeframe, enabled) =>
                            Text(
                              translateTimeframeToString(
                                selectedTimeframe,
                                context,
                              ),
                              style: headerStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                        onChanged: (Timeframe? timeframe) {
                          setState(() {
                            selectedTimeframe = timeframe;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Create statistic button
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              child: AnimatedDialogButton(
                sizeRelativeToWidth: 0.95,
                buttonText: loc.create_statistic,
                onPressed: selectedType != null && selectedScope.isNotEmpty
                    ? () => submitStatistic()
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomDropdownDecoration get decoration => CustomDropdownDecoration(
    listItemDecoration: const ListItemDecoration(
      selectedIconBorder: BorderSide(color: CustomTheme.primaryColor, width: 1),
      selectedIconColor: CustomTheme.primaryColor,
      highlightColor: CustomTheme.secondaryColor,
      splashColor: Colors.transparent,
      selectedColor: CustomTheme.onBoxColor,
    ),
    listItemStyle: itemStyle,
    headerStyle: headerStyle,
    hintStyle: hintStyle,
    closedFillColor: CustomTheme.boxColor,
    closedBorder: Border.all(color: CustomTheme.boxBorderColor, width: 1),
    expandedFillColor: CustomTheme.boxColor,
    expandedBorder: Border.all(color: CustomTheme.boxBorderColor, width: 1),
  );

  CustomDropdownDisabledDecoration get disabledDecoration =>
      CustomDropdownDisabledDecoration(
        fillColor: CustomTheme.boxColor.withAlpha(125),
        border: Border.all(
          color: CustomTheme.boxBorderColor.withAlpha(125),
          width: 1,
        ),
        headerStyle: disabledHeaderStyle,
        hintStyle: disabledHintStyle,
      );

  TextStyle get headerStyle => const TextStyle(
    color: CustomTheme.textColor,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  TextStyle get itemStyle =>
      const TextStyle(color: CustomTheme.textColor, fontSize: 14);

  TextStyle get hintStyle =>
      const TextStyle(color: CustomTheme.hintColor, fontSize: 14);

  TextStyle get disabledHeaderStyle => const TextStyle(
    color: CustomTheme.hintColor,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  TextStyle get disabledHintStyle =>
      const TextStyle(color: CustomTheme.hintColor, fontSize: 14);

  Future<void> loadAllData() async {
    isLoading = true;
    final db = Provider.of<AppDatabase>(context, listen: false);

    Future.wait([
          db.playerDao.getAllPlayers(),
          db.groupDao.getAllGroups(),
          db.gameDao.getAllGames(),
          Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
        ])
        .then((results) async {
          players = results[0];
          groups = results[1];
          games = results[2];
          isLoading = false;
        })
        .catchError((error) {
          print('Error loading data: $error');
        });
  }

  void submitStatistic() {
    final newStatistic = Statistic(
      type: selectedType!,
      scopes: selectedScope,
      timeframe: selectedTimeframe,
      selectedGroups: selectedGroups,
      selectedGames: selectedGames,
    );
    final db = Provider.of<AppDatabase>(context, listen: false);
    db.statisticDao.addStatistic(statistic: newStatistic);
    Navigator.of(context).pop(newStatistic);
  }
}

String translateTimeframeToString(Timeframe timeframe, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (timeframe) {
    case Timeframe.last7Days:
      return loc.last_7_days;
    case Timeframe.last30Days:
      return loc.last_30_days;
    case Timeframe.last90Days:
      return loc.last_90_days;
    case Timeframe.last180Days:
      return loc.last_180_days;
    case Timeframe.lastYear:
      return loc.last_year;
    case Timeframe.allTime:
      return loc.all_time;
  }
}

String translateScopeToString(StatisticScope scope, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (scope) {
    case StatisticScope.allPlayers:
      return loc.all_players;
    case StatisticScope.selectedGroups:
      return loc.selected_groups;
    case StatisticScope.selectedGames:
      return loc.selected_games;
    case StatisticScope.timeframe:
      return loc.timeframe;
  }
}

String translateStatisticTypeToString(
  StatisticType type,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);
  switch (type) {
    case StatisticType.totalMatches:
      return loc.total_matches;
    case StatisticType.totalWins:
      return loc.total_wins;
    case StatisticType.totalScore:
      return loc.total_score;
    case StatisticType.totalLosses:
      return loc.total_losses;
    case StatisticType.averageScore:
      return loc.average_score;
    case StatisticType.bestScore:
      return loc.best_score;
    case StatisticType.worstScore:
      return loc.worst_score;
    case StatisticType.winrate:
      return loc.winrate;
  }
}
