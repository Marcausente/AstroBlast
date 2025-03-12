//
//  GameViewModel.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameModel = GameModel()
    private var timer: Timer?
    private var lastUpdateTime: TimeInterval = 0
    
    // Dimensiones de la pantalla para cálculos
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    // Constantes para la posición y tamaño de la nave
    private let shipHeight: CGFloat = 80 // Altura de la nave
    private let shipWidth: CGFloat = 80 // Ancho de la nave
    
    // Posición relativa de la nave (porcentaje de la pantalla)
    // Ajustamos la posición para que la nave esté en una posición intermedia (70% desde la parte superior)
    private let shipYPositionRatio: CGFloat = 0.70
    
    // Dirección del joystick (-1 a 1)
    @Published var joystickDirection: CGFloat = 0
    
    // Velocidad de movimiento de la nave
    private let shipSpeed: CGFloat = 10
    
    // Constantes para los enemigos
    private let enemySpawnInterval: TimeInterval = 2.0 // Tiempo entre generación de enemigos
    private let enemyShootInterval: TimeInterval = 1.5 // Tiempo entre disparos enemigos
    private let enemySpeed: CGFloat = 2.0 // Velocidad de movimiento de los enemigos
    private let enemyProjectileSpeed: CGFloat = 5.0 // Velocidad de los proyectiles enemigos
    private let playerProjectileSpeed: CGFloat = 15.0 // Velocidad de los proyectiles del jugador
    
    init() {
        // Actualizar las dimensiones de la pantalla
        updateScreenDimensions()
        
        // Iniciar el bucle del juego
        startGameLoop()
        
        // Registrar para notificaciones de cambio de orientación
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenDimensions), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func updateScreenDimensions() {
        screenWidth = UIScreen.main.bounds.width
        screenHeight = UIScreen.main.bounds.height
    }
    
    private func startGameLoop() {
        lastUpdateTime = Date().timeIntervalSince1970
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentTime = Date().timeIntervalSince1970
            let deltaTime = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            
            self.updateGame(deltaTime: deltaTime)
        }
    }
    
    private func updateGame(deltaTime: TimeInterval) {
        if gameModel.isGameOver || gameModel.isLevelCompleted {
            return
        }
        
        // Actualizar el tiempo transcurrido
        gameModel.elapsedTime += deltaTime
        
        // Comprobar si se ha completado el nivel
        if gameModel.elapsedTime >= gameModel.levelDuration {
            gameModel.isLevelCompleted = true
            return
        }
        
        updateProjectiles()
        updateShipPosition()
        updateEnemies(deltaTime: deltaTime)
        updateEnemyProjectiles()
        checkCollisions()
        spawnEnemies(deltaTime: deltaTime)
        enemyShoot(deltaTime: deltaTime)
    }
    
    private func updateShipPosition() {
        if joystickDirection != 0 {
            // Calculamos el nuevo desplazamiento basado en la dirección del joystick
            let movement = joystickDirection * shipSpeed
            
            // Movemos la nave
            movePlayer(to: gameModel.playerPosition + movement)
        }
    }
    
    private func updateProjectiles() {
        // Mover los proyectiles del jugador hacia arriba
        for i in 0..<gameModel.projectiles.count {
            if i < gameModel.projectiles.count {
                var projectile = gameModel.projectiles[i]
                
                // Mover el proyectil en la dirección establecida
                projectile.position.x += projectile.direction.dx * playerProjectileSpeed
                projectile.position.y += projectile.direction.dy * playerProjectileSpeed
                
                // Si el proyectil sale de la pantalla, lo eliminamos
                if projectile.position.y < 0 || 
                   projectile.position.y > screenHeight ||
                   projectile.position.x < 0 || 
                   projectile.position.x > screenWidth {
                    gameModel.projectiles.remove(at: i)
                } else {
                    gameModel.projectiles[i] = projectile
                }
            }
        }
        
        // Forzar actualización de la UI
        objectWillChange.send()
    }
    
    private func updateEnemies(deltaTime: TimeInterval) {
        // Mover los enemigos hacia abajo
        for i in 0..<gameModel.enemies.count {
            if i < gameModel.enemies.count {
                var enemy = gameModel.enemies[i]
                
                // Mover el enemigo hacia abajo
                enemy.position.y += enemySpeed
                
                // Si el enemigo sale de la pantalla, lo eliminamos
                if enemy.position.y > screenHeight + 50 {
                    gameModel.enemies.remove(at: i)
                } else {
                    gameModel.enemies[i] = enemy
                }
            }
        }
    }
    
    private func updateEnemyProjectiles() {
        // Mover los proyectiles enemigos en su dirección
        for i in 0..<gameModel.enemyProjectiles.count {
            if i < gameModel.enemyProjectiles.count {
                var projectile = gameModel.enemyProjectiles[i]
                
                // Mover el proyectil en la dirección establecida
                projectile.position.x += projectile.direction.dx * enemyProjectileSpeed
                projectile.position.y += projectile.direction.dy * enemyProjectileSpeed
                
                // Si el proyectil sale de la pantalla, lo eliminamos
                if projectile.position.y < 0 || 
                   projectile.position.y > screenHeight ||
                   projectile.position.x < 0 || 
                   projectile.position.x > screenWidth {
                    gameModel.enemyProjectiles.remove(at: i)
                } else {
                    gameModel.enemyProjectiles[i] = projectile
                }
            }
        }
    }
    
    private func spawnEnemies(deltaTime: TimeInterval) {
        gameModel.lastEnemySpawnTime += deltaTime
        
        // Generar un nuevo enemigo cada cierto tiempo
        if gameModel.lastEnemySpawnTime >= enemySpawnInterval {
            gameModel.lastEnemySpawnTime = 0
            
            // Posición aleatoria en X
            let randomX = CGFloat.random(in: 50...(screenWidth - 50))
            
            // Crear un nuevo enemigo en la parte superior de la pantalla
            let enemy = GameModel.Enemy(
                position: CGPoint(x: randomX, y: 50)
            )
            
            gameModel.enemies.append(enemy)
        }
    }
    
    private func enemyShoot(deltaTime: TimeInterval) {
        gameModel.lastEnemyShootTime += deltaTime
        
        // Hacer que los enemigos disparen cada cierto tiempo
        if gameModel.lastEnemyShootTime >= enemyShootInterval {
            gameModel.lastEnemyShootTime = 0
            
            // Seleccionar un enemigo aleatorio para disparar
            if !gameModel.enemies.isEmpty {
                let randomIndex = Int.random(in: 0..<gameModel.enemies.count)
                let enemy = gameModel.enemies[randomIndex]
                
                // Posición del jugador
                let playerPosition = CGPoint(x: gameModel.playerPosition, y: getShipYPosition())
                
                // Calcular la dirección hacia el jugador
                let direction = GameModel.Projectile.directionToTarget(
                    from: enemy.position,
                    to: playerPosition
                )
                
                // Crear un proyectil enemigo dirigido hacia el jugador
                let projectile = GameModel.Projectile(
                    position: CGPoint(x: enemy.position.x, y: enemy.position.y + enemy.size.height/2),
                    isEnemy: true,
                    direction: direction
                )
                
                gameModel.enemyProjectiles.append(projectile)
            }
        }
    }
    
    private func checkCollisions() {
        // Verificar colisiones entre proyectiles del jugador y enemigos
        for (projectileIndex, projectile) in gameModel.projectiles.enumerated().reversed() {
            for (enemyIndex, enemy) in gameModel.enemies.enumerated().reversed() {
                if enemy.isHit(by: projectile) {
                    // Eliminar el proyectil
                    if projectileIndex < gameModel.projectiles.count {
                        gameModel.projectiles.remove(at: projectileIndex)
                    }
                    
                    // Eliminar el enemigo
                    if enemyIndex < gameModel.enemies.count {
                        gameModel.enemies.remove(at: enemyIndex)
                    }
                    
                    // Incrementar la puntuación
                    gameModel.score += 10
                    
                    // Aumentar el nivel cada 100 puntos
                    if gameModel.score % 100 == 0 {
                        gameModel.level += 1
                    }
                    
                    break
                }
            }
        }
        
        // Verificar colisiones entre proyectiles enemigos y el jugador
        let playerPosition = CGPoint(x: gameModel.playerPosition, y: getShipYPosition())
        let playerSize = CGSize(width: shipWidth, height: shipHeight)
        
        for (projectileIndex, projectile) in gameModel.enemyProjectiles.enumerated().reversed() {
            if gameModel.isPlayerHit(playerPosition: playerPosition, playerSize: playerSize, by: projectile) {
                // Eliminar el proyectil
                if projectileIndex < gameModel.enemyProjectiles.count {
                    gameModel.enemyProjectiles.remove(at: projectileIndex)
                }
                
                // Reducir vidas
                gameModel.lives -= 1
                
                // Verificar si el juego ha terminado
                if gameModel.lives <= 0 {
                    gameModel.isGameOver = true
                }
                
                break
            }
        }
        
        // Verificar colisiones entre enemigos y el jugador
        for (enemyIndex, enemy) in gameModel.enemies.enumerated().reversed() {
            let enemyRect = CGRect(
                x: enemy.position.x - enemy.size.width/2,
                y: enemy.position.y - enemy.size.height/2,
                width: enemy.size.width,
                height: enemy.size.height
            )
            
            let playerRect = CGRect(
                x: playerPosition.x - playerSize.width/2,
                y: playerPosition.y - playerSize.height/2,
                width: playerSize.width,
                height: playerSize.height
            )
            
            if enemyRect.intersects(playerRect) {
                // Eliminar el enemigo
                if enemyIndex < gameModel.enemies.count {
                    gameModel.enemies.remove(at: enemyIndex)
                }
                
                // Reducir vidas
                gameModel.lives -= 1
                
                // Verificar si el juego ha terminado
                if gameModel.lives <= 0 {
                    gameModel.isGameOver = true
                }
                
                break
            }
        }
    }
    
    // Método para mover la nave del jugador
    func movePlayer(to xPosition: CGFloat) {
        // Aseguramos que la nave no salga de los límites de la pantalla
        let halfPlayerWidth: CGFloat = shipWidth / 2
        let minX = halfPlayerWidth
        let maxX = screenWidth - halfPlayerWidth
        
        gameModel.playerPosition = min(max(xPosition, minX), maxX)
    }
    
    // Método para disparar
    func shoot() {
        // Calculamos la posición Y del proyectil justo encima de la nave
        
        // Calculamos la posición Y de la nave basada en el tamaño de la pantalla
        let shipY = screenHeight * shipYPositionRatio
        
        // El proyectil debe aparecer justo encima de la nave
        let projectileY = shipY - shipHeight / 2 - 5 // 5 píxeles por encima de la nave
        
        let projectile = GameModel.Projectile(
            position: CGPoint(x: gameModel.playerPosition, y: projectileY),
            isEnemy: false,
            direction: CGVector(dx: 0, dy: -1) // Dirección hacia arriba
        )
        gameModel.projectiles.append(projectile)
    }
    
    // Método para obtener la posición Y de la nave
    func getShipYPosition() -> CGFloat {
        return screenHeight * shipYPositionRatio
    }
    
    // Método para reiniciar el juego
    func restartGame() {
        gameModel.resetGame()
    }
    
    // Método para avanzar al siguiente nivel
    func advanceToNextLevel() {
        gameModel.advanceToNextLevel()
    }
    
    // Método para incrementar la puntuación
    func increaseScore(by points: Int = 10) {
        gameModel.score += points
    }
} 