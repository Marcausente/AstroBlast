//
//  GameView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI
import AVFoundation

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

// Vista para la explosión
struct ExplosionView: View {
    let explosion: GameModel.Explosion
    
    var body: some View {
        ZStack {
            // Núcleo de la explosión
            Circle()
                .fill(explosion.isEnemy ? Color.orange : Color.red)
                .frame(width: explosion.size * explosion.scale, height: explosion.size * explosion.scale)
                .opacity(explosion.opacity)
            
            // Ondas de la explosión
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        explosion.isEnemy ? 
                            Color.orange.opacity(0.7 - Double(i) * 0.2) : 
                            Color.red.opacity(0.7 - Double(i) * 0.2),
                        lineWidth: 3 - CGFloat(i)
                    )
                    .frame(
                        width: explosion.size * explosion.scale * (1.0 + CGFloat(i) * 0.2),
                        height: explosion.size * explosion.scale * (1.0 + CGFloat(i) * 0.2)
                    )
                    .opacity(explosion.opacity * (1.0 - Double(i) * 0.2))
            }
            
            // Partículas de la explosión
            ForEach(0..<8) { i in
                let angle = Double(i) * .pi / 4.0
                let distance = explosion.size * explosion.scale * 0.6
                
                Circle()
                    .fill(explosion.isEnemy ? Color.yellow : Color.red)
                    .frame(width: 4, height: 4)
                    .position(
                        x: cos(angle) * distance,
                        y: sin(angle) * distance
                    )
                    .opacity(explosion.opacity * 0.8)
            }
        }
        .position(explosion.position)
    }
}

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var showVictoryScreen = false
    @Environment(\.presentationMode) var presentationMode
    
    // Determinar si estamos en iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Tamaño del joystick basado en el dispositivo
    private var joystickSize: CGFloat {
        return isIPad ? 200 : 100
    }
    
    // Tamaño del botón de disparo basado en el dispositivo
    private var shootButtonSize: CGFloat {
        return isIPad ? 110 : 60
    }
    
    // Padding para los controles basado en el dispositivo
    private var controlsPadding: CGFloat {
        return isIPad ? 80 : 50
    }
    
    // Inicializador que acepta un nivel
    init(level: Int = 1) {
        _viewModel = StateObject(wrappedValue: GameViewModel(level: level))
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
                            // Botón de pausa
                            Button(action: {
                                viewModel.togglePause()
                            }) {
                                Image(systemName: viewModel.gameModel.isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: isIPad ? 30 : 24))
                                    .foregroundColor(.white)
                                    .frame(width: isIPad ? 50 : 40, height: isIPad ? 50 : 40)
                                    .background(Color.blue.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 10)
                            
                            // Vidas
                            HStack(spacing: 5) {
                                ForEach(0..<viewModel.gameModel.lives, id: \.self) { _ in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: isIPad ? 24 : 18))
                                }
                            }
                            .padding(.leading, 10)
                            
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
                    
                    // Explosiones
                    ForEach(viewModel.gameModel.explosions) { explosion in
                        ExplosionView(explosion: explosion)
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
                                .padding(.leading, isIPad ? 30 : 20)
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
                                            .font(.system(size: isIPad ? 55 : 30))
                                    )
                                    .shadow(color: .red.opacity(0.7), radius: 5, x: 0, y: 0)
                            }
                            .padding(.trailing, isIPad ? 40 : 30)
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
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                // Volver al menú
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Menú Principal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.advanceToNextLevel()
                            }) {
                                Text("Siguiente Nivel")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
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
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                // Volver al menú
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Menú Principal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.restartGame()
                            }) {
                                Text("Reintentar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 30)
                    }
                }
                
                // Explosiones (siempre visibles, incluso en pantallas de victoria o game over)
                ForEach(viewModel.gameModel.explosions) { explosion in
                    ExplosionView(explosion: explosion)
                }
                
                // Pantalla de Pausa
                if viewModel.gameModel.isPaused && !viewModel.gameModel.isGameOver && !viewModel.gameModel.isLevelCompleted {
                    VStack(spacing: 20) {
                        Text("PAUSA")
                            .font(.system(size: isIPad ? 40 : 32, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Button("Continuar") {
                            viewModel.togglePause()
                        }
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Reiniciar") {
                            viewModel.restartGame()
                        }
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Menú Principal") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.title)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear {
                print("GameView apareció - Iniciando música del nivel")
                // Inicializar la posición del jugador en el centro
                viewModel.movePlayer(to: geometry.size.width / 2)
                
                // Detener la música del menú
                AudioManager.shared.stopBackgroundMusic()
                
                // Reproducir la música del nivel
                AudioManager.shared.playBackgroundMusic(filename: "Sounds/spacemusic.mp3")
            }
            .onDisappear {
                print("GameView desapareció - Volviendo a la música del menú")
                // Reanudar la música del menú al volver
                AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
            }
            .onDisappear {
                // Reanudar la música del menú cuando se vuelve al menú principal
                AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
            }
        }
        .statusBar(hidden: true)
    }
}