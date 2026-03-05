import SwiftUI

struct NodeControlView: View {
    @State private var selectedNode = "Main-PC-TSH"
    @State private var cameraActive = false
    @State private var microphoneActive = false
    @State private var locationActive = false
    
    let nodes = ["Main-PC-TSH", "MacBook-Pro", "iPhone-15", "Raspberry-Pi"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Node-Auswahl
            Picker("Select Node", selection: $selectedNode) {
                ForEach(nodes, id: \.self) { node in
                    Text(node).tag(node)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Statusanzeige
            Text("Controlling: **\(selectedNode)**")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            // Steuerungselemente
            VStack(spacing: 16) {
                ControlButton(
                    icon: "camera.fill",
                    label: "Camera",
                    color: .red,
                    isActive: cameraActive
                ) {
                    cameraActive.toggle()
                }
                
                ControlButton(
                    icon: "mic.fill",
                    label: "Microphone",
                    color: .green,
                    isActive: microphoneActive
                ) {
                    microphoneActive.toggle()
                }
                
                ControlButton(
                    icon: "location.fill",
                    label: "Location",
                    color: .blue,
                    isActive: locationActive
                ) {
                    locationActive.toggle()
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Node-Status
            VStack(alignment: .leading, spacing: 8) {
                Text("Node Status:")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Camera: \(cameraActive ? "Active" : "Inactive")")
                        .foregroundColor(cameraActive ? .red : .gray)
                    Text("• Microphone: \(microphoneActive ? "Active" : "Inactive")")
                        .foregroundColor(microphoneActive ? .green : .gray)
                    Text("• Location: \(locationActive ? "Active" : "Inactive")")
                        .foregroundColor(locationActive ? .blue : .gray)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Node Control")
    }
}

struct ControlButton: View {
    let icon: String
    let label: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isActive ? color : Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isActive ? .white : color)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NodeControlView_Previews: PreviewProvider {
    static var previews: some View {
        NodeControlView()
    }
}