import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

struct NodeStatus: Codable {
    let nodeId: String
    let isOnline: Bool
    let capabilities: [String]
    let lastSeen: Date?
}

struct CommandResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: Any]?
}