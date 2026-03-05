import Foundation
import Network

// MARK: - SSH Client Protocol

protocol SSHClientProtocol {
    func connect(host: String, port: UInt16, username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func disconnect()
    func executeCommand(_ command: String, completion: @escaping (Result<String, Error>) -> Void)
    func startShell(completion: @escaping (Result<Bool, Error>) -> Void)
    func sendInput(_ input: String, completion: @escaping (Result<Bool, Error>) -> Void)
}

// MARK: - SSH Client Implementation

class SSHClient: SSHClientProtocol {
    private var connection: NWConnection?
    private var isConnected = false
    private var currentCommand: String?
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    init() {
        feedbackGenerator.prepare()
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Connection Management
    
    func connect(host: String, port: UInt16 = 22, username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: .tcp)
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.isConnected = true
                self?.feedbackGenerator.impactOccurred()
                completion(.success(true))
                self?.authenticate(username: username, password: password, connection: connection)
            case .failed(let error):
                self?.isConnected = false
                completion(.failure(error))
            case .cancelled:
                self?.isConnected = false
                completion(.failure(SSHError.connectionCancelled))
            default:
                break
            }
        }
        
        connection.start(queue: .global())
        self.connection = connection
    }
    
    private func authenticate(username: String, password: String, connection: NWConnection) {
        // Simplified SSH authentication - in real implementation use proper SSH protocol
        let authData = "\(username):\(password)".data(using: .utf8)!
        connection.send(content: authData, completion: .contentProcessed({ error in
            if let error = error {
                print("Authentication error: \(error)")
            }
        }))
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
    }
    
    // MARK: - Command Execution
    
    func executeCommand(_ command: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard isConnected, let connection = connection else {
            completion(.failure(SSHError.notConnected))
            return
        }
        
        currentCommand = command
        let commandData = "\(command)\n".data(using: .utf8)!
        
        connection.send(content: commandData, completion: .contentProcessed({ [weak self] error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            self?.receiveResponse(completion: completion)
        }))
    }
    
    private func receiveResponse(completion: @escaping (Result<String, Error>) -> Void) {
        guard let connection = connection else {
            completion(.failure(SSHError.notConnected))
            return
        }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data, let response = String(data: data, encoding: .utf8) {
                completion(.success(response))
                self?.feedbackGenerator.impactOccurred()
            } else {
                completion(.failure(SSHError.noResponse))
            }
        }
    }
    
    // MARK: - Interactive Shell
    
    func startShell(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard isConnected, let connection = connection else {
            completion(.failure(SSHError.notConnected))
            return
        }
        
        // Start interactive shell session
        let shellData = "shell\n".data(using: .utf8)!
        connection.send(content: shellData, completion: .contentProcessed({ error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }))
    }
    
    func sendInput(_ input: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard isConnected, let connection = connection else {
            completion(.failure(SSHError.notConnected))
            return
        }
        
        let inputData = "\(input)\n".data(using: .utf8)!
        connection.send(content: inputData, completion: .contentProcessed({ error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }))
    }
}

// MARK: - Error Handling

enum SSHError: Error {
    case notConnected
    case connectionCancelled
    case authenticationFailed
    case noResponse
    case commandFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .notConnected:
            return "Not connected to SSH server"
        case .connectionCancelled:
            return "Connection was cancelled"
        case .authenticationFailed:
            return "Authentication failed"
        case .noResponse:
            return "No response from server"
        case .commandFailed(let command):
            return "Command failed: \(command)"
        }
    }
}

// MARK: - SSH Session Manager

class SSHSessionManager {
    static let shared = SSHSessionManager()
    
    private var activeSessions: [String: SSHClient] = [:]
    
    private init() {}
    
    func createSession(host: String, port: UInt16, username: String, password: String, completion: @escaping (Result<SSHClient, Error>) -> Void) {
        let client = SSHClient()
        client.connect(host: host, port: port, username: username, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.activeSessions[host] = client
                completion(.success(client))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getSession(host: String) -> SSHClient? {
        return activeSessions[host]
    }
    
    func closeSession(host: String) {
        activeSessions[host]?.disconnect()
        activeSessions.removeValue(forKey: host)
    }
    
    func closeAllSessions() {
        activeSessions.values.forEach { $0.disconnect() }
        activeSessions.removeAll()
    }
}