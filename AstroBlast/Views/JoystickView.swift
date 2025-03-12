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
    
    // Constantes para el joystick
    private let baseSize: CGFloat = 100
    private let stickSize: CGFloat = 50
    private let maxDistance: CGFloat = 30
    
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
                .shadow(color: .white.opacity(0.5), radius: 5)
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