import 'package:flutter/material.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_game_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';

class PreviewMatchView extends StatefulWidget {
  const PreviewMatchView({super.key, required this.match});

  final Match match;

  @override
  State<PreviewMatchView> createState() => _PreviewMatchViewState();
}

class _PreviewMatchViewState extends State<PreviewMatchView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Match"), centerTitle: true),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(child: Text("Preview Match ${widget.match.name}")),
            ),
            BottomAnimatedButton(
              buttonText: "Confirm Import",
              sizeRelativeToWidth: 0.95,
              onPressed: () async {
                await Navigator.of(context).push(
                  adaptivePageRoute(
                    builder: (context) =>
                        AssociateGameView(match: widget.match),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
