//
//  SoundTest.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI
import AVFoundation

struct SoundTest: View {
    @State private var logMessages: [String] = []
    @State private var isShowingLog = false
    
    // Función para obtener la ruta de un recurso
    func getResourcePath(for name: String) -> URL? {
        // Intentar obtener la URL del recurso en el bundle
        if let url = Bundle.main.url(forResource: name, withExtension: nil) {
            addLog("Archivo encontrado en el bundle: \(url.path)")
            return url
        }
        
        // Si no se encuentra, intentar separar nombre y extensión
        let components = name.components(separatedBy: ".")
        if components.count > 1 {
            let filename = components[0]
            let ext = components[1]
            if let url = Bundle.main.url(forResource: filename, withExtension: ext) {
                addLog("Archivo encontrado con nombre y extensión separados: \(url.path)")
                return url
            }
        }
        
        // Si no se encuentra, intentar en el directorio de documentos
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("Sounds").appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                addLog("Archivo encontrado en el directorio de documentos: \(fileURL.path)")
                return fileURL
            }
        }
        
        addLog("No se pudo encontrar el archivo: \(name)")
        return nil
    }
    
    func addLog(_ message: String) {
        logMessages.append(message)
        print(message)
    }
    
    func testMenuMusic() {
        addLog("Probando música del menú...")
        if let url = getResourcePath(for: "menumusic.mp3") {
            addLog("Archivo de música del menú encontrado en: \(url.path)")
        } else {
            addLog("No se pudo encontrar el archivo de música del menú")
        }
    }
    
    func testSpaceMusic() {
        addLog("Probando música del espacio...")
        if let url = getResourcePath(for: "spacemusic.mp3") {
            addLog("Archivo de música del espacio encontrado en: \(url.path)")
        } else {
            addLog("No se pudo encontrar el archivo de música del espacio")
        }
    }
    
    func testShotSound() {
        addLog("Probando sonido de disparo...")
        if let url = getResourcePath(for: "Shotsound.mp3") {
            addLog("Archivo de sonido de disparo encontrado en: \(url.path)")
        } else {
            addLog("No se pudo encontrar el archivo de sonido de disparo")
        }
    }
    
    func testAudioManager() {
        addLog("Iniciando secuencia de prueba de audio...")
        
        // Probar la reproducción de música de fondo
        AudioManager.shared.playBackgroundMusic(filename: "menumusic.mp3")
        addLog("Reproduciendo música del menú")
        
        // Esperar 3 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Probar la reproducción de efectos de sonido
            AudioManager.shared.playSoundEffect(filename: "Shotsound.mp3")
            addLog("Reproduciendo sonido de disparo")
            
            // Esperar 2 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Cambiar la música de fondo
                AudioManager.shared.playBackgroundMusic(filename: "spacemusic.mp3")
                addLog("Cambiando a música del espacio")
            }
        }
    }
    
    func showAudioFileInfo() {
        addLog("Recopilando información de archivos de audio...")
        AudioFileInfo.printAudioFilesInfo()
        addLog("Información de archivos de audio recopilada (ver consola)")
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Prueba de Sonido")
                    .font(.largeTitle)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 15) {
                        Button("Probar Música del Menú") {
                            AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
                            addLog("Reproduciendo música del menú desde Sounds/menumusic.mp3")
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .blue))
                        
                        Button("Probar Música del Espacio") {
                            AudioManager.shared.playBackgroundMusic(filename: "Sounds/spacemusic.mp3")
                            addLog("Reproduciendo música del espacio desde Sounds/spacemusic.mp3")
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .purple))
                        
                        Button("Probar Sonido de Disparo") {
                            AudioManager.shared.playSoundEffect(filename: "Sounds/Shotsound.mp3")
                            addLog("Reproduciendo sonido de disparo desde Sounds/Shotsound.mp3")
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .red))
                        
                        Button("Detener Música") {
                            AudioManager.shared.stopBackgroundMusic()
                            addLog("Música detenida")
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .gray))
                        
                        Button("Copiar Archivos de Audio") {
                            CopyAudioFiles.copyFilesToBundle()
                            addLog("Copiando archivos de audio...")
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .green))
                        
                        Button("Probar Secuencia de Audio") {
                            testAudioManager()
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .orange))
                        
                        Button("Mostrar Información de Archivos") {
                            showAudioFileInfo()
                            isShowingLog = true
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .indigo))
                        
                        Button("Probar Rutas Alternativas") {
                            // Probar diferentes formatos de ruta
                            addLog("Probando rutas alternativas...")
                            AudioManager.shared.playBackgroundMusic(filename: "menumusic.mp3")
                            addLog("Intentando reproducir menumusic.mp3 (sin ruta)")
                        }
                        .buttonStyle(SoundTestButtonStyle(color: .teal))
                    }
                    .padding()
                }
                
                Button("Mostrar Registro") {
                    isShowingLog = true
                }
                .padding()
                .background(Color.secondary.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
            .padding()
            .onAppear {
                logMessages.removeAll()
                addLog("Vista de prueba de sonido iniciada")
                testMenuMusic()
                testSpaceMusic()
                testShotSound()
            }
            
            if isShowingLog {
                LogView(messages: $logMessages, isShowing: $isShowingLog)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: isShowingLog)
            }
        }
    }
}

struct SoundTestButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct LogView: View {
    @Binding var messages: [String]
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShowing = false
                }
            
            VStack {
                HStack {
                    Text("Registro de Actividad")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowing = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages.indices, id: \.self) { index in
                            Text(messages[index])
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button("Limpiar") {
                    messages.removeAll()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .padding()
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .cornerRadius(15)
            .padding()
        }
    }
} 