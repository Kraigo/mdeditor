import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Editor font families offered in settings. The first is the default.
const List<String> kFontFamilies = [
  'Menlo',
  'Monaco',
  'Courier New',
  'SF Mono',
  'Helvetica Neue',
  'Georgia',
  'Times New Roman',
];

const double kMinFontSize = 10;
const double kMaxFontSize = 28;
const double kInitialFontSize = 14;

/// App-wide user settings, persisted with `shared_preferences`.
class SettingsState extends ChangeNotifier {
  static const _kTheme = 'theme_mode';
  static const _kFontFamily = 'font_family';
  static const _kFontSize = 'font_size';

  SharedPreferences? _prefs;
  bool _disposed = false;

  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = kFontFamilies.first;
  double _fontSize = kInitialFontSize;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;

  /// Loads persisted settings. Safe when no backing store is available
  /// (e.g. in tests) — it just keeps the defaults.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      _prefs = prefs;

      final themeIndex = prefs.getInt(_kTheme);
      if (themeIndex != null &&
          themeIndex >= 0 &&
          themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }
      final family = prefs.getString(_kFontFamily);
      if (family != null && kFontFamilies.contains(family)) {
        _fontFamily = family;
      }
      final size = prefs.getDouble(_kFontSize);
      if (size != null) _fontSize = size.clamp(kMinFontSize, kMaxFontSize);

      notifyListeners();
    } catch (_) {
      // No persistence available; keep defaults.
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _prefs?.setInt(_kTheme, mode.index);
    notifyListeners();
  }

  void setFontFamily(String family) {
    if (family == _fontFamily) return;
    _fontFamily = family;
    _prefs?.setString(_kFontFamily, family);
    notifyListeners();
  }

  void setFontSize(double size) {
    final clamped = size.clamp(kMinFontSize, kMaxFontSize);
    if (clamped == _fontSize) return;
    _fontSize = clamped;
    _prefs?.setDouble(_kFontSize, clamped);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
