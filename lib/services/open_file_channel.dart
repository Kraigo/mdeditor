import 'dart:io';

import 'package:flutter/services.dart';

import '../state/editor_state.dart';

/// Bridges native "open file" events (Finder double-click / "Open With") to the
/// editor. macOS delivers paths over the `mdeditor/files` [MethodChannel]; we
/// read each file and open it as a tab.
class OpenFileChannel {
  OpenFileChannel(this._state) {
    _channel.setMethodCallHandler(_handleCall);
    _drainPending();
  }

  static const _channel = MethodChannel('mdeditor/files');
  final EditorState _state;

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'openFiles') {
      await _openPaths((call.arguments as List).cast<String>());
    }
  }

  /// Picks up any files macOS delivered before this handler was registered
  /// (e.g. when the app was launched by opening a file).
  Future<void> _drainPending() async {
    try {
      final pending =
          await _channel.invokeMethod<List<dynamic>>('drainPendingFiles');
      if (pending != null) await _openPaths(pending.cast<String>());
    } on MissingPluginException {
      // Non-macOS platform — nothing to drain.
    }
  }

  Future<void> _openPaths(List<String> paths) async {
    for (final path in paths) {
      try {
        final content = await File(path).readAsString();
        final name = path.split(Platform.pathSeparator).last;
        _state.openFile(path: path, name: name, content: content);
      } catch (_) {
        // Skip unreadable files rather than failing the whole batch.
      }
    }
  }
}
