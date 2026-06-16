import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_import/enter_token_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_import/import_file_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_import/qr_scan_view.dart';

class MatchImportView extends StatefulWidget {
  const MatchImportView({super.key});

  @override
  State<MatchImportView> createState() => _MatchImportViewState();
}

class _MatchImportViewState extends State<MatchImportView>
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
        appBar: AppBar(
          title: const Text('Match Import View'),
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
                  unselectedLabelColor: CustomTheme.textColor,
                  onTap: (_) {
                    HapticFeedback.selectionClick();
                  },
                  tabs: const [
                    Tab(icon: Icon(Icons.qr_code_scanner)),
                    Tab(icon: Icon(Icons.pin)),
                    Tab(icon: Icon(Icons.file_upload)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const QrScanView(),
                  const EnterTokenView(),
                  const ImportFileView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
