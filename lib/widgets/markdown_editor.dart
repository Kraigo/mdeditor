import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../state/editor_state.dart';
import 'markdown_preview.dart';

/// The document body: either the raw Markdown editor or the rendered preview,
/// depending on the active document's [DocumentModel.preview] flag.
class MarkdownEditor extends StatelessWidget {
  const MarkdownEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<EditorState>().activeDocument;
    if (doc == null) return const SizedBox.shrink();

    // Keyed per document so switching tabs rebuilds with the right state.
    return doc.preview
        ? MarkdownPreview(key: ValueKey('preview-${doc.id}'), document: doc)
        : _RawEditor(key: ValueKey('editor-${doc.id}'), document: doc);
  }
}

class _RawEditor extends StatefulWidget {
  const _RawEditor({super.key, required this.document});

  final DocumentModel document;

  @override
  State<_RawEditor> createState() => _RawEditorState();
}

class _RawEditorState extends State<_RawEditor> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(
      initialScrollOffset: widget.document.editorScrollOffset,
    )..addListener(_saveOffset);
  }

  void _saveOffset() => widget.document.editorScrollOffset = _scroll.offset;

  @override
  void dispose() {
    _scroll.removeListener(_saveOffset);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.document.controller,
        focusNode: widget.document.focusNode,
        scrollController: _scroll,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: 'Start writing Markdown…',
        ),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
