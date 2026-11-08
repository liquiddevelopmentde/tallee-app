import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/date_picker_range.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/data/statistics/statistic_calculator.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_circle.dart';
import 'package:tallee/presentation/widgets/date_picker/custom_date_picker.dart';
import 'package:tallee/presentation/widgets/dialog/selection_sheet.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/statistics_tile.dart';

class CreateStatisticView extends StatefulWidget {
  const CreateStatisticView({super.key, required this.onStatisticCreated});

  final void Function(Statistic) onStatisticCreated;

  @override
  State<CreateStatisticView> createState() => _CreateStatisticViewState();
}

class _CreateStatisticViewState extends State<CreateStatisticView> {
  bool isLoading = false;

  /* Data loaded from the database */
  List<Player> players = [];
  List<Game> games = [];
  List<Match> matches = [];
  List<Group> groups = [];

  /* User selections */
  StatisticType? selectedType;
  List<StatisticScope> selectedScopes = [StatisticScope.allPlayers];
  List<Game> selectedGames = [];
  List<Group> selectedGroups = [];
  Timeframe selectedTimeframe = Timeframe.allTime;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // null -> random color
  AppColor? selectedColor;

  AppColor? previewRandomColor;

  bool get hasGroupScope =>
      selectedScopes.contains(StatisticScope.selectedGroups);

  bool get hasGameScope =>
      selectedScopes.contains(StatisticScope.selectedGames);

  bool get hasNoTypeSelected => selectedType == null;

  bool get enableSubmitButton =>
      selectedType != null &&
      selectedScopes.isNotEmpty &&
      (!hasGroupScope || selectedGroups.isNotEmpty) &&
      (!hasGameScope || selectedGames.isNotEmpty) &&
      !isLoading;

  @override
  void initState() {
    previewRandomColor = AppColor.randomColor();
    loadAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);

    return ScaffoldMessenger(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(loc.create_statistic)),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 12),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                // Fill at least the screen so the button sits at the bottom
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview of the statistic with sample data
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: buildPreview(loc),
                        ),

                        // Type selection
                        ChooseTile(
                          title: loc.type,
                          icon: Icons.bar_chart,
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: selectedType == null
                                ? Text(
                                    loc.select_a_type,
                                    style: TextStyle(
                                      color: context.talleeColors.hintColor,
                                    ),
                                  )
                                : Text(
                                    selectedType!.toLocalizedString(context),
                                  ),
                          ),
                          onPressed: () => showTypeSheet(loc),
                        ),

                        // Scope selection
                        ChooseTile(
                          title: loc.scope,
                          icon: Icons.hdr_strong,
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: selectedScopes.isEmpty
                                ? Text(
                                    loc.select_a_scope,
                                    style: TextStyle(
                                      color: context.talleeColors.hintColor,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        selectedScopes.first.toLocalizedString(
                                          context,
                                        ),
                                      ),
                                      if (selectedScopes.length > 1)
                                        Text(
                                          '+ ${selectedScopes.length - 1}',
                                          style: TextStyle(
                                            color: context
                                                .talleeColors
                                                .textColor
                                                .withAlpha(200),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                          onPressed: () => showScopeSheet(loc),
                        ),

                        // Group selection
                        if (hasGroupScope)
                          ChooseTile(
                            title: loc.groups,
                            icon: GROUP_ICON,
                            trailing: buildSelectionTrailing(
                              names: selectedGroups.map((g) => g.name).toList(),
                              hint: loc.select_groups,
                            ),
                            onPressed: showGroupSelection,
                          ),

                        // Game selection
                        if (hasGameScope)
                          ChooseTile(
                            title: loc.games,
                            icon: GAME_ICON,
                            trailing: buildSelectionTrailing(
                              names: selectedGames.map((g) => g.name).toList(),
                              hint: loc.select_games,
                            ),
                            onPressed: showGameSelection,
                          ),

                        // Timeframe selection
                        ChooseTile(
                          title: loc.timeframe,
                          icon: Icons.date_range,
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              selectedTimeframe.toLocalizedString(context),
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
                          icon: Icons.palette,
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Row(
                              spacing: 10,
                              children: [
                                if (selectedColor == null) ...[
                                  const ColoredCircle(isRandomColor: true),
                                  Text(loc.random_color),
                                ] else ...[
                                  ColoredCircle(color: selectedColor),
                                  Text(
                                    selectedColor!.toLocalizedString(context),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          onPressed: () => showColorSheet(loc),
                        ),
                      ],
                    ),

                    // Create statistic button
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 12),
                      child: Center(
                        child: BottomAnimatedButton(
                          text: loc.create_statistic,
                          onPressed: enableSubmitButton
                              ? submitStatistic
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a bottom sheet to choose a color
  void showTypeSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext ctx) => SelectionSheet<StatisticType>(
        title: loc.type,
        description: loc.select_a_type_description,
        values: StatisticType.values,
        selectedValue: selectedType,
        leadingBuilder: (StatisticType type) => Icon(type.icon),
        labelBuilder: (BuildContext ctx, StatisticType scope) =>
            scope.toLocalizedString(ctx),
        onValueUpdated: (StatisticType? type) => setState(() {
          selectedType = type;
          // Drop games that don't fit the rulesets of the new types
          selectedGames = filterGamesForRequiredRuleset(selectedGames);
        }),
      ),
    );
  }

  /// Shows a bottom sheet to choose a color
  void showScopeSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext ctx) => SelectionSheet<StatisticScope>.multiple(
        title: loc.scope,
        description: loc.select_a_scope_description,
        values: StatisticScope.values,
        selectedValues: selectedScopes,
        leadingBuilder: (StatisticScope scope) => Icon(scope.icon),
        labelBuilder: (BuildContext ctx, StatisticScope scope) =>
            scope.toLocalizedString(ctx),
        onValuesUpdated: (List<StatisticScope> scopes) =>
            setState(() => selectedScopes = scopes),
        exclusivePairs: const [
          (StatisticScope.allPlayers, StatisticScope.selectedGroups),
        ],
      ),
    );
  }

  /// Shows a bottom sheet to choose a color
  void showTimeframeSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext ctx) => SelectionSheet<Timeframe>(
        title: loc.timeframe,
        description: loc.select_a_timeframe_description,
        values: Timeframe.values,
        selectedValue: selectedTimeframe,
        labelBuilder: (BuildContext ctx, Timeframe tf) =>
            tf.toLocalizedString(ctx),
        onValueUpdated: (Timeframe? tf) =>
            setState(() => selectedTimeframe = tf!),
      ),
    );
  }

  /// Opens the [ChooseGroupView] to select the groups for the statistic
  Future<void> showGroupSelection() async {
    final result = await Navigator.of(context).push<List<Group>>(
      adaptivePageRoute(
        settings: const RouteSettings(name: RouteNames.chooseGroupView),
        builder: (BuildContext ctx) => ChooseGroupView(
          groups: groups,
          initialGroups: [...selectedGroups],
          enableMultiSelection: true,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => selectedGroups = result);
  }

  /// Opens the [ChooseGameView] to select the games for the statistic. Only
  /// games matching the rulesets of the selected types are shown
  Future<void> showGameSelection() async {
    final result = await Navigator.of(context).push<List<Game>>(
      adaptivePageRoute(
        settings: const RouteSettings(name: RouteNames.chooseGameView),
        builder: (BuildContext ctx) => ChooseGameView(
          games: filterGamesForRequiredRuleset(games),
          initialSelectedGames: [...selectedGames],
          enableMultiSelection: true,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => selectedGames = result);
  }

  /// Builds the trailing widget of a [ChooseTile] showing the first of the
  /// selected [names] and the amount of the remaining ones
  Widget buildSelectionTrailing({
    required List<String> names,
    required String hint,
  }) => Padding(
    padding: const EdgeInsets.only(right: 5),
    child: names.isEmpty
        ? Text(hint, style: TextStyle(color: context.talleeColors.hintColor))
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(names.first, overflow: TextOverflow.ellipsis),
              ),
              if (names.length > 1)
                Text(
                  '+ ${names.length - 1}',
                  style: TextStyle(
                    color: context.talleeColors.textColor.withAlpha(200),
                  ),
                ),
            ],
          ),
  );

  void showColorSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext context) => SelectionSheet<AppColor?>(
        title: loc.color,
        description: loc.select_a_color_description,
        values: const [null, ...AppColor.values],
        selectedValue: selectedColor,
        leadingBuilder: (AppColor? color) => color == null
            ? const ColoredCircle(isRandomColor: true)
            : ColoredCircle(color: color),
        labelBuilder: (BuildContext context, AppColor? color) =>
            color == null ? loc.random_color : color.toLocalizedString(context),
        onValueUpdated: (color) {
          setState(() {
            // if selected color is random, exclude previous color from random selection
            if (color == null) {
              previewRandomColor = AppColor.randomColor(exclude: selectedColor);
              selectedColor = null;
            } else {
              selectedColor = color;
            }
          });
          ;
        },
      ),
    );
  }

  /// Builds a preview of the selected [StatisticType] with the real
  /// match data
  Widget buildPreview(AppLocalizations loc) {
    final type = selectedType ?? StatisticType.totalWins;
    final statistic = buildStat(type);
    final values = StatisticCalculator.computeStatisticValues(
      statistic: statistic,
      matches: matches,
      players: players,
    ).take(statistic.displayCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 10),
          child: Text(
            loc.preview,
            style: TextStyle(
              color: context.talleeColors.hintColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StatisticsTile(
          statistic: statistic,
          values: hasNoTypeSelected ? [] : values,
          displayCount: statistic.displayCount,
          margin: EdgeInsets.zero,
          width: double.infinity,
          // Hides the favourite button
          showAllValues: true,
          emptyAssets: hasNoTypeSelected
              ? (
                  icon: Icons.bar_chart,
                  title: loc.statistic,
                  description: loc.your_statistic_will_be_shown_here,
                )
              : null,
        ),
      ],
    );
  }

  Widget buildDateRangeField(BuildContext context) => InkWell(
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
      decoration: context.standardBoxDecoration,
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: context.talleeColors.textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formatDateRange(context, selectedStartDate, selectedEndDate),
              style: TextStyle(
                color: selectedStartDate != null && selectedEndDate != null
                    ? context.talleeColors.textColor
                    : context.talleeColors.hintColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> loadAllData() async {
    setState(() {
      isLoading = true;
    });
    final db = context.read<AppDatabase>();

    await Future.wait([
          db.playerDao.getAllPlayers(),
          db.groupDao.getAllGroups(),
          db.gameDao.getAllGames(),
          db.matchDao.getAllMatches(),
          Future.delayed(MINIMUM_SKELETON_DURATION),
        ])
        .then((results) async {
          if (!mounted) return;
          setState(() {
            players = results[0];
            groups = results[1];
            games = results[2];
            matches = results[3];
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

  /// Creates one statistic per selected [StatisticType] and saves them
  Future<void> submitStatistic() async {
    final db = context.read<AppDatabase>();
    final stat = buildStat(selectedType!);
    await db.statisticDao.addStatistic(statistic: stat);

    if (!mounted) return;
    widget.onStatisticCreated(stat);
    Navigator.of(context).pop();
  }

  /// Filters the [games] based on the rulesets required by the selected [StatisticType]s
  List<Game> filterGamesForRequiredRuleset(List<Game> games) {
    if (selectedType == null) return games;
    final requiredRulesets = selectedType!.fittingRulesets;
    return games.where((g) => requiredRulesets.contains(g.ruleset)).toList();
  }

  Statistic buildStat(StatisticType type) => Statistic(
    type: type,
    scopes: selectedScopes,
    timeframe: selectedTimeframe,
    startDate: selectedStartDate,
    endDate: selectedEndDate,
    color: selectedColor ?? previewRandomColor,
    selectedGroups: hasGroupScope ? selectedGroups : null,
    selectedGames: hasGameScope ? selectedGames : null,
  );

  String formatDateRange(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null || endDate == null) {
      return AppLocalizations.of(context).choose_date_range;
    }
    return '${startDate.toShortDate(context)} - ${endDate.toShortDate(context)}';
  }

  Future<List<DateTime?>?> showCustomTimeframePicker({
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async => CustomDatePicker.show<List<DateTime?>>(
    context: context,
    selectionMode: DatePickerSelectionMode.range,
    initialRange: initialStartDate != null || initialEndDate != null
        ? DatePickerRange(startDate: initialStartDate, endDate: initialEndDate)
        : null,
  );
}
