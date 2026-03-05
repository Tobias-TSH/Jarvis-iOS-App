import SwiftUI

struct ModelSwitcherView: View {
    @Binding var selectedModel: AIModel
    @State private var showModelSheet = false
    
    var body: some View {
        VStack {
            // Current Model Display
            HStack {
                Text(selectedModel.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showModelSheet.toggle() }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.cyan)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
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
        }
        .sheet(isPresented: $showModelSheet) {
            modelSelectionSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
    
    private var modelSelectionSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Select AI Model")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showModelSheet = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.cyan)
                }
            }
            .padding()
            
            // Model List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(AIModel.allCases, id: \.self) { model in
                        ModelCard(model: model, isSelected: model == selectedModel)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedModel = model
                                    showModelSheet = false
                                    
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.prepare()
                                    generator.impactOccurred()
                                }
                            }
                    }
                }
                .padding()
            }
            
            // Footer
            VStack(spacing: 8) {
                Text("Model Performance")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Speed")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Quality")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            .padding()
        }
        .background(
            // Glassmorphism background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
            )
        )
    }
    
    private func ModelCard(model: AIModel, isSelected: Bool) -> some View {
        HStack(spacing: 12) {
            // Model Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                model.iconGradientStart,
                                model.iconGradientEnd
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: model.iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
            }
            
            // Model Info
            VStack(alignment: .leading, spacing: 4) {
                Text(model.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(model.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Selection Indicator
            if isSelected {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.cyan)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.cyan.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - AI Model Definition

enum AIModel: CaseIterable, Identifiable {
    case devstral
    case opus
    case qwen35B
    case qwen27B
    
    var id: String { rawValue }
    
    var rawValue: String {
        switch self {
        case .devstral: return "devstral"
        case .opus: return "opus"
        case .qwen35B: return "qwen35B"
        case .qwen27B: return "qwen27B"
        }
    }
    
    var displayName: String {
        switch self {
        case .devstral: return "Devstral"
        case .opus: return "Opus 4.6"
        case .qwen35B: return "Qwen 3.5B"
        case .qwen27B: return "Qwen 2.7B"
        }
    }
    
    var description: String {
        switch self {
        case .devstral: return "Fast and efficient"
        case .opus: return "High quality responses"
        case .qwen35B: return "Balanced performance"
        case .qwen27B: return "Lightweight model"
        }
    }
    
    var iconName: String {
        switch self {
        case .devstral: return "bolt.fill"
        case .opus: return "star.fill"
        case .qwen35B: return "cpu.fill"
        case .qwen27B: return "sparkles"
        }
    }
    
    var iconGradientStart: Color {
        switch self {
        case .devstral: return .yellow
        case .opus: return .purple
        case .qwen35B: return .blue
        case .qwen27B: return .green
        }
    }
    
    var iconGradientEnd: Color {
        switch self {
        case .devstral: return .orange
        case .opus: return .pink
        case .qwen35B: return .cyan
        case .qwen27B: return .mint
        }
    }
    
    var speedRating: Int {
        switch self {
        case .devstral: return 5
        case .opus: return 2
        case .qwen35B: return 4
        case .qwen27B: return 3
        }
    }
    
    var qualityRating: Int {
        switch self {
        case .devstral: return 3
        case .opus: return 5
        case .qwen35B: return 4
        case .qwen27B: return 2
        }
    }
}

// MARK: - Preview

struct ModelSwitcherView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                ModelSwitcherView(selectedModel: .constant(.opus))
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}