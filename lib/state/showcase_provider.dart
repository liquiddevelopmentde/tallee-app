import 'package:flutter/cupertino.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class ShowcaseProvider extends ChangeNotifier {
  bool _isTourActive = false;
  final Set<String> _shownInCurrentTour = {};

  bool get isTourActive => _isTourActive;
  bool get isTourSkipped => SharedPreferencesService.isTourSkipped();

  void startTour() {
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
    _shownInCurrentTour.clear();
    notifyListeners();
  }

  bool shouldShowShowcase(String screenKey) {
    if (isTourSkipped && !_isTourActive) return false;

    if (_isTourActive) {
      return !_shownInCurrentTour.contains(screenKey);
    }

    return !SharedPreferencesService.hasSeenShowcase(screenKey);
  }

  void markAsSeen(String screenKey) {
    SharedPreferencesService.setShowcaseSeen(screenKey);
    _shownInCurrentTour.add(screenKey);
    notifyListeners();
  }

  bool hasSeen(String screenKey) {
    return SharedPreferencesService.hasSeenShowcase(screenKey);
  }
}
