import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/preview_import_data_view.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/settings_list_tile.dart';
import 'package:tallee/services/local_share_service.dart';

class DataManagementView extends StatefulWidget {
  const DataManagementView({super.key});

  @override
  State<DataManagementView> createState() => _DataManagementViewState();
}

class _DataManagementViewState extends State<DataManagementView> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ScaffoldMessenger(
      child: Builder(
        builder: (scaffoldMessengerContext) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.data_backup)),
            backgroundColor: CustomTheme.backgroundColor,
            body: SingleChildScrollView(
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          textAlign: TextAlign.start,
                          loc.data_transfer,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          textAlign: TextAlign.start,
                          loc.data_transfer_description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CustomTheme.hintColor,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SettingsListTile(
                    title: loc.export_data,
                    icon: Icons.upload,
                    //description: loc.export_description,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () => handleExport(scaffoldMessengerContext),
                  ),
                  SettingsListTile(
                    title: loc.import_data,
                    icon: Icons.download,
                    //description: loc.import_description,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () => handleImport(scaffoldMessengerContext),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      textAlign: TextAlign.start,
                      loc.danger_zone,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SettingsListTile(
                    title: loc.delete_all_data,
                    icon: Icons.delete,
                    description: loc.delete_app_data_description,
                    suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () =>
                        showDeleteDialog(scaffoldMessengerContext, loc),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void handleExport(BuildContext scaffoldMessengerContext) async {
    final String json = await LocalShareService.getAppDataAsJson(
      scaffoldMessengerContext,
    );

    ExportResult result;

    if (json.isEmpty) {
      result = ExportResult.noData;
    } else {
      result = await LocalShareService.exportData(json, 'data');
    }
    if (!scaffoldMessengerContext.mounted) return;
    showExportSnackBar(context: scaffoldMessengerContext, result: result);
  }

  void handleImport(BuildContext scaffoldMessengerContext) async {
    final path = await LocalShareService.pickImportFilePath();

    if (path == null) {
      if (!scaffoldMessengerContext.mounted) return;
      showImportSnackBar(
        context: scaffoldMessengerContext,
        result: ImportResult.canceled,
      );
      return;
    }

    if (!scaffoldMessengerContext.mounted) return;

    // Pre-check the file type to avoid showing PreviewImportDataView for single matches
    final (_) = await LocalShareService.getDataFromPath(path);

    if (!scaffoldMessengerContext.mounted) return;
    final result = await Navigator.of(scaffoldMessengerContext)
        .push<ImportResult>(
          adaptivePageRoute<ImportResult>(
            settings: const RouteSettings(name: RouteNames.importFile),
            fullscreenDialog: true,
            builder: (_) => PreviewImportDataView(filePath: path),
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
          loc.delete_app_data_description,
          overflow: TextOverflow.visible,
        ),
        actions: [
          CustomDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructive: true,
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
        LocalShareService.deleteAllData(context);
        showSnackbar(
          context: scaffoldMessengerContext,
          message: AppLocalizations.of(context).data_successfully_deleted,
        );
      }
    });
  }

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

  void showSnackbar({required BuildContext context, required String message}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(message: message));
  }
}
