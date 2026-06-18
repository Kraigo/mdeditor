import 'package:flutter_test/flutter_test.dart';

import 'package:mdeditor/stats/document_stats.dart';

void main() {
  test('empty document counts as one line and zero of everything else', () {
    final s = computeStats('');
    expect(s.lines, 1);
    expect(s.characters, 0);
    expect(s.words, 0);
    expect(s.tokens, 0);
  });

  test('counts lines, words and characters', () {
    final s = computeStats('hello world\nsecond line');
    expect(s.lines, 2);
    expect(s.words, 4);
    expect(s.characters, 'hello world\nsecond line'.length);
  });

  test('collapses runs of whitespace when counting words', () {
    expect(computeStats('  a   b  ').words, 2);
  });

  test('approximates tokens at ~4 characters each', () {
    expect(computeStats('12345678').tokens, 2); // 8 / 4
    expect(computeStats('123').tokens, 1); // ceil(3 / 4)
  });
}
