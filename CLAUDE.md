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
  so cursor/undo survive tab switches), a `preview` flag, and a `dirty` `ValueNotifier` (content vs.
  last-saved). It must be `dispose()`d when its tab closes — `EditorState.closeDocument` does this.
- **Save / rename** live on `EditorState` (`save`, `rename`) as UI-free methods that take injected
  `promptPath` / `writeFile` / `moveFile` callbacks, so they unit-test without dialogs or `dart:io`. The
  UI wiring (native save panel + `File` writes, plus the close-confirmation dialog) is in
  [`lib/services/document_io.dart`](lib/services/document_io.dart) — prefer routing close/save/rename
  through its top-level helpers. The Save button and italic tab title listen to `DocumentModel.dirty`; ⌘S
  is bound via `CallbackShortcuts` in the editor screen. Closing a dirty tab prompts Save/Don’t Save/Cancel.
- **`openFile`** replaces the lone pristine startup "Noname" tab (`DocumentModel.isPristine`) instead of
  leaving an empty tab around; a "Noname" is only created at startup.
- **Settings** ([`SettingsState`](lib/state/settings_state.dart)) holds theme mode + editor font
  family/size, persisted via `shared_preferences` (`load()` on startup in `main`, written on each setter).
  It is constructed and loaded before `runApp` and passed into `MdEditorApp`; tests pass nothing and rely
  on `SharedPreferences.setMockInitialValues`. The raw editor reads font family/size from it.
- **Formatting** lives in [`lib/formatting/markdown_format.dart`](lib/formatting/markdown_format.dart) as
  **pure functions** on `TextEditingValue` (`applyFormat`, `activeFormats`) — no widget dependencies, so it
  is unit-tested directly. The toolbar wraps its buttons in `ExcludeFocus` so tapping them does not steal
  focus from the editor (otherwise the text selection collapses before the format is applied).
- **Preview** uses `flutter_markdown_plus` with the GitHub-flavored extension set (renders strikethrough
  and `- [ ]` task lists). Underline is emitted as HTML `<u>…</u>` (Markdown has no native underline) and
  therefore does **not** render in preview — a known limitation.
- Closing the last tab calls `closeApp()` in [`lib/app_window.dart`](lib/app_window.dart)
  (`SystemNavigator.pop()`).

**macOS sandbox:** reading/writing user-picked files requires
`com.apple.security.files.user-selected.read-write` in both `macos/Runner/DebugProfile.entitlements` and
`Release.entitlements`. Other desktop platforms (windows/linux) are scaffolded but their file
entitlement/permission story is untested.

**macOS file association (Open With / default app):** declared via `CFBundleDocumentTypes` (markdown UTI
`net.daringfireball.markdown` + `md`/`markdown` extensions) in `macos/Runner/Info.plist`. When macOS opens
a file, `AppDelegate.application(_:open:)` forwards the paths over the `mdeditor/files` `MethodChannel`
(buffering until the engine is ready; Dart drains via `drainPendingFiles`). The Dart side is
[`lib/services/open_file_channel.dart`](lib/services/open_file_channel.dart), wired up in `EditorScreen`'s
`initState` only on macOS. This path can't be exercised by `flutter test` — verify by launching the built
`.app` from Finder.

**macOS quit confirmation:** `AppDelegate.applicationShouldTerminate` (red button / ⌘Q) calls Flutter's
`confirmQuit` over the same channel; the Dart handler prompts when any document is dirty and replies
whether to quit. `MainFlutterWindow.windowShouldClose` routes the close button through `NSApp.terminate`
so a cancelled quit leaves the window open. Dialogs are shown via the global `navigatorKey`
([`lib/app_navigator.dart`](lib/app_navigator.dart)). Also native-only — verify by quitting with unsaved
changes.

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
