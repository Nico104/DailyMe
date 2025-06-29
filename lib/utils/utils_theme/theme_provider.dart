import 'package:dailyme/utils/utils_theme/store_manager.dart';
import 'package:dailyme/utils/utils_theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

///Provider to tell the App which Theme is active
class ThemeNotifier with ChangeNotifier {
  final darkTheme = constDarkTheme;
  final lightTheme = constLightTheme;
  final highContrast = constDarkTheme;

  ThemeData? _themeData;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeNotifier() {
    // Set default immediately to light theme to avoid color flash
    _themeData = lightTheme;
    _themeMode = ThemeMode.light;

    // Then load from storage (if needed)
    StorageManager.readData('themeMode').then((value) {
      if (value == 'dark') {
        _themeData = darkTheme;
        _themeMode = ThemeMode.dark;
      } else if (value == 'light') {
        _themeData = lightTheme;
        _themeMode = ThemeMode.light;
      } else {
        _themeData = getSystemTheme();
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    });
  }
  /// Returns the current ThemeMode (system, light, dark)
  ThemeMode get themeMode => _themeMode;

  ///Returns the current active Theme
  ThemeData? getTheme() => _themeData;

  ///Sets the current active theme to dark mode

  Future<void> setDarkTheme() async {
    _themeData = darkTheme;
    _themeMode = ThemeMode.dark;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  ///Sets the current active theme to dark mode

  Future<void> setHighContrastTheme() async {
    _themeData = darkTheme;
    _themeMode = ThemeMode.dark;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  ///Sets the current active theme to light mode

  Future<void> setLightTheme() async {
    _themeData = lightTheme;
    _themeMode = ThemeMode.light;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  Future<void> setSystemTheme() async {
    print("set system theme");
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    _themeData = isDarkMode ? darkTheme : lightTheme;
    _themeMode = ThemeMode.system;
    StorageManager.saveData('themeMode', 'system');
    notifyListeners();
  }

  ThemeData getSystemTheme() {
    // var brightness =
    //     SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return isDarkMode ? darkTheme : lightTheme;
  }
}
