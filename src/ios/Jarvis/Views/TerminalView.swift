import SwiftUI
import Combine

struct TerminalView: View {
    @StateObject private var viewModel = TerminalViewModel()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Terminal Output
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.outputLines.indices, id: \.self) { index in
                            let line = viewModel.outputLines[index]
                            
                            HStack(alignment: .top, spacing: 8) {
                                if line.showsPrompt {
                                    Text("$ ")
                                        .foregroundColor(.cyan)
                                        .font(.system(.body, design: .monospaced))
                                }
                                
                                Text(line.text)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(line.isError ? .red : .white)
                                    .textSelection(.enabled)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 2)
                            .id(index)
                        }
                    }
                    .onChange(of: viewModel.outputLines.count) { _ in
                        if viewModel.autoScroll {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .background(Color.black)
                .onTapGesture {
                    isInputFocused = true
                }
            }
            
            // Input Bar
            HStack(spacing: 0) {
                Text("$ ")
                    .foregroundColor(.cyan)
                    .font(.system(.body, design: .monospaced))
                    .padding(.leading, 12)
                
                TextField("Enter command", text: $inputText, axis: .horizontal)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        submitCommand()
                    }
                    .onChange(of: inputText) { newValue in
                        // Handle input changes
                    }
                
                Button(action: submitCommand) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.cyan)
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 44)
            .background(Color.black.opacity(0.8))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.cyan.opacity(0.3)),
                alignment: .top
            )
        }
        .background(Color.black)
        .navigationTitle("Terminal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputFocused = false
                }
            }
        }
        .onAppear {
            isInputFocused = true
            viewModel.startBlinkingCursor()
        }
        .onDisappear {
            viewModel.stopBlinkingCursor()
        }
    }
    
    private func submitCommand() {
        guard !inputText.isEmpty else { return }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        viewModel.addOutputLine(TerminalLine(text: inputText, showsPrompt: true))
        viewModel.executeCommand(inputText)
        inputText = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastIndex = viewModel.outputLines.indices.last {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastIndex, anchor: .bottom)
            }
        }
    }
}

// MARK: - Terminal Line Model

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let showsPrompt: Bool
    let isError: Bool
    
    init(text: String, showsPrompt: Bool = false, isError: Bool = false) {
        self.text = text
        self.showsPrompt = showsPrompt
        self.isError = isError
    }
}

// MARK: - Terminal View Model

class TerminalViewModel: ObservableObject {
    @Published var outputLines: [TerminalLine] = []
    @Published var autoScroll = true
    @Published var isCursorVisible = true
    
    private var cursorTimer: Timer?
    private let sshClient = SSHSessionManager.shared
    private var currentSession: SSHClient?
    
    init() {
        // Initialize with welcome message
        outputLines.append(TerminalLine(text: "Welcome to Jarvis Terminal", isError: false))
        outputLines.append(TerminalLine(text: "Type 'help' for available commands", isError: false))
        outputLines.append(TerminalLine(text: "", isError: false)) // Empty line
    }
    
    func startBlinkingCursor() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.isCursorVisible.toggle()
        }
    }
    
    func stopBlinkingCursor() {
        cursorTimer?.invalidate()
        cursorTimer = nil
        isCursorVisible = true
    }
    
    func addOutputLine(_ line: TerminalLine) {
        DispatchQueue.main.async { [weak self] in
            self?.outputLines.append(line)
        }
    }
    
    func executeCommand(_ command: String) {
        // Handle local commands
        if command.lowercased() == "clear" {
            outputLines.removeAll()
            outputLines.append(TerminalLine(text: "Terminal cleared", isError: false))
            return
        }
        
        if command.lowercased() == "help" {
            showHelp()
            return
        }
        
        // Handle SSH commands if connected
        if let session = currentSession {
            session.executeCommand(command) { [weak self] result in
                switch result {
                case .success(let output):
                    self?.addOutputLine(TerminalLine(text: output, isError: false))
                case .failure(let error):
                    self?.addOutputLine(TerminalLine(text: error.localizedDescription, isError: true))
                }
            }
        } else {
            addOutputLine(TerminalLine(text: "Not connected to SSH server. Use 'connect' command.", isError: true))
        }
    }
    
    private func showHelp() {
        let helpText = """
Available commands:
- help: Show this help message
- clear: Clear terminal screen
- connect <host> <user> <password>: Connect to SSH server
- disconnect: Disconnect from SSH server
- exit: Close terminal session

When connected to SSH server, you can execute any shell command.
"""
        
        let lines = helpText.components(separatedBy: .newlines)
        for line in lines {
            if !line.isEmpty {
                addOutputLine(TerminalLine(text: line, isError: false))
            }
        }
    }
    
    func connectToSSH(host: String, username: String, password: String) {
        sshClient.createSession(host: host, port: 22, username: username, password: password) { [weak self] result in
            switch result {
            case .success(let client):
                self?.currentSession = client
                self?.addOutputLine(TerminalLine(text: "Connected to \(host)", isError: false))
            case .failure(let error):
                self?.addOutputLine(TerminalLine(text: "Connection failed: \(error.localizedDescription)", isError: true))
            }
        }
    }
    
    func disconnectSSH() {
        if let host = currentSession?.description {
            sshClient.closeSession(host: host)
            currentSession = nil
            addOutputLine(TerminalLine(text: "Disconnected from SSH server", isError: false))
        }
    }
}

// MARK: - Preview

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TerminalView()
                .preferredColorScheme(.dark)
        }
    }
}