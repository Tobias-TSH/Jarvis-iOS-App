import SwiftUI

struct CommandBarView: View {
    @StateObject private var viewModel = CommandBarViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @State private var showSuggestions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Command Input
            HStack(spacing: 8) {
                Text("/")
                    .foregroundColor(.cyan)
                    .font(.system(.title3, design: .monospaced))
                
                TextField("Type a command...", text: $viewModel.inputText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(.plain)
                    .onChange(of: viewModel.inputText) { newValue in
                        viewModel.updateSuggestions(for: newValue)
                        showSuggestions = !newValue.isEmpty
                    }
                    .onSubmit {
                        viewModel.executeCommand()
                        isTextFieldFocused = false
                    }
                
                if !viewModel.inputText.isEmpty {
                    Button(action: { 
                        viewModel.inputText = ""
                        showSuggestions = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        // Glassmorphism effect
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 5)
                    )
            )
            .padding(.horizontal)
            
            // Suggestions Dropdown
            if showSuggestions && !viewModel.suggestions.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.suggestions, id: \.self) { suggestion in
                            Button(action: { 
                                viewModel.selectSuggestion(suggestion)
                                showSuggestions = false
                                isTextFieldFocused = true
                            }) {
                                HStack {
                                    Image(systemName: suggestion.icon)
                                        .foregroundColor(.cyan)
                                        .frame(width: 24)
                                    
                                    Text(suggestion.command)
                                        .foregroundColor(.white)
                                        .font(.system(.body, design: .monospaced))
                                    
                                    Spacer()
                                    
                                    Text(suggestion.description)
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if suggestion != viewModel.suggestions.last {
                                Divider()
                                    .background(Color.cyan.opacity(0.2))
                                    .padding(.leading, 34)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.02)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .blur(radius: 3)
                        )
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
        .onTapGesture {
            isTextFieldFocused = true
        }
    }
}

// MARK: - Command Bar View Model

class CommandBarViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var suggestions: [CommandSuggestion] = []
    
    private let allCommands: [CommandSuggestion] = [
        CommandSuggestion(command: "/status", description: "Show system status", icon: "info.circle"),
        CommandSuggestion(command: "/model", description: "Switch AI model", icon: "cpu"),
        CommandSuggestion(command: "/new", description: "Start new conversation", icon: "plus.circle"),
        CommandSuggestion(command: "/reasoning", description: "Toggle reasoning mode", icon: "brain.head.profile"),
        CommandSuggestion(command: "/settings", description: "Open settings", icon: "gearshape"),
        CommandSuggestion(command: "/terminal", description: "Open terminal", icon: "terminal"),
        CommandSuggestion(command: "/help", description: "Show help", icon: "questionmark.circle"),
        CommandSuggestion(command: "/clear", description: "Clear conversation", icon: "trash"),
        CommandSuggestion(command: "/mode", description: "Switch operation mode", icon: "switch.2"),
        CommandSuggestion(command: "/voice", description: "Voice control", icon: "mic")
    ]
    
    func updateSuggestions(for input: String) {
        if input.isEmpty {
            suggestions = []
        } else {
            suggestions = allCommands.filter { 
                $0.command.lowercased().contains(input.lowercased()) ||
                $0.description.lowercased().contains(input.lowercased())
            }
        }
    }
    
    func selectSuggestion(_ suggestion: CommandSuggestion) {
        inputText = suggestion.command
        executeCommand()
    }
    
    func executeCommand() {
        guard !inputText.isEmpty else { return }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        // Handle command execution
        print("Executing command: \(inputText)")
        
        // Reset input
        inputText = ""
    }
}

// MARK: - Command Suggestion Model

struct CommandSuggestion: Hashable {
    let command: String
    let description: String
    let icon: String
    
    static func == (lhs: CommandSuggestion, rhs: CommandSuggestion) -> Bool {
        return lhs.command == rhs.command
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(command)
    }
}

// MARK: - Preview

struct CommandBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                CommandBarView()
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }
}