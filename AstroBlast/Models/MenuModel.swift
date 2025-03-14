//
//  MenuModel.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation

struct MenuModel {
    // Opciones del menú principal
    enum MenuOption: Int, CaseIterable, Identifiable {
        case levels = 0
        case options
        case credits
        case exit
        
        var id: Int {
            return self.rawValue
        }
        
        var title: String {
            switch self {
            case .levels:
                return "Niveles"
            case .options:
                return "Opciones"
            case .credits:
                return "Créditos"
            case .exit:
                return "Salir"
            }
        }
        
        var iconName: String {
            switch self {
            case .levels:
                return "gamecontroller.fill"
            case .options:
                return "gearshape.fill"
            case .credits:
                return "person.3.fill"
            case .exit:
                return "door.left.hand.open"
            }
        }
    }
    
    // Niveles disponibles
    enum GameLevel: Int, CaseIterable, Identifiable {
        case level1 = 1
        case level2 = 2
        case level3 = 3
        case level4 = 4
        case level5 = 5
        
        var id: Int {
            return self.rawValue
        }
        
        var title: String {
            return "Nivel \(self.rawValue)"
        }
        
        var isLocked: Bool {
            // Por defecto, solo el nivel 1 está desbloqueado
            // En una implementación real, esto podría verificar el progreso del jugador
            return self.rawValue > 1
        }
        
        var description: String {
            switch self {
            case .level1:
                return "Misión de entrenamiento. Sobrevive durante 2 minutos."
            case .level2:
                return "Aumenta la dificultad. Más enemigos y más rápidos."
            case .level3:
                return "Aparecen enemigos especiales con más resistencia."
            case .level4:
                return "Los enemigos disparan con mayor frecuencia."
            case .level5:
                return "Batalla final. Enfréntate al jefe alienígena."
            }
        }
    }
    
    // Opciones de configuración
    struct GameOptions {
        var soundEnabled: Bool = true
        var musicEnabled: Bool = true
        var vibrationEnabled: Bool = true
        var difficulty: Difficulty = .normal
        
        enum Difficulty: String, CaseIterable, Identifiable {
            case easy = "Fácil"
            case normal = "Normal"
            case hard = "Difícil"
            
            var id: String {
                return self.rawValue
            }
        }
    }
    
    // Información de créditos
    struct CreditsInfo {
        let title: String = "AstroBlast"
        let version: String = "1.0"
        let developer: String = "Marc Fernández"
        let year: String = "2025"
        let artCredits: String = "Diseño gráfico por el equipo de AstroBlast"
        let musicCredits: String = "Música y efectos de sonido por el equipo de AstroBlast"
    }
    
    // Estado actual del menú
    var currentMenuState: MenuState = .main
    var options: GameOptions = GameOptions()
    let credits: CreditsInfo = CreditsInfo()
    
    // Estados posibles del menú
    enum MenuState {
        case main
        case levels
        case options
        case credits
    }
    
    // Método para cambiar el estado del menú
    mutating func navigateTo(_ state: MenuState) {
        currentMenuState = state
    }
    
    // Método para volver al menú principal
    mutating func backToMain() {
        currentMenuState = .main
    }
    
    // Método para iniciar el juego en un nivel específico
    func startGame(level: GameLevel) -> Bool {
        // En una implementación real, aquí verificaríamos si el nivel está desbloqueado
        return !level.isLocked
    }
} 