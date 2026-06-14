import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/licenses_view.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dialog/custom_dialog_action.dart';
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
                          content: Text(
                            loc.this_cannot_be_undone,
                            overflow: TextOverflow.visible,
                          ),
                          actions: [
                            CustomDialogAction(
                              onPressed: () => Navigator.of(context).pop(true),
                              text: loc.delete,
                            ),
                            CustomDialogAction(
                              onPressed: () => Navigator.of(context).pop(false),
                              buttonType: ButtonType.secondary,
                              text: loc.cancel,
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
                              spacing: 10,
                              children: [
                                HapticIconButton(
                                  icon: const Icon(Icons.language),
                                  onPressed: () async => {
                                    await HapticFeedback.lightImpact(),
                                    launchUrl(
                                      Uri.parse('https://liquid-dev.de'),
                                    ),
                                  },
                                ),
                                HapticIconButton(
                                  icon: const FaIcon(FontAwesomeIcons.github),
                                  onPressed: () async => {
                                    await HapticFeedback.lightImpact(),
                                    launchUrl(
                                      Uri.parse(
                                        'https://github.com/liquiddevelopmentde',
                                      ),
                                    ),
                                  },
                                ),
                                HapticIconButton(
                                  icon: Icon(
                                    Platform.isIOS
                                        ? CupertinoIcons.mail_solid
                                        : Icons.email,
                                  ),
                                  onPressed: () async => {
                                    await HapticFeedback.lightImpact(),
                                    launchUrl(
                                      Uri.parse('mailto:hi@liquid-dev.de'),
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
  }) async {
    final loc = AppLocalizations.of(context);
    switch (result) {
      case ImportResult.success:
        await HapticFeedback.successNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: loc.data_successfully_imported,
          );
        }
      case ImportResult.invalidSchema:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.invalid_schema);
        }
      case ImportResult.invalidData:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: loc.names_or_descriptions_too_long,
          );
        }
      case ImportResult.fileReadError:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.error_reading_file);
        }
      case ImportResult.canceled:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.import_canceled);
        }
      case ImportResult.formatException:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.format_exception);
        }
      case ImportResult.unknownException:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.unknown_exception);
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
        await HapticFeedback.successNotification();
        if (context.mounted) {
          showSnackbar(
            context: context,
            message: loc.data_successfully_exported,
          );
        }
      case ExportResult.canceled:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.export_canceled);
        }
      case ExportResult.unknownException:
        await HapticFeedback.errorNotification();
        if (context.mounted) {
          showSnackbar(context: context, message: loc.unknown_exception);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CustomSnackBar(message: message));
  }

  /// Initializes the package information.
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
}
