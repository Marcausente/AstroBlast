//
//  AudioManager.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [URL: AVAudioPlayer] = [:]
    private var isAudioSessionActive = false
    
    // Volumen para la música de fondo
    var musicVolume: Float = 0.5 {
        didSet {
            backgroundMusicPlayer?.volume = musicVolume
        }
    }
    
    // Volumen para los efectos de sonido
    var soundEffectsVolume: Float = 1.0
    
    // Estado de silencio
    var isMuted: Bool = false {
        didSet {
            if isMuted {
                backgroundMusicPlayer?.volume = 0
            } else {
                backgroundMusicPlayer?.volume = musicVolume
            }
        }
    }
    
    private init() {
        setupAudioSession()
        
        // Registrar para notificaciones de interrupción de audio
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // Registrar para notificaciones de cambio de ruta de audio
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAudioSession() {
        do {
            // Configurar la sesión de audio para reproducción de música de fondo
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            isAudioSessionActive = true
            print("Sesión de audio configurada correctamente")
        } catch {
            print("Error configurando la sesión de audio: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // La interrupción comenzó, pausar la reproducción
            backgroundMusicPlayer?.pause()
            print("Audio interrumpido")
        case .ended:
            // La interrupción terminó, reanudar la reproducción si es apropiado
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                backgroundMusicPlayer?.play()
                print("Audio reanudado después de interrupción")
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleAudioRouteChange(notification: Notification) {
        // Manejar cambios en la ruta de audio (por ejemplo, conectar/desconectar auriculares)
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Si se desconectan los auriculares, pausar la reproducción
        if reason == .oldDeviceUnavailable {
            if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs {
                    if output.portType == .headphones {
                        // Los auriculares se desconectaron, pausar la reproducción
                        backgroundMusicPlayer?.pause()
                        print("Auriculares desconectados, audio pausado")
                        break
                    }
                }
            }
        }
    }
    
    // Método para buscar un archivo de audio en múltiples ubicaciones
    private func findAudioFile(filename: String) -> URL? {
        print("🔍 Buscando archivo de audio: \(filename)")
        
        // 1. Buscar en el bundle principal con la ruta completa
        if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            print("✅ Archivo encontrado en el bundle con ruta completa: \(url.path)")
            return url
        } else {
            print("❌ No se encontró en el bundle con ruta completa")
        }
        
        // 2. Extraer el nombre del archivo y la extensión
        var filenameWithoutPath = filename
        var fileExtension = ""
        
        if let lastSlashIndex = filename.lastIndex(of: "/") {
            filenameWithoutPath = String(filename[filename.index(after: lastSlashIndex)...])
        }
        
        if let lastDotIndex = filenameWithoutPath.lastIndex(of: ".") {
            fileExtension = String(filenameWithoutPath[filenameWithoutPath.index(after: lastDotIndex)...])
            filenameWithoutPath = String(filenameWithoutPath[..<lastDotIndex])
        }
        
        print("🔍 Buscando: nombre='\(filenameWithoutPath)' extensión='\(fileExtension)'")
        
        // 3. Buscar en el bundle principal sin la extensión
        if !fileExtension.isEmpty {
            if let url = Bundle.main.url(forResource: filenameWithoutPath, withExtension: fileExtension) {
                print("✅ Archivo encontrado en el bundle sin ruta: \(url.path)")
                return url
            } else {
                print("❌ No se encontró en el bundle sin ruta")
            }
        }
        
        // 4. Buscar en el directorio Sounds del bundle
        if let url = Bundle.main.url(forResource: "Sounds/\(filenameWithoutPath)", withExtension: fileExtension) {
            print("✅ Archivo encontrado en el directorio Sounds del bundle: \(url.path)")
            return url
        } else {
            print("❌ No se encontró en el directorio Sounds del bundle")
        }
        
        // 5. Buscar en el directorio de documentos
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("Sounds").appendingPathComponent(filenameWithoutPath + (fileExtension.isEmpty ? "" : "." + fileExtension))
            print("🔍 Buscando en documentos: \(fileURL.path)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("✅ Archivo encontrado en el directorio de documentos: \(fileURL.path)")
                return fileURL
            } else {
                print("❌ No se encontró en el directorio de documentos")
            }
        }
        
        // 6. Buscar en el directorio de la aplicación
        if let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let fileURL = appSupportDirectory.appendingPathComponent("Sounds").appendingPathComponent(filenameWithoutPath + (fileExtension.isEmpty ? "" : "." + fileExtension))
            print("🔍 Buscando en soporte de aplicación: \(fileURL.path)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("✅ Archivo encontrado en el directorio de soporte de la aplicación: \(fileURL.path)")
                return fileURL
            } else {
                print("❌ No se encontró en el directorio de soporte de la aplicación")
            }
        }
        
        // 7. Buscar en el directorio de recursos del bundle
        if let resourcesURL = Bundle.main.resourceURL {
            let soundDirURL = resourcesURL.appendingPathComponent("Sounds")
            let fileURL = soundDirURL.appendingPathComponent(filenameWithoutPath + (fileExtension.isEmpty ? "" : "." + fileExtension))
            print("🔍 Buscando en recursos del bundle: \(fileURL.path)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("✅ Archivo encontrado en el directorio de recursos del bundle: \(fileURL.path)")
                return fileURL
            } else {
                print("❌ No se encontró en el directorio de recursos del bundle")
            }
        }
        
        // 8. Buscar en el directorio raíz del bundle
        if let resourcesURL = Bundle.main.resourceURL {
            let fileURL = resourcesURL.appendingPathComponent(filenameWithoutPath + (fileExtension.isEmpty ? "" : "." + fileExtension))
            print("🔍 Buscando en raíz del bundle: \(fileURL.path)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("✅ Archivo encontrado en la raíz del bundle: \(fileURL.path)")
                return fileURL
            } else {
                print("❌ No se encontró en la raíz del bundle")
            }
        }
        
        print("⚠️ No se pudo encontrar el archivo de audio: \(filename)")
        
        // Listar todos los recursos del bundle para depuración
        if let resourcesURL = Bundle.main.resourceURL {
            do {
                let resourceFiles = try FileManager.default.contentsOfDirectory(at: resourcesURL, includingPropertiesForKeys: nil)
                print("📋 Archivos en el bundle:")
                for file in resourceFiles {
                    print("- \(file.lastPathComponent)")
                }
                
                // Buscar específicamente en el directorio Sounds si existe
                let soundsDir = resourcesURL.appendingPathComponent("Sounds")
                if FileManager.default.fileExists(atPath: soundsDir.path) {
                    print("📋 Archivos en el directorio Sounds:")
                    let soundFiles = try FileManager.default.contentsOfDirectory(at: soundsDir, includingPropertiesForKeys: nil)
                    for file in soundFiles {
                        print("- \(file.lastPathComponent)")
                    }
                } else {
                    print("❌ El directorio Sounds no existe en el bundle")
                }
            } catch {
                print("❌ Error al listar archivos del bundle: \(error)")
            }
        }
        
        return nil
    }
    
    func playBackgroundMusic(filename: String) {
        print("Intentando reproducir música de fondo: \(filename)")
        // Asegurarse de que la sesión de audio esté activa
        if !isAudioSessionActive {
            print("La sesión de audio no estaba activa, configurándola...")
            setupAudioSession()
        } else {
            // Reactivar la sesión de audio para asegurar que funcione en dispositivos físicos
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Error reactivando la sesión de audio: \(error.localizedDescription)")
            }
        }
        
        guard let url = findAudioFile(filename: filename) else {
            print("⚠️ No se pudo encontrar el archivo de música: \(filename)")
            return
        }
        
        print("Archivo de música encontrado en: \(url.path)")
        
        do {
            // Detener cualquier reproducción anterior
            if backgroundMusicPlayer != nil {
                print("Deteniendo reproductor de música anterior")
                backgroundMusicPlayer?.stop()
                backgroundMusicPlayer = nil  // Liberar el reproductor anterior
            }
            
            // Crear un nuevo reproductor
            print("Creando nuevo reproductor para: \(url.path)")
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            
            // Verificar que el reproductor se creó correctamente
            guard let player = backgroundMusicPlayer else {
                print("❌ Error: No se pudo crear el reproductor de audio")
                return
            }
            
            player.numberOfLoops = -1 // Reproducir en bucle infinito
            player.volume = 0.7 // Volumen a buen nivel
            player.prepareToPlay() // Preparar antes de reproducir
            
            let success = player.play()
            print("Reproducción de música iniciada: \(success ? "✅ Éxito" : "❌ Fallida")")
            
            if !success {
                // Intentar reiniciar la sesión de audio y reproducir de nuevo
                print("Intentando reiniciar la sesión de audio y reproducir de nuevo")
                setupAudioSession()
                let retrySuccess = player.play()
                print("Segundo intento de reproducción: \(retrySuccess ? "✅ Éxito" : "❌ Fallida")")
                
                if !retrySuccess {
                    // Último intento: recrear el reproductor
                    print("Último intento: recreando el reproductor")
                    backgroundMusicPlayer = nil
                    backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                    backgroundMusicPlayer?.numberOfLoops = -1
                    backgroundMusicPlayer?.volume = 0.7
                    backgroundMusicPlayer?.prepareToPlay()
                    let finalSuccess = backgroundMusicPlayer?.play() ?? false
                    print("Tercer intento de reproducción: \(finalSuccess ? "✅ Éxito" : "❌ Fallida")")
                }
            }
        } catch {
            print("❌ Error reproduciendo música de fondo: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        print("Deteniendo música de fondo")
        if backgroundMusicPlayer != nil {
            backgroundMusicPlayer?.stop()
            print("Música de fondo detenida")
        } else {
            print("No hay reproductor de música de fondo activo para detener")
        }
    }
    
    func playSoundEffect(filename: String) {
        print("🔊 Intentando reproducir efecto de sonido: \(filename)")
        
        // No reproducir sonidos si está silenciado
        if isMuted {
            print("🔇 Audio silenciado, no se reproducirá el efecto de sonido")
            return
        }
        
        // Asegurarse de que la sesión de audio esté activa
        if !isAudioSessionActive {
            print("🔄 La sesión de audio no estaba activa, configurándola...")
            setupAudioSession()
        } else {
            // Reactivar la sesión de audio para asegurar que funcione en dispositivos físicos
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("❌ Error reactivando la sesión de audio: \(error.localizedDescription)")
            }
        }
        
        guard let url = findAudioFile(filename: filename) else {
            print("⚠️ No se pudo encontrar el archivo de sonido: \(filename)")
            return
        }
        
        print("✅ Archivo de sonido encontrado en: \(url.path)")
        
        // Reutilizar un reproductor existente o crear uno nuevo
        if let player = soundEffectPlayers[url] {
            print("♻️ Reutilizando reproductor existente para: \(url.path)")
            player.currentTime = 0
            player.volume = soundEffectsVolume // Asegurarse de que el volumen sea correcto
            let success = player.play()
            print("🎵 Reproducción de efecto de sonido: \(success ? "✅ Éxito" : "❌ Fallida")")
            
            if !success {
                print("🔄 Reproducción fallida, intentando recrear el reproductor")
                // Si falla, intentar recrear el reproductor
                recreateSoundEffectPlayer(for: url)
            }
        } else {
            print("🆕 Creando nuevo reproductor para: \(url.path)")
            recreateSoundEffectPlayer(for: url)
        }
    }
    
    private func recreateSoundEffectPlayer(for url: URL) {
        print("🔄 Creando nuevo reproductor de efectos para: \(url.path)")
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = soundEffectsVolume
            player.prepareToPlay() // Preparar antes de reproducir
            let success = player.play()
            print("🎵 Reproducción de efecto de sonido (nuevo): \(success ? "✅ Éxito" : "❌ Fallida")")
            
            if success {
                soundEffectPlayers[url] = player
                print("✅ Reproductor guardado para reutilización")
            } else {
                // Último intento: reiniciar la sesión de audio
                print("🔄 Intentando reiniciar la sesión de audio para el efecto de sonido")
                setupAudioSession()
                let retrySuccess = player.play()
                print("🎵 Segundo intento de reproducción de efecto: \(retrySuccess ? "✅ Éxito" : "❌ Fallida")")
                
                if retrySuccess {
                    soundEffectPlayers[url] = player
                    print("✅ Reproductor guardado para reutilización después del segundo intento")
                } else {
                    print("❌ No se pudo reproducir el efecto de sonido después de múltiples intentos")
                }
            }
        } catch {
            print("❌ Error reproduciendo efecto de sonido: \(error.localizedDescription)")
        }
    }
    
    // Pausar la música de fondo
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    // Reanudar la música de fondo
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
    }
} 