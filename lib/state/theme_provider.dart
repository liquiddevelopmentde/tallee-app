import 'package:material_ui/material_ui.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeProvider() {
    _themeMode = SharedPreferencesService.getThemeMode();
    WidgetsBinding.instance.addObserver(this);
  }

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    SharedPreferencesService.setThemeMode(mode);
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
