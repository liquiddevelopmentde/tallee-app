import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/import_file_view.dart';
import 'package:tallee/presentation/views/main_menu/custom_navigation_bar.dart';
import 'package:tallee/state/data_refresh_provider.dart';
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
        ChangeNotifierProvider(create: (context) => DataRefreshProvider()),
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
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Channel used by the native side to hand over `.tallee` files that were
  /// opened from outside the app sandbox. The native code copies the file into
  /// the sandbox first (see ios/Runner/SceneDelegate.swift) and forwards the
  /// readable, copied path.
  static const MethodChannel _importChannel = MethodChannel(
    'de.liquid.tallee/import',
  );

  @override
  void initState() {
    super.initState();
    _importChannel.setMethodCallHandler(_handleImportMethodCall);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitialFile());
  }

  Future<dynamic> _handleImportMethodCall(MethodCall call) async {
    if (call.method == 'onFileOpened' && call.arguments is String) {
      _openImport(call.arguments as String);
    }
  }

  /// Fetches a file that launched the app from a cold start, if any.
  Future<void> _checkInitialFile() async {
    try {
      final path = await _importChannel.invokeMethod<String>('getInitialFile');
      if (path != null) _openImport(path);
    } on PlatformException {
      // No native handler available (e.g. non-iOS platforms); nothing to open.
    } on MissingPluginException {
      // Import channel not wired up on this platform.
    }
  }

  /// Pushes the import view for the `.tallee` file at [path].
  void _openImport(String path) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(
      adaptivePageRoute(
        settings: RouteSettings(name: path),
        fullscreenDialog: true,
        builder: (_) =>
            ImportFileView(filePath: path, messengerKey: scaffoldMessengerKey),
      ),
    );
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
      home: const CustomNavigationBar(),
    );
  }
}
