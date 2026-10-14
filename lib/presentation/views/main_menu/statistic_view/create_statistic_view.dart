import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/colored_circle.dart';
import 'package:tallee/presentation/widgets/dialog/selection_sheet.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';
import 'package:uuid/uuid.dart';

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
  List<StatisticType> selectedTypes = [];
  List<StatisticScope> selectedScopes = [];
  List<Game> selectedGames = [];
  List<Group> selectedGroups = [];
  Timeframe selectedTimeframe = Timeframe.allTime;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // null -> random color
  AppColor? selectedColor;

  String get submitButtonText =>
      selectedScopes.contains(StatisticScope.selectedGroups) ||
          selectedScopes.contains(StatisticScope.selectedGames)
      ? AppLocalizations.of(context).continue_
      : AppLocalizations.of(context).create_statistic(selectedTypes.length);

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
        appBar: AppBar(title: Text(loc.create_statistic(1))),
        body: SafeArea(
          maintainBottomViewPadding: true,
          minimum: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selection
                    ChooseTile(
                      title: loc.type,
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: selectedTypes.isEmpty
                            ? Text(
                                loc.select_a_type,
                                style: const TextStyle(
                                  color: CustomTheme.hintColor,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  Text(
                                    translateStatisticTypeToString(
                                      selectedTypes.first,
                                      context,
                                    ),
                                  ),
                                  if (selectedTypes.length > 1)
                                    Text(
                                      '+ ${selectedTypes.length - 1}',
                                      style: TextStyle(
                                        color: CustomTheme.textColor.withAlpha(
                                          200,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      onPressed: () => showTypeSheet(loc),
                    ),

                    // Scope selection
                    ChooseTile(
                      title: loc.scope,
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: selectedScopes.isEmpty
                            ? Text(
                                loc.select_a_scope,
                                style: const TextStyle(
                                  color: CustomTheme.hintColor,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  Text(
                                    translateScopeToString(
                                      selectedScopes.first,
                                      context,
                                    ),
                                  ),
                                  if (selectedScopes.length > 1)
                                    Text(
                                      '+ ${selectedScopes.length - 1}',
                                      style: TextStyle(
                                        color: CustomTheme.textColor.withAlpha(
                                          200,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      onPressed: () => showScopeSheet(loc),
                    ),

                    // Timeframe selection
                    ChooseTile(
                      title: loc.timeframe,
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          translateTimeframeToString(
                            selectedTimeframe,
                            context,
                          ),
                        ),
                      ),
                      onPressed: () => showTimeframeSheet(loc),
                    ),

                    // Date range selection
                    if (selectedTimeframe == Timeframe.custom)
                      buildDateRangeField(context),

                    // Color selection
                    ChooseTile(
                      title: loc.color,
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Row(
                          spacing: 10,
                          children: [
                            if (selectedColor == null) ...[
                              const ColoredCircle(hasRandomColors: true),
                              Text(loc.random_color),
                            ] else ...[
                              ColoredCircle(color: selectedColor!),
                              Text(
                                translateAppColorToString(
                                  selectedColor!,
                                  context,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      onPressed: () => showColorSheet(loc),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 20,
                ),
                child: BottomAnimatedButton(
                  buttonConstraints: const BoxConstraints(minWidth: 390),
                  buttonText: submitButtonText,
                  sizeRelativeToWidth: 0.95,
                  onPressed: enableSubmitButton
                      ? () => submitStatistic()
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get enableSubmitButton =>
      (selectedTypes.isNotEmpty && selectedScopes.isNotEmpty) && !isLoading;

  /// Shows a bottom sheet to choose a color
  void showTypeSheet(AppLocalizations loc) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: CustomTheme.boxColor,
      isScrollControlled: true,
      builder: (BuildContext context) => SelectionSheet<StatisticType>.multiple(
        title: loc.type,
        description: loc.select_a_type_description,
        values: StatisticType.values,
        selectedValues: selectedTypes,
        leadingBuilder: (StatisticType type) =>
            Icon(getStatisticIcon(type: type)),
        labelBuilder: (BuildContext context, StatisticType scope) =>
            translateStatisticTypeToString(scope, context),
        onValuesUpdated: (scopes) => setState(() => selectedTypes = scopes),
      ),
    );
  }

  /// Shows a bottom sheet to choose a color
  void showScopeSheet(AppLocalizations loc) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: CustomTheme.boxColor,
      isScrollControlled: true,
      builder: (BuildContext context) =>
          SelectionSheet<StatisticScope>.multiple(
            title: loc.scope,
            description: loc.select_a_scope_description,
            values: StatisticScope.values,
            selectedValues: selectedScopes,
            leadingBuilder: (StatisticScope scope) =>
                Icon(getScopeIcon(scope: scope)),
            labelBuilder: (BuildContext context, StatisticScope scope) =>
                translateScopeToString(scope, context),
            onValuesUpdated: (scopes) =>
                setState(() => selectedScopes = scopes),
          ),
    );
  }

  /// Shows a bottom sheet to choose a color
  void showTimeframeSheet(AppLocalizations loc) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: CustomTheme.boxColor,
      isScrollControlled: true,
      builder: (BuildContext context) => SelectionSheet<Timeframe>(
        title: loc.timeframe,
        description: loc.select_a_timeframe_description,
        values: Timeframe.values,
        selectedValue: selectedTimeframe,
        labelBuilder: (BuildContext context, Timeframe tf) =>
            translateTimeframeToString(tf, context),
        onValueUpdated: (timeframe) =>
            setState(() => selectedTimeframe = timeframe!),
      ),
    );
  }

  void showColorSheet(AppLocalizations loc) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: CustomTheme.boxColor,
      isScrollControlled: true,
      builder: (BuildContext context) => SelectionSheet<AppColor>(
        title: loc.color,
        description: loc.select_a_color_description,
        values: AppColor.values,
        selectedValue: selectedColor,
        leadingBuilder: (AppColor color) => ColoredCircle(color: color),
        labelBuilder: (BuildContext context, AppColor color) =>
            translateAppColorToString(color, context),
        onValueUpdated: (color) => setState(() => selectedColor = color!),
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
        decoration: CustomTheme.standardBoxDecoration,
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

  Future<void> loadAllData() async {
    setState(() {
      isLoading = true;
    });
    final db = context.read<AppDatabase>();

    Future.wait([
          db.playerDao.getAllPlayers(),
          db.groupDao.getAllGroups(),
          db.gameDao.getAllGames(),
          Future.delayed(MINIMUM_SKELETON_DURATION),
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

  /// Creates the statistic based on the user selections. Navigates to the
  /// ChooseViews if their type has been selected
  Future<void> submitStatistic() async {
    final db = context.read<AppDatabase>();

    final result = await resolveBaseStatistic();
    if (result == null) return; // User cancelled the picker.
    final baseStat = result.statistic;
    final isStatSaved = result.isSaved;

    // Create additional statistic based on the base stat
    final additionalStats = [
      for (final type in selectedTypes.skip(1))
        baseStat.copyWith(id: const Uuid().v4(), type: type),
    ];

    final statsToSave = [
      // When only "All Players" has been selected, stat wont get saved to db
      if (!isStatSaved) baseStat,
      ...additionalStats,
    ];
    if (statsToSave.isNotEmpty) {
      await db.statisticDao.addStatisticsAsList(statistics: statsToSave);
    }

    if (!mounted) return;
    widget.onStatisticCreated([baseStat, ...additionalStats]);
    Navigator.of(context).pop();
  }

  /// Handles the navigation when multiple [StatisticType]s have been selected.
  /// Returns the base statistic + a flag indicating if it has been saved to the db
  Future<({Statistic statistic, bool isSaved})?> resolveBaseStatistic() async {
    final firstType = selectedTypes.first;

    // "Selected Groups" choosen
    if (selectedScopes.contains(StatisticScope.selectedGroups)) {
      final stat = await Navigator.of(context).push<Statistic>(
        adaptivePageRoute(
          settings: const RouteSettings(name: RouteNames.chooseGroupView),
          builder: (context) => ChooseGroupView(
            groups: groups,
            statistic: buildStat(firstType),
            selectedTypes: selectedTypes,
          ),
        ),
      );
      return stat == null ? null : (statistic: stat, isSaved: true);
    }

    // "Selected Games" choosen
    if (selectedScopes.contains(StatisticScope.selectedGames)) {
      final filteredGames = filterGamesForRequiredRuleset(games);
      final stat = await Navigator.of(context).push<Statistic>(
        adaptivePageRoute(
          settings: const RouteSettings(name: RouteNames.chooseGameView),
          builder: (context) => ChooseGameView(
            games: filteredGames,
            statistic: buildStat(firstType),
            selectedTypes: selectedTypes,
          ),
        ),
      );
      return stat == null ? null : (statistic: stat, isSaved: true);
    }

    // "All players" choosen
    return (statistic: buildStat(firstType), isSaved: false);
  }

  /// Filters the [games] based on the rulesets required by the selected [StatisticType]s
  List<Game> filterGamesForRequiredRuleset(List<Game> games) {
    final Set<Ruleset> requiredRulesets = {
      for (final t in selectedTypes) ...getRulesetForTypes(t),
    };
    return games.where((g) => requiredRulesets.contains(g.ruleset)).toList();
  }

  Statistic buildStat(StatisticType type) => Statistic(
    type: type,
    scopes: selectedScopes,
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
    return AppLocalizations.of(context).choose_date_range;
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

  @override
  void dispose() {
    selectedTypeNotifier.dispose();
    selectedScopeNotifier.dispose();
    selectedTimeframeNotifier.dispose();
    selectedColorNotifier.dispose();
    super.dispose();
  }
}
