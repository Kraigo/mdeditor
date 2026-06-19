import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_state.dart';

/// Opens the settings popup.
Future<void> showSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const SettingsDialog(),
  );
}

/// Settings popup, organized into sections. Currently: Appearance → Theme.
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();

    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Appearance'),
            const SizedBox(height: 12),
            const Text('Theme'),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System'),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) =>
                  context.read<SettingsState>().setThemeMode(selection.first),
            ),
            const SizedBox(height: 24),
            _SectionHeader('Editor'),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 64, child: Text('Font')),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: settings.fontFamily,
                    items: [
                      for (final family in kFontFamilies)
                        DropdownMenuItem(
                          value: family,
                          child: Text(family, style: TextStyle(fontFamily: family)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsState>().setFontFamily(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 64, child: Text('Size')),
                Expanded(
                  child: Slider(
                    min: kMinFontSize,
                    max: kMaxFontSize,
                    divisions: (kMaxFontSize - kMinFontSize).round(),
                    value: settings.fontSize,
                    label: '${settings.fontSize.round()}',
                    onChanged: (value) =>
                        context.read<SettingsState>().setFontSize(value),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${settings.fontSize.round()}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.8,
          ),
    );
  }
}
