import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// File paths requested by macOS (double-click / "Open With") before the
  /// Flutter channel was ready. Drained by Dart via "drainPendingFiles".
  var pendingFiles: [String] = []

  /// Set by `MainFlutterWindow` once the Flutter engine is up.
  var fileChannel: FlutterMethodChannel?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
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
