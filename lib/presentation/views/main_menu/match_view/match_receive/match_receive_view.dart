import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/enter_token_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/import_file_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/qr_scan_view.dart';

class MatchReceiveView extends StatefulWidget {
  const MatchReceiveView({super.key});

  @override
  State<MatchReceiveView> createState() => _MatchReceiveViewViewState();
}

class _MatchReceiveViewViewState extends State<MatchReceiveView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Match Receive View'),
          centerTitle: true,
        ),
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
                    Tab(icon: Icon(Icons.qr_code_scanner)),
                    Tab(icon: Icon(Icons.pin)),
                    Tab(icon: Icon(Icons.file_present)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  QrScanView(),
                  EnterTokenView(),
                  ImportFileView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
