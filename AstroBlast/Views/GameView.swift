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
    
    // Determinar si estamos en un iPad
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Tamaño del joystick basado en el dispositivo
    private var joystickSize: CGFloat {
        return isIPad ? 160 : 100
    }
    
    // Tamaño del botón de disparo basado en el dispositivo
    private var shootButtonSize: CGFloat {
        return isIPad ? 90 : 60
    }
    
    // Padding para los controles basado en el dispositivo
    private var controlsPadding: CGFloat {
        return isIPad ? 70 : 50
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo negro para el espacio
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Campo de estrellas
                StarField(starsCount: 150)
                
                // Interfaz de juego
                if !viewModel.gameModel.isGameOver && !viewModel.gameModel.isLevelCompleted {
                    // Puntuación y nivel
                    VStack {
                        HStack {
                            // Vidas
                            HStack(spacing: 5) {
                                ForEach(0..<viewModel.gameModel.lives, id: \.self) { _ in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: isIPad ? 30 : 20))
                                }
                            }
                            .padding(.leading, 20)
                            .padding(.top, 20)
                            
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
                        
                        // Contador de tiempo
                        HStack {
                            Spacer()
                            Text("Tiempo: \(viewModel.gameModel.formatTimeRemaining())")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                                .padding(.trailing, 20)
                        }
                        
                        Spacer()
                    }
                    
                    // Enemigos
                    ForEach(viewModel.gameModel.enemies) { enemy in
                        Image("Enemigo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: enemy.size.width, height: enemy.size.height)
                            .position(enemy.position)
                    }
                    
                    // Proyectiles del jugador
                    ForEach(viewModel.gameModel.projectiles) { projectile in
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 6, height: 6)
                            .position(projectile.position)
                            .shadow(color: .yellow, radius: 4, x: 0, y: 0)
                    }
                    
                    // Proyectiles enemigos
                    ForEach(viewModel.gameModel.enemyProjectiles) { projectile in
                        // Forma de lágrima para los proyectiles enemigos
                        ZStack {
                            // Círculo principal
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            
                            // Estela del proyectil
                            Path { path in
                                let length: CGFloat = 12
                                
                                // Punto inicial (centro del círculo)
                                path.move(to: CGPoint(x: 0, y: 0))
                                
                                // Punto final (en dirección opuesta a la dirección del proyectil)
                                path.addLine(to: CGPoint(
                                    x: -projectile.direction.dx * length,
                                    y: -projectile.direction.dy * length
                                ))
                            }
                            .stroke(Color.red.opacity(0.7), lineWidth: 3)
                            .blur(radius: 2)
                        }
                        .position(projectile.position)
                        .shadow(color: .red, radius: 3, x: 0, y: 0)
                    }
                    
                    // Nave del jugador
                    Image("Nave")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isIPad ? 100 : 80, height: isIPad ? 100 : 80)
                        .position(x: viewModel.gameModel.playerPosition, y: viewModel.getShipYPosition())
                    
                    // Controles
                    VStack {
                        Spacer()
                        HStack {
                            // Joystick (izquierda)
                            JoystickView(direction: $viewModel.joystickDirection)
                                .frame(width: joystickSize, height: joystickSize)
                                .padding(.leading, 20)
                                .padding(.bottom, controlsPadding)
                            
                            Spacer()
                            
                            // Botón de disparo (derecha)
                            Button(action: {
                                viewModel.shoot()
                            }) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: shootButtonSize, height: shootButtonSize)
                                    .overlay(
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: isIPad ? 45 : 30))
                                    )
                                    .shadow(color: .red.opacity(0.7), radius: 5, x: 0, y: 0)
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, controlsPadding)
                        }
                    }
                } else if viewModel.gameModel.isLevelCompleted {
                    // Pantalla de Victoria
                    VStack {
                        Text("¡VICTORIA!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("Has acabado el nivel \(viewModel.gameModel.level)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        
                        Text("¡Sobreviviste durante 2 minutos!")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        
                        Text("Puntuación: \(viewModel.gameModel.score)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button(action: {
                            viewModel.advanceToNextLevel()
                        }) {
                            Text("Continuar al Nivel \(viewModel.gameModel.level + 1)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding(.top, 30)
                    }
                } else {
                    // Pantalla de Game Over
                    VStack {
                        Text("GAME OVER")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding()
                        
                        Text("Puntuación: \(viewModel.gameModel.score)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        
                        Text("Nivel alcanzado: \(viewModel.gameModel.level)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button(action: {
                            viewModel.restartGame()
                        }) {
                            Text("Reiniciar Juego")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 30)
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