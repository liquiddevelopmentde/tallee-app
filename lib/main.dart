import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_with_app/open_with_app.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/self_signed_cert_http_overrides.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/custom_navigation_bar.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/feedback_form_view.dart';
import 'package:tallee/presentation/views/preview_import_data_view.dart';
import 'package:tallee/presentation/views/splash_screen.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/services/local_share_service.dart';
import 'package:tallee/services/package_info_service.dart';
import 'package:tallee/services/shared_preferences_service.dart';
import 'package:tallee/state/data_refresh_provider.dart';
import 'package:tallee/state/game_search_provider.dart';
import 'package:tallee/state/group_search_provider.dart';
import 'package:tallee/state/match_search_provider.dart';

void main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) HttpOverrides.global = SelfSignedCertHttpOverrides();

  await dotenv.load();
  await SharedPreferencesService.init();
  await PackageInfoService.init();
  await SentryFlutter.init(
    (options) {
      // error reporting & feedback is disabled in debugMode
      options.dsn = kReleaseMode ? dotenv.get('SENTRY_DSN', fallback: '') : '';
      // Disable sending personal identfiable information
      options.sendDefaultPii = false;
      options.enableLogs = true;
      // Decrease sampleRate in stable to avoid sending too many events
      options.tracesSampleRate = 1.0;
      options.environment = kReleaseMode ? 'production' : 'development';

      // disabled because not supported by glitchtip
      options.enableAutoSessionTracking = false;

      options.beforeSend = (event, hint) {
        if (event.level == SentryLevel.error ||
            event.level == SentryLevel.fatal) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = Tallee.navigatorKey.currentContext;
            if (context != null) {
              final loc = AppLocalizations.of(context);
              Tallee.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
              Tallee.scaffoldMessengerKey.currentState?.showSnackBar(
                CustomSnackBar(
                  message: loc.unexpected_error,
                  actionLabel: loc.report_error,
                  onActionTap: () async {
                    Tallee.scaffoldMessengerKey.currentState
                        ?.hideCurrentSnackBar();
                    final result = await Tallee.navigatorKey.currentState
                        ?.push<bool>(
                          MaterialPageRoute(
                            builder: (context) => FeedbackFormView(
                              associatedEventId: event.eventId,
                            ),
                          ),
                        );
                    if (result == true) {
                      Tallee.scaffoldMessengerKey.currentState?.showSnackBar(
                        CustomSnackBar(message: loc.thank_you_for_report),
                      );
                    }
                  },
                ),
              );
            }
          });
        }
        return event;
      };
    },
    appRunner: () => runApp(
      SentryWidget(
        child: MultiProvider(
          providers: [
            Provider<AppDatabase>(
              create: (context) => AppDatabase(),
              dispose: (context, db) => db.close(),
            ),
            ChangeNotifierProvider(create: (context) => MatchSearchProvider()),
            ChangeNotifierProvider(create: (context) => GroupSearchProvider()),
            ChangeNotifierProvider(create: (context) => GameSearchProvider()),
            ChangeNotifierProvider(create: (context) => DataRefreshProvider()),
          ],
          child: DefaultAssetBundle(
            bundle: SentryAssetBundle(),
            child: const Tallee(),
          ),
        ),
      ),
    ),
  );
}

class Tallee extends StatefulWidget {
  const Tallee({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<Tallee> createState() => _TalleeState();
}

class _TalleeState extends State<Tallee> {
  /// Receives .tallee files opened via the system.
  final OpenWithApp openWithApp = OpenWithApp();
  StreamSubscription<String>? fileSubscription;
  String? pendingImportPath;

  @override
  void initState() {
    super.initState();
    // Warm start: a file opened while the app is already running.
    fileSubscription = openWithApp.getFileStream().listen(openImport);
    // Cold start: a file that launched the app.
    WidgetsBinding.instance.addPostFrameCallback((_) => checkInitialFile());
  }

  @override
  void dispose() {
    fileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Tallee.navigatorKey,
      scaffoldMessengerKey: Tallee.scaffoldMessengerKey,
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
      navigatorObservers: [SentryNavigatorObserver()],
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
      home: SplashScreen(onFinished: handleSplashFinished),
    );
  }

  void handleSplashFinished() {
    final navigator = Tallee.navigatorKey.currentState;
    if (navigator == null) return;

    final path = pendingImportPath;
    pendingImportPath = null;

    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CustomNavigationBar(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (path != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => openImport(path));
    }
  }

  /// Fetches a file that launched the app from a cold start, if any.
  Future<void> checkInitialFile() async {
    final path = await openWithApp.getInitialFile();
    if (path != null) {
      pendingImportPath = path;
    }
  }

  /// Pushes the import view for the .tallee file at [path].
  void openImport(String path) async {
    final navigator = Tallee.navigatorKey.currentState;
    if (navigator == null) return;

    final (_) = await LocalShareService.getDataFromPath(path);

    Future.delayed(OPEN_WITH_NAVIGATION_DELAY, () {
      navigator.push(
        adaptivePageRoute(
          settings: const RouteSettings(name: RouteNames.importFile),
          fullscreenDialog: true,
          builder: (_) => PreviewImportDataView(
            filePath: path,
            messengerKey: Tallee.scaffoldMessengerKey,
          ),
        ),
      );
    });
  }
}
