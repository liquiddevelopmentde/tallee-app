import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/import_file_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/licenses_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/privacy_policy_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/settings_list_tile.dart';
import 'package:tallee/services/data_transfer_service.dart';
import 'package:tallee/services/package_info_service.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Builder(
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
                  padding: const EdgeInsets.only(left: 16, top: 10),
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
                  onPressed: () => handleExport(scaffoldMessengerContext),
                ),
                SettingsListTile(
                  title: loc.import_data,
                  icon: Icons.download,
                  suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => handleImport(scaffoldMessengerContext),
                ),
                SettingsListTile(
                  title: loc.delete_all_data,
                  icon: Icons.delete,
                  suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () =>
                      showDeleteDialog(scaffoldMessengerContext, loc),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 10),
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
                                  launchUrl(Uri.parse('https://liquid-dev.de')),
                                },
                              ),
                              HapticIconButton(
                                icon: const FaIcon(FontAwesomeIcons.github),
                                onPressed: () => {
                                  HapticFeedback.lightImpact(),
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
                                onPressed: () => {
                                  HapticFeedback.lightImpact(),
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
                          'Version ${packageInfo.version} (${packageInfo.buildNumber})',
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
      case ImportResult.invalidSchema:
      case ImportResult.invalidData:
      case ImportResult.fileReadError:
      case ImportResult.fileNotFound:
      case ImportResult.canceled:
      case ImportResult.formatException:
      case ImportResult.unknownException:
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

  void handleExport(BuildContext scaffoldMessengerContext) async {
    final String json = await DataTransferService.getAppDataAsJson(
      scaffoldMessengerContext,
    );

    ExportResult result;

    if (json.isEmpty) {
      result = ExportResult.noData;
    } else {
      result = await DataTransferService.exportData(json, 'data');
    }
    if (!scaffoldMessengerContext.mounted) return;
    showExportSnackBar(context: scaffoldMessengerContext, result: result);
  }

  void handleImport(BuildContext scaffoldMessengerContext) async {
    final path = await DataTransferService.pickImportFilePath();

    if (path == null) {
      if (!scaffoldMessengerContext.mounted) return;
      showImportSnackBar(
        context: scaffoldMessengerContext,
        result: ImportResult.canceled,
      );
      return;
    }

    if (!scaffoldMessengerContext.mounted) return;
    final result = await Navigator.of(scaffoldMessengerContext)
        .push<ImportResult>(
          adaptivePageRoute<ImportResult>(
            fullscreenDialog: true,
            builder: (_) => ImportFileView(filePath: path),
          ),
        );

    if (result == null) return;
    if (!scaffoldMessengerContext.mounted) return;
    showImportSnackBar(context: scaffoldMessengerContext, result: result);
  }

  void showDeleteDialog(
    BuildContext scaffoldMessengerContext,
    AppLocalizations loc,
  ) {
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
      if (confirmed == true && mounted && scaffoldMessengerContext.mounted) {
        DataTransferService.deleteAllData(context);
        showSnackbar(
          context: scaffoldMessengerContext,
          message: AppLocalizations.of(context).data_successfully_deleted,
        );
      }
    });
  }
}
