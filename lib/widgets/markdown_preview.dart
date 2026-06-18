import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../models/document.dart';

/// Renders a document as an evaluated, read-only Markdown view.
///
/// Uses the GitHub-flavored extension set so strikethrough and `- [ ]`
/// task-list checkboxes (produced by the formatting toolbar) render natively.
/// Its scroll offset is preserved on [DocumentModel] so it survives toggling
/// back and forth with the raw editor.
class MarkdownPreview extends StatefulWidget {
  const MarkdownPreview({super.key, required this.document});

  final DocumentModel document;

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}

class _MarkdownPreviewState extends State<MarkdownPreview> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(
      initialScrollOffset: widget.document.previewScrollOffset,
    )..addListener(_saveOffset);
  }

  void _saveOffset() => widget.document.previewScrollOffset = _scroll.offset;

  @override
  void dispose() {
    _scroll.removeListener(_saveOffset);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Markdown(
      controller: _scroll,
      data: widget.document.content,
      selectable: true,
      padding: const EdgeInsets.all(16),
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }
}
