import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';

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

  late bool isLoading;

  @override
  void initState() {
    super.initState();

    ///TODO: Make this gather all the required data, e.g. associated players, groups, games, ...
    final qrCode = QrCode.fromData(
      data: 'A6K1FJ', //widget.match.toJson().toString(),
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    qrImage = QrImage(qrCode);
  }

  @override
  Widget build(BuildContext context) {
    isLoading = false;

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
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: CustomTheme.primaryColor,
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: CustomTheme.textColor,
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
                children: [qrCodeView(), codeView(), fileView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  QrImage loadingStateQr() {
    final qrCode = QrCode.fromData(
      data: 'NOT_READY_YET',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    return QrImage(qrCode);
  }

  Widget qrCodeView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
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

  Widget codeView() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A6K1FJ', style: TextStyle(fontSize: 60)),
            SizedBox(width: 5),
            Icon(Icons.copy, size: 35),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: const Text(
            'Send the code to a person who also has Tallee to share this match.',
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

  Widget fileView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.file_present, size: 30),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "shared_match.tallee",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: CustomTheme.textColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "15 KB",
                        style: TextStyle(
                          fontSize: 14,
                          color: CustomTheme.textColor,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "x Players",
                        style: TextStyle(
                          fontSize: 14,
                          color: CustomTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.onBoxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: const Text(
            'Manually share the match data in a file for a 100% local transfer.',
            style: TextStyle(
              color: CustomTheme.textColor,
              fontSize: 14,
              overflow: TextOverflow.visible,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        BottomAnimatedButton(
          buttonText: 'Share File',
          sizeRelativeToWidth: 0.85,
          onPressed: () {},
          //icon: Icons.file_present,
        ),
      ],
    );
  }
}
