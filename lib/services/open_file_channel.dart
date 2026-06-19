import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_navigator.dart';
import '../state/editor_state.dart';

/// Bridges native macOS events to the editor over the `mdeditor/files`
/// [MethodChannel]:
///  - `openFiles` — files opened via Finder / "Open With", opened as tabs;
///  - `confirmQuit` — the app is terminating (red button / ⌘Q); returns whether
///    quitting is allowed, prompting first if any document has unsaved changes.
class OpenFileChannel {
  OpenFileChannel(this._state) {
    _channel.setMethodCallHandler(_handleCall);
    _drainPending();
  }

  static const _channel = MethodChannel('mdeditor/files');
  final EditorState _state;
  bool _confirmingQuit = false;

  Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'openFiles':
        await _openPaths((call.arguments as List).cast<String>());
        return null;
      case 'confirmQuit':
        return _confirmQuit();
    }
    return null;
  }

  /// Returns whether the app may quit. Asks the user when there are unsaved
  /// changes; otherwise allows quitting immediately.
  Future<bool> _confirmQuit() async {
    final hasUnsaved = _state.documents.any((doc) => doc.dirty.value);
    if (!hasUnsaved) return true;
    if (_confirmingQuit) return false; // a prompt is already open

    final context = navigatorKey.currentContext;
    if (context == null) return true; // no UI to ask with; don't trap the user

    _confirmingQuit = true;
    try {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text(
            'You have documents with unsaved changes. Quit and discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard & Quit'),
            ),
          ],
        ),
      );
      return discard ?? false;
    } finally {
      _confirmingQuit = false;
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
