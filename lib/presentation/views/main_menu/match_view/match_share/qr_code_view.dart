import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/custom_theme.dart';

class QrCodeView extends StatelessWidget {
  const QrCodeView({
    super.key,
    required this.qrImage,
    required this.isLoading,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final QrImage qrImage;
  final bool isLoading;
  final int secondsRemaining;
  final int totalSeconds;

  QrImage loadingStateQr() {
    final qrCode = QrCode.fromData(
      data: 'NOT_READY_YET',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    return QrImage(qrCode);
  }

  @override
  Widget build(BuildContext context) {
    final double progress = secondsRemaining / totalSeconds;
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                      Visibility(
                        visible: !isLoading,
                        replacement: Opacity(
                          opacity: 0.3,
                          child: PrettyQrView(
                            qrImage: loadingStateQr(),
                            decoration: const PrettyQrDecoration(
                              shape: PrettyQrSquaresSymbol(),
                              background: Colors.white,
                            ),
                          ),
                        ),
                        child: PrettyQrView(
                          qrImage: qrImage,
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
              ? 'QR Code expired'
              : 'Expires in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: CustomTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: const Text(
            'Scan the QR Code with another Tallee instance to share the match.',
            style: TextStyle(
              color: CustomTheme.textColor,
              fontSize: 14,
              overflow: TextOverflow.visible,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
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
