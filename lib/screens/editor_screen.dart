import 'package:flutter/material.dart';

import '../widgets/document_tab_bar.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/markdown_editor.dart';
import '../widgets/status_bar.dart';

/// Main app screen: toolbar, tab strip, document body, then the status bar.
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // A light, almost-white gray editing surface (subtly off the white chrome).
    final editorBackground = isLight
        ? const Color(0xFFF5F5F5)
        : Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const EditorToolbar(),
            const DocumentTabBar(),
            Expanded(
              child: ColoredBox(
                color: editorBackground,
                child: const MarkdownEditor(),
              ),
            ),
            const StatusBar(),
          ],
        ),
      ),
    );
  }
}
