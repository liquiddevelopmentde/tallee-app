import 'package:material_ui/material_ui.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class ShowcaseProvider extends ChangeNotifier {
  bool _isTourActive = false;
  final Set<String> _shownInCurrentTour = {};

  bool get isTourActive => _isTourActive;

  bool get isTourSkipped => SharedPreferencesService.tourSkipped;

  bool get isTourCompleted => SharedPreferencesService.tourCompleted;

  void startTour() {
    if (_isTourActive) return;
    _isTourActive = true;
    _shownInCurrentTour.clear();
    notifyListeners();
  }

  void restartTour() {
    SharedPreferencesService.tourSkipped = false;
    SharedPreferencesService.tourCompleted = false;
    SharedPreferencesService.resetSeenShowcase();
    _shownInCurrentTour.clear();
    _isTourActive = true;
    notifyListeners();
  }

  void skipTour() {
    _isTourActive = false;
    SharedPreferencesService.tourSkipped = true;
    notifyListeners();
  }

  void completeTour() {
    _isTourActive = false;
    SharedPreferencesService.tourCompleted = true;
    notifyListeners();
  }

  bool hasSeen(String screenKey) {
    if (_shownInCurrentTour.isEmpty) {
      _shownInCurrentTour.addAll(SharedPreferencesService.showcaseSeen);
    }
    return _shownInCurrentTour.contains(screenKey);
  }

  bool shouldShowShowcase(String screenKey) {
    if (isTourSkipped || !_isTourActive) return false;
    return !hasSeen(screenKey);
  }

  void markAsSeen(String screenKey) {
    _shownInCurrentTour.add(screenKey);
    SharedPreferencesService.markShowcaseSeen(_shownInCurrentTour.toList());
    notifyListeners();
  }
}
