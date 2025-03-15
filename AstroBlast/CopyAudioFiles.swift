//
//  CopyAudioFiles.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation

// Esta clase es solo para uso en desarrollo
// Ayuda a copiar los archivos de audio al directorio de recursos del proyecto
class CopyAudioFiles {
    static func copyFilesToBundle() {
        print("🔊 Copiando archivos de audio al bundle...")
        
        // Obtener la URL del directorio de documentos
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ No se pudo obtener el directorio de documentos")
            return
        }
        
        // Crear el directorio Sounds si no existe
        let soundsDirectory = documentsDirectory.appendingPathComponent("Sounds")
        if !FileManager.default.fileExists(atPath: soundsDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: soundsDirectory, withIntermediateDirectories: true)
                print("✅ Directorio Sounds creado en: \(soundsDirectory.path)")
            } catch {
                print("❌ Error al crear el directorio Sounds: \(error)")
                return
            }
        }
        
        // Obtener la URL del bundle principal
        guard let bundleURL = Bundle.main.resourceURL else {
            print("❌ No se pudo obtener la URL del bundle principal")
            return
        }
        
        // Obtener la URL del directorio Sounds en el bundle
        let bundleSoundsURL = bundleURL.appendingPathComponent("Sounds")
        
        // Verificar si el directorio Sounds existe en el bundle
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: bundleSoundsURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
            print("✅ Directorio Sounds encontrado en el bundle: \(bundleSoundsURL.path)")
            
            // Listar los archivos en el directorio Sounds del bundle
            do {
                let soundFiles = try FileManager.default.contentsOfDirectory(at: bundleSoundsURL, includingPropertiesForKeys: nil)
                print("📋 Archivos en el directorio Sounds del bundle:")
                
                // Copiar cada archivo al directorio de documentos
                for fileURL in soundFiles {
                    let fileName = fileURL.lastPathComponent
                    let destinationURL = soundsDirectory.appendingPathComponent(fileName)
                    
                    print("🔄 Copiando \(fileName) a \(destinationURL.path)")
                    
                    // Eliminar el archivo existente si ya existe
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        do {
                            try FileManager.default.removeItem(at: destinationURL)
                            print("🗑️ Archivo existente eliminado: \(destinationURL.path)")
                        } catch {
                            print("⚠️ Error al eliminar archivo existente: \(error)")
                        }
                    }
                    
                    // Copiar el archivo
                    do {
                        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                        print("✅ Archivo copiado correctamente: \(fileName)")
                    } catch {
                        print("❌ Error al copiar archivo: \(error)")
                    }
                }
            } catch {
                print("❌ Error al listar archivos en el directorio Sounds del bundle: \(error)")
            }
        } else {
            print("⚠️ El directorio Sounds no existe en el bundle. Buscando archivos de audio en el directorio raíz del bundle...")
            
            // Buscar archivos MP3 en el directorio raíz del bundle
            do {
                let bundleContents = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
                let mp3Files = bundleContents.filter { $0.pathExtension.lowercased() == "mp3" }
                
                print("📋 Archivos MP3 encontrados en el directorio raíz del bundle:")
                
                // Copiar cada archivo MP3 al directorio Sounds
                for fileURL in mp3Files {
                    let fileName = fileURL.lastPathComponent
                    let destinationURL = soundsDirectory.appendingPathComponent(fileName)
                    
                    print("🔄 Copiando \(fileName) a \(destinationURL.path)")
                    
                    // Eliminar el archivo existente si ya existe
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        do {
                            try FileManager.default.removeItem(at: destinationURL)
                            print("🗑️ Archivo existente eliminado: \(destinationURL.path)")
                        } catch {
                            print("⚠️ Error al eliminar archivo existente: \(error)")
                        }
                    }
                    
                    // Copiar el archivo
                    do {
                        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                        print("✅ Archivo copiado correctamente: \(fileName)")
                    } catch {
                        print("❌ Error al copiar archivo: \(error)")
                    }
                }
            } catch {
                print("❌ Error al listar archivos en el directorio raíz del bundle: \(error)")
            }
        }
        
        // Verificar los archivos copiados
        do {
            let copiedFiles = try FileManager.default.contentsOfDirectory(at: soundsDirectory, includingPropertiesForKeys: nil)
            print("📋 Archivos en el directorio Sounds después de la copia:")
            for fileURL in copiedFiles {
                print("- \(fileURL.lastPathComponent)")
            }
        } catch {
            print("❌ Error al listar archivos copiados: \(error)")
        }
    }
} 