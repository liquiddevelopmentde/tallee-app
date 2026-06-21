import 'package:flutter/material.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';

class AssociateGroupsView extends StatefulWidget {
  const AssociateGroupsView({
    required this.match,
    required this.associations,
    super.key,
  });

  final Match match;

  final Map<String, Player?> associations;

  @override
  State<AssociateGroupsView> createState() => _AssociateGroupsViewState();
}

class _AssociateGroupsViewState extends State<AssociateGroupsView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Associate Groups')),
        body: Column(
          children: [
            BottomAnimatedButton(
              buttonText: 'Save match',
              sizeRelativeToWidth: 0.95,
              onPressed: () {
                //TODO: Handle match save logic
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
