//
//  GameView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

struct StarField: View {
    let starsCount: Int
    @State private var stars: [Star] = []
    
    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
    }
    
    init(starsCount: Int = 100) {
        self.starsCount = starsCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .opacity(star.opacity)
                }
            }
            .onAppear {
                stars = (0..<starsCount).map { _ in
                    Star(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height),
                        size: CGFloat.random(in: 1...3),
                        opacity: Double.random(in: 0.3...1.0)
                    )
                }
            }
        }
    }
}

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo negro para el espacio
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Campo de estrellas
                StarField(starsCount: 150)
                
                // Puntuación y nivel
                VStack {
                    HStack {
                        Spacer()
                        Text("Nivel: \(viewModel.gameModel.level)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Puntos: \(viewModel.gameModel.score)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                    }
                    
                    Spacer()
                }
                
                // Proyectiles
                ForEach(viewModel.gameModel.projectiles) { projectile in
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 6, height: 6)
                        .position(projectile.position)
                        .shadow(color: .yellow, radius: 4, x: 0, y: 0)
                }
                
                // Nave del jugador
                Image("Nave")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .position(x: viewModel.gameModel.playerPosition, y: viewModel.getShipYPosition())
                
                // Controles
                VStack {
                    Spacer()
                    HStack {
                        // Joystick (izquierda)
                        JoystickView(direction: $viewModel.joystickDirection)
                            .frame(width: 100, height: 100)
                            .padding(.leading, 20)
                            .padding(.bottom, 50)
                        
                        Spacer()
                        
                        // Botón de disparo (derecha)
                        Button(action: {
                            viewModel.shoot()
                        }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 30))
                                )
                                .shadow(color: .red.opacity(0.7), radius: 5, x: 0, y: 0)
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 50)
                    }
                }
            }
            .onAppear {
                // Inicializar la posición del jugador en el centro
                viewModel.movePlayer(to: geometry.size.width / 2)
                
                // Forzar orientación vertical
                OrientationManager.shared.lockOrientation(.portrait)
            }
        }
        .statusBar(hidden: true)
        .lockDeviceOrientation()
    }
}