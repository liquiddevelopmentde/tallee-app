import 'package:flutter/material.dart';

class MatchSearchProvider extends ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _query = "";
  String get query => _query;

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) _query = ""; // Reset bei Schließen
    notifyListeners();
  }

  void updateQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }
}
