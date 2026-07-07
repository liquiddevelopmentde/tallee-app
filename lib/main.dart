import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/import_file_view.dart';
import 'package:tallee/presentation/views/main_menu/custom_navigation_bar.dart';
import 'package:tallee/state/group_search_provider.dart';
import 'package:tallee/state/match_search_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (context) => AppDatabase(),
          dispose: (context, db) => db.close(),
        ),
        ChangeNotifierProvider(create: (context) => MatchSearchProvider()),
        ChangeNotifierProvider(create: (context) => GroupSearchProvider()),
      ],
      child: const GameTracker(),
    ),
  );
}

class GameTracker extends StatefulWidget {
  const GameTracker({super.key});

  @override
  State<GameTracker> createState() => _GameTrackerState();
}

class _GameTrackerState extends State<GameTracker> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Handles routes pushed by the OS when the app is opened via a `.tallee`
  /// file. The route name contains the file path/URI to import.
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name != null && name.toLowerCase().endsWith('.tallee')) {
      return adaptivePageRoute(
        settings: settings,
        fullscreenDialog: true,
        builder: (_) =>
            ImportFileView(filePath: name, messengerKey: scaffoldMessengerKey),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      onGenerateRoute: onGenerateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.firstWhere(
          (locale) => locale.languageCode == 'en',
        );
      },
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).app_name,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        // main colors
        primaryColor: CustomTheme.primaryColor,
        scaffoldBackgroundColor: CustomTheme.backgroundColor,
        // themes
        appBarTheme: CustomTheme.appBarTheme,
        textTheme: CustomTheme.textTheme,
        actionIconTheme: CustomTheme.actionIconTheme,
        inputDecorationTheme: CustomTheme.inputDecorationTheme,
        searchBarTheme: CustomTheme.searchBarTheme,
        radioTheme: CustomTheme.radioTheme,
        // deactivate splash effects
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        // color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomTheme.textColor,
          brightness: Brightness.dark,
          primary: CustomTheme.primaryColor,
          onPrimary: CustomTheme.textColor,
          surface: CustomTheme.backgroundColor,
          onSurface: CustomTheme.textColor,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
      ),
      home: const CustomNavigationBar(),
    );
  }
}
