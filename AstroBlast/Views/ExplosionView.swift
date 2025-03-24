import SwiftUI

// Vista optimizada para explosiones que reduce la carga gráfica
struct ExplosionView: View {
    let explosion: GameModel.Explosion
    
    // Determinar si estamos en un dispositivo de bajo rendimiento
    private var isLowPerformanceDevice: Bool {
        // Si es un dispositivo antiguo o está en modo de accesibilidad con mayor tamaño de texto
        return UIDevice.current.systemVersion.compare("15.0", options: .numeric) == .orderedAscending
    }
    
    var body: some View {
        if isLowPerformanceDevice {
            // Versión muy simplificada para dispositivos de bajo rendimiento
            Circle()
                .fill(explosion.isEnemy ? Color.orange : Color.red)
                .frame(width: explosion.size * explosion.scale, height: explosion.size * explosion.scale)
                .opacity(explosion.opacity)
                .position(explosion.position)
        } else {
            // Versión optimizada pero visualmente atractiva
            ZStack {
                // Núcleo de la explosión
                Circle()
                    .fill(explosion.isEnemy ? Color.orange : Color.red)
                    .frame(width: explosion.size * explosion.scale, height: explosion.size * explosion.scale)
                    .opacity(explosion.opacity)
                
                // Onda exterior (solo una para mejorar rendimiento)
                Circle()
                    .stroke(
                        explosion.isEnemy ? Color.orange.opacity(0.5) : Color.red.opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(
                        width: explosion.size * explosion.scale * 1.2,
                        height: explosion.size * explosion.scale * 1.2
                    )
                    .opacity(explosion.opacity * 0.8)
            }
            .position(explosion.position)
        }
    }
} 