import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mdeditor/state/settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults before anything is persisted', () async {
    final settings = SettingsState();
    await settings.load();
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.fontFamily, kFontFamilies.first);
    expect(settings.fontSize, kInitialFontSize);
  });

  test('persists theme and font settings across reloads', () async {
    final settings = SettingsState();
    await settings.load();
    settings.setThemeMode(ThemeMode.dark);
    settings.setFontFamily(kFontFamilies.last);
    settings.setFontSize(20);

    final reloaded = SettingsState();
    await reloaded.load();
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.fontFamily, kFontFamilies.last);
    expect(reloaded.fontSize, 20);
  });

  test('clamps font size to the supported range', () async {
    final settings = SettingsState();
    await settings.load();
    settings.setFontSize(1000);
    expect(settings.fontSize, kMaxFontSize);
  });
}
