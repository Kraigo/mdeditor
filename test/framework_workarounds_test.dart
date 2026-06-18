import 'package:flutter_test/flutter_test.dart';

import 'package:mdeditor/framework_workarounds.dart';

void main() {
  test('matches the benign macOS key-up assertion', () {
    final error = AssertionError(
      'A KeyUpEvent is dispatched, but the state shows that the physical key '
      'is pressed on a different logical key.',
    );
    expect(isBenignKeyboardAssertion(error), isTrue);
  });

  test('does not match unrelated errors', () {
    expect(isBenignKeyboardAssertion(AssertionError('something else')), isFalse);
    expect(isBenignKeyboardAssertion(StateError('boom')), isFalse);
  });
}
