import 'package:flutter_test/flutter_test.dart';

import 'package:mdeditor/state/editor_state.dart';

void main() {
  group('dirty tracking', () {
    test('a fresh document is not dirty until edited', () {
      final doc = EditorState().activeDocument!;
      expect(doc.dirty.value, isFalse);

      doc.controller.text = 'hello';
      expect(doc.dirty.value, isTrue);
    });

    test('reverting to saved content clears the dirty flag', () {
      final doc = EditorState().activeDocument!;
      doc.controller.text = 'x';
      expect(doc.dirty.value, isTrue);
      doc.controller.text = '';
      expect(doc.dirty.value, isFalse);
    });
  });

  group('save', () {
    test('new document prompts for a path, then writes and clears dirty',
        () async {
      final state = EditorState();
      final doc = state.activeDocument!;
      doc.controller.text = '# Note';

      String? written;
      final saved = await state.save(
        doc,
        promptPath: (suggested) async {
          expect(suggested, 'Noname.md');
          return '/tmp/notes.md';
        },
        writeFile: (path, content) async => written = content,
      );

      expect(saved, isTrue);
      expect(written, '# Note');
      expect(doc.filePath, '/tmp/notes.md');
      expect(doc.title, 'notes.md');
      expect(doc.dirty.value, isFalse);
    });

    test('cancelling the path prompt does not save', () async {
      final state = EditorState();
      final doc = state.activeDocument!;
      doc.controller.text = 'x';

      var wrote = false;
      final saved = await state.save(
        doc,
        promptPath: (_) async => null, // cancelled
        writeFile: (path, content) async => wrote = true,
      );

      expect(saved, isFalse);
      expect(wrote, isFalse);
      expect(doc.dirty.value, isTrue);
    });

    test('existing file saves without prompting', () async {
      final state = EditorState();
      state.openFile(path: '/tmp/a.md', name: 'a.md', content: 'a');
      final doc = state.activeDocument!;
      doc.controller.text = 'a changed';

      var prompted = false;
      await state.save(
        doc,
        promptPath: (_) async {
          prompted = true;
          return null;
        },
        writeFile: (path, content) async {},
      );

      expect(prompted, isFalse);
      expect(doc.dirty.value, isFalse);
    });
  });

  group('rename', () {
    test('renames the title and moves the file when on disk', () async {
      final state = EditorState();
      state.openFile(path: '/tmp/old.md', name: 'old.md', content: 'x');
      final doc = state.activeDocument!;

      await state.rename(
        doc,
        'new.md',
        moveFile: (from, name) async => '/tmp/$name',
      );

      expect(doc.title, 'new.md');
      expect(doc.filePath, '/tmp/new.md');
    });

    test('renames in-memory title for an unsaved document', () async {
      final state = EditorState();
      final doc = state.activeDocument!;
      await state.rename(doc, 'Draft');
      expect(doc.title, 'Draft');
      expect(doc.filePath, isNull);
    });
  });
}
