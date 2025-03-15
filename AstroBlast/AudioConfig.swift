import Foundation
import AVFoundation

// Esta clase se encarga de verificar y configurar todo lo relacionado con el audio
class AudioConfig {
    static let shared = AudioConfig()
    
    private init() {}
    
    // Verificar que los archivos de audio estén disponibles
    func verifyAudioFiles() {
        print("🔊 Verificando archivos de audio...")
        
        // Lista de archivos de audio que deberían estar disponibles
        let requiredAudioFiles = [
            "Sounds/menumusic.mp3",
            "Sounds/spacemusic.mp3",
            "Sounds/Shotsound.mp3"
        ]
        
        // Verificar cada archivo
        for filename in requiredAudioFiles {
            if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
                print("✅ Archivo encontrado: \(filename) en \(url.path)")
                
                // Verificar si el archivo se puede cargar como AVAudioPlayer
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    print("✅ Archivo cargado correctamente: \(filename), duración: \(player.duration) segundos")
                } catch {
                    print("❌ Error cargando archivo \(filename): \(error.localizedDescription)")
                }
            } else {
                // Intentar buscar el archivo sin la ruta
                let components = filename.components(separatedBy: "/")
                if let lastComponent = components.last,
                   let url = Bundle.main.url(forResource: lastComponent, withExtension: nil) {
                    print("⚠️ Archivo encontrado sin ruta: \(lastComponent) en \(url.path)")
                } else {
                    print("❌ Archivo no encontrado: \(filename)")
                }
            }
        }
        
        // Listar todos los archivos de audio en el bundle
        print("📋 Listando todos los archivos de audio en el bundle:")
        if let bundleURL = Bundle.main.resourceURL {
            listAudioFiles(in: bundleURL)
        }
    }
    
    // Listar recursivamente todos los archivos de audio en un directorio
    private func listAudioFiles(in directory: URL) {
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            for url in contents {
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // Es un directorio, listar su contenido recursivamente
                        listAudioFiles(in: url)
                    } else {
                        // Es un archivo, verificar si es un archivo de audio
                        let pathExtension = url.pathExtension.lowercased()
                        if ["mp3", "wav", "aac", "m4a"].contains(pathExtension) {
                            print("- \(url.path)")
                        }
                    }
                }
            }
        } catch {
            print("Error listando archivos: \(error.localizedDescription)")
        }
    }
    
    // Configurar la sesión de audio para la aplicación
    func configureAudioSession() {
        do {
            // Configurar la sesión de audio para reproducción de música de fondo
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Sesión de audio configurada correctamente")
        } catch {
            print("❌ Error configurando la sesión de audio: \(error.localizedDescription)")
        }
    }
} 