import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/data_management_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/feedback_form_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/licenses_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/privacy_policy_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_adaptive_switch.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/tiles/settings_list_tile.dart';
import 'package:tallee/services/package_info_service.dart';
import 'package:tallee/services/shared_preferences_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  /// The settings view of the application, allowing users to manage data
  /// and view legal information.
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final PackageInfo packageInfo = PackageInfoService.info;

  bool isOnlineSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ScaffoldMessenger(
      child: Builder(
        builder: (scaffoldMessengerContext) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.settings)),
            backgroundColor: CustomTheme.backgroundColor,
            body: SingleChildScrollView(
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      textAlign: TextAlign.start,
                      loc.general,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SettingsListTile(
                    title: loc.send_feedback,
                    icon: Icons.chat_bubble_outline_rounded,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute<bool>(
                          fullscreenDialog: true,
                          builder: (context) => const FeedbackFormView(),
                        ),
                      );
                      if (result == true && scaffoldMessengerContext.mounted) {
                        showSnackbar(
                          context: scaffoldMessengerContext,
                          message: loc.thank_you_for_feedback,
                        );
                      }
                    },
                  ),
                  SettingsListTile(
                    title: loc.online_sharing_title,
                    icon: Icons.cloud,
                    description: loc.online_sharing_info_text,
                    suffixWidget: CustomAdaptiveSwitch(
                      value: isOnlineSharingEnabled,
                      onChanged: (value) async {
                        setState(() {
                          isOnlineSharingEnabled = value;
                        });
                        await SharedPreferencesService.setSharingConsent(value);
                      },
                    ),
                    onPressed: null,
                  ),
                  SettingsListTile(
                    title: loc.data_backup,
                    icon: Icons.storage_rounded,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      Navigator.of(context).push(
                        adaptivePageRoute(
                          settings: const RouteSettings(
                            name: RouteNames.dataManagementView,
                          ),
                          builder: (context) => const DataManagementView(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      textAlign: TextAlign.start,
                      loc.legal,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SettingsListTile(
                    title: loc.licenses,
                    icon: Icons.insert_drive_file,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      Navigator.of(context).push(
                        adaptivePageRoute(
                          settings: const RouteSettings(
                            name: RouteNames.licensesView,
                          ),
                          builder: (context) => const LicensesView(),
                        ),
                      );
                    },
                  ),
                  SettingsListTile(
                    title: loc.legal_notice,
                    icon: Icons.account_balance_sharp,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () async {
                      await launchUrl(
                        Uri.parse(Constants.LIQUID_WEBSITE_LEGAL_URL),
                      );
                    },
                  ),
                  SettingsListTile(
                    title: loc.privacy_policy,
                    icon: Icons.gpp_good_rounded,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyView(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Center(
                      child: Column(
                        spacing: 4,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                HapticIconButton(
                                  icon: const Icon(Icons.language),
                                  onPressed: () => {
                                    HapticFeedback.lightImpact(),
                                    launchUrl(
                                      Uri.parse(Constants.LIQUID_WEBSITE_URL),
                                    ),
                                  },
                                ),
                                HapticIconButton(
                                  icon: const FaIcon(FontAwesomeIcons.github),
                                  onPressed: () => {
                                    HapticFeedback.lightImpact(),
                                    launchUrl(
                                      Uri.parse(Constants.LIQUID_GITHUB_URL),
                                    ),
                                  },
                                ),
                                HapticIconButton(
                                  icon: Icon(
                                    Platform.isIOS
                                        ? CupertinoIcons.mail_solid
                                        : Icons.email,
                                  ),
                                  onPressed: () => {
                                    HapticFeedback.lightImpact(),
                                    launchUrl(
                                      Uri.parse(
                                        'mailto:${Constants.LIQUID_CONTACT_EMAIL}',
                                      ),
                                    ),
                                  },
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '© ${DateFormat('yyyy').format(DateTime.now())} Liquid Development',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${loc.version} ${packageInfo.version} (${packageInfo.buildNumber})',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Displays a snackbar based on the import result.
  ///
  /// [context] The BuildContext to show the snackbar in.
  /// [result] The result of the import operation.
  void showImportSnackBar({
    required BuildContext context,
    required ImportResult result,
  }) async {
    final loc = AppLocalizations.of(context);
    switch (result) {
      case ImportResult.success:
        HapticFeedback.successNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: loc.data_successfully_imported,
          );
        }
      default:
        HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: translateImportResultToString(result, context),
          );
        }
    }
  }

  /// Displays a snackbar based on the export result.
  ///
  /// [context] The BuildContext to show the snackbar in.
  /// [result] The result of the export operation.
  void showExportSnackBar({
    required BuildContext context,
    required ExportResult result,
  }) async {
    final loc = AppLocalizations.of(context);
    switch (result) {
      case ExportResult.success:
        HapticFeedback.successNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: loc.data_successfully_exported,
          );
        }
      case ExportResult.canceled:
      case ExportResult.unknownException:
      case ExportResult.noData:
        HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: translateExportResultToString(result, context),
          );
        }
    }
  }

  /// Displays a snackbar with the given message and optional action.
  ///
  /// [context] The BuildContext to show the snackbar in.
  /// [message] The message to display in the snackbar.
  void showSnackbar({required BuildContext context, required String message}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(message: message));
  }

  Future<void> loadSettings() async {
    final onlineSharing = SharedPreferencesService.getStoredSharingConsent();
    setState(() {
      isOnlineSharingEnabled = onlineSharing ?? false;
    });
  }
}
