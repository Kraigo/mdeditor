import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/document_io.dart';
import '../services/open_file_channel.dart';
import '../state/editor_state.dart';
import '../widgets/document_tab_bar.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/markdown_editor.dart';
import '../widgets/status_bar.dart';

/// Main app screen: toolbar, tab strip, document body, then the status bar.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void initState() {
    super.initState();
    // Receive files opened via Finder / "Open With" on macOS. The instance
    // keeps itself alive through its registered method-call handler.
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      OpenFileChannel(context.read<EditorState>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // A light, almost-white gray editing surface (subtly off the white chrome).
    final editorBackground = isLight
        ? const Color(0xFFF5F5F5)
        : Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: SafeArea(
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () =>
                _saveActive(context),
          },
          child: Focus(
            autofocus: true,
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
        ),
      ),
    );
  }

  void _saveActive(BuildContext context) {
    final doc = context.read<EditorState>().activeDocument;
    if (doc != null && doc.dirty.value) saveDocument(context, doc);
  }
}
