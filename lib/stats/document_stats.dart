/// Line / character / word / token counts for the status bar.
class DocumentStats {
  const DocumentStats({
    required this.lines,
    required this.characters,
    required this.words,
    required this.tokens,
  });

  final int lines;
  final int characters;
  final int words;

  /// Approximate token count (see [computeStats]).
  final int tokens;
}

final _whitespace = RegExp(r'\s+');

/// Computes document statistics for [text].
///
/// [tokens] is an approximation — a real tokenizer (e.g. BPE) is not bundled —
/// using the widely-used ~4-characters-per-token rule of thumb.
DocumentStats computeStats(String text) {
  final characters = text.length;
  final lines = text.isEmpty ? 1 : '\n'.allMatches(text).length + 1;

  final trimmed = text.trim();
  final words = trimmed.isEmpty ? 0 : trimmed.split(_whitespace).length;

  final tokens = characters == 0 ? 0 : (characters / 4).ceil();

  return DocumentStats(
    lines: lines,
    characters: characters,
    words: words,
    tokens: tokens,
  );
}
