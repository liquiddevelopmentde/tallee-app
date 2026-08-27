import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_with_app/open_with_app.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/local_dev_http_overrides.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/preview_import_data.dart';
import 'package:tallee/presentation/views/splash_screen.dart';
import 'package:tallee/services/shared_preferences_service.dart';
import 'package:tallee/state/data_refresh_provider.dart';
import 'package:tallee/state/group_search_provider.dart';
import 'package:tallee/state/match_search_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) HttpOverrides.global = LocalDevHttpOverrides();

  await dotenv.load();
  await SharedPreferencesService.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (context) => AppDatabase(),
          dispose: (context, db) => db.close(),
        ),
        ChangeNotifierProvider(create: (context) => MatchSearchProvider()),
        ChangeNotifierProvider(create: (context) => GroupSearchProvider()),
        ChangeNotifierProvider(create: (context) => DataRefreshProvider()),
      ],
      child: const Tallee(),
    ),
  );
}

class Tallee extends StatefulWidget {
  const Tallee({super.key});

  @override
  State<Tallee> createState() => _TalleeState();
}

class _TalleeState extends State<Tallee> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Receives .tallee files opened via the system.
  final OpenWithApp openWithApp = OpenWithApp();
  StreamSubscription<String>? fileSubscription;

  @override
  void initState() {
    super.initState();
    // Warm start: a file opened while the app is already running.
    fileSubscription = openWithApp.getFileStream().listen(openImport);
    // Cold start: a file that launched the app.
    WidgetsBinding.instance.addPostFrameCallback((_) => checkInitialFile());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
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
      home: const SplashScreen(),
    );
  }

  /// Fetches a file that launched the app from a cold start, if any.
  Future<void> checkInitialFile() async {
    final path = await openWithApp.getInitialFile();
    if (path != null) openImport(path);
  }

  /// Pushes the import view for the .tallee file at [path].
  void openImport(String path) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(
      adaptivePageRoute(
        settings: RouteSettings(name: path),
        fullscreenDialog: true,
        builder: (_) => PreviewImportDataView(
          filePath: path,
          messengerKey: scaffoldMessengerKey,
        ),
      ),
    );
  }

  @override
  void dispose() {
    fileSubscription?.cancel();
    super.dispose();
  }
}
