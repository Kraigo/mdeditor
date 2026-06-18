import 'package:flutter/foundation.dart';

/// True for the known, benign `HardwareKeyboard` assertion that fires on macOS
/// desktop when a character key is released while ⌘ is held.
///
/// macOS does not deliver key-up events for character keys while ⌘ is pressed,
/// so Flutter synthesizes them with a fallback logical key — tripping
/// `assert(_pressedKeys[event.physicalKey] == event.logicalKey)`. It is
/// non-fatal (the app keeps running) but spams the debug console.
/// See https://github.com/flutter/flutter/issues/100783.
bool isBenignKeyboardAssertion(Object exception) {
  return exception is AssertionError &&
      exception.message.toString().contains('A KeyUpEvent is dispatched');
}

/// Suppresses [isBenignKeyboardAssertion] errors while forwarding everything
/// else to the previous handler. Only ever matches in debug builds (assertions
/// are stripped from profile/release), so it is a no-op in production.
void installFrameworkWorkarounds() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (isBenignKeyboardAssertion(details.exception)) return;
    previous?.call(details);
  };
}
