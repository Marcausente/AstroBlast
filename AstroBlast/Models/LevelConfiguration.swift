import Foundation
import AVFoundation

class LevelConfiguration {
    static func configureForLevel(
        _ level: Int,
        gameModel: inout GameModel,
        enemySpawnInterval: inout TimeInterval,
        enemyShootInterval: inout TimeInterval,
        enemySpeed: inout CGFloat,
        enemyProjectileSpeed: inout CGFloat,
        spawnBoss: (() -> Void)? = nil
    ) {
        // Reiniciar el estado del nivel
        gameModel.isLevelCompleted = false
        gameModel.elapsedTime = 0
        
        print("Configurando nivel: \(level)")
        
        switch level {
        case 1:
            // Nivel 1: Configuración básica
            enemySpawnInterval = 2.2  // Tiempo de spawn
            enemyShootInterval = 1.6  // Tiempo dentre disparos enemigos
            enemySpeed = 1.5 // velocidad de los enemigos
            enemyProjectileSpeed = 3.5 //Velocidad de proyectiles
            gameModel.levelDuration = 60 // Tiempo que dura el nivel
            gameModel.playerShootCooldown = 0.4
            gameModel.isBossLevel = false
            
            // Música del nivel 1
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/spacemusic.mp3")
            
        case 2:
            enemySpawnInterval = 1.5  // Tiempo de spawn
            enemyShootInterval = 1.3  // Tiempo de disparo
            enemySpeed = 1.8
            enemyProjectileSpeed = 4.0
            gameModel.levelDuration = 60
            gameModel.playerShootCooldown = 0.35
            gameModel.isBossLevel = false
            
            // Música del nivel 2
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/Bowser's Galaxy Generator - Super Mario Galaxy 2.mp3")
            
        case 3:
            // Nivel 3: Enemigos más agresivos, fondo morado
            enemySpawnInterval = 1.2  // Tiempo de spawn
            enemyShootInterval = 1.0  // Tiempo de disparo
            enemySpeed = 2.0
            enemyProjectileSpeed = 4.5
            gameModel.levelDuration = 60
            gameModel.playerShootCooldown = 0.3
            gameModel.isBossLevel = false
            
            // Música del nivel 3
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/Melty Monster Galaxy - Super Mario Galaxy 2.mp3")
            
        case 4:
            print("Configurando nivel de BOSS")
            // Nivel 4: Boss final
            enemyShootInterval = 0.8
            enemySpeed = 0.3
            enemyProjectileSpeed = 3.0
            gameModel.playerShootCooldown = 0.25 // Esto es para que el player dispare un poquito mas rapido
            gameModel.isBossLevel = true // Activar el modo boss
            gameModel.levelDuration = 9999 // Un valor alto para que no termine automáticamente
            
            // Música del nivel del boss
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/bossmusic.mp3") // Música especial para el boss
            
            // Eliminar todos los enemigos existentes
            gameModel.enemies.removeAll()
            gameModel.enemyProjectiles.removeAll()
            gameModel.projectiles.removeAll()
            
            // Llamar a la función para generar el boss una sola vez
            if let spawnBossFunction = spawnBoss {
                print("Llamando a la función spawnBoss desde LevelConfiguration")
                // Ejecutar después de un breve delay para asegurar que todo está listo
                DispatchQueue.main.async {
                    spawnBossFunction()
                }
            } else {
                print("ERROR: La función spawnBoss es nil")
            }
            
        default:
            // Si por alguna razón se intenta acceder a un nivel superior al 4,
            // se reinicia al nivel 1
            configureForLevel(1, 
                             gameModel: &gameModel, 
                             enemySpawnInterval: &enemySpawnInterval, 
                             enemyShootInterval: &enemyShootInterval, 
                             enemySpeed: &enemySpeed, 
                             enemyProjectileSpeed: &enemyProjectileSpeed,
                             spawnBoss: spawnBoss)
        }
    }
} 
