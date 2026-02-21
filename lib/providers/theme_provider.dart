import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  final String _boxName = 'settingsBox';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  
  void _loadTheme() {
    var box = Hive.box(_boxName);
    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    notifyListeners();
  }

  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    var box = Hive.box(_boxName);
    box.put('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}