import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/custom_navigation_bar.dart';

void main() {
  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      child: const GameTracker(),
      dispose: (context, db) => db.close(),
    ),
  );
}

class GameTracker extends StatelessWidget {
  const GameTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      themeMode: ThemeMode.dark, // forces dark mode
      theme: ThemeData(
        primaryColor: CustomTheme.primaryColor,
        scaffoldBackgroundColor: CustomTheme.backgroundColor,
        appBarTheme: CustomTheme.appBarTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomTheme.primaryColor,
          brightness: Brightness.dark,
        ).copyWith(surface: CustomTheme.backgroundColor),
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
