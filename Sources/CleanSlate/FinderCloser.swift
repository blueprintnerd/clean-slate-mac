import Foundation

enum FinderCloser {
    /// Closes every open Finder window without quitting Finder itself
    /// (Finder is always running in the background on macOS).
    @discardableResult
    static func closeAllWindows() -> Bool {
        let script = "tell application \"Finder\" to close every window"
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
        return error == nil
    }
}
