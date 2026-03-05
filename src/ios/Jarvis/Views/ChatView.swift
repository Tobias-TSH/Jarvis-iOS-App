import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Nachrichtenbereich
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Eingabebereich
            HStack {
                TextField("Type a message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.cyan)
                        .clipShape(Circle())
                }
                .padding(.trailing, 8)
            }
            .padding(.bottom, 8)
        }
        .background(Color(.systemGray6))
        .navigationTitle("JARVIS Chat")
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let newMessage = ChatMessage(id: UUID(), text: inputText, isUser: true)
        messages.append(newMessage)
        inputText = ""
        
        // Simulierte Antwort von JARVIS
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = ChatMessage(id: UUID(), text: "Understood, TSH. Executing command.", isUser: false)
            messages.append(response)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}