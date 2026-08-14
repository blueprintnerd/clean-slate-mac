import AppKit
import SwiftUI

/// Finds the hosting NSWindow once it's available and pins it to float above
/// normal windows, including when other apps or full-screen spaces are active.
private struct AlwaysOnTopAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            configure(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(nsView.window)
        }
    }

    private func configure(_ window: NSWindow?) {
        guard let window else { return }
        window.level = .floating
        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.collectionBehavior.insert(.fullScreenAuxiliary)
    }
}

extension View {
    func alwaysOnTop() -> some View {
        background(AlwaysOnTopAccessor())
    }
}
