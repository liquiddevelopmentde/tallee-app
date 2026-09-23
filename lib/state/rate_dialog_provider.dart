import 'package:flutter/material.dart';

class RateDialogProvider extends ChangeNotifier {
  bool _shouldShow = false;

  bool get shouldShow => _shouldShow;

  void request() {
    _shouldShow = true;
    notifyListeners();
  }

  void markAsShown() {
    _shouldShow = false;
    notifyListeners();
  }
}
