import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// File paths requested by macOS (double-click / "Open With") before the
  /// Flutter channel was ready. Drained by Dart via "drainPendingFiles".
  var pendingFiles: [String] = []

  /// Set by `MainFlutterWindow` once the Flutter engine is up.
  var fileChannel: FlutterMethodChannel?

  /// Set once Flutter has confirmed quitting, to avoid re-prompting.
  private var confirmedQuit = false

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if confirmedQuit { return .terminateNow }
    guard let channel = fileChannel else { return .terminateNow }

    // Ask Flutter; it prompts when there are unsaved changes.
    channel.invokeMethod("confirmQuit", arguments: nil) { [weak self] result in
      let allow = (result as? Bool) ?? true
      if allow { self?.confirmedQuit = true }
      NSApp.reply(toApplicationShouldTerminate: allow)
    }
    return .terminateLater
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    let paths = urls.filter { $0.isFileURL }.map { $0.path }
    guard !paths.isEmpty else { return }
    if let channel = fileChannel {
      channel.invokeMethod("openFiles", arguments: paths)
    } else {
      pendingFiles.append(contentsOf: paths)
    }
  }
}
