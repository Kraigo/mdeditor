import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mdeditor/formatting/markdown_format.dart';

/// Builds a value with [text] and a selection from [start] to [end]
/// (collapsed at [start] when [end] is omitted).
TextEditingValue val(String text, int start, [int? end]) => TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: start, extentOffset: end ?? start),
    );

void main() {
  group('inline formats', () {
    test('wraps a selection in bold markers', () {
      final result = applyFormat(val('hello world', 0, 5), MarkdownFormat.bold);
      expect(result.text, '**hello** world');
      // Selection stays around the inner word.
      expect(result.selection, const TextSelection(baseOffset: 2, extentOffset: 7));
    });

    test('toggles bold off when the selection is already wrapped', () {
      // Caret selection covering "hello" inside the markers.
      final result =
          applyFormat(val('**hello** world', 2, 7), MarkdownFormat.bold);
      expect(result.text, 'hello world');
    });

    test('collapsed caret inserts empty markers for next input', () {
      final result = applyFormat(val('', 0), MarkdownFormat.italic);
      expect(result.text, '**');
      // Caret sits between the markers.
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 1);
    });

    test('underline uses HTML tags', () {
      final result =
          applyFormat(val('note', 0, 4), MarkdownFormat.underline);
      expect(result.text, '<u>note</u>');
    });
  });

  group('line prefixes', () {
    test('prefixes a single line with a bullet', () {
      final result = applyFormat(val('item', 0), MarkdownFormat.list);
      expect(result.text, '- item');
    });

    test('prefixes every line in a multi-line selection', () {
      final result = applyFormat(val('a\nb', 0, 3), MarkdownFormat.checkbox);
      expect(result.text, '- [ ] a\n- [ ] b');
    });

    test('toggles the bullet off when already present', () {
      final result = applyFormat(val('- item', 3), MarkdownFormat.list);
      expect(result.text, 'item');
    });
  });

  group('link', () {
    test('wraps a selection and selects the url placeholder', () {
      final result = applyFormat(val('Anthropic', 0, 9), MarkdownFormat.link);
      expect(result.text, '[Anthropic](url)');
      expect(
        result.text.substring(result.selection.start, result.selection.end),
        'url',
      );
    });

    test('inserts a template when there is no selection', () {
      final result = applyFormat(val('', 0), MarkdownFormat.link);
      expect(result.text, '[text](url)');
    });
  });

  group('activeFormats', () {
    test('reports bold when the selection is wrapped', () {
      expect(
        activeFormats(val('**hi**', 2, 4)),
        contains(MarkdownFormat.bold),
      );
    });

    test('reports checkbox but not list on a checkbox line', () {
      final active = activeFormats(val('- [ ] task', 8));
      expect(active, contains(MarkdownFormat.checkbox));
      expect(active, isNot(contains(MarkdownFormat.list)));
    });

    test('reports nothing on plain text', () {
      expect(activeFormats(val('plain', 2)), isEmpty);
    });

    test('handles an empty document with the caret at offset 0', () {
      expect(activeFormats(val('', 0)), isEmpty);
    });

    test('handles an unfocused field (offset -1)', () {
      expect(activeFormats(const TextEditingValue(text: '')), isEmpty);
    });
  });
}
