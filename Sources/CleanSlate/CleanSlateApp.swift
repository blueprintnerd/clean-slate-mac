import SwiftUI

@main
struct CleanSlateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 460, minHeight: 420)
        }
        .windowResizability(.contentSize)
    }
}
