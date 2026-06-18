import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'framework_workarounds.dart';
import 'screens/editor_screen.dart';
import 'state/editor_state.dart';
import 'state/settings_state.dart';

void main() {
  installFrameworkWorkarounds();
  runApp(const MdEditorApp());
}

class MdEditorApp extends StatelessWidget {
  const MdEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
      ],
      child: Consumer<SettingsState>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Markdown Editor',
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
