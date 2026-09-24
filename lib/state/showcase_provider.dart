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

  void restartTour() {
    SharedPreferencesService.setTourSkipped(false);
    SharedPreferencesService.setTourCompleted(false);
    SharedPreferencesService.resetSeenShowcase();
    _shownInCurrentTour.clear();
    _isTourActive = true;
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

    if (_shownInCurrentTour.isEmpty) {
      _shownInCurrentTour.addAll(SharedPreferencesService.getShowcaseSeen());
    }
    return !_shownInCurrentTour.contains(screenKey);
  }

  void markAsSeen(String screenKey) {
    _shownInCurrentTour.add(screenKey);
    SharedPreferencesService.setShowcaseSeen(_shownInCurrentTour.toList());
    notifyListeners();
  }
}
