import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/util/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/dropdown/labeled_dropdown.dart';

class CreateStatisticView extends StatefulWidget {
  const CreateStatisticView({super.key, required this.onStatisticCreated});

  final void Function(List<Statistic>) onStatisticCreated;

  @override
  State<CreateStatisticView> createState() => _CreateStatisticViewState();
}

class _CreateStatisticViewState extends State<CreateStatisticView> {
  bool isLoading = false;

  /* Controllers for user selections */
  final ValueNotifier<List<StatisticType>> selectedTypeNotifier =
      ValueNotifier<List<StatisticType>>([]);
  final ValueNotifier<List<StatisticScope>> selectedScopeNotifier =
      ValueNotifier<List<StatisticScope>>([]);
  final ValueNotifier<Timeframe> selectedTimeframeNotifier =
      ValueNotifier<Timeframe>(Timeframe.allTime);
  late final ValueNotifier<AppColor?> selectedColorNotifier =
      ValueNotifier<AppColor?>(null);

  /* Data loaded from the database */
  List<Player> players = [];
  List<Game> games = [];
  List<Group> groups = [];

  /* User selections */
  List<StatisticType> selectedType = [];
  List<StatisticScope> selectedScope = [];
  List<Game> selectedGames = [];
  List<Player> selectedPlayers = [];
  List<Group> selectedGroups = [];
  Timeframe selectedTimeframe = Timeframe.allTime;
  // null -> random color
  AppColor? selectedColor;

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
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: CustomTheme.boxColor,
                  border: Border.all(color: CustomTheme.boxBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Classifier section
                    LabeledDropdown<StatisticType>.multi(
                      title: loc.classifier,
                      description: loc.classifier_description,
                      hintText: loc.select_a_classifier,
                      enabled: !isLoading,
                      multiValueListenable: selectedTypeNotifier,
                      options: [
                        for (final type in StatisticType.values)
                          DropdownOption(
                            value: type,
                            label: translateStatisticTypeToString(
                              type,
                              context,
                            ),
                          ),
                      ],
                      onItemTap: onClassifierTapped,
                    ),

                    // Scope section
                    LabeledDropdown<StatisticScope>.multi(
                      title: loc.scope,
                      description: loc.scope_description,
                      hintText: loc.select_a_scope,
                      multiValueListenable: selectedScopeNotifier,
                      options: [
                        for (final scope in StatisticScope.values)
                          DropdownOption(
                            value: scope,
                            label: translateScopeToString(scope, context),
                          ),
                      ],
                      onItemTap: onScopeTapped,
                    ),

                    // Timeframe section
                    LabeledDropdown<Timeframe>(
                      title: loc.timeframe,
                      description: loc.select_the_filtered_timeframe,
                      hintText: isLoading
                          ? loc.loading
                          : loc.select_a_timeframe,
                      enabled: !isLoading,
                      valueListenable: selectedTimeframeNotifier,
                      options: [
                        for (final timeframe in Timeframe.values)
                          DropdownOption(
                            value: timeframe,
                            label: translateTimeframeToString(
                              timeframe,
                              context,
                            ),
                          ),
                      ],
                      onChanged: (timeframe) {
                        if (timeframe == null) return;
                        selectedTimeframeNotifier.value = timeframe;
                        setState(() => selectedTimeframe = timeframe);
                      },
                    ),

                    // Color section
                    LabeledDropdown<AppColor?>(
                      title: loc.color,
                      description: loc.select_a_display_color,
                      hintText: isLoading
                          ? loc.loading
                          : loc.select_a_timeframe,
                      valueListenable: selectedColorNotifier,
                      options: [
                        DropdownOption<AppColor?>(
                          value: null,
                          label: loc.random_color,
                          leading: buildColorCircle(),
                        ),
                        for (final color in AppColor.values)
                          DropdownOption<AppColor?>(
                            value: color,
                            label: translateAppColorToString(color, context),
                            leading: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: getColorFromAppColor(color),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                      onChanged: (color) {
                        selectedColorNotifier.value = color;
                        setState(() => selectedColor = color);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Create statistic button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: BottomAnimatedButton(
                buttonConstraints: const BoxConstraints(minWidth: 390),
                buttonText: submitButtonText,
                onPressed:
                    (selectedType.isNotEmpty && selectedScope.isNotEmpty) &&
                        !isLoading
                    ? () => submitStatistic()
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles a classifier (statistic type) selection.
  void onClassifierTapped(StatisticType value) {
    final current = [...selectedTypeNotifier.value];
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    selectedTypeNotifier.value = current;
    setState(() {
      selectedType = current;
    });
  }

  /// Toggles a scope selection, keeping `selectedGroups` and `allPlayers`
  /// mutually exclusive.
  void onScopeTapped(StatisticScope value) {
    final current = [...selectedScopeNotifier.value];
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }

    // Keep selectedGroups and allPlayers mutually exclusive.
    if (current.contains(StatisticScope.selectedGroups) &&
        current.contains(StatisticScope.allPlayers)) {
      if (value == StatisticScope.selectedGroups) {
        current.remove(StatisticScope.allPlayers);
      } else if (value == StatisticScope.allPlayers) {
        current.remove(StatisticScope.selectedGroups);
      }
    }

    selectedScopeNotifier.value = current;
    setState(() {
      selectedScope = current;
    });
  }

  String get submitButtonText =>
      selectedScope.contains(StatisticScope.selectedGroups) ||
          selectedScope.contains(StatisticScope.selectedGames)
      ? AppLocalizations.of(context).confirm
      : AppLocalizations.of(context).create_statistic;

  Future<void> loadAllData() async {
    setState(() {
      isLoading = true;
    });
    final db = Provider.of<AppDatabase>(context, listen: false);

    Future.wait([
          db.playerDao.getAllPlayers(),
          db.groupDao.getAllGroups(),
          db.gameDao.getAllGames(),
          Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
        ])
        .then((results) async {
          if (!mounted) return;
          setState(() {
            players = results[0];
            groups = results[1];
            games = results[2];
            isLoading = false;
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
          print('Error loading data: $error');
        });
  }

  /// Creates the statistic based on the user selections. If the statistic
  /// requires selecting specific groups or games, navigates to the respective
  /// selection view. For multiple selected types, one [Statistic] per type is
  /// created — all sharing the same scope, timeframe and color.
  Future<void> submitStatistic() async {
    final scopes = [...selectedScope];
    final db = Provider.of<AppDatabase>(context, listen: false);

    if (scopes.contains(StatisticScope.selectedGroups)) {
      final created = await Navigator.of(context).push<Statistic>(
        adaptivePageRoute(
          builder: (context) => ChooseGroupView(
            groups: groups,
            statistic: buildStat(selectedType.first),
          ),
        ),
      );
      if (created == null) return;
      final additionalStats = [
        for (final type in selectedType.skip(1)) created.copyWith(type: type),
      ];
      for (final stat in additionalStats) {
        await db.statisticDao.addStatistic(statistic: stat);
      }
      if (!mounted) return;
      widget.onStatisticCreated([created, ...additionalStats]);
      Navigator.of(context).pop();
    } else if (scopes.contains(StatisticScope.selectedGames)) {
      final created = await Navigator.of(context).push<Statistic>(
        adaptivePageRoute(
          builder: (context) => ChooseGameView(
            games: games,
            statistic: buildStat(selectedType.first),
          ),
        ),
      );
      if (created == null) return;
      final additionalStats = [
        for (final t in selectedType.skip(1)) created.copyWith(type: t),
      ];
      for (final stat in additionalStats) {
        await db.statisticDao.addStatistic(statistic: stat);
      }
      if (!mounted) return;
      widget.onStatisticCreated([created, ...additionalStats]);
      Navigator.of(context).pop();
    } else {
      final stats = [for (final t in selectedType) buildStat(t)];
      await db.statisticDao.addStatisticsAsList(statistics: stats);
      if (!mounted) return;
      widget.onStatisticCreated(stats);
      Navigator.of(context).pop();
    }
  }

  Statistic buildStat(StatisticType type) => Statistic(
    type: type,
    scopes: selectedScope,
    timeframe: selectedTimeframe,
    color: selectedColor ?? getRandomAppColor(),
  );

  Widget buildColorCircle() {
    final segmentColors = [
      AppColor.red,
      AppColor.purple,
      AppColor.blue,
      AppColor.green,
      AppColor.yellow,
      AppColor.orange,
    ].map((c) => getColorFromAppColor(c)).toList();

    // Repeat first color at the end so the seam does not swallow red.
    final colors = [...segmentColors, segmentColors.first];
    final stops = List<double>.generate(
      colors.length,
      (i) => i / (colors.length - 1),
    );

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }

  @override
  void dispose() {
    selectedTypeNotifier.dispose();
    selectedScopeNotifier.dispose();
    selectedTimeframeNotifier.dispose();
    selectedColorNotifier.dispose();
    super.dispose();
  }
}
