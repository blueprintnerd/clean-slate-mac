import SwiftUI

struct ContentView: View {
    @State private var log: [String] = []
    @State private var isRunning = false
    @State private var showConfirm = false
    @State private var hasBackup = DockManager.hasBackup
    @State private var showRestoreConfirm = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Clean Slate")
                    .font(.title2).bold()
                Text("Quits every open app and clears every pinned icon from the Dock.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button(role: .destructive) {
                    showConfirm = true
                } label: {
                    Label("Quit All & Clear Dock", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isRunning)

                Button {
                    showRestoreConfirm = true
                } label: {
                    Label("Restore Dock", systemImage: "arrow.uturn.backward")
                }
                .disabled(isRunning || !hasBackup)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Divider()

            Text("Activity")
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(log.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(20)
        .alert("Quit all apps and clear the Dock?", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Continue", role: .destructive) { runCleanSlate() }
        } message: {
            Text("Every open app (except Finder) will be asked to quit — apps with unsaved work may prompt you first. Your current Dock layout will be backed up automatically so you can restore it afterward.")
        }
        .alert("Restore your last Dock backup?", isPresented: $showRestoreConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Restore") { runRestore() }
        } message: {
            Text("This replaces the current Dock with the layout saved before the last clear.")
        }
    }

    private func runCleanSlate() {
        isRunning = true
        errorMessage = nil
        log.append("── Starting ──")

        Task.detached {
            let quitNames = AppQuitter.quitAllApps()
            await appendLog(quitNames.isEmpty ? "No other apps were running." : "Asked to quit: \(quitNames.joined(separator: ", "))")

            do {
                try DockManager.backupCurrentDock()
                await appendLog("Backed up current Dock layout.")

                try DockManager.clearPinnedApps()
                await appendLog("Cleared all pinned Dock icons.")

                await MainActor.run {
                    hasBackup = DockManager.hasBackup
                    isRunning = false
                    log.append("── Done ──")
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isRunning = false
                }
            }
        }
    }

    private func runRestore() {
        isRunning = true
        errorMessage = nil
        Task.detached {
            do {
                try DockManager.restoreBackup()
                await appendLog("Restored Dock from backup.")
                await MainActor.run { isRunning = false }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isRunning = false
                }
            }
        }
    }

    @MainActor
    private func appendLog(_ line: String) {
        log.append(line)
    }
}

#Preview {
    ContentView()
}
