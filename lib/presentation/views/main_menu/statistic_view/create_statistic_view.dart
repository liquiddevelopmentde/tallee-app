import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
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
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
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
                    buildClassifierSection(context, loc),
                    buildScopeSection(context, loc),
                    buildTimeframeSection(context, loc),
                    if (selectedTimeframe == Timeframe.custom)
                      buildCustomTimeframeSection(context, loc),
                    buildColorSection(context, loc),
                  ],
                ),
              ),
            ),
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

  Widget buildClassifierSection(BuildContext context, AppLocalizations loc) {
    return LabeledDropdown<StatisticType>.multi(
      title: loc.classifier,
      description: loc.classifier_description,
      hintText: loc.select_a_classifier,
      enabled: !isLoading,
      multiValueListenable: selectedTypeNotifier,
      options: [
        for (final type in StatisticType.values)
          DropdownOption(
            value: type,
            label: translateStatisticTypeToString(type, context),
          ),
      ],
      onItemTap: onClassifierTapped,
    );
  }

  Widget buildScopeSection(BuildContext context, AppLocalizations loc) {
    return LabeledDropdown<StatisticScope>.multi(
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
    );
  }

  Widget buildTimeframeSection(BuildContext context, AppLocalizations loc) {
    return LabeledDropdown<Timeframe>(
      title: loc.timeframe,
      description: loc.select_the_filtered_timeframe,
      hintText: isLoading ? loc.loading : loc.select_a_timeframe,
      enabled: !isLoading,
      valueListenable: selectedTimeframeNotifier,
      options: [
        for (final timeframe in Timeframe.values)
          DropdownOption(
            value: timeframe,
            label: translateTimeframeToString(timeframe, context),
          ),
      ],
      onChanged: (timeframe) {
        if (timeframe == null) return;
        selectedTimeframeNotifier.value = timeframe;
        setState(() => selectedTimeframe = timeframe);
      },
    );
  }

  Widget buildCustomTimeframeSection(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Text(
              loc.custom,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              loc.select_a_date_range,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          buildDateRangeField(context),
        ],
      ),
    );
  }

  Widget buildDateRangeField(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isLoading
          ? null
          : () async {
              final results = await showCustomTimeframePicker(
                initialStartDate: selectedStartDate,
                initialEndDate: selectedEndDate,
              );

              if (results != null &&
                  results.length >= 2 &&
                  results[0] != null &&
                  results[1] != null) {
                setState(() {
                  selectedStartDate = results[0];
                  selectedEndDate = results[1];
                });
              }
            },
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CustomTheme.onBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: CustomTheme.textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatDateRange(context, selectedStartDate, selectedEndDate),
                style: TextStyle(
                  color: selectedStartDate != null && selectedEndDate != null
                      ? CustomTheme.textColor
                      : CustomTheme.hintColor,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColorSection(BuildContext context, AppLocalizations loc) {
    return LabeledDropdown<AppColor?>(
      title: loc.color,
      description: loc.select_a_display_color,
      hintText: isLoading ? loc.loading : loc.select_a_timeframe,
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
    startDate: selectedStartDate,
    endDate: selectedEndDate,
    color: selectedColor ?? getRandomAppColor(),
  );

  String formatDateRange(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && endDate != null) {
      final locale = Localizations.localeOf(context).toString();
      return '${DateFormat.yMd(locale).format(startDate)} - ${DateFormat.yMd(locale).format(endDate)}';
    }
    return AppLocalizations.of(context).custom;
  }

  Future<List<DateTime?>?> showCustomTimeframePicker({
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async {
    return showDialog<List<DateTime?>>(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: CustomTheme.primaryColor,
              onPrimary: CustomTheme.textColor,
              surface: CustomTheme.boxColor,
              onSurface: CustomTheme.textColor,
            ),
          ),
          child: Dialog(
            backgroundColor: CustomTheme.boxColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: CustomTheme.boxBorderColor),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 450,
              child: SfDateRangePicker(
                backgroundColor: CustomTheme.boxColor,
                showNavigationArrow: true,
                initialSelectedRange:
                    initialStartDate != null && initialEndDate != null
                    ? PickerDateRange(initialStartDate, initialEndDate)
                    : null,
                headerStyle: const DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.transparent,
                  textStyle: TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                monthCellStyle: const DateRangePickerMonthCellStyle(
                  textStyle: TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 16,
                  ),
                  todayTextStyle: TextStyle(
                    color: CustomTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  leadingDatesTextStyle: TextStyle(
                    color: CustomTheme.hintColor,
                    fontSize: 16,
                  ),
                  trailingDatesTextStyle: TextStyle(
                    color: CustomTheme.hintColor,
                    fontSize: 16,
                  ),
                ),
                yearCellStyle: const DateRangePickerYearCellStyle(
                  textStyle: TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 16,
                  ),
                  todayTextStyle: TextStyle(
                    color: CustomTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: TextStyle(
                      color: CustomTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  firstDayOfWeek: 1,
                ),
                selectionMode: DateRangePickerSelectionMode.range,
                selectionColor: CustomTheme.primaryColor,
                startRangeSelectionColor: CustomTheme.primaryColor,
                endRangeSelectionColor: CustomTheme.primaryColor,
                rangeSelectionColor: CustomTheme.primaryColor.withValues(
                  alpha: 0.15,
                ),
                selectionTextStyle: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                rangeTextStyle: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 16,
                ),
                showActionButtons: true,
                onSubmit: (value) {
                  if (value is PickerDateRange) {
                    Navigator.pop(context, [value.startDate, value.endDate]);
                  }
                },
                onCancel: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      },
    );
  }

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
