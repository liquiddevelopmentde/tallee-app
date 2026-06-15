import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/code_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/file_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_share/qr_code_view.dart';

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

  Timer? _timer;

  int _secondsRemaining = 600; // 10 Minuten

  static const int _totalSeconds = 600;

  String? shareCode;

  @override
  void initState() {
    super.initState();

    initSharing();
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
                  ),
                  CodeView(
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: _totalSeconds,
                    shareCode: shareCode,
                    isLoading: isLoading,
                  ),
                  const FileView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initSharing() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      shareCode = "A3K1FJ";
      final qrCode = QrCode.fromData(
        data: shareCode!, //widget.match.toJson().toString(),
        errorCorrectLevel: QrErrorCorrectLevel.H,
      );
      qrImage = QrImage(qrCode);
      _startTimer();
      isLoading = false;
    });
  }
}
