import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../stats/document_stats.dart';
import '../state/editor_state.dart';

/// Slim bottom bar showing live counts for the active document.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final doc = context.watch<EditorState>().activeDocument;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      alignment: Alignment.centerRight,
      child: doc == null
          ? const SizedBox.shrink()
          : ValueListenableBuilder<TextEditingValue>(
              valueListenable: doc.controller,
              builder: (context, value, _) {
                final stats = computeStats(value.text);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatItem(label: 'Lines', value: '${stats.lines}'),
                    _StatItem(label: 'Words', value: '${stats.words}'),
                    _StatItem(label: 'Characters', value: '${stats.characters}'),
                    _StatItem(
                      label: 'Tokens',
                      value: '~${stats.tokens}',
                      tooltip: 'Approximate (~4 characters per token)',
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.tooltip});

  final String label;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final text = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
    return tooltip == null ? text : Tooltip(message: tooltip!, child: text);
  }
}
