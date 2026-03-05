import Foundation
import Combine

class JarvisViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var messages: [ChatMessage] = []
    @Published var nodes: [NodeStatus] = []
    @Published var currentNode: String?
    
    private var webSocketManager: WebSocketManager
    private var audioService: AudioService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with default server URL (will be configured later)
        let serverURL = URL(string: "ws://localhost:8080/ws")!
        self.webSocketManager = WebSocketManager(serverURL: serverURL)
        self.audioService = AudioService()
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        webSocketManager.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        webSocketManager.$lastMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleIncomingMessage(message)
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        webSocketManager.connect()
    }
    
    func disconnect() {
        webSocketManager.disconnect()
    }
    
    func sendMessage(_ text: String) {
        let message = ChatMessage(text: text, isUser: true)
        messages.append(message)
        webSocketManager.sendMessage(text)
    }
    
    func startListening() {
        audioService.startListening()
    }
    
    func stopListening() {
        audioService.stopListening()
    }
    
    func sendNodeCommand(nodeId: String, action: String) {
        webSocketManager.sendNodeControl(nodeId: nodeId, action: action)
    }
    
    private func handleIncomingMessage(_ message: String) {
        // Parse the message and update the state accordingly
        if let data = message.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            if json["type"] as? String == "chat" {
                if let text = json["text"] as? String {
                    let response = ChatMessage(text: text, isUser: false)
                    messages.append(response)
                }
            } else if json["type"] as? String == "node_status" {
                // Handle node status updates
            }
        }
    }
}

// MARK: - Configuration

extension JarvisViewModel {
    func configure(serverURL: URL) {
        webSocketManager = WebSocketManager(serverURL: serverURL)
        setupSubscriptions()
    }
    
    func setVoicePreferences(language: String, rate: Float, pitch: Float) {
        // Configure audio service preferences
    }
}