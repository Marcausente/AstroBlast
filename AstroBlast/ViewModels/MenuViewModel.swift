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
        }
        
        if let musicEnabled = musicEnabled {
            menuModel.options.musicEnabled = musicEnabled
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
    
    // Iniciar animaciones
    func startAnimations() {
        withAnimation(Animation.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
            animateBackground = true
        }
        
        withAnimation(Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
            animateStars = true
        }
    }
} 