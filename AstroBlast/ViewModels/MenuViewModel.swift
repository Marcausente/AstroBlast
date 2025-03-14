//
//  MenuViewModel.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation
import SwiftUI
import Combine

class MenuViewModel: ObservableObject {
    @Published var menuModel = MenuModel()
    @Published var showGameView = false
    @Published var selectedLevel: MenuModel.GameLevel = .level1
    @Published var showExitConfirmation = false
    
    // Efectos visuales
    @Published var animateBackground = false
    @Published var animateStars = false
    
    // Inicializador
    init() {
        // Configurar observadores para cambios en las opciones
        setupObservers()
    }
    
    // Configurar observadores para cambios en las opciones
    private func setupObservers() {
        // Observar cambios en la opción de música
        $menuModel
            .map(\.options.musicEnabled)
            .removeDuplicates()
            .sink { [weak self] musicEnabled in
                self?.handleMusicEnabledChange(musicEnabled)
            }
            .store(in: &cancellables)
    }
    
    // Manejar cambios en la opción de música
    private func handleMusicEnabledChange(_ enabled: Bool) {
        if enabled {
            // Iniciar la reproducción de música si está habilitada
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
        } else {
            // Detener la música si está deshabilitada
            AudioManager.shared.stopBackgroundMusic()
        }
    }
    
    // Almacenamiento para cancelables
    private var cancellables = Set<AnyCancellable>()
    
    // Método para navegar a una sección del menú
    func navigateTo(_ state: MenuModel.MenuState) {
        menuModel.navigateTo(state)
    }
    
    // Método para volver al menú principal
    func backToMain() {
        menuModel.backToMain()
    }
    
    // Método para iniciar el juego en un nivel específico
    func startGame(level: MenuModel.GameLevel) {
        if menuModel.startGame(level: level) {
            selectedLevel = level
            
            // Pausar la música del menú antes de iniciar el juego
            if menuModel.options.musicEnabled {
                AudioManager.shared.pauseBackgroundMusic()
            }
            
            showGameView = true
        } else {
            // El nivel está bloqueado, podríamos mostrar un mensaje
            print("Nivel bloqueado")
        }
    }
    
    // Método para desbloquear todos los niveles (para propósitos de demostración)
    func unlockAllLevels() {
        // En una implementación real, esto modificaría el estado persistente del juego
        print("Todos los niveles desbloqueados")
    }
    
    // Método para actualizar las opciones del juego
    func updateOptions(soundEnabled: Bool? = nil, musicEnabled: Bool? = nil, vibrationEnabled: Bool? = nil, difficulty: MenuModel.GameOptions.Difficulty? = nil) {
        if let soundEnabled = soundEnabled {
            menuModel.options.soundEnabled = soundEnabled
            
            // Actualizar el estado de silencio en el AudioManager
            AudioManager.shared.isMuted = !soundEnabled
        }
        
        if let musicEnabled = musicEnabled {
            menuModel.options.musicEnabled = musicEnabled
            
            // La lógica para iniciar/detener la música se maneja en el observador
        }
        
        if let vibrationEnabled = vibrationEnabled {
            menuModel.options.vibrationEnabled = vibrationEnabled
        }
        
        if let difficulty = difficulty {
            menuModel.options.difficulty = difficulty
        }
    }
    
    // Método para salir de la aplicación
    func exitGame() {
        // Detener la música antes de salir
        AudioManager.shared.stopBackgroundMusic()
        
        // En una aplicación real, esto podría guardar el estado del juego antes de salir
        exit(0)
    }
    
    // Método para mostrar el diálogo de confirmación de salida
    func confirmExit() {
        showExitConfirmation = true
    }
    
    // Método para cancelar la salida
    func cancelExit() {
        showExitConfirmation = false
    }
    
    // Iniciar animaciones y música
    func startAnimations() {
        withAnimation(Animation.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
            animateBackground = true
        }
        
        withAnimation(Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
            animateStars = true
        }
        
        // Iniciar la música del menú si está habilitada
        if menuModel.options.musicEnabled {
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
        }
    }
} 