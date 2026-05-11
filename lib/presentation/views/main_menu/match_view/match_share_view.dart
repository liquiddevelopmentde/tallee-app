import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';

class MatchShareView extends StatefulWidget {
  const MatchShareView({super.key, required this.match});

  /// The match to share
  final Match match;

  @override
  State<MatchShareView> createState() => _MatchShareViewState();
}

class _MatchShareViewState extends State<MatchShareView> {
  @protected
  late QrImage qrImage;

  @override
  void initState() {
    super.initState();

    ///TODO: Make this gather all the required data, e.g. associated players, groups, games, ...
    final qrCode = QrCode.fromData(
      data: widget.match.toJson().toString(),
      errorCorrectLevel: QrErrorCorrectLevel.Q,
    );

    qrImage = QrImage(qrCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Share'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: ClipRRect(
              borderRadius: CustomTheme.standardBorderRadiusAll,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: PrettyQrView(
                  qrImage: qrImage,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSquaresSymbol(),
                    background: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CustomTheme.onBoxColor,
              border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
              borderRadius: CustomTheme.standardBorderRadiusAll,
            ),
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: Text(
              "Scan the QR Code with another Tallee instance to share the match.",
              style: TextStyle(color: CustomTheme.textColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
