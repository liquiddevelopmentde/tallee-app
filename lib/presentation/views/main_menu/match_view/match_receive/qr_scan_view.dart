import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/match_import/associate_games_view.dart';
import 'package:tallee/services/match_share_service.dart';
import 'package:tallee/services/share_exceptions.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({super.key});

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: CustomTheme.standardBorderRadiusAll,
              border: Border.all(color: CustomTheme.boxBorderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                CustomTheme.standardBorderRadius - 3,
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scanAreaSize = constraints.maxWidth * 0.65;

                    return Stack(
                      children: [
                        MobileScanner(
                          tapToFocus: true,
                          controller: controller,
                          fit: BoxFit.cover,
                          onDetect: _isProcessing
                              ? null
                              : handleQrCodeDetection,
                        ),
                        // Scanner Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: QrScannerOverlayShape(
                                borderColor: CustomTheme.primaryColor,
                                borderRadius: 20,
                                borderLength: 40,
                                borderWidth: 6,
                                cutOutSize: scanAreaSize,
                              ),
                            ),
                          ),
                        ),
                        statusErrorOverlay(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: CustomTheme.onBoxColor,
              border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
              borderRadius: CustomTheme.standardBorderRadiusAll,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: const Text(
              'Scanne den QR-Code einer anderen Tallee-Instanz, um das Match zu empfangen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomTheme.textColor,
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleQrCodeDetection(BarcodeCapture result) async {
    final token = result.barcodes.first.rawValue;
    if (token == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    await Future.delayed(Constants.MINIMUM_SKELETON_DURATION);

    try {
      final loadedMatch = await MatchShareService().getMatchByToken(token);
      if (!mounted) return;

      await Navigator.of(context).push(
        adaptivePageRoute(
          builder: (_) => AssociateGamesView(match: loadedMatch),
        ),
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      String message = 'Ein unerwarteter Fehler ist aufgetreten.';

      if (error is NetworkException) {
        message = 'Netzwerkfehler. Bitte Internetverbindung prüfen.';
      } else if (error is ServerException) {
        message = (error.statusCode == 404 || error.statusCode == 410)
            ? 'Dieser QR-Code ist ungültig oder abgelaufen.'
            : 'Serverfehler (${error.statusCode}).';
      } else if (error is ParsingException) {
        message = 'Der gescannte Code enthält keine gültigen Match-Daten.';
      } else {
        message = 'Fehler beim Laden: ${error.toString()}';
      }

      setState(() => _errorMessage = message);

      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = null;
        });
      }
    }
  }

  Widget statusErrorOverlay() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _isProcessing ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: IgnorePointer(
          ignoring: !_isProcessing,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage == null) ...[
                    const CircularProgressIndicator(
                      color: CustomTheme.primaryColor,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Lade Match...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final left = rect.left + (rect.width - cutOutSize) / 2;
    final top = rect.top + (rect.height - cutOutSize) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cutOutSize, cutOutSize),
          Radius.circular(borderRadius),
        ),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(rect), cutoutPath),
      backgroundPaint,
    );

    final cornerPath = Path();
    cornerPath.moveTo(left, top + borderLength);
    cornerPath.lineTo(left, top + borderRadius);
    cornerPath.arcToPoint(
      Offset(left + borderRadius, top),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left + borderLength, top);

    cornerPath.moveTo(left + cutOutSize - borderLength, top);
    cornerPath.lineTo(left + cutOutSize - borderRadius, top);
    cornerPath.arcToPoint(
      Offset(left + cutOutSize, top + borderRadius),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left + cutOutSize, top + borderLength);

    cornerPath.moveTo(left + cutOutSize, top + cutOutSize - borderLength);
    cornerPath.lineTo(left + cutOutSize, top + cutOutSize - borderRadius);
    cornerPath.arcToPoint(
      Offset(left + cutOutSize - borderRadius, top + cutOutSize),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left + cutOutSize - borderLength, top + cutOutSize);

    cornerPath.moveTo(left + borderLength, top + cutOutSize);
    cornerPath.lineTo(left + borderRadius, top + cutOutSize);
    cornerPath.arcToPoint(
      Offset(left, top + cutOutSize - borderRadius),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left, top + cutOutSize - borderLength);

    canvas.drawPath(cornerPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
