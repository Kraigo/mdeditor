import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_navigator.dart';
import 'framework_workarounds.dart';
import 'screens/editor_screen.dart';
import 'state/editor_state.dart';
import 'state/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installFrameworkWorkarounds();
  final settings = SettingsState();
  await settings.load();
  runApp(MdEditorApp(settings: settings));
}

class MdEditorApp extends StatefulWidget {
  const MdEditorApp({super.key, this.settings});

  /// Pre-loaded settings. When null (e.g. in tests) one is created and loaded.
  final SettingsState? settings;

  @override
  State<MdEditorApp> createState() => _MdEditorAppState();
}

class _MdEditorAppState extends State<MdEditorApp> {
  late final bool _ownsSettings = widget.settings == null;
  late final SettingsState _settings = widget.settings ?? (SettingsState()..load());

  @override
  void dispose() {
    if (_ownsSettings) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorState()),
        ChangeNotifierProvider<SettingsState>.value(value: _settings),
      ],
      child: Consumer<SettingsState>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Markdown Editor',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: settings.themeMode,
          home: const EditorScreen(),
        ),
      ),
    );
  }

  static ThemeData _theme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
          brightness: brightness,
        ),
      );
}
