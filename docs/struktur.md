# Jarvis-iOS-App - Projektstruktur

## Übersicht

Die App folgt einer modernen SwiftUI-Architektur mit klarer Trennung von Views, Networking, Services und State Management.

## Ordnerstruktur

```
src/ios/Jarvis/
├── Core/              # Kernlogik und State Management
│   └── JarvisViewModel.swift
├── Network/           # Netzwerkkommunikation
│   └── WebSocketManager.swift
├── Views/             # Benutzeroberfläche
│   ├── ChatView.swift
│   ├── VoiceControlView.swift
│   ├── NodeControlView.swift
│   └── ContentView.swift
├── Models/            # Datenmodelle
│   └── ChatMessage.swift
└── Services/          # Dienstleistungen
    └── AudioService.swift
```

## Hauptkomponenten

### 1. Views (SwiftUI)
- **ContentView**: Haupt-Tab-Navigation
- **ChatView**: Chat-Interface mit Nachrichtenverlauf
- **VoiceControlView**: Sprachsteuerung mit STT/TTS
- **NodeControlView**: Node-Steuerungsoberfläche

### 2. Network
- **WebSocketManager**: Echtzeit-Kommunikation mit OpenClaw Gateway
  - Heartbeat-Mechanismus
  - JSON-Nachrichten-Handling
  - Command- und Node-Control-Nachrichten

### 3. Models
- **ChatMessage**: Struktur für Chat-Nachrichten
- **NodeStatus**: Node-Informationen
- **CommandResponse**: Antwortformat für Befehle

### 4. Services
- **AudioService**: Sprachverarbeitung
  - Speech-to-Text (SFSpeechRecognizer)
  - Text-to-Speech (AVSpeechSynthesizer)
  - Audio-Session-Management

### 5. Core
- **JarvisViewModel**: Zentrales State Management
  - Kombiniert alle Services
  - Verwaltet Application State
  - Handhabt Nachrichtenfluss

## Technische Highlights

### WebSocket-Kommunikation
- URLSessionWebSocketTask für native WebSocket-Unterstützung
- Heartbeat alle 30 Sekunden
- JSON-basiertes Nachrichtenformat
- Command- und Node-Control-Protokoll

### Sprachverarbeitung
- SFSpeechRecognizer für STT
- AVSpeechSynthesizer für TTS
- Echtzeit-Audio-Processing
- Sprachauswahl-Unterstützung

### State Management
- Combine Framework für reaktive Programmierung
- ObservableObject für View-Updates
- Klare Trennung von UI und Business Logic

## Nächste Schritte

Für die Hardcore-Aufgaben:
1. **Metal Shader**: Custom Rendering für AR-Overlays
2. **MDM Integration**: Mobile Device Management
3. **Sideloading**: App-Verteilung ohne App Store
4. **SSH Integration**: Sichere Node-Kommunikation

Die Basis-Struktur ist jetzt komplett und bereit für die erweiterten Funktionen!