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
    var isPaused: Bool = false
    var lives: Int = 3
    var isBossLevel: Bool = false // Indica si estamos en un nivel de jefe
    
    // Tiempo de juego
    var elapsedTime: TimeInterval = 0
    var levelDuration: TimeInterval = 60 // Contador del tiempo
    
    // Posición del jugador
    var playerPosition: CGFloat = 0 // Posición X de la nave del jugador
    
    // Proyectiles del jugador
    var projectiles: [Projectile] = []
    
    // Enemigos
    var enemies: [Enemy] = []
    
    // Proyectiles enemigos
    var enemyProjectiles: [Projectile] = []
    
    // Explosiones
    var explosions: [Explosion] = []
    
    // Tiempo desde el último enemigo generado
    var lastEnemySpawnTime: TimeInterval = 0
    
    // Tiempo desde el último disparo enemigo
    var lastEnemyShootTime: TimeInterval = 0
    
    // Último momento en que el jugador disparó
    var lastShotTime: Date = Date()
    
    // Tiempo mínimo entre disparos del jugador (en segundos)
    var playerShootCooldown: TimeInterval = 0.3
    
    // Estructura para proyectiles (tanto del jugador como de enemigos)
    struct Projectile: Identifiable {
        let id = UUID()
        var position: CGPoint
        var isEnemy: Bool = false // Para distinguir entre proyectiles del jugador y enemigos
        var direction: CGVector = CGVector(dx: 0, dy: -1) // Por defecto, hacia arriba
        
        // Método para calcular la dirección hacia un punto objetivo
        static func directionToTarget(from start: CGPoint, to target: CGPoint) -> CGVector {
            let dx = target.x - start.x
            let dy = target.y - start.y
            let distance = sqrt(dx * dx + dy * dy)
            
            // Normalizar el vector para obtener la dirección
            if distance > 0 {
                return CGVector(dx: dx / distance, dy: dy / distance)
            } else {
                return CGVector(dx: 0, dy: 1) // Si están en el mismo punto, por defecto hacia abajo
            }
        }
    }
    
    // Explosiones
    struct Explosion: Identifiable {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        var lifetime: TimeInterval = 0
        let maxLifetime: TimeInterval = 0.5
        var scale: CGFloat = 0.1
        var opacity: Double = 1.0
        var isEnemy: Bool = true // Para diferenciar entre explosiones de enemigos y del jugador
        
        // Método para actualizar la explosión
        mutating func update(deltaTime: TimeInterval) -> Bool {
            lifetime += deltaTime
            
            // Escalar la explosión
            if lifetime < maxLifetime * 0.3 {
                // Fase de expansión rápida
                scale = min(1.0, scale + CGFloat(deltaTime * 5.0))
            } else {
                // Fase de desvanecimiento
                opacity = max(0.0, opacity - Double(deltaTime * 3.0))
            }
            
            // Devolver true si la explosión debe mantenerse, false si debe eliminarse
            return lifetime < maxLifetime
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
        isPaused = false
        lives = 3
        elapsedTime = 0
        projectiles.removeAll()
        enemies.removeAll()
        enemyProjectiles.removeAll()
        explosions.removeAll()
        lastEnemySpawnTime = 0
        lastEnemyShootTime = 0
    }
    
    // Método para avanzar al siguiente nivel
    mutating func advanceToNextLevel() {
        level += 1 // Incrementar el nivel
        isLevelCompleted = false
        isPaused = false
        elapsedTime = 0
        projectiles.removeAll()
        enemies.removeAll()
        enemyProjectiles.removeAll()
        explosions.removeAll()
        lastEnemySpawnTime = 0
        lastEnemyShootTime = 0
        
        // Aumentar la dificultad en niveles superiores
        // Por ahora, mantenemos la misma duración para todos los niveles
    }
    
    // Método para formatear el tiempo restante
    func formatTimeRemaining() -> String {
        let timeRemaining = max(0, levelDuration - elapsedTime)
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Método para alternar el estado de pausa
    mutating func togglePause() {
        isPaused = !isPaused
    }
    
    // Método para crear una explosión
    mutating func createExplosion(at position: CGPoint, size: CGFloat, isEnemy: Bool = true) {
        // Limitar el número de explosiones simultáneas para mejorar rendimiento
        if explosions.count >= 10 {
            // Eliminar la explosión más antigua
            explosions.removeFirst()
        }
        
        let explosion = Explosion(
            position: position,
            size: size,
            isEnemy: isEnemy
        )
        explosions.append(explosion)
    }
} 
