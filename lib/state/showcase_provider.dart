import 'package:flutter/cupertino.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class ShowcaseProvider extends ChangeNotifier {
  bool _isTourActive = false;
  final Set<String> _shownInCurrentTour = {};

  bool get isTourActive => _isTourActive;

  bool get isTourSkipped => SharedPreferencesService.isTourSkipped();

  bool get isTourCompleted => SharedPreferencesService.isTourCompleted();

  void startTour() {
    if (_isTourActive) return;
    _isTourActive = true;
    _shownInCurrentTour.clear();
    notifyListeners();
  }

  void skipTour() {
    _isTourActive = false;
    SharedPreferencesService.setTourSkipped(true);
    notifyListeners();
  }

  void completeTour() {
    _isTourActive = false;
    SharedPreferencesService.setTourCompleted(true);
    notifyListeners();
  }

  bool shouldShowShowcase(String screenKey) {
    if (isTourSkipped || !_isTourActive) return false;

    if (_isTourActive) {
      if (screenKey == 'select_winner_widget_listview_key') {
        print('should show ${!_shownInCurrentTour.contains(screenKey)}');
      }
      return !_shownInCurrentTour.contains(screenKey);
    }

    return !SharedPreferencesService.hasSeenShowcase(screenKey);
  }

  void markAsSeen(String screenKey) {
    print("$screenKey markedAsSeen");
    SharedPreferencesService.setShowcaseSeen(screenKey);
    _shownInCurrentTour.add(screenKey);
    notifyListeners();
  }
}
