//
//  GameModel.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation
import SwiftUI

struct GameModel {
    // Estado del juego
    var score: Int = 0
    var level: Int = 1
    var isGameOver: Bool = false
    var isLevelCompleted: Bool = false
    var lives: Int = 3
    
    // Tiempo de juego
    var elapsedTime: TimeInterval = 0
    var levelDuration: TimeInterval = 180 // 3 minutos en segundos
    
    // Posición del jugador
    var playerPosition: CGFloat = 0 // Posición X de la nave del jugador
    
    // Proyectiles del jugador
    var projectiles: [Projectile] = []
    
    // Enemigos
    var enemies: [Enemy] = []
    
    // Proyectiles enemigos
    var enemyProjectiles: [Projectile] = []
    
    // Tiempo desde el último enemigo generado
    var lastEnemySpawnTime: TimeInterval = 0
    
    // Tiempo desde el último disparo enemigo
    var lastEnemyShootTime: TimeInterval = 0
    
    // Estructura para proyectiles (tanto del jugador como de enemigos)
    struct Projectile: Identifiable {
        let id = UUID()
        var position: CGPoint
        var isEnemy: Bool = false // Para distinguir entre proyectiles del jugador y enemigos
    }
    
    // Estructura para enemigos
    struct Enemy: Identifiable {
        let id = UUID()
        var position: CGPoint
        var health: Int = 1
        var size: CGSize = CGSize(width: 60, height: 60)
        var lastShootTime: TimeInterval = 0
        
        // Método para verificar colisión con un proyectil
        func isHit(by projectile: Projectile) -> Bool {
            let enemyRect = CGRect(
                x: position.x - size.width/2,
                y: position.y - size.height/2,
                width: size.width,
                height: size.height
            )
            
            return enemyRect.contains(projectile.position)
        }
    }
    
    // Método para verificar si la nave del jugador es impactada por un proyectil enemigo
    func isPlayerHit(playerPosition: CGPoint, playerSize: CGSize, by projectile: Projectile) -> Bool {
        let playerRect = CGRect(
            x: playerPosition.x - playerSize.width/2,
            y: playerPosition.y - playerSize.height/2,
            width: playerSize.width,
            height: playerSize.height
        )
        
        return playerRect.contains(projectile.position)
    }
    
    // Método para reiniciar el juego
    mutating func resetGame() {
        score = 0
        level = 1
        isGameOver = false
        isLevelCompleted = false
        lives = 3
        elapsedTime = 0
        projectiles.removeAll()
        enemies.removeAll()
        enemyProjectiles.removeAll()
        lastEnemySpawnTime = 0
        lastEnemyShootTime = 0
    }
    
    // Método para avanzar al siguiente nivel
    mutating func advanceToNextLevel() {
        level += 1
        isLevelCompleted = false
        elapsedTime = 0
        projectiles.removeAll()
        enemies.removeAll()
        enemyProjectiles.removeAll()
        lastEnemySpawnTime = 0
        lastEnemyShootTime = 0
    }
    
    // Método para formatear el tiempo restante
    func formatTimeRemaining() -> String {
        let timeRemaining = max(0, levelDuration - elapsedTime)
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 