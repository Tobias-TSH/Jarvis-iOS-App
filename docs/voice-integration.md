# Voice-Integration - Technische Umsetzung

## 1. Sprach-zu-Text (STT)

### Optionen für iOS:

#### A. Lokale Verarbeitung (CoreML)
```swift
import Speech

let recognizer = SFSpeechRecognizer()
let request = SFSpeechURLRecognitionRequest(url: audioFileURL)

recognizer?.recognitionTask(with: request) { result, error in
    guard let result = result else { return }
    let text = result.bestTranscription.formattedString
    // Sende an Jarvis
}
```

**Vorteile:**
- Keine Internetverbindung nötig
- Schnellere Reaktion
- Datenschutz

**Nachteile:**
- Begrenzte Genauigkeit
- Kein Kontextverständnis

#### B. Cloud-basiert (Google/Anthropic)
```swift
// Über OpenClaw API
let audioData = ... // Aufgenommene Audiodaten
let response = try await OpenClawAPI.transcribe(audio: audioData)
let text = response.text
```

**Vorteile:**
- Höhere Genauigkeit
- Kontextverständnis möglich
- Mehrsprachig

**Nachteile:**
- Internet nötig
- Latenz

### Empfohlene Lösung:
**Hybrid-Ansatz:**
1. Lokale STT für schnelle Befehle
2. Cloud-STT für komplexe Anfragen
3. Automatische Umschaltung

---

## 2. Text-zu-Sprache (TTS)

### Optionen:

#### A. AVSpeechSynthesizer (Lokal)
```swift
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: "Hallo Tobias")
utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
synthesizer.speak(utterance)
```

**Vorteile:**
- Offline verfügbar
- Geringe Latenz

**Nachteile:**
- Roboterhafte Stimme
- Begrenzte Anpassung

#### B. Cloud-TTS (Google/Anthropic)
```swift
let response = try await OpenClawAPI.synthesize(text: "Hallo", voice: "Nova")
let audioData = response.audioData
play(audioData)
```

**Vorteile:**
- Natürliche Stimmen
- Emotionale Betonung
- Mehrsprachig

**Nachteile:**
- Internet nötig
- Kosten

### Empfohlene Lösung:
**Cloud-TTS mit Caching:**
1. Standardmäßig Cloud-TTS nutzen
2. Häufige Phrasen lokal cachen
3. Offline-Fallback

---

## 3. Echtzeit-Kommunikation

### WebSocket-Architektur:
```
[iOS App] ↔ [WebSocket] ↔ [OpenClaw Gateway] ↔ [Jarvis-Coder]
```

**Nachrichtenformat:**
```json
// STT
{
  "type": "voice",
  "subtype": "stt",
  "audio": "base64...",
  "format": "wav",
  "sampleRate": 16000
}

// TTS
{
  "type": "voice",
  "subtype": "tts",
  "text": "Hallo",
  "voice": "Nova",
  "speed": 1.0
}
```

---

## 4. Node-Steuerung (Volle Rechte)

### Technische Umsetzung:

#### A. Berechtigungsmodell:
```swift
// In Info.plist
<key>NSCameraUsageDescription</key>
<string>Jarvis benötigt Kamera für AR-Funktionen</string>
<key>NSMicrophoneUsageDescription</key>
<string>Jarvis benötigt Mikrofon für Sprachsteuerung</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Jarvis benötigt Standort für Navigation</string>
```

#### B. OpenClaw Node-API Integration:
```swift
// Kamera-Steuerung
let response = try await OpenClawAPI.node(command: .camera(
    action: .capture,
    resolution: .high
))

// Mikrofon-Steuerung
let audioStream = try await OpenClawAPI.node(command: .microphone(
    action: .startStream
))

// Standort
let location = try await OpenClawAPI.node(command: .location(
    accuracy: .high
))
```

### Volle Steuerungsrechte:

1. **Kamera:**
   - Foto/Video Aufnahme
   - AR-Session Steuerung
   - Echtzeit-Bildanalyse

2. **Mikrofon:**
   - Audio-Aufnahme
   - Echtzeit-Streaming
   - Rauschunterdrückung

3. **Standort:**
   - GPS-Daten
   - Geofencing
   - Bewegungsanalyse

4. **Gerätefunktionen:**
   - Kontakte lesen/schreiben
   - Kalender verwalten
   - Erinnerungen erstellen

5. **System:**
   - Batteriestatus
   - Netzwerkinformationen
   - Speichernutzung

---

## 5. Sicherheitskonzept

### Authentifizierung:
```swift
// FaceID Integration
import LocalAuthentication

let context = LAContext()
var error: NSError?

if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    context.evaluatePolicy(...) { success, error in
        if success {
            // Authentifizierung erfolgreich
        }
    }
}
```

### Berechtigungsmanagement:
```json
// Berechtigungsprofil
{
  "camera": "allowed",
  "microphone": "allowed",
  "location": "prompt",
  "contacts": "denied",
  "calendar": "allowed"
}
```

---

## 6. Implementierungsplan

### Phase 1: Voice-Integration
1. [ ] AVSpeechSynthesizer implementieren
2. [ ] SFSpeechRecognizer integrieren
3. [ ] WebSocket-Verbindung aufbauen
4. [ ] Hybrid-STT implementieren

### Phase 2: Node-Steuerung
1. [ ] Berechtigungen anfordern
2. [ ] Kamera-Steuerung
3. [ ] Mikrofon-Streaming
4. [ ] Standortdienste
5. [ ] Systeminformationen

### Phase 3: Sicherheit
1. [ ] FaceID-Integration
2. [ ] Berechtigungsmanagement
3. [ ] Verschlüsselte Kommunikation

---

## 7. Offene Fragen

1. Soll Voice-Integration **immer aktiv** sein oder manuell aktiviert?
2. Brauchen wir **Hintergrund-Audio** für TTS?
3. Soll Node-Steuerung **automatisch** oder mit Bestätigung?
4. Welche **Stimme** für TTS (männlich/weiblich/neutral)?

---

**Letzte Aktualisierung:** 05.03.2026 19:48