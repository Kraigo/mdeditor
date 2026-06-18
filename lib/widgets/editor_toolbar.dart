import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../formatting/markdown_format.dart';
import '../models/document.dart';
import '../services/document_io.dart';
import '../state/editor_state.dart';
import 'settings_dialog.dart';

/// Topmost navigation bar.
///
/// Layout (left → right): open-file action, formatting button groups, and the
/// raw/rendered toggle. The open action and toggle are wired up in later tasks.
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<EditorState>();
    final doc = state.activeDocument;
    final preview = doc?.preview ?? false;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Left: open file.
          IconButton(
            tooltip: 'Open Markdown file',
            icon: const Icon(Icons.folder_open),
            onPressed: () => openDocument(context),
          ),
          // Save (enabled only when there are unsaved changes).
          _SaveButton(document: doc),
          // Settings popup.
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showSettingsDialog(context),
          ),
          const SizedBox(width: 8),
          // Middle: formatting button groups.
          Expanded(
            child: doc == null
                ? const SizedBox.shrink()
                : _FormattingBar(document: doc),
          ),
          const SizedBox(width: 8),
          // Right: raw/rendered toggle.
          IconButton(
            tooltip: preview ? 'Edit raw Markdown' : 'Preview rendered document',
            isSelected: preview,
            icon: const Icon(Icons.visibility_outlined),
            selectedIcon: const Icon(Icons.visibility),
            onPressed: doc == null ? null : state.togglePreview,
          ),
        ],
      ),
    );
  }
}

/// Save button that enables only when the active document has unsaved changes.
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.document});

  final DocumentModel? document;

  @override
  Widget build(BuildContext context) {
    final doc = document;
    if (doc == null) {
      return const IconButton(
        tooltip: 'Save (⌘S)',
        icon: Icon(Icons.save_outlined),
        onPressed: null,
      );
    }
    return ValueListenableBuilder<bool>(
      valueListenable: doc.dirty,
      builder: (context, isDirty, _) => IconButton(
        tooltip: 'Save (⌘S)',
        icon: const Icon(Icons.save_outlined),
        onPressed: isDirty ? () => saveDocument(context, doc) : null,
      ),
    );
  }
}

/// The formatting button groups for the active document.
///
/// Rebuilds on every selection/text change (via [ValueListenableBuilder]) so
/// active formats stay highlighted. Wrapped in [ExcludeFocus] so tapping a
/// button does not steal focus from the editor — the text selection survives.
class _FormattingBar extends StatelessWidget {
  const _FormattingBar({required this.document});

  final DocumentModel document;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: document.controller,
      builder: (context, value, _) {
        final active = activeFormats(value);
        return ExcludeFocus(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _button(MarkdownFormat.bold, active),
              _button(MarkdownFormat.italic, active),
              _button(MarkdownFormat.strikethrough, active),
              _button(MarkdownFormat.underline, active),
              const _GroupDivider(),
              _button(MarkdownFormat.list, active),
              _button(MarkdownFormat.checkbox, active),
              const _GroupDivider(),
              _button(MarkdownFormat.link, active),
            ],
          ),
        );
      },
    );
  }

  Widget _button(MarkdownFormat format, Set<MarkdownFormat> active) {
    return _FormatButton(
      format: format,
      isActive: active.contains(format),
      onPressed: () {
        document.controller.value =
            applyFormat(document.controller.value, format);
        // Return focus to the editor so the caret/selection stays visible.
        document.focusNode.requestFocus();
      },
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.format,
    required this.isActive,
    required this.onPressed,
  });

  final MarkdownFormat format;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: _tooltip(format),
      isSelected: isActive,
      iconSize: 20,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(_icon(format)),
      style: IconButton.styleFrom(
        backgroundColor: isActive ? scheme.primaryContainer : null,
        foregroundColor:
            isActive ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: VerticalDivider(
        width: 1,
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

IconData _icon(MarkdownFormat format) => switch (format) {
      MarkdownFormat.bold => Icons.format_bold,
      MarkdownFormat.italic => Icons.format_italic,
      MarkdownFormat.strikethrough => Icons.format_strikethrough,
      MarkdownFormat.underline => Icons.format_underlined,
      MarkdownFormat.list => Icons.format_list_bulleted,
      MarkdownFormat.checkbox => Icons.checklist,
      MarkdownFormat.link => Icons.link,
    };

String _tooltip(MarkdownFormat format) => switch (format) {
      MarkdownFormat.bold => 'Bold',
      MarkdownFormat.italic => 'Italic',
      MarkdownFormat.strikethrough => 'Strikethrough',
      MarkdownFormat.underline => 'Underline',
      MarkdownFormat.list => 'Bulleted list',
      MarkdownFormat.checkbox => 'Checkbox',
      MarkdownFormat.link => 'Link',
    };
