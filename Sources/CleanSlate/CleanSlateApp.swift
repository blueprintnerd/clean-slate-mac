import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    // Without this, closing the window leaves the process running with no
    // window — and clicking the Dock icon again doesn't reliably reopen one
    // (a known SwiftUI WindowGroup quirk), so the app looks stuck/unresponsive
    // until force-quit. Terminating on close guarantees every click is a
    // fresh launch with a fresh window.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct CleanSlateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 460, minHeight: 420)
                .alwaysOnTop()
        }
        .windowResizability(.contentSize)
    }
}
