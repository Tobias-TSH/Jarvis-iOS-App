import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
            
            VoiceControlView()
                .tabItem {
                    Label("Voice", systemImage: "mic.fill")
                }
            
            NodeControlView()
                .tabItem {
                    Label("Nodes", systemImage: "laptopcomputer")
                }
        }
        .accentColor(.cyan)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}