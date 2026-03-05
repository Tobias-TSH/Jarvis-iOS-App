import SwiftUI

struct VoiceControlView: View {
    @State private var isListening = false
    @State private var transcript = ""
    @State private var lastCommand = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Statusanzeige
            Text(isListening ? "LISTENING..." : "VOICE CONTROL")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isListening ? .green : .white)
                .tracking(2)
            
            // Mikrofon-Button
            Button(action: toggleListening) {
                ZStack {
                    Circle()
                        .fill(isListening ? Color.green : Color.cyan)
                        .frame(width: 150, height: 150)
                        .shadow(radius: 10)
                    
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Transkript
            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(transcript)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            // Letzter Befehl
            if !lastCommand.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Command:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(lastCommand)
                        .font(.body)
                        .foregroundColor(.cyan)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Voice Control")
    }
    
    private func toggleListening() {
        isListening.toggle()
        
        if isListening {
            transcript = ""
            lastCommand = ""
            
            // Simulierte Spracherkennung
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                transcript = "TSH, activate node camera and check surroundings"
                lastCommand = "activate node camera"
                isListening = false
            }
        }
    }
}

struct VoiceControlView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceControlView()
    }
}