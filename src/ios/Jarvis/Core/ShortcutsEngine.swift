import Intents
import Foundation

class ShortcutsEngine: NSObject {
    static let shared = ShortcutsEngine()
    
    private override init() {}
    
    // MARK: - Intent Handling
    
    func donateShortcut(intent: INIntent, completion: ((Error?) -> Void)? = nil) {
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Error donating shortcut: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("Successfully donated shortcut")
                completion?(nil)
            }
        }
    }
    
    func setupShortcuts() {
        // Register custom intents
        INPreferences.requestSiriAuthorization { status in
            switch status {
            case .authorized:
                print("Siri authorization granted")
                self.registerCustomIntents()
            case .denied:
                print("Siri authorization denied")
            case .notDetermined:
                print("Siri authorization not determined")
            case .restricted:
                print("Siri authorization restricted")
            @unknown default:
                print("Unknown Siri authorization status")
            }
        }
    }
    
    private func registerCustomIntents() {
        // Custom intents would be registered here
        // For example:
        // let intent = JarvisShortcutIntent()
        // intent.suggestedInvocationPhrase = "Hey Jarvis"
        // donateShortcut(intent: intent)
    }
    
    // MARK: - Shortcut Execution
    
    func executeShortcut(identifier: String, completion: @escaping (Bool, String?) -> Void) {
        let intent: INIntent
        
        switch identifier {
        case "toggleWifi":
            intent = ToggleWifiIntent()
        case "toggleBluetooth":
            intent = ToggleBluetoothIntent()
        case "setBrightness":
            let brightnessIntent = SetBrightnessIntent()
            brightnessIntent.level = 0.5 // Default value
            intent = brightnessIntent
        case "setVolume":
            let volumeIntent = SetVolumeIntent()
            volumeIntent.level = 0.7 // Default value
            intent = volumeIntent
        case "toggleFocus":
            intent = ToggleFocusModeIntent()
        default:
            completion(false, "Unknown shortcut")
            return
        }
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, "Shortcut executed successfully")
            }
        }
    }
    
    // MARK: - Siri Shortcut Management
    
    func getAvailableShortcuts(completion: @escaping ([INIntent]) -> Void) {
        let shortcuts: [INIntent] = [
            ToggleWifiIntent(),
            ToggleBluetoothIntent(),
            SetBrightnessIntent(),
            SetVolumeIntent(),
            ToggleFocusModeIntent()
        ]
        
        completion(shortcuts)
    }
    
    func removeShortcut(intent: INIntent, completion: ((Error?) -> Void)? = nil) {
        // In einer echten App würde hier der Shortcut aus den Siri Vorschlägen entfernt werden
        // Dies erfordert spezielle Berechtigungen
        completion?(nil)
    }
}

// MARK: - Custom Intent Handlers

extension ShortcutsEngine {
    func handleToggleWifi() {
        Task {
            do {
                let result = try await AppIntentsManager.shared.executeIntent(ToggleWifiIntent())
                print("WiFi toggle result: \(result)")
            } catch {
                print("Error toggling WiFi: \(error)")
            }
        }
    }
    
    func handleToggleBluetooth() {
        Task {
            do {
                let result = try await AppIntentsManager.shared.executeIntent(ToggleBluetoothIntent())
                print("Bluetooth toggle result: \(result)")
            } catch {
                print("Error toggling Bluetooth: \(error)")
            }
        }
    }
    
    func handleSetBrightness(level: Double) {
        Task {
            let intent = SetBrightnessIntent()
            intent.level = level
            do {
                let result = try await AppIntentsManager.shared.executeIntent(intent)
                print("Brightness result: \(result)")
            } catch {
                print("Error setting brightness: \(error)")
            }
        }
    }
    
    func handleSetVolume(level: Double) {
        Task {
            let intent = SetVolumeIntent()
            intent.level = level
            do {
                let result = try await AppIntentsManager.shared.executeIntent(intent)
                print("Volume result: \(result)")
            } catch {
                print("Error setting volume: \(error)")
            }
        }
    }
    
    func handleToggleFocus() {
        Task {
            do {
                let result = try await AppIntentsManager.shared.executeIntent(ToggleFocusModeIntent())
                print("Focus mode result: \(result)")
            } catch {
                print("Error toggling focus mode: \(error)")
            }
        }
    }
}