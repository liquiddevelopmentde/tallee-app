import 'dart:core' hide Match;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/share_exceptions.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/preview_match_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/qr_scanner_overlay_shape.dart';
import 'package:tallee/services/remote_share_service.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScanComponent extends StatefulWidget {
  const QrScanComponent({super.key, this.tabController});

  final TabController? tabController;

  @override
  State<QrScanComponent> createState() => _QrScanComponentState();
}

class _QrScanComponentState extends State<QrScanComponent>
    with AutomaticKeepAliveClientMixin {
  static const _fadeDuration = Duration(milliseconds: 300);

  late final MobileScannerController _controller;
  late final AppLifecycleListener _lifecycleListener;

  bool _isProcessing = false;
  String? _errorMessage;
  bool _isStarting = false;
  bool _retryAfterSettings = false;

  @override
  bool get wantKeepAlive => true;

  bool get _isVisible =>
      widget.tabController == null || widget.tabController!.index == 0;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      autoStart: false,
    );

    _lifecycleListener = AppLifecycleListener(
      onResume: handleAppResume,
      onPause: _controller.stop,
    );

    if (_isVisible) {
      startScanner();
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppColors.standardBorderRadiusAll,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: AppColors.standardBorderRadiusAll,
                border: Border.all(
                  color: context.talleeColors.boxBorderColor,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppColors.standardBorderRadius - 3,
                ),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scanAreaSize = constraints.maxWidth * 0.65;

                      return ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, scanner) {
                          final errorCode = state.error?.errorCode;
                          final showError = errorCode != null;

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              const ColoredBox(color: Colors.black),
                              AnimatedOpacity(
                                opacity:
                                    errorCode == null && state.isInitialized
                                    ? 1.0
                                    : 0.0,
                                duration: _fadeDuration,
                                curve: Curves.easeInOut,
                                child: scanner,
                              ),
                              AnimatedOpacity(
                                opacity: showError ? 0.0 : 1.0,
                                duration: _fadeDuration,
                                curve: Curves.easeInOut,
                                child: Container(
                                  decoration: ShapeDecoration(
                                    shape: QrScannerOverlayShape(
                                      borderColor: AppColors.primaryColor,
                                      borderRadius: 20,
                                      borderWidth: 6,
                                      cutOutSize: scanAreaSize,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: _fadeDuration,
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                layoutBuilder: (child, previousChildren) =>
                                    Stack(
                                      fit: StackFit.expand,
                                      children: [...previousChildren, ?child],
                                    ),
                                child: showError
                                    ? _ScannerErrorView(
                                        key: const ValueKey('scannerError'),
                                        errorCode: errorCode,
                                        onOpenSettingsPressed:
                                            handleSettingsButtonPress,
                                      )
                                    : const SizedBox.expand(
                                        key: ValueKey('scannerRunning'),
                                      ),
                              ),
                              _StatusErrorOverlay(
                                isProcessing: _isProcessing,
                                errorMessage: _errorMessage,
                              ),
                            ],
                          );
                        },
                        child: MobileScanner(
                          tapToFocus: true,
                          controller: _controller,
                          onDetect: handleQrCodeDetection,
                          errorBuilder: (context, error) =>
                              const SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: context.talleeColors.onBoxColor,
              border: Border.all(
                color: context.talleeColors.boxBorderColor,
                width: 2,
              ),
              borderRadius: AppColors.standardBorderRadiusAll,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              loc.scan_qr_receive_instruction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.talleeColors.textColor,
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

  Future<void> startScanner() async {
    if (_isStarting || _controller.value.isRunning) return;
    _isStarting = true;
    try {
      if (!_controller.value.isRunning) {
        await _controller.start();
      }
    } on MobileScannerException {
      // The scanner widget renders the error through its errorBuilder.
    } finally {
      _isStarting = false;
    }
  }

  /// Restarts the scanner when the app returns to the foreground.
  Future<void> handleAppResume() async {
    if (!_isVisible) return;
    if (_controller.value.error != null && !_retryAfterSettings) return;

    _retryAfterSettings = false;
    await startScanner();
  }

  Future<void> handleSettingsButtonPress() async {
    _retryAfterSettings = true;

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse('app-settings:'));
      } else if (Platform.isAndroid) {
        const channel = MethodChannel('de.liquiddev.tallee/settings');
        await channel.invokeMethod<void>('openAppSettings');
      }
    } catch (_) {}
  }

  Future<void> handleQrCodeDetection(BarcodeCapture result) async {
    final barcodes = result.barcodes;
    if (barcodes.isEmpty || _isProcessing || !mounted) return;

    final token = barcodes.first.rawValue;
    if (token == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    await _controller.stop();

    await Future.delayed(MINIMUM_SKELETON_DURATION);

    try {
      final response = await RemoteShareService().getMatchByToken(token);

      // If an import error occured
      if (!response.result.isSuccess && mounted) {
        final message = response.result.toLocalizedMatchImportString(context);
        await displayErrorMessage(message);
      } else {
        final loadedMatch = response.match!;
        if (!mounted) return;

        await Navigator.of(context).push(
          adaptivePageRoute(
            settings: const RouteSettings(name: RouteNames.previewMatchView),
            builder: (_) => PreviewMatchView(match: loadedMatch),
            fullscreenDialog: true,
          ),
        );
      }

      if (mounted) {
        await startScanner();
        setState(() {
          _isProcessing = false;
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
            : loc.server_error;
      } else if (error is ParsingException) {
        message = loc.qr_code_parsing_error;
      } else {
        message = loc.error_loading_match(error.toString());
      }

      await displayErrorMessage(message);
    }
  }

  /// Displays the [message] for 4 seconds and then resets the state.
  Future<void> displayErrorMessage(String message) async {
    setState(() => _errorMessage = message);

    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      await startScanner();

      setState(() {
        _isProcessing = false;
        _errorMessage = null;
      });
    }
  }
}

class _ScannerErrorView extends StatelessWidget {
  final MobileScannerErrorCode errorCode;
  final VoidCallback onOpenSettingsPressed;

  const _ScannerErrorView({
    super.key,
    required this.errorCode,
    required this.onOpenSettingsPressed,
  });

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

class _StatusErrorOverlay extends StatelessWidget {
  final bool isProcessing;
  final String? errorMessage;

  const _StatusErrorOverlay({required this.isProcessing, this.errorMessage});

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
