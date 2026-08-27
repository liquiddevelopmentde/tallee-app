import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class QrCodeComponent extends StatelessWidget {
  const QrCodeComponent({
    super.key,
    required this.qrImage,
    required this.isLoading,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.serverSharingEnabled,
    required this.onOnlineSharingPrefChanged,
  });

  final QrImage? qrImage;
  final bool isLoading;
  final int secondsRemaining;
  final int totalSeconds;
  final bool serverSharingEnabled;
  final VoidCallback onOnlineSharingPrefChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final double progress = secondsRemaining / totalSeconds;
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;

    return !serverSharingEnabled
        ? Column(
            children: [
              TopCenteredMessage(
                title: loc.online_sharing_disabled,
                message: loc.go_to_settings_to_enable,
                icon: Icons.close,
              ),
              const SizedBox(height: 20),
              FloatingAnimatedButton(
                text: loc.open_settings,
                icon: Icons.settings,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    adaptivePageRoute(
                      builder: (context) => const SettingsView(),
                    ),
                  );
                  onOnlineSharingPrefChanged.call();
                },
              ),
            ],
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: CustomPaint(
                  foregroundPainter: CountdownPainter(
                    progress: progress,
                    color: CustomTheme.primaryColor,
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
                              opacity: (isLoading || qrImage == null)
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CustomTheme.onBoxColor,
                  border: Border.all(
                    color: CustomTheme.boxBorderColor,
                    width: 2,
                  ),
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

  QrImage loadingStateQr() {
    final qrCode = QrCode.fromData(
      data: 'NOT_READY_YET',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    return QrImage(qrCode);
  }
}

class CountdownPainter extends CustomPainter {
  final double progress;
  final Color color;

  CountdownPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round;

    final path = ui.Path();

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    const double radius = CustomTheme.standardBorderRadius - 2;

    path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(radius)));

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final extractPath = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(CountdownPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
