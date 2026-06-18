import 'package:flutter_test/flutter_test.dart';

import 'package:mdeditor/state/editor_state.dart';

void main() {
  test('starts with a single Noname document', () {
    final state = EditorState();
    expect(state.documents, hasLength(1));
    expect(state.documents.single.title, 'Noname');
    expect(state.activeDocument, isNotNull);
  });

  test('openFile adds an active tab carrying the file content', () {
    final state = EditorState();
    state.openFile(path: '/tmp/notes.md', name: 'notes.md', content: '# Hi');

    expect(state.documents, hasLength(2));
    expect(state.activeDocument!.title, 'notes.md');
    expect(state.activeDocument!.content, '# Hi');
    expect(state.activeDocument!.filePath, '/tmp/notes.md');
  });

  test('openFile re-activates an already-open file instead of duplicating', () {
    final state = EditorState();
    state.openFile(path: '/tmp/a.md', name: 'a.md', content: 'a');
    state.openFile(path: '/tmp/b.md', name: 'b.md', content: 'b');
    expect(state.documents, hasLength(3));

    state.openFile(path: '/tmp/a.md', name: 'a.md', content: 'a');
    expect(state.documents, hasLength(3));
    expect(state.activeDocument!.filePath, '/tmp/a.md');
  });

  test('closing the active tab keeps a valid active document', () {
    final state = EditorState();
    state.openFile(path: '/tmp/a.md', name: 'a.md', content: 'a');
    final activeId = state.activeDocument!.id;

    final stillOpen = state.closeDocument(activeId);

    expect(stillOpen, isTrue);
    expect(state.documents, hasLength(1));
    expect(state.activeDocument!.title, 'Noname');
  });

  test('closeDocument reports false when the last tab is closed', () {
    final state = EditorState();
    final stillOpen = state.closeDocument(state.documents.single.id);
    expect(stillOpen, isFalse);
    expect(state.hasDocuments, isFalse);
  });
}
