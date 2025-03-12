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
    
    // Dimensiones de la pantalla para cálculos
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    // Constantes para la posición y tamaño de la nave
    private let shipHeight: CGFloat = 80 // Altura de la nave
    private let shipWidth: CGFloat = 80 // Ancho de la nave
    
    // Posición relativa de la nave (porcentaje de la pantalla)
    // Ajustamos la posición para que la nave esté más arriba (75% desde la parte superior)
    private let shipYPositionRatio: CGFloat = 0.75
    
    // Dirección del joystick (-1 a 1)
    @Published var joystickDirection: CGFloat = 0
    
    // Velocidad de movimiento de la nave
    private let shipSpeed: CGFloat = 10
    
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func updateGame() {
        updateProjectiles()
        updateShipPosition()
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
        // Mover los proyectiles hacia arriba
        for i in 0..<gameModel.projectiles.count {
            if i < gameModel.projectiles.count {
                var projectile = gameModel.projectiles[i]
                projectile.position.y -= 15 // Velocidad del proyectil aumentada
                
                // Si el proyectil sale de la pantalla, lo eliminamos
                if projectile.position.y < 0 {
                    gameModel.projectiles.remove(at: i)
                } else {
                    gameModel.projectiles[i] = projectile
                }
            }
        }
        
        // Forzar actualización de la UI
        objectWillChange.send()
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
            position: CGPoint(x: gameModel.playerPosition, y: projectileY)
        )
        gameModel.projectiles.append(projectile)
    }
    
    // Método para obtener la posición Y de la nave
    func getShipYPosition() -> CGFloat {
        return screenHeight * shipYPositionRatio
    }
    
    // Método para incrementar la puntuación
    func increaseScore(by points: Int = 10) {
        gameModel.score += points
    }
    
    // Método para avanzar al siguiente nivel
    func nextLevel() {
        gameModel.level += 1
    }
} 