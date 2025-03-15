//
//  AudioFileInfo.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation
import AVFoundation

class AudioFileInfo {
    static func printAudioFilesInfo() {
        print("=== INFORMACIÓN DE ARCHIVOS DE AUDIO ===")
        
        // Verificar el directorio de recursos del bundle
        if let resourcesURL = Bundle.main.resourceURL {
            print("\nDirectorio de recursos del bundle: \(resourcesURL.path)")
            
            // Verificar el directorio de sonidos
            let soundDirURL = resourcesURL.appendingPathComponent("sound")
            var isDirectory: ObjCBool = false
            
            if FileManager.default.fileExists(atPath: soundDirURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                print("Directorio de sonidos encontrado: \(soundDirURL.path)")
                
                do {
                    let files = try FileManager.default.contentsOfDirectory(at: soundDirURL, includingPropertiesForKeys: nil)
                    print("Archivos en el directorio de sonidos:")
                    for file in files {
                        print("- \(file.lastPathComponent)")
                        
                        // Verificar si el archivo es un archivo de audio válido
                        do {
                            let audioPlayer = try AVAudioPlayer(contentsOf: file)
                            print("  ✓ Archivo de audio válido: \(audioPlayer.duration) segundos, \(audioPlayer.numberOfChannels) canales")
                        } catch {
                            print("  ✗ No es un archivo de audio válido: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    print("Error al listar archivos: \(error.localizedDescription)")
                }
            } else {
                print("Directorio de sonidos no encontrado en: \(soundDirURL.path)")
            }
            
            // Listar todos los recursos del bundle
            do {
                let resourceFiles = try FileManager.default.contentsOfDirectory(at: resourcesURL, includingPropertiesForKeys: nil)
                print("\nTodos los archivos en el bundle:")
                for file in resourceFiles {
                    print("- \(file.lastPathComponent)")
                }
            } catch {
                print("Error al listar archivos del bundle: \(error.localizedDescription)")
            }
        }
        
        // Verificar el directorio de documentos
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("\nDirectorio de documentos: \(documentsDirectory.path)")
            
            let soundsDirectory = documentsDirectory.appendingPathComponent("Sounds")
            var isDirectory: ObjCBool = false
            
            if FileManager.default.fileExists(atPath: soundsDirectory.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                print("Directorio Sounds encontrado: \(soundsDirectory.path)")
                
                do {
                    let files = try FileManager.default.contentsOfDirectory(at: soundsDirectory, includingPropertiesForKeys: nil)
                    print("Archivos en el directorio Sounds:")
                    for file in files {
                        print("- \(file.lastPathComponent)")
                    }
                } catch {
                    print("Error al listar archivos: \(error.localizedDescription)")
                }
            } else {
                print("Directorio Sounds no encontrado en documentos")
            }
        }
        
        // Probar la búsqueda de archivos específicos
        print("\nPrueba de búsqueda de archivos específicos:")
        testFindFile(filename: "menumusic.mp3")
        testFindFile(filename: "Sounds/menumusic.mp3")
        testFindFile(filename: "Sounds/menumusic.mp3")
        
        print("=== FIN DE INFORMACIÓN DE ARCHIVOS DE AUDIO ===")
    }
    
    static func testFindFile(filename: String) {
        print("Buscando: \(filename)")
        
        // Método 1: Buscar con URL(forResource:)
        if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            print("✓ Encontrado con URL(forResource:): \(url.path)")
        } else {
            print("✗ No encontrado con URL(forResource:)")
        }
        
        // Método 2: Buscar con path(forResource:)
        if let path = Bundle.main.path(forResource: filename, ofType: nil) {
            print("✓ Encontrado con path(forResource:): \(path)")
        } else {
            print("✗ No encontrado con path(forResource:)")
        }
        
        // Método 3: Extraer nombre y extensión
        let components = filename.components(separatedBy: "/")
        let filenameWithoutPath = components.last ?? filename
        
        let fileComponents = filenameWithoutPath.components(separatedBy: ".")
        if fileComponents.count > 1 {
            let name = fileComponents[0]
            let ext = fileComponents[1]
            
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                print("✓ Encontrado con nombre y extensión separados: \(url.path)")
            } else {
                print("✗ No encontrado con nombre y extensión separados")
            }
        }
    }
} 