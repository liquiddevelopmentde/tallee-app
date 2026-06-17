import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/file_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/qr_code_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/token_view.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/services/match_share_service.dart';
import 'package:tallee/services/share_exceptions.dart';

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

  void _startTimer() {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Match Share'), centerTitle: true),
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
                  unselectedLabelColor: CustomTheme.textColor,
                  onTap: (_) {
                    HapticFeedback.selectionClick();
                  },
                  tabs: const [
                    Tab(icon: Icon(Icons.qr_code)),
                    Tab(icon: Icon(Icons.numbers)),
                    Tab(icon: Icon(Icons.file_present)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  QrCodeView(
                    qrImage: qrImage,
                    isLoading: isLoading,
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    serverSharingEnabled: serverSharingEnabled,
                    onOnlineSharingPrefChanged: () {
                      initSharingView();
                    },
                  ),
                  TokenView(
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    shareToken: shareToken,
                    isLoading: isLoading,
                    serverSharingEnabled: serverSharingEnabled,
                    onOnlineSharingPrefChanged: () {
                      initSharingView();
                    },
                  ),
                  FileView(match: widget.match),
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
    late bool? storedSharingConsent;

    if (initialSharingConsent == null) {
      storedSharingConsent = await getStoredSharingConsent();
      if (storedSharingConsent == null) {
        bool? userDecision = await showConsentDialog();
        if (userDecision != null) {
          await saveStoredSharingConsent(userDecision);
          storedSharingConsent = userDecision;
        } else {
          // if the user closed popup without selecting an option, set decision
          // temporarily to false and ask again next time
          storedSharingConsent = false;
        }
      }
    } else {
      storedSharingConsent = initialSharingConsent;
    }

    setState(() {
      storedSharingConsent == true
          ? serverSharingEnabled = true
          : serverSharingEnabled = false;
    });

    if (serverSharingEnabled) {
      _tabController.animateTo(0);
    } else {
      _tabController.animateTo(2);
    }

    if (storedSharingConsent) {
      Future.wait([
            MatchShareService().getShareToken(widget.match),
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
                _startTimer();
                isLoading = false;
              });
            }
          })
          .catchError((error) {
            if (!mounted) {
              return;
            }

            String errorMessage;

            if (error is NetworkException) {
              errorMessage = 'Network error. Please check your connection.';
            } else if (error is ServerException) {
              errorMessage = 'Server error: ${error.statusCode}';
            } else if (error is ParsingException) {
              errorMessage = 'Data parsing error. Please try again later.';
            } else {
              errorMessage = 'An unexpected error occurred.';
            }
            _scaffoldMessengerKey.currentState?.showSnackBar(
              CustomSnackBar(
                message: errorMessage,
                actionText: 'Retry',
                onActionTap: () {
                  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  initSharingView(storedSharingConsent);
                },
              ),
            );
          });
    }
  }

  /// Returns null when the key is not set, so user wasn't asked yet
  Future<bool?> getStoredSharingConsent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? shareConsent = prefs.getBool('shareConsent');
    return shareConsent;
  }

  Future<void> saveStoredSharingConsent(bool consent) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareConsent', consent);
  }

  Future<bool?> showConsentDialog() {
    return showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Online Sharing',
        content: const Text(
          'To allow others to load your match, the game data needs to be transferred to our server. The share token is only temporarily valid, and the data will be deleted automatically after 10 minutes. Would you like to enable online sharing?',
          overflow: TextOverflow.visible,
        ),
        actions: [
          CustomDialogAction(
            text: 'Enable',
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CustomDialogAction(
            text: 'Disable',
            buttonType: ButtonType.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
