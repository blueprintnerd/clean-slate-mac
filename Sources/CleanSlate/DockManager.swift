import Foundation

enum DockManagerError: Error, LocalizedError {
    case processFailed(String)

    var errorDescription: String? {
        switch self {
        case .processFailed(let detail):
            return "Command failed: \(detail)"
        }
    }
}

enum DockManager {
    private static func backupDirectory() -> URL {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CleanSlate", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static var backupURL: URL {
        backupDirectory().appendingPathComponent("dock-backup.plist")
    }

    static var hasBackup: Bool {
        FileManager.default.fileExists(atPath: backupURL.path)
    }

    @discardableResult
    private static func run(_ launchPath: String, _ arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
            let errText = String(data: errData, encoding: .utf8) ?? "unknown error"
            throw DockManagerError.processFailed(errText)
        }
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// Exports the entire com.apple.dock preferences domain so pinned apps,
    /// Dock size/position, and other settings can be restored later.
    static func backupCurrentDock() throws {
        try run("/usr/bin/defaults", ["export", "com.apple.dock", backupURL.path])
    }

    /// Removes every pinned (persistent) app icon from the Dock and restarts
    /// the Dock process so the change takes effect immediately. Running-but-
    /// unpinned apps disappear from the Dock automatically once quit.
    static func clearPinnedApps() throws {
        try run("/usr/bin/defaults", ["write", "com.apple.dock", "persistent-apps", "-array"])
        try run("/usr/bin/killall", ["Dock"])
    }

    /// Restores the Dock to whatever was captured by the last `backupCurrentDock()`.
    static func restoreBackup() throws {
        guard hasBackup else {
            throw DockManagerError.processFailed("No backup found.")
        }
        try run("/usr/bin/defaults", ["import", "com.apple.dock", backupURL.path])
        try run("/usr/bin/killall", ["Dock"])
    }
}
