import 'package:flutter/foundation.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:tallee/core/enums.dart';

/// The current environment.
// ignore: non_constant_identifier_names
AppEnvironment ENVIRONMENT = kDebugMode
    ? AppEnvironment.development
    : AppEnvironment.testing;

// ignore: non_constant_identifier_names
bool get IS_PROD_ENV => ENVIRONMENT == AppEnvironment.production;
// ignore: non_constant_identifier_names
bool get IS_DEV_ENV => ENVIRONMENT == AppEnvironment.development;
// ignore: non_constant_identifier_names
bool get IS_TEST_ENV => ENVIRONMENT == AppEnvironment.testing;

// Config for rate my app package.
// ignore: non_constant_identifier_names
final RateMyApp RATE_MY_APP = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 28,
  minLaunches: 20,
  remindDays: 28,
  remindLaunches: 10,
  googlePlayIdentifier: '',
  appStoreIdentifier: '',
);
