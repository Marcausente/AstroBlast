//
//  GameModel.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import Foundation

struct GameModel {
    var score: Int = 0
    var level: Int = 1
    var playerPosition: CGFloat = 0 // Posición X de la nave del jugador
    var projectiles: [Projectile] = []
    
    struct Projectile: Identifiable {
        let id = UUID()
        var position: CGPoint
    }
} 