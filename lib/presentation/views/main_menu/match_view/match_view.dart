import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/configs.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/cards/text_chip.dart';
import 'package:tallee/presentation/widgets/custom_showcase_widget.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/match_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';
import 'package:tallee/services/shared_preferences_service.dart';
import 'package:tallee/state/match_search_provider.dart';
import 'package:tallee/state/rate_dialog_provider.dart';
import 'package:tallee/state/showcase_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchView extends StatefulWidget {
  /// A view that displays a list of matches
  const MatchView({super.key});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late final AppDatabase db;
  late final MatchSearchProvider searchProvider;
  late RateDialogProvider rateProvider;

  bool isLoading = true;
  bool isSearchBarVisible = true;
  MatchFilter selectedFilter =
      SharedPreferencesService.getMatchFilter() ?? MatchFilter.all;

  final GlobalKey matchViewCreateButtonKey = GlobalKey();
  final String matchViewCreateButtonIdentifier =
      'match_view_create_match_button';

  final String navbarMatchViewIdentifier = 'navbar_match_view';

  late final ShowcaseProvider showcaseProvider;

  TextEditingController searchBarController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  /// Loaded matches from the database, initially filled with skeleton matches
  List<Match> allMatches = List.filled(
    4,
    Match(
      name: 'Skeleton match name',
      game: Game(
        name: 'Game name',
        ruleset: Ruleset.winner,
        color: AppColor.blue,
      ),
      group: Group(
        name: 'Group name',
        members: List.filled(5, Player(name: 'Player')),
      ),
      players: [
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(id: 'mvp_id', name: 'Player'),
      ],
      scores: {'mvp_id': ScoreEntry(score: 1)},
      endedAt: DateTime.now(),
    ),
  );

  /// Matches based on the selected filter
  late List<Match> filteredMatches = [...allMatches];

  /// Matches based on the search query
  late List<Match> displayedMatches = [...allMatches];

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();

    searchProvider = context.read<MatchSearchProvider>();
    searchProvider.addListener(handleSearchToggle);

    rateProvider = context.read<RateDialogProvider>();
    rateProvider.addListener(handleRatingDialog);

    showcaseProvider = context.read<ShowcaseProvider>();

    loadMatches();

    if (showcaseProvider.hasSeen(navbarMatchViewIdentifier)) {
      handleShowcase(
        widgetKeys: [matchViewCreateButtonKey],
        identifiers: [matchViewCreateButtonIdentifier],
        showcaseProvider: showcaseProvider,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    searchProvider.removeListener(handleSearchToggle);
    rateProvider.removeListener(handleRatingDialog);
    searchBarController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final searchProvider = context.read<MatchSearchProvider>();

    // Reset filtered matches when search is disabled
    if (!searchProvider.isSearching) {
      applySearch('');
      isSearchBarVisible = true;
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AppSkeleton(
            enabled: isLoading,

            // No matches created
            child: Column(
              children: [
                // Searchbar
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    );

                    return ClipRect(
                      child: SizeTransition(
                        sizeFactor: curvedAnimation,
                        alignment: Alignment.topCenter,
                        child: FadeTransition(
                          opacity: curvedAnimation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: searchProvider.isSearching && isSearchBarVisible
                      ? Padding(
                          key: const ValueKey('match-searchbar-visible'),
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 10,
                          ),
                          child: CustomSearchBar(
                            controller: searchBarController,
                            hintText: '',
                            trailingButtonShown:
                                searchBarController.text.isNotEmpty,
                            onTrailingButtonPressed: () {
                              searchBarController.clear();
                              setState(() {
                                applySearch('');
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                applySearch(value);
                              });
                            },
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('match-searchbar-hidden'),
                        ),
                ),

                // Filter row
                SingleChildScrollView(
                  padding: CustomTheme.filterRowPadding,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 5,
                    children: [
                      // All matches
                      TextChip(
                        text: loc.all,
                        onTap: () => setFilter(MatchFilter.all),
                        activated: selectedFilter == MatchFilter.all,
                      ),

                      // Active matches
                      TextChip(
                        text: loc.active_matches,
                        onTap: () => setFilter(MatchFilter.active),
                        activated: selectedFilter == MatchFilter.active,
                      ),

                      // Finished matches
                      TextChip(
                        text: loc.finished_matches,
                        onTap: () => setFilter(MatchFilter.finished),
                        activated: selectedFilter == MatchFilter.finished,
                      ),

                      // Team matches
                      TextChip(
                        text: loc.team_matches,
                        onTap: () => setFilter(MatchFilter.team),
                        activated: selectedFilter == MatchFilter.team,
                      ),

                      // To keep padding on the right side
                      const SizedBox.shrink(),
                    ],
                  ),
                ),

                // Matches
                Expanded(
                  // No matches created

                  child: allMatches.isEmpty
                      ? Center(
                          child: TopCenteredMessage(
                            icon: Icons.info,
                            title: loc.info,
                            message: loc.no_matches_created_yet,
                          ),
                        )
                      // No matches in filter
                      : filteredMatches.isEmpty
                      ? Center(
                          child: TopCenteredMessage(
                            icon: Icons.info,
                            title: loc.info,
                            message: loc.there_is_no_match_matching_your_filter,
                          ),
                        )
                      // No matches in search
                      : displayedMatches.isEmpty
                      ? TopCenteredMessage(
                          icon: Icons.info,
                          title: loc.info,
                          message: loc.there_is_no_match_matching_your_search,
                        )
                      : NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            if (notification.direction ==
                                    ScrollDirection.reverse &&
                                isSearchBarVisible) {
                              setState(() => isSearchBarVisible = false);
                            } else if (notification.direction ==
                                    ScrollDirection.forward &&
                                !isSearchBarVisible) {
                              setState(() => isSearchBarVisible = true);
                            }
                            return true;
                          },
                          child: ListView.builder(
                            controller: scrollController,
                            padding: CustomTheme.listViewPadding(context),
                            itemCount: displayedMatches.length,
                            itemBuilder: (BuildContext context, int index) {
                              return MatchTile(
                                width: MediaQuery.sizeOf(context).width * 0.95,
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    adaptivePageRoute(
                                      settings: const RouteSettings(
                                        name: RouteNames.matchDetailView,
                                      ),
                                      builder: (context) => MatchDetailView(
                                        match: displayedMatches[index],
                                        onMatchUpdate: loadMatches,
                                      ),
                                    ),
                                  );
                                },
                                match: displayedMatches[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: CustomShowcaseWidget(
              showcaseKey: matchViewCreateButtonKey,
              identifier: matchViewCreateButtonIdentifier,
              description: loc.showcase_match_view_create,
              disableBarrierInteraction: true,
              disposeOnTap: true,
              onTargetClick: () {
                navigateToCreateMatchView();
                showcaseProvider.markAsSeen('match_view_create_match_button');
              },
              tooltipPosition: TooltipPosition.top,
              targetBorderRadius: BorderRadius.circular(30),
              child: FloatingAnimatedButton(
                text: loc.create_match,
                icon: MATCH_ICON,
                showAddBadge: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    adaptivePageRoute(
                      settings: const RouteSettings(
                        name: RouteNames.createMatchView,
                      ),
                      builder: (context) => CreateMatchView(
                        onWinnerChanged: loadMatches,
                        onMatchesUpdated: loadMatches,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToCreateMatchView() {
    Navigator.push(
      context,
      adaptivePageRoute(
        settings: const RouteSettings(name: RouteNames.createMatchView),
        builder: (context) => CreateMatchView(
          onWinnerChanged: loadMatches,
          onMatchesUpdated: loadMatches,
        ),
      ),
    );
  }

  void setFilter(MatchFilter filter) {
    setState(() {
      selectedFilter = filter;
      applyFilter(filter);
    });
    SharedPreferencesService.setMatchFilter(filter);
  }

  void applyFilter(MatchFilter filter) {
    switch (filter) {
      case MatchFilter.all:
        filteredMatches = [...allMatches];
      case MatchFilter.active:
        filteredMatches = allMatches
            .where((match) => match.endedAt == null)
            .toList();
      case MatchFilter.finished:
        filteredMatches = allMatches
            .where((match) => match.endedAt != null)
            .toList();
      case MatchFilter.team:
        filteredMatches = allMatches
            .where((match) => match.isTeamMatch)
            .toList();
    }
    displayedMatches = [...filteredMatches];
  }

  void applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedMatches = [...filteredMatches];
      } else {
        final List<({Match match, int score})> scoredMatches = [];

        for (final match in allMatches) {
          int maxScore = 0;

          // Check match name
          maxScore = max(maxScore, weightedRatio(match.name, query));

          // Check game name
          maxScore = max(maxScore, weightedRatio(match.game.name, query));

          // Check group name
          if (match.group != null) {
            maxScore = max(maxScore, weightedRatio(match.group!.name, query));
          }

          // Check player names
          for (final player in match.players) {
            maxScore = max(
              maxScore,
              weightedRatio('${player.name} #${player.nameCount}', query),
            );
          }

          // Check team names
          if (match.teams != null) {
            for (final team in match.teams!) {
              maxScore = max(maxScore, weightedRatio(team.name, query));
            }
          }

          if (maxScore >= FUZZY_SEARCH_THRESHOLD) {
            scoredMatches.add((match: match, score: maxScore));
          }
        }

        // Sort by score descending
        scoredMatches.sort((a, b) => b.score.compareTo(a.score));
        displayedMatches = scoredMatches.map((e) => e.match).toList();
      }
    });
  }

  void handleRatingDialog() {
    if (!mounted || !rateProvider.shouldShow) return;

    rateProvider.markAsShown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) triggerRatingDialog();
    });
  }

  /// Triggers the rate dialog if the user has not rated the app yet and the conditions are met.
  Future<void> triggerRatingDialog() async {
    // show only in prod or dev
    if (IS_TEST_ENV) return;
    if (!RATE_MY_APP.shouldOpenDialog) return;

    final loc = AppLocalizations.of(context);
    bool? didUserLikeApp;

    await Future.delayed(const Duration(milliseconds: 500), () async {
      didUserLikeApp = await showPreRateDialog(loc);
    });

    if (didUserLikeApp is bool && mounted) {
      didUserLikeApp!
          ? RATE_MY_APP.showStarRateDialog(context)
          : await Future.delayed(
              const Duration(milliseconds: 500),
              () => showBadRatingDialog(loc),
            );
    }
  }

  /// Shows a dialog to check for the users opinion on the app
  Future<bool?> showPreRateDialog(AppLocalizations loc) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        closeButtonColor: CustomTheme.hintColor,
        showCloseButton: true,
        title: loc.do_you_like_the_app,
        content: Text(loc.feedback_info_text, overflow: TextOverflow.visible),
        actions: [
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isEmphasized: true,
            text: loc.yes,
          ),
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            buttonType: ButtonType.primary,
            text: loc.no,
          ),
        ],
      ),
    );
  }

  /// Shows a dialog prompting the user to contact support via email if they are unsatisfied with the app.
  void showBadRatingDialog(AppLocalizations loc) {
    showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: loc.unsatisfied,
        content: Text(
          loc.contact_us_through_mail,
          overflow: TextOverflow.visible,
        ),
        actions: [
          CustomDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse('mailto:$LIQUID_CONTACT_EMAIL'));
            },
            text: loc.write_email,
          ),
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            buttonType: ButtonType.secondary,
            text: loc.cancel,
          ),
        ],
      ),
    );
  }

  void handleSearchToggle() {
    if (!mounted) return;

    setState(() {
      isSearchBarVisible = true;
      if (!searchProvider.isSearching) {
        searchBarController.clear();
      } else {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  /// Loads the matches from the database and sorts them by creation date.
  void loadMatches() {
    setState(() => isLoading = true);

    Future.wait([
      db.matchDao.getAllMatches(includeDeletedPlayer: true),
      Future.delayed(MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (!mounted) return;

      final loadedMatches = results[0] as List<Match>;
      setState(() {
        allMatches = [...loadedMatches]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filteredMatches = [...allMatches];

        searchBarController.text.isEmpty
            ? displayedMatches = [...allMatches]
            : applySearch(searchBarController.text);

        isLoading = false;
      });
    });
  }
}
