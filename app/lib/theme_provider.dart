import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
