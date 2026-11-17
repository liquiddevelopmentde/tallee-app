import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class StatusErrorOverlay extends StatelessWidget {
  const StatusErrorOverlay({
    required this.isProcessing,
    this.errorMessage,
    super.key,
  });

  final bool isProcessing;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: isProcessing ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: IgnorePointer(
          ignoring: !isProcessing,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null) ...[
                    Icon(
                      Icons.error_outline,
                      color: context.talleeColors.errorColor,
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        overflow: TextOverflow.visible,
                      ),
                      softWrap: true,
                    ),
                  ] else if (isProcessing) ...[
                    const CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      loc.loading_match,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
