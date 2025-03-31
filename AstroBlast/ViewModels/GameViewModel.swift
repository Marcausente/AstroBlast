//
//  GameViewModel.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class GameViewModel: ObservableObject {
    @Published var gameModel = GameModel()
    @Published var isBossCharging: Bool = false // Indica si el boss está en fase de carga/pausa
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
    private let shipSpeed: CGFloat = 12 // Reducida de 18 a 12 para un movimiento más controlado
    
    // Constantes para los enemigos
    private var enemySpawnInterval: TimeInterval = 2.0 // Tiempo entre generación de enemigos
    private var enemyShootInterval: TimeInterval = 1.5 // Tiempo entre disparos enemigos
    private var enemySpeed: CGFloat = 2.0 // Velocidad de movimiento de los enemigos
    private var enemyProjectileSpeed: CGFloat = 3.5 // Reducida de 5.0 a 3.5
    private var playerProjectileSpeed: CGFloat = 10.0 // Reducida de 15.0 a 10.0
    
    // Posición Y objetivo para los enemigos (mitad de la pantalla)
    private var enemyTargetY: CGFloat {
        return screenHeight * 0.5
    }
    
    // Distancia mínima entre enemigos
    private let minEnemyDistance: CGFloat = 70
    
    // Dirección de movimiento del boss
    private var bossMovingRight = true
    
    // Inicializador que acepta un nivel
    init(level: Int = 1) {
        // Configurar el nivel inicial
        gameModel.level = level
        
        print("Inicializando GameViewModel con nivel: \(level)")
        
        // Ajustar la dificultad según el nivel
        if level == 4 {
            // Configuración especial para el nivel boss
            print("Inicializando nivel BOSS")
            gameModel.isBossLevel = true
            gameModel.isLevelCompleted = false
            gameModel.levelDuration = 9999
        }
        
        // Actualizar las dimensiones de la pantalla
        updateScreenDimensions()
        
        // Configurar el nivel (después de actualizar dimensiones)
        configureForLevel(level)
        
        // Iniciar el bucle del juego
        startGameLoop()
        
        // Registrar para notificaciones de cambio de orientación
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenDimensions), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // Método para configurar el juego según el nivel
    private func configureForLevel(_ level: Int) {
        print("GameViewModel - Configurando nivel: \(level)")
        
        // Primero configuramos los parámetros básicos a través de LevelConfiguration
        LevelConfiguration.configureForLevel(
            level,
            gameModel: &gameModel,
            enemySpawnInterval: &enemySpawnInterval,
            enemyShootInterval: &enemyShootInterval,
            enemySpeed: &enemySpeed,
            enemyProjectileSpeed: &enemyProjectileSpeed,
            spawnBoss: { [weak self] in
                // Este es el único lugar donde deberíamos generar el boss
                if self?.gameModel.enemies.isEmpty == true {
                    print("Generando boss desde callback de LevelConfiguration")
                    self?.spawnBoss()
                }
            }
        )
    }
    
    @objc private func updateScreenDimensions() {
        screenWidth = UIScreen.main.bounds.width
        screenHeight = UIScreen.main.bounds.height
    }
    
    private func startGameLoop() {
        lastUpdateTime = Date().timeIntervalSince1970
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentTime = Date().timeIntervalSince1970
            let deltaTime = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            
            // Limitamos deltaTime para evitar saltos bruscos si hay lag
            let cappedDeltaTime = min(deltaTime, 0.033) // Máximo ~30fps
            
            self.updateGame(deltaTime: cappedDeltaTime)
        }
        
        // Asegurarnos que el timer se ejecute en el modo común de ejecución
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func updateGame(deltaTime: TimeInterval) {
        if gameModel.isGameOver || gameModel.isLevelCompleted {
            return
        }
        
        // Si el juego está pausado, no actualizar
        if gameModel.isPaused {
            return
        }
        
        // Actualizar el tiempo transcurrido
        gameModel.elapsedTime += deltaTime
        
        // Comprobar si se ha completado el nivel (solo para niveles normales, no para el boss)
        if !gameModel.isBossLevel && gameModel.elapsedTime >= gameModel.levelDuration {
            gameModel.isLevelCompleted = true
            return
        }
        
        updateProjectiles()
        updateShipPosition()
        updateEnemies(deltaTime: deltaTime)
        updateEnemyProjectiles()
        updateExplosions(deltaTime: deltaTime)
        checkCollisions()
        
        // Solo generar enemigos y disparos enemigos si no estamos en nivel de jefe
        if !gameModel.isBossLevel {
            spawnEnemies(deltaTime: deltaTime)
            enemyShoot(deltaTime: deltaTime)
        } else if !gameModel.enemies.isEmpty {
            // Si estamos en nivel de jefe, usar un patrón de disparo especial
            bossShoot(deltaTime: deltaTime)
        } else if gameModel.isBossLevel && gameModel.elapsedTime > 2.0 {
            // Si no hay enemigos en el nivel de jefe y ha pasado suficiente tiempo,
            // significa que el boss ha sido derrotado
            print("Boss derrotado. Nivel completado.")
            gameModel.isLevelCompleted = true
        }
    }
    
    private func updateShipPosition() {
        if joystickDirection != 0 {
            // Calculamos el desplazamiento basado en la dirección del joystick
            let movement = joystickDirection * shipSpeed
            
            // Movemos la nave
            movePlayer(to: gameModel.playerPosition + movement)
        }
    }
    
    private func updateProjectiles() {
        // Actualizar proyectiles del jugador
        for (index, projectile) in gameModel.projectiles.enumerated().reversed() {
            // Si el proyectil sale de la pantalla, eliminarlo
            if projectile.position.y < -10 {
                if index < gameModel.projectiles.count {
                    gameModel.projectiles.remove(at: index)
                }
                continue
            }
            
            // Mover el proyectil
            var newPosition = projectile.position
            newPosition.y -= playerProjectileSpeed
            
            if index < gameModel.projectiles.count {
                gameModel.projectiles[index].position = newPosition
            }
            
            // Comprobar colisiones con enemigos
            for (enemyIndex, enemy) in gameModel.enemies.enumerated().reversed() {
                if enemy.isHit(by: projectile) {
                    // Crear una explosión en la posición del enemigo
                    createExplosion(
                        at: enemy.position,
                        size: enemy.size.width * 0.3,
                        isEnemy: true
                    )
                    
                    // Reproducir el sonido de explosión
                    AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
                    
                    // Eliminar el proyectil
                    if index < gameModel.projectiles.count {
                        gameModel.projectiles.remove(at: index)
                    }
                    
                    // Si es un boss, reducir su salud en lugar de eliminarlo directamente
                    if enemy.type == .boss {
                        if enemyIndex < gameModel.enemies.count {
                            var updatedBoss = gameModel.enemies[enemyIndex]
                            updatedBoss.health -= 1
                            print("Boss dañado. Salud restante: \(updatedBoss.health)")
                            
                            // Si el boss ha sido derrotado
                            if updatedBoss.health <= 0 {
                                // Crear una gran explosión para el boss
                                createExplosion(
                                    at: updatedBoss.position,
                                    size: updatedBoss.size.width,
                                    isEnemy: true
                                )
                                
                                // Eliminar el boss
                                gameModel.enemies.remove(at: enemyIndex)
                                
                                // Incrementar la puntuación (más puntos por derrotar al boss)
                                increaseScore(by: 50)
                                
                                // Marcar el nivel como completado
                                gameModel.isLevelCompleted = true
                            } else {
                                // Actualizar el boss con la salud reducida
                                gameModel.enemies[enemyIndex] = updatedBoss
                            }
                        }
                    } else {
                        // Para enemigos normales, eliminarlos directamente
                        if enemyIndex < gameModel.enemies.count {
                            gameModel.enemies.remove(at: enemyIndex)
                        }
                        
                        // Incrementar la puntuación
                        increaseScore()
                    }
                    
                    break
                }
            }
        }
        
        // Forzar actualización de la UI
        objectWillChange.send()
    }
    
    private func updateEnemies(deltaTime: TimeInterval) {
        
        for i in 0..<gameModel.enemies.count {
            if i < gameModel.enemies.count && gameModel.enemies[i].targetY == nil {
                var enemy = gameModel.enemies[i]
                enemy.targetY = enemyTargetY
                gameModel.enemies[i] = enemy
            }
        }
        
        var positionMap: [CGPoint: Bool] = [:]
        for enemy in gameModel.enemies {
            let gridX = Int(enemy.position.x / 60) // Tamaño de la cuadrícula
            let gridY = Int(enemy.position.y / 60) // Añadimos la definición de gridY

            positionMap[CGPoint(x: gridX, y: gridY)] = true
        }
        
        for i in 0..<gameModel.enemies.count {
            if i < gameModel.enemies.count {
                var enemy = gameModel.enemies[i]
                
                // Comportamiento especial para el boss
                if enemy.type == .boss {
                    updateBossMovement(deltaTime: deltaTime, bossIndex: i)
                    continue
                }
                
                if enemy.isMoving {
                    let gridX = Int(enemy.position.x / 60)
                    let gridY = Int(enemy.position.y / 60)
                    
                    let shouldStop = positionMap[CGPoint(x: gridX, y: gridY + 1)] == true
                    
                    if !shouldStop {
                        enemy.position.y += enemySpeed
                        
                        // Verificar si ha llegado a la posición objetivo
                        if let targetY = enemy.targetY, enemy.position.y >= targetY {
                            enemy.position.y = targetY // Ajustar a la posición exacta
                            enemy.isMoving = false // Detener el movimiento
                        }
                    } else {
                        // Si hay un obstáculo, detener temporalmente
                        enemy.isMoving = false
                    }
                } else {
                    // Verificar si puede moverse nuevamente
                    let gridX = Int(enemy.position.x / 60)
                    let gridY = Int(enemy.position.y / 60)
                    
                    let canMove = positionMap[CGPoint(x: gridX, y: gridY + 1)] != true
                    
                    // Si puede moverse y no ha llegado a su objetivo, reanudar movimiento
                    if canMove && enemy.position.y < enemy.targetY! {
                        enemy.isMoving = true
                    }
                }
                
                // Si el enemigo sale de la pantalla, lo eliminamos
                if enemy.position.y > screenHeight + 50 {
                    gameModel.enemies.remove(at: i)
                } else {
                    gameModel.enemies[i] = enemy
                }
            }
        }
    }
    
    // Método para actualizar el movimiento del boss
    private func updateBossMovement(deltaTime: TimeInterval, bossIndex: Int) {
        if bossIndex < gameModel.enemies.count {
            var boss = gameModel.enemies[bossIndex]
            
            // Si el boss aún está descendiendo a su posición inicial
            if boss.isMoving {
                boss.position.y += enemySpeed
                
                if let targetY = boss.targetY, boss.position.y >= targetY {
                    boss.position.y = targetY // Ajustar a la posición exacta
                    boss.isMoving = false // Detener el descenso
                }
            } else {
                // Movimiento lateral del boss
                let moveSpeed: CGFloat = 2.0
                
                if bossMovingRight {
                    boss.position.x += moveSpeed
                    
                    // Cambiar dirección si llega al borde derecho
                    if boss.position.x > screenWidth - boss.size.width/2 {
                        bossMovingRight = false
                    }
                } else {
                    boss.position.x -= moveSpeed
                    
                    // Cambiar dirección si llega al borde izquierdo
                    if boss.position.x < boss.size.width/2 {
                        bossMovingRight = true
                    }
                }
            }
            
            gameModel.enemies[bossIndex] = boss
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
    
    private func updateExplosions(deltaTime: TimeInterval) {
        // Actualizar todas las explosiones
        for i in (0..<gameModel.explosions.count).reversed() {
            if i < gameModel.explosions.count {
                var explosion = gameModel.explosions[i]
                
                // Actualizar la explosión y verificar si debe mantenerse
                if !explosion.update(deltaTime: deltaTime) {
                    // Si la explosión ha terminado, eliminarla
                    gameModel.explosions.remove(at: i)
                } else {
                    // Actualizar la explosión en el modelo
                    gameModel.explosions[i] = explosion
                }
            }
        }
    }
    
    private func spawnEnemies(deltaTime: TimeInterval) {
        gameModel.lastEnemySpawnTime += deltaTime
        
        // Generar un nuevo enemigo cada cierto tiempo
        if gameModel.lastEnemySpawnTime >= enemySpawnInterval {
            gameModel.lastEnemySpawnTime = 0
            
            // Limitar el número máximo de enemigos para evitar sobrecarga
            let maxEnemies = 10 + (gameModel.level * 3)
            if gameModel.enemies.count >= maxEnemies {
                return
            }
            
            // Posición aleatoria en X
            let randomX = CGFloat.random(in: 50...(screenWidth - 50))
            
            // Verificar si hay espacio para un nuevo enemigo
            var canSpawn = true
            
            for enemy in gameModel.enemies {
                // Si hay un enemigo cerca de la posición de generación
                if abs(enemy.position.x - randomX) < 60 && enemy.position.y < 100 {
                    canSpawn = false
                    break
                }
            }
            
            // Solo generar si hay espacio
            if canSpawn {
                // Personalización de enemigos según el nivel
                var enemySize = CGSize(width: 60, height: 60)
                var enemyHealth = 1
                var enemyType: Enemy.EnemyType = .normal
                
                switch gameModel.level {
                case 1:
                    // Nivel 1: Enemigos básicos
                    enemyHealth = 1
                    enemySize = CGSize(width: 60, height: 60)
                    enemyType = .normal
                    
                case 2:
                    // Nivel 2: Enemigos básicos
                    enemyHealth = 1
                    enemySize = CGSize(width: 60, height: 60)
                    enemyType = .normal
                    
                case 3:
                    // Nivel 3: Dos tipos de enemigos
                    let roll = Int.random(in: 1...10)
                    if roll <= 6 {
                        // 60% de probabilidad para enemigos normales
                        enemyHealth = 1
                        enemySize = CGSize(width: 60, height: 60)
                        enemyType = .normal
                    } else {
                        // 40% de probabilidad para enemigos grandes
                        enemyHealth = 2
                        enemySize = CGSize(width: 70, height: 70)
                        enemyType = .big
                    }
                    
                default:
                    // Si por alguna razón se intenta acceder a un nivel superior al 3,
                    // se usa la configuración del nivel 1
                    enemyHealth = 1
                    enemySize = CGSize(width: 60, height: 60)
                    enemyType = .normal
                }
                
                // Crear un nuevo enemigo en la parte superior de la pantalla
                var enemy = Enemy(
                    position: CGPoint(x: randomX, y: 50),
                    isMoving: true,
                    targetY: enemyTargetY
                )
                
                // Configurar salud, tamaño y tipo
                enemy.health = enemyHealth
                enemy.size = enemySize
                enemy.type = enemyType
                
                gameModel.enemies.append(enemy)
            }
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
        let playerPosition = CGPoint(x: gameModel.playerPosition, y: getShipYPosition())
        let playerSize = CGSize(width: shipWidth * 0.85, height: shipHeight * 0.85) // Hitbox de la nave
        let playerRect = CGRect(
            x: playerPosition.x - playerSize.width/2,
            y: playerPosition.y - playerSize.height/2,
            width: playerSize.width,
            height: playerSize.height
        )
        
        // Verificar colisiones entre proyectiles del jugador y enemigos
        for (projectileIndex, projectile) in gameModel.projectiles.enumerated().reversed() {
            // Si el proyectil está fuera del área de enemigos, saltar
            if projectile.position.y < 0 {
                continue
            }
            
            for (enemyIndex, currentEnemy) in gameModel.enemies.enumerated().reversed() {
                if currentEnemy.isHit(by: projectile) {
                    // Eliminar el proyectil
                    if projectileIndex < gameModel.projectiles.count {
                        gameModel.projectiles.remove(at: projectileIndex)
                    }
                    
                    // Reducir la salud del enemigo o eliminarlo
                    if enemyIndex < gameModel.enemies.count {
                        var updatedEnemy = currentEnemy
                        updatedEnemy.health -= 1
                        
                        if updatedEnemy.health <= 0 {
                            // Crear una explosión en la posición del enemigo
                            createExplosion(
                                at: currentEnemy.position,
                                size: currentEnemy.size.width,
                                isEnemy: true
                            )
                            
                            // Reproducir el sonido de explosión
                            AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
                            
                            // Eliminar el enemigo
                            gameModel.enemies.remove(at: enemyIndex)
                            
                            // Incrementar la puntuación (más puntos para enemigos más difíciles)
                            let basePoints = 10
                            let levelMultiplier = max(1, gameModel.level)
                            let healthMultiplier = currentEnemy.type == .big ? 2 : 1
                            
                            gameModel.score += basePoints * levelMultiplier * healthMultiplier
                        } else {
                            // Actualizar el enemigo con la salud reducida pero manteniendo su tipo
                            updatedEnemy.type = currentEnemy.type // Mantener el tipo original
                            gameModel.enemies[enemyIndex] = updatedEnemy
                        }
                    }
                    
                    break
                }
            }
        }
        
        // Verificar colisiones entre proyectiles enemigos y el jugador
        for (projectileIndex, projectile) in gameModel.enemyProjectiles.enumerated().reversed() {
            if playerRect.contains(projectile.position) {
                // Eliminar el proyectil
                if projectileIndex < gameModel.enemyProjectiles.count {
                    gameModel.enemyProjectiles.remove(at: projectileIndex)
                }
                
                // Crear una pequeña explosión donde impactó el proyectil
                createExplosion(
                    at: projectile.position,
                    size: 30,
                    isEnemy: false
                )
                
                // Reproducir el sonido de explosión
                AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
                
                // Reducir vidas
                gameModel.lives -= 1
                
                // Verificar si el juego ha terminado
                if gameModel.lives <= 0 {
                    // Crear una explosión grande para la nave del jugador
                    createExplosion(
                        at: playerPosition,
                        size: shipWidth * 1.5,
                        isEnemy: false
                    )
                    
                    AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
                    
                    gameModel.isGameOver = true
                }
                
                break
            }
        }
        
        // Verificar colisiones entre enemigos y el jugador
        for (enemyIndex, currentEnemy) in gameModel.enemies.enumerated().reversed() {
            let enemyRect = CGRect(
                x: currentEnemy.position.x - currentEnemy.size.width/2,
                y: currentEnemy.position.y - currentEnemy.size.height/2,
                width: currentEnemy.size.width,
                height: currentEnemy.size.height
            )
            
            if enemyRect.intersects(playerRect) {
                // Crear una explosión en la posición del enemigo
                createExplosion(
                    at: currentEnemy.position,
                    size: currentEnemy.size.width,
                    isEnemy: true
                )
                
                // Reproducir el sonido de explosión
                AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
                
                // Eliminar el enemigo
                if enemyIndex < gameModel.enemies.count {
                    gameModel.enemies.remove(at: enemyIndex)
                }
                
                // Reducir vidas
                gameModel.lives -= 1
                
                // Verificar si el juego ha terminado
                if gameModel.lives <= 0 {
                    // Crear una explosión grande para la nave del jugador
                    createExplosion(
                        at: playerPosition,
                        size: shipWidth * 1.5,
                        isEnemy: false
                    )
                    
                    // Reproducir el sonido de explosión para la nave del jugador
                    AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
                    
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
        // Si el juego está pausado, no permitir disparar
        if gameModel.isPaused {
            return
        }
        
        // Comprobar si ha pasado suficiente tiempo desde el último disparo
        let currentTime = Date()
        if currentTime.timeIntervalSince(gameModel.lastShotTime) < gameModel.playerShootCooldown {
            return // No ha pasado suficiente tiempo, ignorar este disparo
        }
        
        // Actualizar el tiempo del último disparo
        gameModel.lastShotTime = currentTime
        
        // Reproducir el sonido de disparo
        AudioManager.shared.playSoundEffect(filename: "Sounds/Shotsound.mp3")
        
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
        gameModel.level = max(1, gameModel.level) // Mantener el nivel actual
        configureForLevel(gameModel.level) // Reconfigurar para el nivel actual
    }
    
    // Método para avanzar al siguiente nivel
    func advanceToNextLevel() {
        let nextLevel = gameModel.level + 1
        
        // Si ya completamos el nivel 4 (boss), volvemos al nivel 1
        if gameModel.level == 4 {
            // En este caso, solo regresamos al menú (la vista GameView se encargará de mostrar el botón)
            return
        }
        
        gameModel.advanceToNextLevel()
        gameModel.lives = 3 // Restablecer las vidas a 3
        configureForLevel(nextLevel) // Configurar para el nuevo nivel
    }
    
    // Método para incrementar la puntuación
    func increaseScore(by points: Int = 10) {
        gameModel.score += points
    }
    
    // Método para alternar el estado de pausa
    func togglePause() {
        gameModel.togglePause()
    }
    
    // Método para crear una explosión
    func createExplosion(at position: CGPoint, size: CGFloat, isEnemy: Bool = true) {
        // Limitar el número de explosiones simultáneas para mejorar rendimiento
        if gameModel.explosions.count >= 10 {
            // Eliminar la explosión más antigua
            gameModel.explosions.removeFirst()
        }
        
        let explosion = GameModel.Explosion(
            position: position,
            size: size,
            isEnemy: isEnemy
        )
        gameModel.explosions.append(explosion)
        
        // Reproducir el sonido de explosión
        AudioManager.shared.playSoundEffect(filename: "Sounds/Destroysound.mp3")
    }
    
    // Método para generar el boss
    private func spawnBoss() {
        // Verificar si ya existe un boss
        let bosses = gameModel.enemies.filter { $0.type == .boss }
        if !bosses.isEmpty {
            print("Ya existe un boss en el juego. No se generará otro.")
            return
        }
        
        print("Generando boss...")
        
        // Crear el boss en el centro de la pantalla
        var boss = Enemy(
            position: CGPoint(x: screenWidth/2, y: 100),
            health: 85,
            size: CGSize(width: 280, height: 280), // Boss más grande
            isMoving: true,
            type: .boss
        )
        
        // Añadir el boss al juego
        gameModel.enemies.append(boss)
        
        print("Boss generado con \(boss.health) de salud y tamaño \(boss.size)")
    }
    
    // Variable para controlar el ciclo de disparo del boss
    private var bossShootingCycle: TimeInterval = 0
    private let bossShootingPeriod: TimeInterval = 3.0 // 3 segundos de disparos, 1 segundo de pausa
    
    // Método para el patrón de disparo del boss
    private func bossShoot(deltaTime: TimeInterval) {
        // Actualizar el ciclo de disparo
        bossShootingCycle += deltaTime
        if bossShootingCycle >= 5.0 { // Aumentado de 4.0 a 5.0 segundos (3 de disparos + 2 de pausa)
            bossShootingCycle = 0
        }
        
        // Actualizar el estado de carga del boss
        isBossCharging = bossShootingCycle >= 3.0
        
        // Solo disparar durante los primeros 3 segundos del ciclo (pausa en los últimos 2 segundos)
        if bossShootingCycle < 3.0 {
            gameModel.lastEnemyShootTime += deltaTime
            
            // El boss dispara más frecuentemente
            if gameModel.lastEnemyShootTime >= enemyShootInterval && !gameModel.enemies.isEmpty {
                gameModel.lastEnemyShootTime = 0
                
                // Obtener el boss (primer enemigo)
                let boss = gameModel.enemies[0]
                
                // Posición del jugador
                let playerPosition = CGPoint(x: gameModel.playerPosition, y: getShipYPosition())
                
                // Diferentes patrones de disparo según el momento del ciclo
                if bossShootingCycle < 0.8 {
                    // Patrón 1: Disparo directo (primeros 0.8 segundos del ciclo)
                    for i in 0...2 { // 3 disparos cada vez
                        // Calcular posiciones de disparo (izquierda, centro, derecha)
                        let offsetX = CGFloat(i - 1) * (boss.size.width * 0.4)
                        let shootPosition = CGPoint(
                            x: boss.position.x + offsetX,
                            y: boss.position.y + boss.size.height * 0.4
                        )
                        
                        // Dirección directa hacia el jugador
                        let direction = GameModel.Projectile.directionToTarget(
                            from: shootPosition,
                            to: playerPosition
                        )
                        
                        // Crear proyectil
                        let projectile = GameModel.Projectile(
                            position: shootPosition,
                            isEnemy: true,
                            direction: direction
                        )
                        
                        gameModel.enemyProjectiles.append(projectile)
                    }
                } else if bossShootingCycle < 1.8 {
                    // Pausa entre patrones de 0.8 a 1.8
                } else if bossShootingCycle < 2.6 {
                    // Patrón 2: Disparo en abanico (segundos 1.8-2.6 del ciclo)
                    for i in 0...4 { // 5 disparos en abanico
                        let baseAngle = -0.4 // Ángulo inicial
                        let angleStep = 0.2 // Incremento entre cada disparo
                        let angle = baseAngle + (Double(i) * angleStep)
                        
                        let shootPosition = CGPoint(
                            x: boss.position.x,
                            y: boss.position.y + boss.size.height * 0.4
                        )
                        
                        // Crear dirección basada en el ángulo
                        let direction = CGVector(
                            dx: CGFloat(sin(angle)),
                            dy: CGFloat(cos(angle))
                        )
                        
                        // Crear proyectil
                        let projectile = GameModel.Projectile(
                            position: shootPosition,
                            isEnemy: true,
                            direction: direction
                        )
                        
                        gameModel.enemyProjectiles.append(projectile)
                    }
                }
                // No hay tercer patrón, dejando más tiempo de pausa entre ciclos completos
            }
        }
        // Durante los últimos 2 segundos del ciclo, el boss no dispara (pausa más larga)
    }
} 
