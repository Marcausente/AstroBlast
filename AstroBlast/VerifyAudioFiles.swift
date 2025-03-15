import Foundation
import SwiftUI
import AVFoundation

struct VerifyAudioFiles: View {
    @State private var logs: [String] = []
    @State private var isVerifying = false
    
    var body: some View {
        VStack {
            Text("Verificación de Archivos de Audio")
                .font(.title)
                .padding()
            
            Button(action: {
                logs.removeAll()
                isVerifying = true
                verifyAudioFiles()
            }) {
                Text("Verificar Archivos")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isVerifying)
            
            if isVerifying {
                ProgressView()
                    .padding()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logs, id: \.self) { log in
                        Text(log)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
    
    func verifyAudioFiles() {
        addLog("🔍 Iniciando verificación de archivos de audio...")
        
        // Lista de archivos de audio que deberían estar disponibles
        let requiredAudioFiles = [
            "Sounds/menumusic.mp3",
            "Sounds/spacemusic.mp3",
            "Sounds/Shotsound.mp3"
        ]
        
        // Verificar cada archivo
        for filename in requiredAudioFiles {
            addLog("Verificando: \(filename)")
            
            // 1. Verificar con ruta completa
            if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
                addLog("✅ Encontrado con ruta completa: \(url.path)")
                verifyAudioFile(url: url)
                continue
            }
            
            // 2. Verificar sin ruta
            let components = filename.components(separatedBy: "/")
            if let lastComponent = components.last {
                if let url = Bundle.main.url(forResource: lastComponent, withExtension: nil) {
                    addLog("✅ Encontrado sin ruta: \(url.path)")
                    verifyAudioFile(url: url)
                    continue
                }
                
                // 3. Verificar separando nombre y extensión
                let nameComponents = lastComponent.components(separatedBy: ".")
                if nameComponents.count > 1 {
                    let name = nameComponents[0]
                    let ext = nameComponents[1]
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        addLog("✅ Encontrado con nombre y extensión separados: \(url.path)")
                        verifyAudioFile(url: url)
                        continue
                    }
                }
            }
            
            // 4. Verificar en el directorio de recursos
            if let resourcesURL = Bundle.main.resourceURL {
                let fileURL = resourcesURL.appendingPathComponent(filename)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    addLog("✅ Encontrado en recursos: \(fileURL.path)")
                    verifyAudioFile(url: fileURL)
                    continue
                }
            }
            
            addLog("❌ No se encontró el archivo: \(filename)")
        }
        
        // Listar todos los archivos de audio en el bundle
        addLog("\n📋 Listando todos los archivos de audio en el bundle:")
        if let bundleURL = Bundle.main.resourceURL {
            listAudioFiles(in: bundleURL)
        }
        
        // Verificar la configuración de la sesión de audio
        addLog("\n🔊 Verificando configuración de la sesión de audio:")
        do {
            let session = AVAudioSession.sharedInstance()
            addLog("Categoría actual: \(session.category.rawValue)")
            addLog("Modo actual: \(session.mode.rawValue)")
            addLog("Opciones actuales: \(session.categoryOptions.rawValue)")
            addLog("Está activa: \(session.isOtherAudioPlaying ? "Sí" : "No")")
            
            // Intentar activar la sesión
            try session.setActive(true)
            addLog("✅ Sesión activada correctamente")
        } catch {
            addLog("❌ Error con la sesión de audio: \(error.localizedDescription)")
        }
        
        isVerifying = false
        addLog("\n✅ Verificación completada")
    }
    
    func verifyAudioFile(url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            addLog("✅ Archivo cargado correctamente")
            addLog("   - Duración: \(String(format: "%.2f", player.duration)) segundos")
            addLog("   - Canales: \(player.numberOfChannels)")
            addLog("   - Formato: \(player.format)")
        } catch {
            addLog("❌ Error cargando archivo: \(error.localizedDescription)")
        }
    }
    
    func listAudioFiles(in directory: URL) {
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            for url in contents {
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // Es un directorio, listar su contenido recursivamente
                        if url.lastPathComponent != "Plugins" && !url.lastPathComponent.hasSuffix(".framework") {
                            addLog("📁 \(url.lastPathComponent):")
                            listAudioFiles(in: url)
                        }
                    } else {
                        // Es un archivo, verificar si es un archivo de audio
                        let pathExtension = url.pathExtension.lowercased()
                        if ["mp3", "wav", "aac", "m4a"].contains(pathExtension) {
                            addLog("🎵 \(url.lastPathComponent)")
                        }
                    }
                }
            }
        } catch {
            addLog("❌ Error listando archivos: \(error.localizedDescription)")
        }
    }
    
    func addLog(_ message: String) {
        DispatchQueue.main.async {
            logs.append(message)
        }
    }
}

#Preview {
    VerifyAudioFiles()
} 