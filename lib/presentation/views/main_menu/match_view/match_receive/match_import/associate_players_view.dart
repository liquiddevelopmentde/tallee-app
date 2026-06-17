import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:tallee/data/models/models.dart';

class AssociatePlayersView extends StatefulWidget {
  const AssociatePlayersView({super.key, required this.match});

  final Match match;

  @override
  State<AssociatePlayersView> createState() => _AssociatePlayersViewState();
}

class _AssociatePlayersViewState extends State<AssociatePlayersView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Associate Players View'),
        centerTitle: true,
      ),
      body: Center(child: Text('Associate Players View: ${widget.match.name}')),
    );
  }
}
