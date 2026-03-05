import Foundation
import Combine

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var timer: Timer?
    
    @Published var isConnected = false
    @Published var lastMessage: String?
    
    private let serverURL: URL
    
    init(serverURL: URL) {
        self.serverURL = serverURL
    }
    
    func connect() {
        guard webSocketTask == nil else { return }
        
        let session = URLSession(configuration: .default)
        self.urlSession = session
        
        let task = session.webSocketTask(with: serverURL)
        self.webSocketTask = task
        
        task.resume()
        isConnected = true
        
        startHeartbeat()
        listenForMessages()
    }
    
    func disconnect() {
        timer?.invalidate()
        timer = nil
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        
        isConnected = false
    }
    
    func sendMessage(_ message: String) {
        guard isConnected, let task = webSocketTask else { return }
        
        let messageData = URLSessionWebSocketTask.Message.string(message)
        task.send(messageData) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    private func listenForMessages() {
        guard let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.lastMessage = text
                    }
                    print("Received message: \(text)")
                case .data(let data):
                    print("Received data: \(data.count) bytes")
                @unknown default:
                    break
                }
                self?.listenForMessages()
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.isConnected = false
            }
        }
    }
    
    private func startHeartbeat() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self, self.isConnected else { return }
            self.sendMessage("{\"type\":\"heartbeat\"}")
        }
    }
}

// MARK: - Message Handling

extension WebSocketManager {
    func sendCommand(_ command: String, parameters: [String: Any]? = nil) {
        var message: [String: Any] = [
            "type": "command",
            "command": command,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let parameters = parameters {
            message["parameters"] = parameters
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: message),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sendMessage(jsonString)
        }
    }
    
    func sendNodeControl(nodeId: String, action: String, parameters: [String: Any]? = nil) {
        var message: [String: Any] = [
            "type": "node_control",
            "nodeId": nodeId,
            "action": action,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let parameters = parameters {
            message["parameters"] = parameters
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: message),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sendMessage(jsonString)
        }
    }
}