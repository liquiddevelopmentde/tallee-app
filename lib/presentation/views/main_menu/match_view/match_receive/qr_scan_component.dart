import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/share_exceptions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_games_view.dart';
import 'package:tallee/presentation/widgets/qr_scanner_overlay_shape.dart';
import 'package:tallee/services/remote_share_service.dart';

class QrScanComponent extends StatefulWidget {
  const QrScanComponent({super.key});

  @override
  State<QrScanComponent> createState() => _QrScanComponentState();
}

class _QrScanComponentState extends State<QrScanComponent> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  bool isProcessing = false;
  String? errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                          onDetect: isProcessing ? null : handleQrCodeDetection,
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
                        StatusErrorOverlay(
                          isProcessing: isProcessing,
                          errorMessage: errorMessage,
                        ),
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
            child: Text(
              loc.scan_qr_receive_instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleQrCodeDetection(BarcodeCapture result) async {
    final token = result.barcodes.first.rawValue;
    if (token == null || isProcessing) return;

    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    await Future.delayed(Constants.MINIMUM_SKELETON_DURATION);

    try {
      final loadedMatch = await RemoteShareService().getMatchByToken(token);
      if (!mounted) return;

      await Navigator.of(context).push(
        adaptivePageRoute(
          builder: (_) => AssociateGamesView(match: loadedMatch),
        ),
      );

      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      final loc = AppLocalizations.of(context);
      String message = loc.unexpected_error;

      if (error is NetworkException) {
        message = loc.network_error;
      } else if (error is ServerException) {
        message = (error.statusCode == 404 || error.statusCode == 410)
            ? loc.invalid_qr_code
            : loc.server_error(error.statusCode);
      } else if (error is ParsingException) {
        message = loc.qr_code_parsing_error;
      } else {
        message = loc.error_loading_match(error.toString());
      }
      setState(() => errorMessage = message);

      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        setState(() {
          isProcessing = false;
          errorMessage = null;
        });
      }
    }
  }
}

class StatusErrorOverlay extends StatelessWidget {
  final bool isProcessing;
  final String? errorMessage;

  const StatusErrorOverlay({
    super.key,
    required this.isProcessing,
    this.errorMessage,
  });

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
                  if (errorMessage == null) ...[
                    const CircularProgressIndicator(
                      color: CustomTheme.primaryColor,
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
                  ] else ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
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
