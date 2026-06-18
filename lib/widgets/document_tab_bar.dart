import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_window.dart';
import '../models/document.dart';
import '../state/editor_state.dart';

/// VS Code–style horizontal strip of document tabs.
///
/// Each tab reveals a close button on hover; closing the final tab quits the
/// application.
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
                  onClose: () => _close(context, doc),
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

  void _close(BuildContext context, DocumentModel doc) {
    final stillOpen = context.read<EditorState>().closeDocument(doc.id);
    if (!stillOpen) closeApp();
  }
}

class _DocumentTab extends StatefulWidget {
  const _DocumentTab({
    super.key,
    required this.document,
    required this.selected,
    required this.onTap,
    required this.onClose,
  });

  final DocumentModel document;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  State<_DocumentTab> createState() => _DocumentTabState();
}

class _DocumentTabState extends State<_DocumentTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showClose = _hovered || widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
              Text(
                widget.document.title,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.selected
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: showClose ? 1 : 0,
                duration: const Duration(milliseconds: 100),
                child: InkWell(
                  onTap: widget.onClose,
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
