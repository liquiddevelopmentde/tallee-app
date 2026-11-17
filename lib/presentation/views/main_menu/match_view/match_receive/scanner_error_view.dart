import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class ScannerErrorView extends StatelessWidget {
  const ScannerErrorView({
    required this.errorCode,
    required this.onOpenSettingsPressed,
    super.key,
  });

  final MobileScannerErrorCode errorCode;
  final VoidCallback onOpenSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final message = switch (errorCode) {
      MobileScannerErrorCode.permissionDenied => loc.camera_permission_denied,
      MobileScannerErrorCode.unsupported => loc.camera_unsupported,
      _ => loc.camera_error,
    };

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: context.talleeColors.errorColor,
                size: 40,
              ),
              const SizedBox(height: 15),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  overflow: TextOverflow.visible,
                ),
                softWrap: true,
              ),
              if (errorCode == MobileScannerErrorCode.permissionDenied) ...[
                const SizedBox(height: 20),
                FloatingAnimatedButton(
                  text: loc.open_settings,
                  icon: Icons.settings,
                  compact: true,
                  onPressed: onOpenSettingsPressed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
