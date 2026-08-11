import AppKit

enum AppQuitter {
    // Bundle IDs that should never be closed by this tool.
    static let excludedBundleIDs: Set<String> = [
        Bundle.main.bundleIdentifier ?? "com.local.cleanslate",
        "com.apple.finder",
    ]

    /// Asks every regular, user-facing app (other than the excluded ones) to quit.
    /// Uses `terminate()` rather than a force-kill so apps get a chance to prompt
    /// for unsaved changes. Returns the display names of the apps that were asked to quit.
    static func quitAllApps() -> [String] {
        var quitNames: [String] = []
        for app in NSWorkspace.shared.runningApplications {
            guard app.activationPolicy == .regular else { continue }
            guard let bundleID = app.bundleIdentifier else { continue }
            guard !excludedBundleIDs.contains(bundleID) else { continue }

            let name = app.localizedName ?? bundleID
            if app.terminate() {
                quitNames.append(name)
            } else {
                quitNames.append("\(name) (declined to quit — may have unsaved changes)")
            }
        }
        return quitNames
    }
}
