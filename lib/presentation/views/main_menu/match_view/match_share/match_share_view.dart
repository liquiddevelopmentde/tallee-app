import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class MatchShareView extends StatefulWidget {
  const MatchShareView({super.key, required this.match});

  /// The match to share
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

  Timer? _timer;

  int _secondsRemaining = 600; // 10 Minuten

  static const int _totalSeconds = 600;

  String? shareToken;

  late final TabController _tabController;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSharingView();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
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
                  controller: _tabController,
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  QrCodeComponent(
                    qrImage: qrImage,
                    isLoading: isLoading,
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    serverSharingEnabled: serverSharingEnabled,
                    onOnlineSharingPrefChanged: () {
                      initSharingView();
                    },
                  ),
                  TokenComponent(
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    shareToken: shareToken,
                    isLoading: isLoading,
                    serverSharingEnabled: serverSharingEnabled,
                    onOnlineSharingPrefChanged: () {
                      initSharingView();
                    },
                  ),
                  SaveFileComponent(match: widget.match),
                ],
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
      hasStoredSharingConsent = await getStoredSharingConsent();
      if (hasStoredSharingConsent == null) {
        bool? userDecision = await showConsentDialog();
        if (userDecision != null) {
          await saveStoredSharingConsent(userDecision);
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
      _tabController.animateTo(0);
    } else {
      _tabController.animateTo(2);
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
            _scaffoldMessengerKey.currentState?.showSnackBar(
              CustomSnackBar(
                message: errorMessage,
                actionIcon: Icons.refresh,
                onActionTap: () {
                  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  initSharingView(hasStoredSharingConsent);
                },
              ),
            );
          });
    }
  }

  /// Returns null when the key is not set, so user wasn't asked yet
  Future<bool?> getStoredSharingConsent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? hasStoredSharingConsent = prefs.getBool('shareConsent');
    return hasStoredSharingConsent;
  }

  Future<void> saveStoredSharingConsent(bool hasSharingConsent) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareConsent', hasSharingConsent);
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer!.cancel();
          }
        });
      }
    });
  }
}
