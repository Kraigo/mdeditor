import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mdeditor/main.dart';

void main() {
  testWidgets('opens with a single Noname document', (tester) async {
    await tester.pumpWidget(const MdEditorApp());

    expect(find.text('Noname'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('new-document button opens an additional tab', (tester) async {
    await tester.pumpWidget(const MdEditorApp());

    await tester.tap(find.byTooltip('New document'));
    await tester.pumpAndSettle();

    expect(find.text('Noname'), findsOneWidget);
    expect(find.text('Noname 2'), findsOneWidget);
  });

  testWidgets('bold toolbar button wraps the selected text', (tester) async {
    await tester.pumpWidget(const MdEditorApp());

    await tester.enterText(find.byType(TextField), 'hi');
    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 2);
    await tester.pump();

    await tester.tap(find.byTooltip('Bold'));
    await tester.pumpAndSettle();

    expect(controller.text, '**hi**');
  });

  testWidgets('editor keeps focus after a formatting button is tapped',
      (tester) async {
    await tester.pumpWidget(const MdEditorApp());

    final field = find.byType(TextField);
    await tester.tap(field);
    await tester.pump();
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);

    await tester.tap(find.byTooltip('Italic'));
    await tester.pumpAndSettle();

    // Focus returned to the editor rather than being lost to the button.
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
  });

  testWidgets('preview toggle swaps the editor for the rendered view',
      (tester) async {
    await tester.pumpWidget(const MdEditorApp());
    await tester.enterText(find.byType(TextField), '# Title');

    // Switch to preview: the raw editor is gone.
    await tester.tap(find.byTooltip('Preview rendered document'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    // Switch back: the editor returns with its content intact.
    await tester.tap(find.byTooltip('Edit raw Markdown'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '# Title',
    );
  });

  testWidgets('settings popup switches the theme', (tester) async {
    await tester.pumpWidget(const MdEditorApp());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // Choose the Dark theme and confirm the app applies a dark MaterialApp.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
  });

  testWidgets('status bar reflects typed content', (tester) async {
    await tester.pumpWidget(const MdEditorApp());
    await tester.enterText(find.byType(TextField), 'one two');
    await tester.pump();

    expect(find.text('Words: 2'), findsOneWidget);
    expect(find.text('Characters: 7'), findsOneWidget);
  });

  testWidgets('closing a tab removes it while others remain', (tester) async {
    await tester.pumpWidget(const MdEditorApp());

    await tester.tap(find.byTooltip('New document'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    // The active tab (Noname 2) is last in the strip; close it.
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();

    // One document remains (its editor is still shown).
    expect(find.text('Noname 2'), findsNothing);
    expect(find.text('Noname'), findsOneWidget);
  });
}
