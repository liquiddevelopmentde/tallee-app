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

class _MatchShareViewState extends State<MatchShareView> {
  @protected
  QrImage? qrImage;

  bool isLoading = true;

  //standardmäßig true, um screen erst auf qr code zu leiten, daten werden erst
  // nach consent gesendet
  bool enableServerSharing = true;

  Timer? _timer;

  int _secondsRemaining = 600; // 10 Minuten

  static const int _totalSeconds = 600;

  String? shareToken;

  @override
  void initState() {
    super.initState();
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
    return DefaultTabController(
      initialIndex: enableServerSharing ? 0 : 2,
      length: 3,
      child: Scaffold(
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
                children: [
                  QrCodeView(
                    qrImage: qrImage,
                    isLoading: isLoading,
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    enableServerSharing: enableServerSharing,
                  ),
                  TokenView(
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    shareToken: shareToken,
                    isLoading: isLoading,
                    enableServerSharing: enableServerSharing,
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
      print("StoredSharingConsent 1: " + storedSharingConsent.toString());
      if (storedSharingConsent == null) {
        bool? userDecision = await showConsentDialog();
        if (userDecision != null) {
          await saveStoredSharingConsent(userDecision);
          storedSharingConsent = userDecision;
        } else {
          //if user closed popup, set decision temporarily to false and ask again next time
          storedSharingConsent = false;
        }
      } else if (storedSharingConsent == false) {
        setState(() {
          enableServerSharing = false;
        });
      }
    } else {
      storedSharingConsent = initialSharingConsent;
    }

    if (storedSharingConsent!) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                message: errorMessage,
                actionText: "Retry",
                onActionTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
        title: 'Share Match Data',
        content: const Text(
          'To allow others to load your match, the game data needs to be transferred to our external server. The online token is only temporarily valid, and the data will be deleted automatically afterwards. Would you like to enable online sharing?',
          overflow: TextOverflow.visible,
        ),
        actions: [
          CustomDialogAction(
            text: "Enable",
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CustomDialogAction(
            text: "Disable",
            buttonType: ButtonType.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
