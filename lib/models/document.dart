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
  }) : controller = TextEditingController(text: content) {
    _savedContent = content;
    controller.addListener(_updateDirty);
  }

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

  /// Whether the document has unsaved changes. Drives the italic tab title and
  /// the enabled state of the Save button; widgets listen to it directly.
  final ValueNotifier<bool> dirty = ValueNotifier<bool>(false);

  /// The on-disk content as of the last open/save, compared against [content]
  /// to derive [dirty].
  late String _savedContent;

  /// Last scroll offset of each view, preserved across raw ⇄ rendered toggles.
  double editorScrollOffset = 0;
  double previewScrollOffset = 0;

  String get content => controller.text;

  /// Suggested file name when saving an as-yet-unsaved document.
  String get suggestedFileName =>
      title.toLowerCase().endsWith('.md') ? title : '$title.md';

  void _updateDirty() {
    final isDirty = controller.text != _savedContent;
    if (dirty.value != isDirty) dirty.value = isDirty;
  }

  /// Records that the document was just persisted to [path] under [title].
  void applySaved({required String path, required String title}) {
    filePath = path;
    this.title = title;
    _savedContent = controller.text;
    dirty.value = false;
  }

  void dispose() {
    controller.removeListener(_updateDirty);
    controller.dispose();
    focusNode.dispose();
    dirty.dispose();
  }
}
