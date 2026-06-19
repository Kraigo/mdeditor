import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.delegate = self

    // Channel for delivering files opened via Finder / "Open With".
    let channel = FlutterMethodChannel(
      name: "mdeditor/files",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    if let appDelegate = NSApp.delegate as? AppDelegate {
      appDelegate.fileChannel = channel
      channel.setMethodCallHandler { (call, result) in
        if call.method == "drainPendingFiles" {
          let files = appDelegate.pendingFiles
          appDelegate.pendingFiles.removeAll()
          result(files)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

extension MainFlutterWindow: NSWindowDelegate {
  // Route the window's close button through app termination so a cancelled
  // quit (unsaved changes) leaves the window open instead of closing it early.
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    NSApp.terminate(nil)
    return false
  }
}
