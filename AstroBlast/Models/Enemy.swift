import Foundation
import SwiftUI

// Estructura para enemigos
struct Enemy: Identifiable {
    let id = UUID()
    var position: CGPoint
    var health: Int = 1
    var size: CGSize = CGSize(width: 60, height: 60)
    var lastShootTime: TimeInterval = 0
    var isMoving: Bool = true // Indica si el enemigo está en movimiento
    var targetY: CGFloat? = nil // Posición Y objetivo (mitad de la pantalla)
    var type: EnemyType = .normal // Tipo de enemigo
    
    enum EnemyType {
        case normal
        case big
        case boss
    }
    
    // Método para verificar colisión con un proyectil
    func isHit(by projectile: GameModel.Projectile) -> Bool {
        let enemyRect = CGRect(
            x: position.x - size.width/2,
            y: position.y - size.height/2,
            width: size.width,
            height: size.height
        )
        
        // Para el boss, usamos un hitbox más pequeño para mejor precisión
        if type == .boss {
            let bossHitboxWidth = size.width * 0.7
            let bossHitboxHeight = size.height * 0.7
            
            let bossHitbox = CGRect(
                x: position.x - bossHitboxWidth/2,
                y: position.y - bossHitboxHeight/2,
                width: bossHitboxWidth,
                height: bossHitboxHeight
            )
            
            return bossHitbox.contains(projectile.position)
        }
        
        return enemyRect.contains(projectile.position)
    }
    
    // Método para verificar colisión con otro enemigo
    func isColliding(with otherEnemy: Enemy) -> Bool {
        // Calcular la distancia entre los centros de los enemigos
        let dx = position.x - otherEnemy.position.x
        let dy = position.y - otherEnemy.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Calcular la suma de los radios (considerando que son círculos)
        let minDistance = (size.width + otherEnemy.size.width) / 2
        
        // Hay colisión si la distancia es menor que la suma de los radios
        return distance < minDistance
    }
    
    // Método para verificar si el enemigo está por encima de otro
    func isAbove(_ otherEnemy: Enemy) -> Bool {
        return position.y < otherEnemy.position.y && abs(position.x - otherEnemy.position.x) < size.width
    }
} 