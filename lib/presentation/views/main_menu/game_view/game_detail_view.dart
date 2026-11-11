import 'package:material_ui/material_ui.dart';

class GameDetailView extends StatefulWidget {
  const GameDetailView({super.key});

  @override
  State<GameDetailView> createState() => _GameDetailViewState();
}

class _GameDetailViewState extends State<GameDetailView> {
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('GameDetailView'));
}
