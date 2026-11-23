import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/data/models/models.dart';

class SharedPreferencesService {
  static SharedPreferences? _prefs;

  /// Loads and caches the [SharedPreferences] instance.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPreferencesService.init() must be called before use.',
      );
    }
    return prefs;
  }

  static const String filteredGroupsKey = 'filtered_groups';
  static const String filteredGamesKey = 'filtered_games';
  static const String filteredTimeframesKey = 'filtered_timeframes';
  static const String filteredStatisticTypesKey = 'filtered_statistic_types';
  static const String showFavouritesKey = 'show_favourites';
  static const String sharingConsentKey = 'share_consent';
  static const String showcaseTourSkippedKey = 'showcase_tour_skipped';
  static const String showcaseTourCompletedKey = 'showcase_tour_completed';
  static const String showcaseSeenKey = 'showcase_seen';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String matchFilterKey = 'match_filter';
  static const String themeModeKey = 'theme_mode';

  static void deleteAllPreferences() {
    _instance.remove(filteredGroupsKey);
    _instance.remove(filteredGamesKey);
    _instance.remove(filteredTimeframesKey);
    _instance.remove(filteredStatisticTypesKey);
    _instance.remove(showFavouritesKey);
    _instance.remove(sharingConsentKey);
    _instance.remove(matchFilterKey);
  }

  static void resetStatisticFilter({required bool includeFavourites}) {
    filteredGroupIds = [];
    filteredGameIds = [];
    filteredTimeframes = [];
    filteredStatisticTypes = [];
    if (includeFavourites) showFavourites = false;
  }

  static void deleteAllFilters({required bool includeFavourites}) {
    final SharedPreferences prefs = _instance;
    prefs.remove(filteredGroupsKey);
    prefs.remove(filteredGamesKey);
    prefs.remove(filteredTimeframesKey);
    prefs.remove(filteredStatisticTypesKey);
    if (includeFavourites) {
      prefs.remove(showFavouritesKey);
    }
  }

  // ==================== Match filter ====================

  /// The last selected match filter, `null` if none was stored yet.
  static MatchFilter? get matchFilter {
    final filterString = _instance.getString(matchFilterKey);
    return MatchFilter.values.firstWhereOrNull(
      (filter) => filter.toString() == filterString,
    );
  }

  /// Setting `null` removes the stored filter.
  static set matchFilter(MatchFilter? filter) {
    if (filter == null) {
      _instance.remove(matchFilterKey);
    } else {
      _instance.setString(matchFilterKey, filter.toString());
    }
  }

  // ==================== Theme ====================

  static ThemeMode get themeMode {
    final storedMode = _instance.getString(themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == storedMode,
      orElse: () => ThemeMode.system,
    );
  }

  static set themeMode(ThemeMode mode) =>
      _instance.setString(themeModeKey, mode.name);

  // ==================== Sharing consent ====================

  /// `null` when the user wasn't asked yet.
  static bool? get sharingConsent => _instance.getBool(sharingConsentKey);

  /// Setting `null` removes the stored decision, so the user is asked again.
  static set sharingConsent(bool? hasSharingConsent) {
    if (hasSharingConsent == null) {
      _instance.remove(sharingConsentKey);
    } else {
      _instance.setBool(sharingConsentKey, hasSharingConsent);
    }
  }

  // ==================== Statistic filters ====================

  static bool get showFavourites =>
      _instance.getBool(showFavouritesKey) ?? false;

  static set showFavourites(bool showFavourites) =>
      _instance.setBool(showFavouritesKey, showFavourites);

  static List<String> get filteredGroupIds =>
      _instance.getStringList(filteredGroupsKey) ?? [];

  static set filteredGroupIds(List<String> groupIds) =>
      _instance.setStringList(filteredGroupsKey, groupIds);

  static List<String> get filteredGameIds =>
      _instance.getStringList(filteredGamesKey) ?? [];

  static set filteredGameIds(List<String> gameIds) =>
      _instance.setStringList(filteredGamesKey, gameIds);

  static List<Timeframe> get filteredTimeframes {
    final List<String> timeframeStringList =
        _instance.getStringList(filteredTimeframesKey) ?? [];
    return timeframeStringList
        .map(
          (timeframeString) => Timeframe.values.firstWhere(
            (timeframe) => timeframe.toString() == timeframeString,
            orElse: () => Timeframe.allTime,
          ),
        )
        .toList();
  }

  static set filteredTimeframes(List<Timeframe> timeframes) =>
      _instance.setStringList(
        filteredTimeframesKey,
        timeframes.map((timeframe) => timeframe.toString()).toList(),
      );

  static List<StatisticType> get filteredStatisticTypes {
    final List<String> typeStringList =
        _instance.getStringList(filteredStatisticTypesKey) ?? [];
    return typeStringList
        .map(
          (typeString) => StatisticType.values.firstWhere(
            (type) => type.toString() == typeString,
            orElse: () => StatisticType.totalMatches,
          ),
        )
        .toList();
  }

  static set filteredStatisticTypes(List<StatisticType> types) =>
      _instance.setStringList(
        filteredStatisticTypesKey,
        types.map((type) => type.toString()).toList(),
      );

  // ==================== Onboarding & showcase ====================

  static bool get onboardingCompleted =>
      _instance.getBool(onboardingCompletedKey) ?? false;

  static set onboardingCompleted(bool completed) =>
      _instance.setBool(onboardingCompletedKey, completed);

  static bool get tourSkipped =>
      _instance.getBool(showcaseTourSkippedKey) ?? false;

  static set tourSkipped(bool skipped) =>
      _instance.setBool(showcaseTourSkippedKey, skipped);

  static bool get tourCompleted =>
      _instance.getBool(showcaseTourCompletedKey) ?? false;

  static set tourCompleted(bool completed) =>
      _instance.setBool(showcaseTourCompletedKey, completed);

  static List<String> get showcaseSeen =>
      _instance.getStringList(showcaseSeenKey) ?? [];

  /// Adds [screenKeys] to the already seen showcases (does not replace them).
  static void markShowcaseSeen(List<String> screenKeys) {
    final updatedKeys = {...showcaseSeen, ...screenKeys}.toList();
    _instance.setStringList(showcaseSeenKey, updatedKeys);
  }

  static bool hasSeenShowcase(String screenKey) =>
      showcaseSeen.contains(screenKey);

  static void resetSeenShowcase() =>
      _instance.setStringList(showcaseSeenKey, []);
}
