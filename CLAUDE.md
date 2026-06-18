# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app is

A minimalistic **desktop** Markdown editor built with **Flutter Material Design**, with `provider` for
state. Requirements live in `docs/requirements.md` / `docs/description.md`. The core flows from the spec
are all implemented: VS Code–style tabs (empty "Noname" doc on launch, hover-to-close, closing the last
tab quits the app), a formatting toolbar, a raw ⇄ rendered toggle, and opening `.md` files via the native
picker.

**Vertical layout, top to bottom:** (1) the topmost navbar — open-file icon at far left, formatting button
groups in the middle, raw/rendered toggle at far right; (2) the VS Code–style tab strip; (3) the document
editor / rendered view.

## Architecture

State is a single [`EditorState`](lib/state/editor_state.dart) (`ChangeNotifier`) provided at the root in
[`main.dart`](lib/main.dart). It owns the list of [`DocumentModel`](lib/models/document.dart) tabs and the
active index; widgets read it with `context.watch`/`context.read`.

- **`DocumentModel`** owns a `TextEditingController` per tab (the source of truth for that document's text,
  so cursor/undo survive tab switches) plus a `preview` flag. It must be `dispose()`d when its tab closes —
  `EditorState.closeDocument` does this.
- **Formatting** lives in [`lib/formatting/markdown_format.dart`](lib/formatting/markdown_format.dart) as
  **pure functions** on `TextEditingValue` (`applyFormat`, `activeFormats`) — no widget dependencies, so it
  is unit-tested directly. The toolbar wraps its buttons in `ExcludeFocus` so tapping them does not steal
  focus from the editor (otherwise the text selection collapses before the format is applied).
- **Preview** uses `flutter_markdown_plus` with the GitHub-flavored extension set (renders strikethrough
  and `- [ ]` task lists). Underline is emitted as HTML `<u>…</u>` (Markdown has no native underline) and
  therefore does **not** render in preview — a known limitation.
- Closing the last tab calls `closeApp()` in [`lib/app_window.dart`](lib/app_window.dart)
  (`SystemNavigator.pop()`).

**macOS sandbox:** reading user-picked files requires `com.apple.security.files.user-selected.read-only`
in both `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`. Other desktop platforms
(windows/linux) are scaffolded but their file-open entitlement/permission story is untested.

## Testing notes

- `test/markdown_format_test.dart` and `test/editor_state_test.dart` cover the pure logic — prefer adding
  cases here over widget tests when the behavior isn't UI-specific.
- Widget tests run in a narrow viewport; keep an eye on toolbar overflow.

## Commands

```bash
flutter pub get                 # install dependencies (run after editing pubspec.yaml)
flutter run -d macos            # run the desktop app (also: -d windows, -d linux)
flutter run -d chrome           # run in browser

flutter test                    # run all tests
flutter test test/widget_test.dart            # run a single test file
flutter test --name "substring of test name"  # run a single test by name

flutter analyze                 # static analysis / lint (config in analysis_options.yaml)
dart format .                   # format code
```

Targets `flutter_lints` (see `analysis_options.yaml`) and Dart SDK `^3.10.9`.
