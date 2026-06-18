import 'package:flutter/widgets.dart';

/// A single open Markdown document (one editor tab).
///
/// The [controller] is the source of truth for the document's text so that
/// cursor position and undo history survive switching between tabs. It is
/// owned by this model and must be disposed via [dispose] when the document
/// is closed.
class DocumentModel {
  DocumentModel({
    required this.id,
    required this.title,
    String content = '',
    this.filePath,
  }) : controller = TextEditingController(text: content);

  /// Stable identifier, unique for the lifetime of the app session.
  final String id;

  /// Tab label — a file name once saved/opened, otherwise "Noname".
  String title;

  /// Absolute path on disk, or null for an unsaved document.
  String? filePath;

  /// Whether this tab shows the rendered preview instead of the raw editor.
  bool preview = false;

  final TextEditingController controller;

  /// Focus for this document's editor, so focus can be returned to the caret
  /// after a toolbar action steals it.
  final FocusNode focusNode = FocusNode();

  /// Last scroll offset of each view, preserved across raw ⇄ rendered toggles.
  double editorScrollOffset = 0;
  double previewScrollOffset = 0;

  String get content => controller.text;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
