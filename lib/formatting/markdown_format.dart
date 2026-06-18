import 'package:flutter/widgets.dart';

/// The formats the toolbar can apply to the active document.
enum MarkdownFormat { bold, italic, strikethrough, underline, list, checkbox, link }

/// Inline (wrap-the-selection) formats and their Markdown markers.
const Map<MarkdownFormat, (String left, String right)> _inlineMarkers = {
  MarkdownFormat.bold: ('**', '**'),
  MarkdownFormat.italic: ('*', '*'),
  MarkdownFormat.strikethrough: ('~~', '~~'),
  // Markdown has no native underline; HTML is the common convention.
  MarkdownFormat.underline: ('<u>', '</u>'),
};

/// Line-prefix (block) formats and the prefix added to each affected line.
const Map<MarkdownFormat, String> _linePrefixes = {
  MarkdownFormat.checkbox: '- [ ] ',
  MarkdownFormat.list: '- ',
};

/// Applies [format] to [value], returning the updated text and selection.
///
/// With a non-empty selection the markup is wrapped around / prefixed onto it
/// (and toggled off if already applied). With a collapsed caret, inline formats
/// insert empty markers and place the caret between them so the *next* input is
/// formatted — satisfying the "enable this mode for next input" requirement.
TextEditingValue applyFormat(TextEditingValue value, MarkdownFormat format) {
  if (_inlineMarkers.containsKey(format)) {
    return _applyInline(value, _inlineMarkers[format]!);
  }
  if (_linePrefixes.containsKey(format)) {
    return _applyLinePrefix(value, _linePrefixes[format]!);
  }
  return _applyLink(value);
}

/// The formats currently in effect at the caret/selection, used to highlight
/// the matching toolbar buttons.
Set<MarkdownFormat> activeFormats(TextEditingValue value) {
  final result = <MarkdownFormat>{};
  final sel = _safeSelection(value);
  final text = value.text;

  for (final entry in _inlineMarkers.entries) {
    if (_isWrapped(text, sel.start, sel.end, entry.value)) {
      result.add(entry.key);
    }
  }

  final line = text.substring(
    _lineStart(text, sel.start),
    _lineEnd(text, sel.start),
  );
  // Check the more specific prefix (checkbox) before the more general (list).
  if (line.startsWith(_linePrefixes[MarkdownFormat.checkbox]!)) {
    result.add(MarkdownFormat.checkbox);
  } else if (line.startsWith(_linePrefixes[MarkdownFormat.list]!)) {
    result.add(MarkdownFormat.list);
  }

  return result;
}

TextEditingValue _applyInline(TextEditingValue value, (String, String) marker) {
  final (left, right) = marker;
  final sel = _safeSelection(value);
  final text = value.text;
  final start = sel.start;
  final end = sel.end;

  // Already wrapped → toggle the markers off.
  if (_isWrapped(text, start, end, marker)) {
    final newText = text.substring(0, start - left.length) +
        text.substring(start, end) +
        text.substring(end + right.length);
    return TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start - left.length,
        extentOffset: end - left.length,
      ),
    );
  }

  final selected = text.substring(start, end);
  final newText =
      text.substring(0, start) + left + selected + right + text.substring(end);
  final innerStart = start + left.length;
  return TextEditingValue(
    text: newText,
    selection: TextSelection(
      baseOffset: innerStart,
      extentOffset: innerStart + selected.length,
    ),
  );
}

TextEditingValue _applyLinePrefix(TextEditingValue value, String prefix) {
  final sel = _safeSelection(value);
  final text = value.text;
  final blockStart = _lineStart(text, sel.start);
  final blockEnd = _lineEnd(text, sel.end);
  final lines = text.substring(blockStart, blockEnd).split('\n');

  final allPrefixed = lines.every((l) => l.startsWith(prefix));
  final newLines = lines
      .map((l) => allPrefixed ? l.substring(prefix.length) : '$prefix$l')
      .toList();
  final newBlock = newLines.join('\n');
  final newText =
      text.substring(0, blockStart) + newBlock + text.substring(blockEnd);
  final delta = (allPrefixed ? -1 : 1) * prefix.length * lines.length;

  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: (sel.end + delta).clamp(0, newText.length)),
  );
}

TextEditingValue _applyLink(TextEditingValue value) {
  final sel = _safeSelection(value);
  final text = value.text;
  final label = text.substring(sel.start, sel.end);
  final labelText = label.isEmpty ? 'text' : label;
  const url = 'url';
  final inserted = '[$labelText]($url)';
  final newText =
      text.substring(0, sel.start) + inserted + text.substring(sel.end);

  // Select the "url" placeholder so the user can immediately type the address.
  final urlStart = sel.start + '[$labelText]('.length;
  return TextEditingValue(
    text: newText,
    selection: TextSelection(baseOffset: urlStart, extentOffset: urlStart + url.length),
  );
}

bool _isWrapped(String text, int start, int end, (String, String) marker) {
  final (left, right) = marker;
  if (start - left.length < 0 || end + right.length > text.length) return false;
  return text.substring(start - left.length, start) == left &&
      text.substring(end, end + right.length) == right;
}

/// Returns a valid selection, falling back to a caret at the end of the text
/// when the field has never been focused (offset of -1).
TextSelection _safeSelection(TextEditingValue value) {
  final sel = value.selection;
  if (sel.start < 0 || sel.end < 0) {
    return TextSelection.collapsed(offset: value.text.length);
  }
  return sel;
}

int _lineStart(String text, int offset) {
  if (offset <= 0) return 0;
  return text.lastIndexOf('\n', offset - 1) + 1;
}

int _lineEnd(String text, int offset) {
  final i = text.indexOf('\n', offset);
  return i == -1 ? text.length : i;
}
