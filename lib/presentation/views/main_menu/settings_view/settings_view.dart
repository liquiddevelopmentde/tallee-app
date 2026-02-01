import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses_view.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';
import 'package:tallee/presentation/widgets/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/settings_list_tile.dart';
import 'package:tallee/services/data_transfer_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  /// The settings view of the application, allowing users to manage data
  /// and view legal information.
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'n.A.',
    packageName: 'n.A.',
    version: 'n.A.',
    buildNumber: 'n.A.',
  );
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ScaffoldMessenger(
      child: Builder(
        builder: (scaffoldMessengerContext) {
          return Scaffold(
            appBar: AppBar(backgroundColor: CustomTheme.backgroundColor),
            backgroundColor: CustomTheme.backgroundColor,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 10),
                    child: Text(
                      textAlign: TextAlign.start,
                      loc.settings,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      textAlign: TextAlign.start,
                      loc.data,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SettingsListTile(
                    title: loc.export_data,
                    icon: Icons.upload,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () async {
                      final String json =
                          await DataTransferService.getAppDataAsJson(
                            scaffoldMessengerContext,
                          );
                      final result = await DataTransferService.exportData(
                        json,
                        'tallee-data',
                      );
                      if (!scaffoldMessengerContext.mounted) return;
                      showExportSnackBar(
                        context: scaffoldMessengerContext,
                        result: result,
                      );
                    },
                  ),
                  SettingsListTile(
                    title: loc.import_data,
                    icon: Icons.download,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () async {
                      final result = await DataTransferService.importData(
                        scaffoldMessengerContext,
                      );
                      if (!scaffoldMessengerContext.mounted) return;
                      showImportSnackBar(
                        context: scaffoldMessengerContext,
                        result: result,
                      );
                    },
                  ),
                  SettingsListTile(
                    title: loc.delete_all_data,
                    icon: Icons.delete,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      showDialog<bool>(
                        context: context,
                        builder: (context) => CustomAlertDialog(
                          title: '${loc.delete_all_data}?',
                          content: loc.this_cannot_be_undone,
                          actions: [
                            AnimatedDialogButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                loc.cancel,
                                style: const TextStyle(
                                  color: CustomTheme.textColor,
                                ),
                              ),
                            ),
                            AnimatedDialogButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                loc.delete,
                                style: const TextStyle(
                                  color: CustomTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).then((confirmed) {
                        if (confirmed == true && context.mounted) {
                          DataTransferService.deleteAllData(context);
                          showSnackbar(
                            context: scaffoldMessengerContext,
                            message: AppLocalizations.of(
                              context,
                            ).data_successfully_deleted,
                          );
                        }
                      });
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
                        MaterialPageRoute(
                          builder: (context) => const LicensesView(),
                        ),
                      );
                    },
                  ),
                  SettingsListTile(
                    title: loc.legal_notice,
                    icon: Icons.account_balance_sharp,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: null,
                  ),
                  SettingsListTile(
                    title: loc.privacy_policy,
                    icon: Icons.gpp_good_rounded,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: null,
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
                              spacing: 40,
                              children: [
                                GestureDetector(
                                  child: const Icon(Icons.language),
                                  onTap: () => {
                                    launchUrl(
                                      Uri.parse('https://liquid-dev.de'),
                                    ),
                                  },
                                ),
                                GestureDetector(
                                  child: const FaIcon(FontAwesomeIcons.github),
                                  onTap: () => {
                                    launchUrl(
                                      Uri.parse(
                                        'https://github.com/liquiddevelopmentde',
                                      ),
                                    ),
                                  },
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Platform.isIOS
                                        ? CupertinoIcons.mail_solid
                                        : Icons.email,
                                  ),
                                  onTap: () => launchUrl(
                                    Uri.parse('mailto:hi@liquid-dev.de'),
                                  ),
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
                            'Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
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
  }) {
    final loc = AppLocalizations.of(context);
    switch (result) {
      case ImportResult.success:
        showSnackbar(context: context, message: loc.data_successfully_imported);
      case ImportResult.invalidSchema:
        showSnackbar(context: context, message: loc.invalid_schema);
      case ImportResult.fileReadError:
        showSnackbar(context: context, message: loc.error_reading_file);
      case ImportResult.canceled:
        showSnackbar(context: context, message: loc.import_canceled);
      case ImportResult.formatException:
        showSnackbar(context: context, message: loc.format_exception);
      case ImportResult.unknownException:
        showSnackbar(context: context, message: loc.unknown_exception);
    }
  }

  /// Displays a snackbar based on the export result.
  ///
  /// [context] The BuildContext to show the snackbar in.
  /// [result] The result of the export operation.
  void showExportSnackBar({
    required BuildContext context,
    required ExportResult result,
  }) {
    final loc = AppLocalizations.of(context);
    switch (result) {
      case ExportResult.success:
        showSnackbar(context: context, message: loc.data_successfully_exported);
      case ExportResult.canceled:
        showSnackbar(context: context, message: loc.export_canceled);
      case ExportResult.unknownException:
        showSnackbar(context: context, message: loc.unknown_exception);
    }
  }

  /// Displays a snackbar with the given message and optional action.
  ///
  /// [context] The BuildContext to show the snackbar in.
  /// [message] The message to display in the snackbar.
  /// [duration] The duration for which the snackbar is displayed.
  /// [action] An optional callback function to execute when the action button is pressed.
  void showSnackbar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
  }) {
    if (!context.mounted) return;

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: CustomTheme.onBoxColor,
        duration: duration,
        action: action != null
            ? SnackBarAction(label: loc.undo, onPressed: action)
            : null,
      ),
    );
  }

  /// Initializes the package information.
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
}
