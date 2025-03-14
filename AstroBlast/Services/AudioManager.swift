//
//  AudioManager.swift
//  AstroBlast
//
//  Created by Marc Fernández on 14/3/25.
//

import Foundation
import AVFoundation

class AudioManager {
    // Singleton para acceso global
    static let shared = AudioManager()
    
    // Reproductor para la música de fondo
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    // Reproductor para efectos de sonido
    private var soundEffectPlayers: [URL: AVAudioPlayer] = [:]
    
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
        // Configurar la sesión de audio
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error al configurar la sesión de audio: \(error.localizedDescription)")
        }
    }
    
    // Reproducir música de fondo
    func playBackgroundMusic(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("No se pudo encontrar el archivo de música: \(filename)")
            return
        }
        
        do {
            // Detener la música actual si está reproduciéndose
            backgroundMusicPlayer?.stop()
            
            // Crear un nuevo reproductor
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Reproducir en bucle infinito
            backgroundMusicPlayer?.volume = isMuted ? 0 : musicVolume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Error al reproducir música de fondo: \(error.localizedDescription)")
        }
    }
    
    // Detener la música de fondo
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    // Pausar la música de fondo
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    // Reanudar la música de fondo
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
    }
    
    // Reproducir un efecto de sonido
    func playSoundEffect(filename: String) {
        guard !isMuted else { return }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("No se pudo encontrar el archivo de sonido: \(filename)")
            return
        }
        
        // Reutilizar un reproductor existente o crear uno nuevo
        if let player = soundEffectPlayers[url] {
            player.currentTime = 0
            player.volume = soundEffectsVolume
            player.play()
        } else {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = soundEffectsVolume
                player.prepareToPlay()
                soundEffectPlayers[url] = player
                player.play()
            } catch {
                print("Error al reproducir efecto de sonido: \(error.localizedDescription)")
            }
        }
    }
} 