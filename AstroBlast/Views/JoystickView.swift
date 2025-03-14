//
//  JoystickView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

struct JoystickView: View {
    @Binding var direction: CGFloat // -1 (izquierda) a 1 (derecha)
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    // Determinar si estamos en un iPad
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Constantes para el joystick, adaptadas según el dispositivo
    private var baseSize: CGFloat {
        return isIPad ? 160 : 80
    }
    
    private var stickSize: CGFloat {
        return isIPad ? 80 : 40
    }
    
    private var maxDistance: CGFloat {
        return isIPad ? 40 : 25
    }
    
    var body: some View {
        ZStack {
            // Base del joystick
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: baseSize, height: baseSize)
            
            // Stick del joystick
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: stickSize, height: stickSize)
                .offset(x: limitOffset(dragOffset.width), y: 0)
                .shadow(color: .white.opacity(0.5), radius: isIPad ? 8 : 5)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            // Solo permitimos movimiento horizontal
                            dragOffset = CGSize(width: value.translation.width, height: 0)
                            // Actualizamos la dirección (-1 a 1)
                            updateDirection()
                        }
                        .onEnded { _ in
                            // Volvemos a la posición central
                            withAnimation(.spring()) {
                                dragOffset = .zero
                                direction = 0
                                isDragging = false
                            }
                        }
                )
        }
        .overlay(
            // Indicadores visuales para mejorar la usabilidad
            HStack(spacing: isIPad ? 100 : 50) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: isIPad ? 24 : 16))
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: isIPad ? 24 : 16))
            }
            .opacity(isDragging ? 0 : 0.7) // Se ocultan durante el arrastre
        )
    }
    
    // Limita el offset del stick dentro del rango permitido
    private func limitOffset(_ offset: CGFloat) -> CGFloat {
        return min(maxDistance, max(-maxDistance, offset))
    }
    
    // Actualiza la dirección basada en el offset
    private func updateDirection() {
        let limitedOffset = limitOffset(dragOffset.width)
        direction = limitedOffset / maxDistance // Normalizado entre -1 y 1
    }
}

#Preview {
    JoystickView(direction: .constant(0))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.black)
} 