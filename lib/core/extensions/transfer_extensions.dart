import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

extension ImportResultExtension on ImportResult {
  /// Translates a [ImportResult] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case ImportResult.success:
        return loc.data_successfully_imported;
      case ImportResult.invalidSchema:
        return loc.invalid_schema;
      case ImportResult.invalidData:
        return loc.names_or_descriptions_too_long;
      case ImportResult.invalidExtension:
        return loc.invalid_extension;
      case ImportResult.fileReadError:
        return loc.error_reading_file;
      case ImportResult.fileNotFound:
        return loc.file_couldnt_be_accessed;
      case ImportResult.canceled:
        return loc.import_canceled;
      case ImportResult.formatException:
        return loc.format_exception;
      case ImportResult.unknownException:
        return loc.unknown_exception;
      case ImportResult.incompatibleVersion:
        return loc.incompatible_version;
    }
  }

  /// Translates a [ImportResult] enum value to its corresponding localized string.
  String toLocalizedMatchImportString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case ImportResult.success:
        return loc.data_successfully_imported;
      case ImportResult.invalidSchema:
        return '${loc.invalid_file} ${loc.update_app_version}';
      case ImportResult.invalidData:
        return '${loc.invalid_file} ${loc.choose_other_file}';
      case ImportResult.incompatibleVersion:
        return '${loc.incompatible_version} ${loc.choose_other_file}';
      case ImportResult.invalidExtension:
        return '${loc.invalid_extension}\n${loc.choose_other_file}';
      case ImportResult.unknownException:
      case ImportResult.fileNotFound:
      case ImportResult.fileReadError:
        return loc.error_while_processing_file_try_again;
      case ImportResult.canceled:
        return loc.import_canceled;
      case ImportResult.formatException:
        return loc.format_exception;
    }
  }

  bool get isSuccess => this == ImportResult.success;

  bool get isCanceled => this == ImportResult.canceled;
}

extension ExportResultExtension on ExportResult {
  /// Translates a [ExportResult] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case ExportResult.success:
        return loc.data_successfully_exported;
      case ExportResult.noData:
        return loc.no_data_to_export;
      case ExportResult.canceled:
        return loc.export_canceled;
      case ExportResult.unknownException:
        return loc.unknown_exception;
    }
  }
}
