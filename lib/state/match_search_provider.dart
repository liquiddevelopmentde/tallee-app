import 'package:material_ui/material_ui.dart';

class MatchSearchProvider extends ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  void toggleSearch() {
    _isSearching = !_isSearching;
    notifyListeners();
  }
}
