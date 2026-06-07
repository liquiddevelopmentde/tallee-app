import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
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
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';

class CreateStatisticView extends StatefulWidget {
  const CreateStatisticView({super.key, required this.onStatisticCreated});

  final void Function() onStatisticCreated;

  @override
  State<CreateStatisticView> createState() => _CreateStatisticViewState();
}

class _CreateStatisticViewState extends State<CreateStatisticView> {
  bool isLoading = false;

  /* Controllers for user selections */
  final ValueNotifier<StatisticType?> selectedTypeNotifier =
      ValueNotifier<StatisticType?>(null);
  final ValueNotifier<List<StatisticScope>> selectedScopeNotifier =
      ValueNotifier<List<StatisticScope>>([]);
  final ValueNotifier<Timeframe> selectedTimeframeNotifier =
      ValueNotifier<Timeframe>(Timeframe.allTime);
  late final ValueNotifier<AppColor> selectedColorNotifier;

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
  Timeframe selectedTimeframe = Timeframe.allTime;
  late AppColor selectedColor;

  @override
  void initState() {
    loadAllData();

    final initialColor = getRandomAppColor();
    selectedColorNotifier = ValueNotifier<AppColor>(initialColor);
    selectedColor = initialColor;

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
                    Column(
                      spacing: 0,
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
                              Text(
                                loc.classifier_description,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<StatisticType>(
                              isExpanded: true,
                              hint: Text(
                                loc.select_a_classifier,
                                style: hintStyle,
                              ),
                              valueListenable: selectedTypeNotifier,
                              items: StatisticType.values
                                  .map(
                                    (item) => DropdownItem<StatisticType>(
                                      value: item,
                                      height: 44,
                                      child: Text(
                                        translateStatisticTypeToString(
                                          item,
                                          context,
                                        ),
                                        style: itemStyle,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      selectedTypeNotifier.value = value;
                                      setState(() {
                                        selectedType = value;
                                      });
                                    },
                              selectedItemBuilder: (context) {
                                return StatisticType.values
                                    .map(
                                      (_) =>
                                          ValueListenableBuilder<
                                            StatisticType?
                                          >(
                                            valueListenable:
                                                selectedTypeNotifier,
                                            builder: (context, current, _) {
                                              if (current == null) {
                                                return Text(
                                                  loc.select_a_classifier,
                                                  style: hintStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                );
                                              }
                                              return Text(
                                                translateStatisticTypeToString(
                                                  current,
                                                  context,
                                                ),
                                                style: headerStyle,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            },
                                          ),
                                    )
                                    .toList();
                              },
                              buttonStyleData: buttonStyle,
                              iconStyleData: const IconStyleData(
                                iconEnabledColor: CustomTheme.textColor,
                                iconDisabledColor: CustomTheme.hintColor,
                              ),
                              dropdownStyleData: dropdownStyle,
                              menuItemStyleData: menuStyle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Scope section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              Text(
                                loc.scope_description,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<StatisticScope>(
                              isExpanded: true,
                              hint: Text(loc.select_a_scope, style: hintStyle),
                              multiValueListenable: selectedScopeNotifier,
                              items: StatisticScope.values
                                  .map(
                                    (scope) => DropdownItem<StatisticScope>(
                                      value: scope,
                                      height: 44,
                                      closeOnTap: false,
                                      child:
                                          ValueListenableBuilder<
                                            List<StatisticScope>
                                          >(
                                            valueListenable:
                                                selectedScopeNotifier,
                                            builder: (context, values, _) {
                                              final isSelected = values
                                                  .contains(scope);
                                              return Row(
                                                children: [
                                                  Icon(
                                                    isSelected
                                                        ? Icons
                                                              .check_box_outlined
                                                        : Icons
                                                              .check_box_outline_blank,
                                                    color:
                                                        CustomTheme.textColor,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      translateScopeToString(
                                                        scope,
                                                        context,
                                                      ),
                                                      style: itemStyle,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                final current = [
                                  ...selectedScopeNotifier.value,
                                ];
                                final isSelected = current.contains(value);

                                if (isSelected) {
                                  current.remove(value);
                                } else {
                                  current.add(value);
                                }

                                // Keep selectedGroups and allPlayers mutually exclusive.
                                if (current.contains(
                                      StatisticScope.selectedGroups,
                                    ) &&
                                    current.contains(
                                      StatisticScope.allPlayers,
                                    )) {
                                  if (value == StatisticScope.selectedGroups) {
                                    current.remove(StatisticScope.allPlayers);
                                  } else if (value ==
                                      StatisticScope.allPlayers) {
                                    current.remove(
                                      StatisticScope.selectedGroups,
                                    );
                                  }
                                }

                                selectedScopeNotifier.value = current;
                                setState(() {
                                  selectedScope = current;
                                });
                              },
                              selectedItemBuilder: (context) {
                                return StatisticScope.values
                                    .map(
                                      (_) =>
                                          ValueListenableBuilder<
                                            List<StatisticScope>
                                          >(
                                            valueListenable:
                                                selectedScopeNotifier,
                                            builder: (context, values, _) {
                                              return Text(
                                                values
                                                    .map(
                                                      (s) =>
                                                          translateScopeToString(
                                                            s,
                                                            context,
                                                          ),
                                                    )
                                                    .join(', '),
                                                style: values.isEmpty
                                                    ? hintStyle
                                                    : headerStyle,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            },
                                          ),
                                    )
                                    .toList();
                              },
                              buttonStyleData: buttonStyle,
                              iconStyleData: const IconStyleData(
                                iconEnabledColor: CustomTheme.textColor,
                              ),
                              dropdownStyleData: dropdownStyle,
                              menuItemStyleData: menuStyle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Timeframe section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        // timeframe selection
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<Timeframe>(
                              isExpanded: true,
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  isLoading
                                      ? loc.loading
                                      : loc.select_a_timeframe,
                                  style: hintStyle,
                                ),
                              ),
                              valueListenable: selectedTimeframeNotifier,
                              items: Timeframe.values
                                  .map(
                                    (timeframe) => DropdownItem<Timeframe>(
                                      value: timeframe,
                                      height: 44,
                                      child: Text(
                                        translateTimeframeToString(
                                          timeframe,
                                          context,
                                        ),
                                        style: itemStyle,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isLoading
                                  ? null
                                  : (timeframe) {
                                      if (timeframe == null) return;
                                      selectedTimeframeNotifier.value =
                                          timeframe;
                                      setState(() {
                                        selectedTimeframe = timeframe;
                                      });
                                    },
                              buttonStyleData: buttonStyle,
                              iconStyleData: const IconStyleData(
                                iconEnabledColor: CustomTheme.textColor,
                                iconDisabledColor: CustomTheme.hintColor,
                              ),
                              dropdownStyleData: dropdownStyle,
                              menuItemStyleData: menuStyle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Color section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // color title
                        Padding(
                          padding: const EdgeInsetsGeometry.only(left: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.color,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: CustomTheme.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                loc.select_a_display_color,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: CustomTheme.textColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // color selection
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<AppColor>(
                              isExpanded: true,
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  isLoading
                                      ? loc.loading
                                      : loc.select_a_timeframe,
                                  style: hintStyle,
                                ),
                              ),
                              valueListenable: selectedColorNotifier,
                              items: AppColor.values
                                  .map(
                                    (color) => DropdownItem<AppColor>(
                                      value: color,
                                      height: 44,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: getColorFromAppColor(
                                                color,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            translateAppColorToString(
                                              color,
                                              context,
                                            ),
                                            style: itemStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (color) {
                                if (color == null) return;
                                selectedColorNotifier.value = color;
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              buttonStyleData: buttonStyle,
                              iconStyleData: const IconStyleData(
                                iconEnabledColor: CustomTheme.textColor,
                                iconDisabledColor: CustomTheme.hintColor,
                              ),
                              dropdownStyleData: dropdownStyle,
                              menuItemStyleData: menuStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Create statistic button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: AnimatedDialogButton(
                buttonConstraints: const BoxConstraints(minWidth: 390),
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

  TextStyle get headerStyle => const TextStyle(
    color: CustomTheme.textColor,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  TextStyle get itemStyle =>
      const TextStyle(color: CustomTheme.textColor, fontSize: 14);

  TextStyle get hintStyle =>
      const TextStyle(color: CustomTheme.hintColor, fontSize: 14);

  ButtonStyleData get buttonStyle => ButtonStyleData(
    height: 54,
    decoration: BoxDecoration(
      color: CustomTheme.onBoxColor,
      borderRadius: BorderRadius.circular(12),
    ),
  );

  MenuItemStyleData get menuStyle =>
      const MenuItemStyleData(padding: EdgeInsets.zero);

  DropdownStyleData get dropdownStyle => DropdownStyleData(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: CustomTheme.boxColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomTheme.boxBorderColor, width: 1),
    ),
  );

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
  /// selection view. Otherwise, saves the statistic to the database and returns
  /// to the previous screen.
  Future<void> submitStatistic() async {
    final scopes = [...selectedScope];
    final statistic = Statistic(
      type: selectedType!,
      scopes: scopes,
      timeframe: selectedTimeframe,
      color: selectedColor,
    );

    if (scopes.contains(StatisticScope.selectedGroups)) {
      // Navigating to the group selection
      final createdStatistic = await Navigator.of(context).push<Statistic>(
        adaptivePageRoute(
          builder: (context) =>
              ChooseGroupView(groups: groups, statistic: statistic),
        ),
      );
      if (!mounted) return;
      if (createdStatistic != null) {
        widget.onStatisticCreated();
        Navigator.of(context).pop(createdStatistic);
      }
    } else if (scopes.contains(StatisticScope.selectedGames)) {
      // Navigating to the game selection
      final createdStatistic = await Navigator.of(context).push<Statistic>(
        adaptivePageRoute(
          builder: (context) =>
              ChooseGameView(games: games, statistic: statistic),
        ),
      );
      if (!mounted) return;
      if (createdStatistic != null) {
        widget.onStatisticCreated();
        Navigator.of(context).pop(createdStatistic);
      }
    } else {
      // Create statistic and pop
      final db = Provider.of<AppDatabase>(context, listen: false);
      await db.statisticDao.addStatistic(statistic: statistic);
      if (!mounted) return;
      widget.onStatisticCreated();
      Navigator.of(context).pop(statistic);
    }
  }

  @override
  void dispose() {
    selectedTypeNotifier.dispose();
    selectedScopeNotifier.dispose();
    selectedTimeframeNotifier.dispose();
    super.dispose();
  }
}
