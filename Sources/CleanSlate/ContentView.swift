import SwiftUI

struct ContentView: View {
    @State private var log: [String] = []
    @State private var isRunning = false
    @State private var showConfirm = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Clean Slate")
                    .font(.title2).bold()
                Text("Quits every open app, clearing its Dock icon (if unpinned) and its \"currently open\" indicator dot. Pinned Dock icons are left exactly where they are.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button(role: .destructive) {
                showConfirm = true
            } label: {
                Label("Quit All Apps", systemImage: "xmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(isRunning)

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
        .alert("Quit all open apps?", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Continue", role: .destructive) { runCleanSlate() }
        } message: {
            Text("Every open app (except Finder) will be asked to quit — apps with unsaved work may prompt you first. Pinned Dock icons are not affected.")
        }
    }

    private func runCleanSlate() {
        isRunning = true
        errorMessage = nil
        log.append("── Starting ──")

        Task.detached {
            let quitNames = AppQuitter.quitAllApps()
            await appendLog(quitNames.isEmpty ? "No other apps were running." : "Asked to quit: \(quitNames.joined(separator: ", "))")

            await MainActor.run {
                isRunning = false
                log.append("── Done ──")
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
