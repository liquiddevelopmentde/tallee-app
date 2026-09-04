import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/share_exceptions.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/qr_code_component.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/save_file_component.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/token_component.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/services/remote_share_service.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class MatchShareView extends StatefulWidget {
  const MatchShareView({super.key, required this.match});

  final Match match;

  @override
  State<MatchShareView> createState() => _MatchShareViewState();
}

class _MatchShareViewState extends State<MatchShareView>
    with SingleTickerProviderStateMixin {
  @protected
  QrImage? qrImage;

  bool isLoading = true;

  // this gets set to false before any data is sent
  // defaults to true, to already show the qr code behind the ConsentDialog
  bool serverSharingEnabled = true;

  Timer? timer;

  int secondsRemaining = 600; // 10 Minutes

  static const int totalSeconds = 600;

  String? shareToken;

  late final TabController tabController;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSharingView();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(loc.match_share), centerTitle: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: CustomTheme.onBoxColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: CustomTheme.boxBorderColor,
                    width: 2,
                  ),
                ),
                child: TabBar(
                  controller: tabController,
                  splashFactory: NoSplash.splashFactory,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  enableFeedback: false,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: CustomTheme.primaryColor,
                  ),
                  labelColor: Colors.black,
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  unselectedLabelColor: CustomTheme.textColor,
                  onTap: (_) {
                    HapticFeedback.selectionClick();
                  },
                  tabs: const [
                    Tab(icon: Icon(Icons.qr_code)),
                    Tab(icon: Icon(Icons.pin)),
                    Tab(icon: Icon(Icons.file_present)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    QrCodeComponent(
                      qrImage: qrImage,
                      isLoading: isLoading,
                      secondsRemaining: secondsRemaining,
                      totalSeconds: totalSeconds,
                      serverSharingEnabled: serverSharingEnabled,
                      onOnlineSharingPrefChanged: () {
                        initSharingView();
                      },
                      renewToken: renewToken,
                    ),
                    TokenComponent(
                      secondsRemaining: secondsRemaining,
                      totalSeconds: totalSeconds,
                      shareToken: shareToken,
                      isLoading: isLoading,
                      serverSharingEnabled: serverSharingEnabled,
                      onOnlineSharingPrefChanged: () {
                        initSharingView();
                      },
                      renewToken: renewToken,
                    ),
                    SaveFileComponent(match: widget.match),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initSharingView([bool? initialSharingConsent]) async {
    isLoading = true;
    late bool? hasStoredSharingConsent;

    if (initialSharingConsent == null) {
      hasStoredSharingConsent =
          SharedPreferencesService.getStoredSharingConsent();
      if (hasStoredSharingConsent == null) {
        bool? userDecision = await showConsentDialog();
        if (userDecision != null) {
          await SharedPreferencesService.setSharingConsent(userDecision);
          hasStoredSharingConsent = userDecision;
        } else {
          // if the user closed popup without selecting an option, set decision
          // temporarily to false and ask again next time
          hasStoredSharingConsent = false;
        }
      }
    } else {
      hasStoredSharingConsent = initialSharingConsent;
    }

    setState(() {
      hasStoredSharingConsent!
          ? serverSharingEnabled = true
          : serverSharingEnabled = false;
    });

    if (serverSharingEnabled) {
      tabController.animateTo(0);
    } else {
      tabController.animateTo(2);
    }

    if (hasStoredSharingConsent) {
      Future.wait([
            RemoteShareService().getShareToken(widget.match),
            Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
          ])
          .then((results) {
            if (mounted) {
              setState(() {
                final loadedShareToken = results[0] as String?;
                shareToken = loadedShareToken;
                final qrCode = QrCode.fromData(
                  data: shareToken!,
                  errorCorrectLevel: QrErrorCorrectLevel.H,
                );
                qrImage = QrImage(qrCode);
                startTimer();
                isLoading = false;
              });
            }
          })
          .catchError((error, stacktrace) {
            if (!mounted) {
              return;
            }

            final loc = AppLocalizations.of(context);
            String errorMessage;

            if (error is NetworkException) {
              errorMessage = loc.network_error;
            } else if (error is ServerException) {
              errorMessage = loc.server_error(error.statusCode);
            } else if (error is ParsingException) {
              errorMessage = loc.parsing_error;
            } else {
              errorMessage = loc.unexpected_error;
            }
            scaffoldMessengerKey.currentState?.showSnackBar(
              CustomSnackBar(
                message: errorMessage,
                actionIcon: Icons.refresh,
                onActionTap: () {
                  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  initSharingView(hasStoredSharingConsent);
                },
              ),
            );
          });
    }
  }

  Future<bool?> showConsentDialog() {
    final loc = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: loc.online_sharing_title,
        content: Text(
          loc.online_sharing_consent_text,
          overflow: TextOverflow.visible,
        ),
        actions: [
          CustomDialogAction(
            text: loc.enable,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CustomDialogAction(
            text: loc.disable,
            buttonType: ButtonType.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (secondsRemaining > 0) {
            secondsRemaining--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void renewToken() async {
    setState(() {
      isLoading = true;
      secondsRemaining = totalSeconds;
    });

    try {
      final newToken = await RemoteShareService().getShareToken(widget.match);
      if (mounted) {
        setState(() {
          shareToken = newToken;
          final qrCode = QrCode.fromData(
            data: shareToken!,
            errorCorrectLevel: QrErrorCorrectLevel.H,
          );
          qrImage = QrImage(qrCode);
          isLoading = false;
          timer?.cancel();
          startTimer();
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      final loc = AppLocalizations.of(context);
      String errorMessage;

      if (error is NetworkException) {
        errorMessage = loc.network_error;
      } else if (error is ServerException) {
        errorMessage = loc.server_error(error.statusCode);
      } else if (error is ParsingException) {
        errorMessage = loc.parsing_error;
      } else {
        errorMessage = loc.unexpected_error;
      }
      scaffoldMessengerKey.currentState?.showSnackBar(
        CustomSnackBar(
          message: errorMessage,
          actionIcon: Icons.refresh,
          onActionTap: () {
            scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            renewToken();
          },
        ),
      );
    }
  }
}
