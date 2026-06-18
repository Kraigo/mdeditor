import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../state/editor_state.dart';

const _markdownGroup =
    XTypeGroup(label: 'Markdown', extensions: ['md', 'markdown']);

/// Saves [doc], prompting for a location with the native panel when the
/// document has never been saved. Returns whether it was saved.
Future<bool> saveDocument(BuildContext context, DocumentModel doc) async {
  final state = context.read<EditorState>();
  final messenger = ScaffoldMessenger.of(context);
  try {
    return await state.save(
      doc,
      promptPath: (suggestedName) async {
        final location = await getSaveLocation(
          suggestedName: suggestedName,
          acceptedTypeGroups: const [_markdownGroup],
        );
        return location?.path;
      },
      writeFile: (path, content) => File(path).writeAsString(content),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not save file: $error')),
    );
    return false;
  }
}

/// Opens the native picker and opens the chosen `.md` file as a new tab.
Future<void> openDocument(BuildContext context) async {
  final state = context.read<EditorState>();
  final messenger = ScaffoldMessenger.of(context);
  try {
    final file = await openFile(acceptedTypeGroups: const [_markdownGroup]);
    if (file == null) return; // cancelled
    final content = await file.readAsString();
    state.openFile(path: file.path, name: file.name, content: content);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open file: $error')),
    );
  }
}

/// Prompts for a new name and renames [doc] (and its file on disk, if saved).
Future<void> renameDocument(BuildContext context, DocumentModel doc) async {
  final newName = await _promptName(context, doc.title);
  if (newName == null || !context.mounted) return;

  final state = context.read<EditorState>();
  final messenger = ScaffoldMessenger.of(context);
  try {
    await state.rename(
      doc,
      newName,
      moveFile: (from, name) async {
        final dir = from.substring(0, from.lastIndexOf(Platform.pathSeparator) + 1);
        final to = '$dir$name';
        await File(from).rename(to);
        return to;
      },
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not rename file: $error')),
    );
  }
}

Future<String?> _promptName(BuildContext context, String current) {
  final controller = TextEditingController(text: current);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rename'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Rename'),
        ),
      ],
    ),
  );
}
