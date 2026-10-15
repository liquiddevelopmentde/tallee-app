import 'package:material_ui/material_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/countdown_painter.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';

class QrCodeComponent extends StatelessWidget {
  const QrCodeComponent({
    super.key,
    required this.qrImage,
    required this.isLoading,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.serverSharingEnabled,
    required this.onOnlineSharingPrefChanged,
    required this.renewToken,
  });

  final QrImage? qrImage;
  final bool isLoading;
  final int secondsRemaining;
  final int totalSeconds;
  final bool serverSharingEnabled;
  final VoidCallback onOnlineSharingPrefChanged;
  final VoidCallback renewToken;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final double progress = secondsRemaining / totalSeconds;
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;

    if (serverSharingEnabled) {
      return Column(
        spacing: 10,
        children: [
          // QR Code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: CustomPaint(
              foregroundPainter: CountdownPainter(
                progress: progress,
                color: secondsRemaining != 0
                    ? CustomTheme.primaryColor
                    : Colors.transparent,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity:
                              (isLoading ||
                                  qrImage == null ||
                                  secondsRemaining == 0)
                              ? 0.3
                              : 1.0,
                          child: PrettyQrView(
                            qrImage: qrImage ?? loadingStateQr(),
                            decoration: const PrettyQrDecoration(
                              shape: PrettyQrSquaresSymbol(),
                              background: Colors.white,
                            ),
                          ),
                        ),
                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: CustomTheme.primaryColor,
                              strokeWidth: 5,
                            ),
                          ),
                        if (secondsRemaining == 0)
                          Center(
                            child: HapticIconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: CustomTheme.primaryColor,
                                size: 70,
                              ),
                              onPressed: renewToken,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // TTL text
          Text(
            minutes == 0 && seconds == 0
                ? loc.qr_code_expired
                : loc.expires_in(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  ),
            style: const TextStyle(
              color: CustomTheme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              overflow: TextOverflow.visible,
            ),
            softWrap: true,
          ),

          // Explanation container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: CustomTheme.onBoxColor,
              border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
              borderRadius: CustomTheme.standardBorderRadiusAll,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              loc.scan_qr_code_instruction,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ],
      );
    }

    // Online sharing deactivated
    return Column(
      spacing: 10,
      children: [
        // QR Code
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              color: CustomTheme.boxBorderColor.withAlpha(100),
              border: Border.all(color: CustomTheme.boxBorderColor),
              borderRadius: CustomTheme.standardBorderRadiusAll,
            ),
            padding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.50,
                  child: PrettyQrView(
                    qrImage: qrImage ?? loadingStateQr(),
                    decoration: const PrettyQrDecoration(
                      shape: PrettyQrSquaresSymbol(
                        color: CustomTheme.boxBorderColor,
                      ),
                      background: Colors.transparent,
                    ),
                  ),
                ),

                // Icon + Message
                Column(
                  spacing: 20,
                  children: [
                    // Icon
                    const Icon(Icons.cloud_off, size: 50),

                    // Message
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Text(
                            loc.online_sharing_disabled,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          Text(
                            loc.share_as_qr_code_info,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.visible,
                              color: CustomTheme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Open settings button
        FloatingAnimatedButton(
          text: loc.open_settings,
          icon: Icons.settings,
          onPressed: () async {
            await Navigator.push(
              context,
              adaptivePageRoute(builder: (context) => const SettingsView()),
            );
            onOnlineSharingPrefChanged.call();
          },
        ),
      ],
    );
  }

  QrImage loadingStateQr() {
    final qrCode = QrCode.fromData(
      data: 'NOT_READY_YET',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    return QrImage(qrCode);
  }
}
