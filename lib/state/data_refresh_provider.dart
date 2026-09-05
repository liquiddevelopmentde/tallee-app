import 'package:flutter/material.dart';

class DataRefreshProvider extends ChangeNotifier {
  int _revision = 0;
  int get revision => _revision;

  void refresh() {
    _revision++;
    notifyListeners();
  }
}
