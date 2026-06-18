import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_window.dart';
import '../models/document.dart';
import '../services/document_io.dart';
import '../state/editor_state.dart';

/// VS Code–style horizontal strip of document tabs.
///
/// Each tab reveals a close button on hover, shows an italic title while it has
/// unsaved changes, and offers a right-click menu (Save / Rename / Close).
/// Closing the final tab quits the application.
class DocumentTabBar extends StatelessWidget {
  const DocumentTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditorState>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 36,
      color: scheme.surfaceContainerHigh,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.documents.length,
              itemBuilder: (context, i) {
                final doc = state.documents[i];
                return _DocumentTab(
                  key: ValueKey(doc.id),
                  document: doc,
                  selected: i == state.activeIndex,
                  onTap: () => state.setActive(i),
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'New document',
            icon: const Icon(Icons.add, size: 18),
            onPressed: state.newDocument,
          ),
        ],
      ),
    );
  }
}

enum _TabAction { save, rename, close }

class _DocumentTab extends StatefulWidget {
  const _DocumentTab({
    super.key,
    required this.document,
    required this.selected,
    required this.onTap,
  });

  final DocumentModel document;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DocumentTab> createState() => _DocumentTabState();
}

class _DocumentTabState extends State<_DocumentTab> {
  bool _hovered = false;

  void _close() {
    final stillOpen = context.read<EditorState>().closeDocument(widget.document.id);
    if (!stillOpen) closeApp();
  }

  Future<void> _showContextMenu(Offset globalPosition) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final action = await showMenu<_TabAction>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: _TabAction.save,
          child: _MenuItemLabel(label: 'Save', shortcut: '⌘S'),
        ),
        PopupMenuItem(
          value: _TabAction.rename,
          child: _MenuItemLabel(label: 'Rename'),
        ),
        PopupMenuItem(
          value: _TabAction.close,
          child: _MenuItemLabel(label: 'Close'),
        ),
      ],
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _TabAction.save:
        await saveDocument(context, widget.document);
      case _TabAction.rename:
        await renameDocument(context, widget.document);
      case _TabAction.close:
        _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showClose = _hovered || widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapDown: (details) => _showContextMenu(details.globalPosition),
        child: Container(
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: widget.selected ? scheme.surface : scheme.surfaceContainerHigh,
            border: Border(
              right: BorderSide(color: scheme.outlineVariant),
              bottom: BorderSide(
                color: widget.selected ? scheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: widget.document.dirty,
                builder: (context, isDirty, _) => Text(
                  widget.document.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: isDirty ? FontStyle.italic : FontStyle.normal,
                    color: widget.selected
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: showClose ? 1 : 0,
                duration: const Duration(milliseconds: 100),
                child: InkWell(
                  onTap: _close,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 14, color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A context-menu row with the label on the left and an optional keyboard
/// shortcut hint on the right, styled like a native macOS menu.
class _MenuItemLabel extends StatelessWidget {
  const _MenuItemLabel({required this.label, this.shortcut});

  final String label;
  final String? shortcut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        if (shortcut != null) ...[
          const SizedBox(width: 32),
          const Spacer(),
          Text(
            shortcut!,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
