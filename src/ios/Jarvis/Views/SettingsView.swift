import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingAdvancedSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                // Mode Selection
                Section(header: Text("OPERATION MODE").font(.caption).foregroundColor(.cyan)) {
                    Picker("Mode", selection: $viewModel.selectedMode) {
                        ForEach(OperationMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.black.opacity(0.3))
                }
                .listRowBackground(Color.clear)
                
                // TTS Settings
                Section(header: Text("TEXT-TO-SPEECH").font(.caption).foregroundColor(.cyan)) {
                    Picker("TTS Provider", selection: $viewModel.ttsProvider) {
                        Text("ElevenLabs").tag(TTSProvider.elevenLabs)
                        Text("Local").tag(TTSProvider.local)
                    }
                    
                    if viewModel.ttsProvider == .elevenLabs {
                        TextField("API Key", text: $viewModel.elevenLabsAPIKey)
                            .textContentType(.password)
                            .disableAutocorrection(true)
                    }
                }
                .listRowBackground(Color.black.opacity(0.3))
                
                // STT Settings
                Section(header: Text("SPEECH-TO-TEXT").font(.caption).foregroundColor(.cyan)) {
                    Picker("STT Provider", selection: $viewModel.sttProvider) {
                        Text("Whisper").tag(STTProvider.whisper)
                        Text("Apple").tag(STTProvider.apple)
                    }
                }
                .listRowBackground(Color.black.opacity(0.3))
                
                // Network Settings
                Section(header: Text("NETWORK").font(.caption).foregroundColor(.cyan)) {
                    Toggle("Use Tailscale", isOn: $viewModel.useTailscale)
                        .toggleStyle(SwitchToggleStyle(tint: .cyan))
                    
                    if viewModel.useTailscale {
                        TextField("Tailscale IP", text: $viewModel.tailscaleIP)
                            .keyboardType(.decimalPad)
                            .disableAutocorrection(true)
                    }
                }
                .listRowBackground(Color.black.opacity(0.3))
                
                // Advanced Settings
                if showingAdvancedSettings {
                    advancedSettingsSection
                }
                
                // Actions
                Section {
                    Button(action: { 
                        showingAdvancedSettings.toggle()
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        HStack {
                            Spacer()
                            Text(showingAdvancedSettings ? "Hide Advanced" : "Show Advanced")
                                .foregroundColor(.cyan)
                            Spacer()
                        }
                    }
                    
                    Button(action: { 
                        viewModel.saveSettings()
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Settings")
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.black.opacity(0.3))
            }
            .navigationTitle("Jarvis Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        // Close settings
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.cyan)
                    }
                }
            }
            .background(
                // Futuristic background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.blue.opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
        }
        .navigationViewStyle(.stack)
    }
    
    private var advancedSettingsSection: some View {
        Section(header: Text("ADVANCED").font(.caption).foregroundColor(.red)) {
            Toggle("Enable Debug Logging", isOn: $viewModel.debugLogging)
                .toggleStyle(SwitchToggleStyle(tint: .red))
            
            Stepper("Max Tokens: \(viewModel.maxTokens)", value: $viewModel.maxTokens, in: 50...4000, step: 50)
            
            Picker("Temperature", selection: $viewModel.temperature) {
                Text("Low (0.2)").tag(0.2)
                Text("Medium (0.7)").tag(0.7)
                Text("High (1.0)").tag(1.0)
            }
            
            Toggle("Stream Responses", isOn: $viewModel.streamResponses)
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
        }
        .listRowBackground(Color.black.opacity(0.3))
    }
}

// MARK: - Settings View Model

class SettingsViewModel: ObservableObject {
    @Published var selectedMode: OperationMode = .agent
    @Published var ttsProvider: TTSProvider = .elevenLabs
    @Published var sttProvider: STTProvider = .whisper
    @Published var useTailscale: Bool = false
    @Published var tailscaleIP: String = "100.100.100.100"
    
    @Published var elevenLabsAPIKey: String = ""
    @Published var debugLogging: Bool = false
    @Published var maxTokens: Int = 1000
    @Published var temperature: Double = 0.7
    @Published var streamResponses: Bool = true
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        // Load from UserDefaults or other storage
        if let savedMode = UserDefaults.standard.string(forKey: "selectedMode") {
            selectedMode = OperationMode(rawValue: savedMode) ?? .agent
        }
        
        ttsProvider = TTSProvider(rawValue: UserDefaults.standard.string(forKey: "ttsProvider") ?? "elevenLabs") ?? .elevenLabs
        sttProvider = STTProvider(rawValue: UserDefaults.standard.string(forKey: "sttProvider") ?? "whisper") ?? .whisper
        useTailscale = UserDefaults.standard.bool(forKey: "useTailscale")
        tailscaleIP = UserDefaults.standard.string(forKey: "tailscaleIP") ?? "100.100.100.100"
        elevenLabsAPIKey = UserDefaults.standard.string(forKey: "elevenLabsAPIKey") ?? ""
        debugLogging = UserDefaults.standard.bool(forKey: "debugLogging")
        maxTokens = UserDefaults.standard.integer(forKey: "maxTokens")
        temperature = UserDefaults.standard.double(forKey: "temperature")
        streamResponses = UserDefaults.standard.bool(forKey: "streamResponses")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(selectedMode.rawValue, forKey: "selectedMode")
        UserDefaults.standard.set(ttsProvider.rawValue, forKey: "ttsProvider")
        UserDefaults.standard.set(sttProvider.rawValue, forKey: "sttProvider")
        UserDefaults.standard.set(useTailscale, forKey: "useTailscale")
        UserDefaults.standard.set(tailscaleIP, forKey: "tailscaleIP")
        UserDefaults.standard.set(elevenLabsAPIKey, forKey: "elevenLabsAPIKey")
        UserDefaults.standard.set(debugLogging, forKey: "debugLogging")
        UserDefaults.standard.set(maxTokens, forKey: "maxTokens")
        UserDefaults.standard.set(temperature, forKey: "temperature")
        UserDefaults.standard.set(streamResponses, forKey: "streamResponses")
    }
}

// MARK: - Enums

enum OperationMode: String, CaseIterable, Identifiable {
    case agent = "agent"
    case god = "god"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .agent: return "Agent Mode"
        case .god: return "God Mode"
        }
    }
    
    var description: String {
        switch self {
        case .agent: return "System control and automation"
        case .god: return "Root access and advanced features"
        }
    }
}

enum TTSProvider: String, CaseIterable, Identifiable {
    case elevenLabs = "elevenLabs"
    case local = "local"
    
    var id: String { rawValue }
}

enum STTProvider: String, CaseIterable, Identifiable {
    case whisper = "whisper"
    case apple = "apple"
    
    var id: String { rawValue }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}