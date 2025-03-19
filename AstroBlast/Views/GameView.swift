//
//  GameView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI
import AVFoundation

// Fondo de nebulosas espaciales
struct NebulaBackground: View {
    let level: Int
    @State private var nebulas: [Nebula] = []
    @State private var timer: Timer?
    
    struct Nebula: Identifiable {
        let id = UUID()
        var position: CGPoint
        var size: CGSize
        var rotation: Double
        let color: Color
        let opacity: Double
        let speed: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Nebulosas en el fondo
                ForEach(nebulas) { nebula in
                    Ellipse()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [nebula.color, nebula.color.opacity(0)]),
                                center: .center,
                                startRadius: 1,
                                endRadius: nebula.size.width / 2
                            )
                        )
                        .frame(width: nebula.size.width, height: nebula.size.height)
                        .position(nebula.position)
                        .rotationEffect(.degrees(nebula.rotation))
                        .opacity(nebula.opacity)
                        .blur(radius: 15)
                }
            }
            .onAppear {
                // Crear nebulosas
                nebulas = createNebulas(in: geometry)
                
                // Crear un timer para animar las nebulosas
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    updateNebulas(in: geometry)
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    private func createNebulas(in geometry: GeometryProxy) -> [Nebula] {
        // Número de nebulosas basado en el tamaño de la pantalla
        let count = Int(geometry.size.width / 200) + 1
        
        // Colores de nebulosa según el nivel
        let colors: [Color]
        switch level % 5 {
        case 0:
            colors = [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]
        case 1:
            colors = [Color.red.opacity(0.2), Color.orange.opacity(0.2)]
        case 2:
            colors = [Color.green.opacity(0.2), Color.blue.opacity(0.2)]
        case 3:
            colors = [Color.purple.opacity(0.2), Color.pink.opacity(0.2)]
        default:
            colors = [Color.orange.opacity(0.2), Color.yellow.opacity(0.2)]
        }
        
        return (0..<count).map { _ in
            let width = CGFloat.random(in: geometry.size.width * 0.5...geometry.size.width * 1.5)
            return Nebula(
                position: CGPoint(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: CGFloat.random(in: -width/2...geometry.size.height + width/2)
                ),
                size: CGSize(
                    width: width,
                    height: width * CGFloat.random(in: 0.3...0.7)
                ),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement() ?? .blue.opacity(0.3),
                opacity: Double.random(in: 0.1...0.3),
                speed: CGFloat.random(in: 0.1...0.5)
            )
        }
    }
    
    private func updateNebulas(in geometry: GeometryProxy) {
        // Factor de velocidad basado en el nivel (más lento que las estrellas)
        let levelSpeedFactor = 1.0 + (Double(level) * 0.05)
        
        for i in 0..<nebulas.count {
            // Mover la nebulosa hacia abajo
            nebulas[i].position.y += nebulas[i].speed * CGFloat(levelSpeedFactor)
            
            // Si la nebulosa sale de la pantalla, crear una nueva en la parte superior
            if nebulas[i].position.y - nebulas[i].size.height/2 > geometry.size.height {
                let width = CGFloat.random(in: geometry.size.width * 0.5...geometry.size.width * 1.5)
                nebulas[i].position = CGPoint(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: -width/2
                )
                nebulas[i].size = CGSize(
                    width: width,
                    height: width * CGFloat.random(in: 0.3...0.7)
                )
                nebulas[i].rotation = Double.random(in: 0...360)
            }
        }
    }
}

struct StarField: View {
    let starsCount: Int
    let level: Int // Nivel actual para ajustar la velocidad
    @State private var stars: [Star] = []
    @State private var timer: Timer?
    
    struct Star: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let opacity: Double
        let speed: CGFloat // Velocidad base de movimiento de la estrella
        let color: Color // Color de la estrella
    }
    
    init(starsCount: Int = 100, level: Int = 1) {
        self.starsCount = starsCount
        self.level = level
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Capa de fondo (estrellas más lentas y pequeñas para dar sensación de profundidad)
                ForEach(stars.filter { $0.speed < 1.0 }) { star in
                    Circle()
                        .fill(star.color)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .opacity(star.opacity)
                }
                
                // Capa intermedia
                ForEach(stars.filter { $0.speed >= 1.0 && $0.speed < 2.0 }) { star in
                    Circle()
                        .fill(star.color)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .opacity(star.opacity)
                        .blur(radius: 0.2)
                }
                
                // Capa frontal (estrellas más rápidas y grandes)
                ForEach(stars.filter { $0.speed >= 2.0 }) { star in
                    ZStack {
                        // Estrella
                        Circle()
                            .fill(star.color)
                            .frame(width: star.size, height: star.size)
                            .position(x: star.x, y: star.y)
                            .opacity(star.opacity)
                            .blur(radius: 0.3)
                            .shadow(color: star.color, radius: 1, x: 0, y: 0)
                        
                        // Estela de la estrella
                        Path { path in
                            path.move(to: CGPoint(x: star.x, y: star.y))
                            path.addLine(to: CGPoint(x: star.x, y: star.y - star.speed * 2))
                        }
                        .stroke(star.color, lineWidth: star.size * 0.7)
                        .opacity(star.opacity * 0.7)
                        .blur(radius: 0.8)
                    }
                }
            }
            .onAppear {
                // Crear estrellas iniciales
                stars = (0..<starsCount).map { _ in
                    createStar(in: geometry)
                }
                
                // Crear un timer para animar las estrellas
                timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    updateStars(in: geometry)
                }
            }
            .onDisappear {
                // Detener el timer cuando la vista desaparece
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    // Crear una nueva estrella
    private func createStar(in geometry: GeometryProxy) -> Star {
        // Determinar el tamaño y la velocidad (relacionados: más grandes = más rápidas)
        let starSize = CGFloat.random(in: 1...4)
        let speed = starSize * CGFloat.random(in: 0.3...0.8)
        
        // Colores posibles para las estrellas
        let colors: [Color] = [
            .white,
            Color(red: 0.9, green: 0.9, blue: 1.0),  // Blanco azulado
            Color(red: 1.0, green: 0.9, blue: 0.8),  // Blanco amarillento
            Color(red: 0.8, green: 0.8, blue: 1.0),  // Azul claro
            Color(red: 1.0, green: 0.8, blue: 0.8)   // Rojo claro
        ]
        
        return Star(
            x: CGFloat.random(in: 0...geometry.size.width),
            y: CGFloat.random(in: 0...geometry.size.height),
            size: starSize,
            opacity: Double.random(in: 0.3...1.0),
            speed: speed,
            color: colors.randomElement() ?? .white
        )
    }
    
    // Actualizar la posición de las estrellas
    private func updateStars(in geometry: GeometryProxy) {
        // Factor de velocidad basado en el nivel (aumenta gradualmente)
        let levelSpeedFactor = 1.0 + (Double(level) * 0.1)
        
        for i in 0..<stars.count {
            // Mover la estrella hacia abajo para dar efecto de avance
            // La velocidad se multiplica por el factor del nivel
            stars[i].y += stars[i].speed * CGFloat(levelSpeedFactor)
            
            // Si la estrella sale de la pantalla, crear una nueva en la parte superior
            if stars[i].y > geometry.size.height {
                stars[i].y = 0
                stars[i].x = CGFloat.random(in: 0...geometry.size.width)
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
                
                // Fondo de nebulosas (más lento)
                NebulaBackground(level: viewModel.gameModel.level)
                
                // Campo de estrellas
                StarField(starsCount: 150, level: viewModel.gameModel.level)
                
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