import 'package:flutter/foundation.dart';

import '../models/document.dart';

/// Owns the set of open documents and which one is active.
///
/// Exposed to the widget tree via `provider`'s [ChangeNotifierProvider].
class EditorState extends ChangeNotifier {
  EditorState() {
    newDocument();
  }

  final List<DocumentModel> _documents = [];
  int _activeIndex = 0;
  int _untitledCount = 0;
  int _idSeq = 0;

  List<DocumentModel> get documents => List.unmodifiable(_documents);
  int get activeIndex => _activeIndex;
  bool get hasDocuments => _documents.isNotEmpty;

  DocumentModel? get activeDocument =>
      _documents.isEmpty ? null : _documents[_activeIndex];

  /// Opens a new empty "Noname" document and makes it active.
  void newDocument() {
    _untitledCount++;
    final title = _untitledCount == 1 ? 'Noname' : 'Noname $_untitledCount';
    _documents.add(DocumentModel(id: 'doc-${_idSeq++}', title: title));
    _activeIndex = _documents.length - 1;
    notifyListeners();
  }

  /// Toggles the active document between the raw editor and rendered preview.
  void togglePreview() {
    final doc = activeDocument;
    if (doc == null) return;
    doc.preview = !doc.preview;
    notifyListeners();
  }

  /// Opens [content] read from [path] as a new tab and makes it active.
  ///
  /// If a document for [path] is already open, it is re-activated instead of
  /// opening a duplicate.
  void openFile({required String path, required String name, required String content}) {
    final existing = _documents.indexWhere((d) => d.filePath == path);
    if (existing != -1) {
      _activeIndex = existing;
      notifyListeners();
      return;
    }
    _documents.add(DocumentModel(
      id: 'doc-${_idSeq++}',
      title: name,
      content: content,
      filePath: path,
    ));
    _activeIndex = _documents.length - 1;
    notifyListeners();
  }

  void setActive(int index) {
    if (index < 0 || index >= _documents.length || index == _activeIndex) return;
    _activeIndex = index;
    notifyListeners();
  }

  /// Closes the document with [id] and disposes its resources.
  ///
  /// Returns whether any documents remain open. The caller is responsible for
  /// quitting the app when this returns `false` (see requirements: closing the
  /// last tab closes the application).
  bool closeDocument(String id) {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) return _documents.isNotEmpty;

    final doc = _documents.removeAt(index);
    doc.dispose();

    if (_documents.isEmpty) {
      _activeIndex = 0;
      notifyListeners();
      return false;
    }

    // Keep the active index pointing at a valid, intuitively-adjacent tab.
    if (_activeIndex > index || _activeIndex >= _documents.length) {
      _activeIndex = (_activeIndex - 1).clamp(0, _documents.length - 1);
    }

    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    for (final doc in _documents) {
      doc.dispose();
    }
    super.dispose();
  }
}
