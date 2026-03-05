# Jarvis iOS App

## Installation mit AltStore

### 1. AltServer auf Windows installieren
1. Lade AltServer von [altstore.io](https://altstore.io) herunter
2. Installiere die Software auf deinem Windows-PC
3. Starte AltServer und melde dich mit deiner Apple-ID an

### 2. AltStore auf iPhone installieren
1. Verbinde dein iPhone mit dem PC über USB
2. Klicke in der Taskleiste auf das AltServer-Symbol
3. Wähle "Install AltStore" und dann dein iPhone aus
4. Folge den Anweisungen auf dem Bildschirm

### 3. Jarvis IPA herunterladen
1. Gehe zu den [GitHub Actions](https://github.com/TSH/Jarvis-iOS-App/actions) dieses Repos
2. Lade die neueste Jarvis.ipa aus den Artefakten herunter

### 4. IPA auf iPhone installieren
1. Öffne AltStore auf deinem iPhone
2. Gehe zu "My Apps" und tippe auf das "+" Symbol
3. Wähle die heruntergeladene Jarvis.ipa Datei aus
4. Warte bis die Installation abgeschlossen ist

## Wichtig
- Die App muss alle 7 Tage neu signiert werden (AltStore-Erinnerung)
- Verwende dieselbe Apple-ID für AltStore und iPhone
- USB-Verbindung für erste Installation erforderlich

## Entwicklung

### Voraussetzungen
- Xcode 15+
- iOS 17.0+ Deployment Target
- Swift 5+

### Projekt öffnen
```bash
cd src/ios/Jarvis
open Jarvis.xcodeproj
```

### Build
```bash
xcodebuild -scheme Jarvis -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Berechtigungen
Die App benötigt folgende Berechtigungen:
- Mikrofon (Sprachbefehle)
- Kamera (Bildverarbeitung)
- Standort (Ortsbasierte Dienste)
- Kontakte (Integration)
- Kalender (Terminverwaltung)
- Spracherkennung (Sprachbefehle)
- FaceID (Sichere Authentifizierung)
- Bluetooth (Geräteverbindung)
- Lokales Netzwerk (Gerätekommunikation)

## Lizenz
MIT
