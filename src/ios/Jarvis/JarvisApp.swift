import SwiftUI

@main
struct JarvisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Tiefschwarzer OLED-Modus als Standard für futuristischen Look
                .preferredColorScheme(.dark)
        }
    }
}