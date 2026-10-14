import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeProvider() {
    _themeMode = SharedPreferencesService.getThemeMode();
    WidgetsBinding.instance.addObserver(this);
    _updateCustomTheme();
  }

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    SharedPreferencesService.setThemeMode(mode);
    _updateCustomTheme();
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      _updateCustomTheme();
      notifyListeners();
    }
  }

  void _updateCustomTheme() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = switch (_themeMode) {
      ThemeMode.system => platformBrightness == Brightness.dark,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };
    CustomTheme.setColors(dark: isDark);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
