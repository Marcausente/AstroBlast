//
//  MenuView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var showUnlockConfirmation = false
    
    var body: some View {
        ZStack {
            // Fondo animado
            AnimatedBackground()
            
            // Campo de estrellas
            AnimatedStarField(starsCount: 200)
            
            // Contenido del menú
            VStack {
                // Logo del juego
                MenuTitle(title: "AstroBlast")
                    .padding(.top, 50)
                
                Spacer()
                
                // Contenido según el estado actual del menú
                Group {
                    switch viewModel.menuModel.currentMenuState {
                    case .main:
                        MainMenuView(viewModel: viewModel)
                    case .levels:
                        LevelsMenuView(viewModel: viewModel)
                    case .options:
                        OptionsMenuView(viewModel: viewModel)
                    case .credits:
                        CreditsView(viewModel: viewModel)
                    }
                }
                
                Spacer()
                
                // Versión del juego
                Text("v1.0")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 10)
            }
            
            // Diálogo de confirmación para salir
            if viewModel.showExitConfirmation {
                ExitConfirmationView(viewModel: viewModel)
            }
            
            // Diálogo de confirmación para desbloquear niveles
            if showUnlockConfirmation {
                UnlockConfirmationView(
                    isPresented: $showUnlockConfirmation,
                    onConfirm: {
                        viewModel.unlockAllLevels()
                        showUnlockConfirmation = false
                    }
                )
            }
        }
        .statusBar(hidden: true)
        .fullScreenCover(isPresented: $viewModel.showGameView) {
            GameView(level: viewModel.selectedLevel.rawValue)
        }
        .onAppear {
            viewModel.startAnimations()
            
            // Forzar orientación vertical
            OrientationManager.shared.lockOrientation(.portrait)
        }
        .gesture(
            // Gesto secreto para desbloquear todos los niveles (triple tap)
            TapGesture(count: 3)
                .onEnded {
                    showUnlockConfirmation = true
                }
        )
    }
}

// Vista del menú principal
struct MainMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(MenuModel.MenuOption.allCases) { option in
                MenuButton(
                    title: option.title,
                    iconName: option.iconName,
                    action: {
                        switch option {
                        case .levels:
                            viewModel.navigateTo(.levels)
                        case .options:
                            viewModel.navigateTo(.options)
                        case .credits:
                            viewModel.navigateTo(.credits)
                        case .exit:
                            viewModel.confirmExit()
                        }
                    }
                )
            }
        }
        .padding(.vertical, 20)
    }
}

// Vista del menú de niveles
struct LevelsMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        VStack {
            // Título de la sección
            Text("Selecciona un nivel")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Lista de niveles
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(MenuModel.GameLevel.allCases) { level in
                        LevelButton(
                            level: level,
                            action: {
                                viewModel.startGame(level: level)
                            }
                        )
                    }
                }
                .padding()
            }
            
            // Botón para volver al menú principal
            BackButton(action: {
                viewModel.backToMain()
            })
            .padding(.bottom, 20)
        }
    }
}

// Botón de nivel
struct LevelButton: View {
    let level: MenuModel.GameLevel
    let action: () -> Void
    
    var body: some View {
        Button(action: level.isLocked ? {} : action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(level.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if level.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(level.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: level.isLocked ? 
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] : 
                                [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: level.isLocked ? 
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] : 
                                        [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .opacity(level.isLocked ? 0.6 : 1.0)
        }
        .disabled(level.isLocked)
        .padding(.horizontal)
    }
}

// Vista del menú de opciones
struct OptionsMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        VStack {
            // Título de la sección
            Text("Opciones")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Opciones
            VStack(spacing: 20) {
                CustomToggle(
                    title: "Sonido",
                    isOn: Binding(
                        get: { viewModel.menuModel.options.soundEnabled },
                        set: { viewModel.updateOptions(soundEnabled: $0) }
                    )
                )
                
                CustomToggle(
                    title: "Música",
                    isOn: Binding(
                        get: { viewModel.menuModel.options.musicEnabled },
                        set: { viewModel.updateOptions(musicEnabled: $0) }
                    )
                )
                
                CustomToggle(
                    title: "Vibración",
                    isOn: Binding(
                        get: { viewModel.menuModel.options.vibrationEnabled },
                        set: { viewModel.updateOptions(vibrationEnabled: $0) }
                    )
                )
                
                VStack(alignment: .leading) {
                    Text("Dificultad")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Picker("Dificultad", selection: Binding(
                        get: { viewModel.menuModel.options.difficulty },
                        set: { viewModel.updateOptions(difficulty: $0) }
                    )) {
                        ForEach(MenuModel.GameOptions.Difficulty.allCases) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            
            Spacer()
            
            // Botón para volver al menú principal
            BackButton(action: {
                viewModel.backToMain()
            })
            .padding(.bottom, 20)
        }
    }
}

// Vista de créditos
struct CreditsView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        VStack {
            // Título de la sección
            Text("Créditos")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Información de créditos
            VStack(spacing: 20) {
                Text(viewModel.menuModel.credits.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Versión \(viewModel.menuModel.credits.version)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                    .frame(height: 30)
                
                Text("Desarrollado por")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(viewModel.menuModel.credits.developer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(viewModel.menuModel.credits.year)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                    .frame(height: 30)
                
                Text(viewModel.menuModel.credits.artCredits)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(viewModel.menuModel.credits.musicCredits)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            Spacer()
            
            // Botón para volver al menú principal
            BackButton(action: {
                viewModel.backToMain()
            })
            .padding(.bottom, 20)
        }
    }
}

// Diálogo de confirmación para salir
struct ExitConfirmationView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("¿Estás seguro de que quieres salir?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.cancelExit()
                    }) {
                        Text("Cancelar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.blue.opacity(0.6))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.exitGame()
                    }) {
                        Text("Salir")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 0)
        }
    }
}

// Diálogo de confirmación para desbloquear niveles
struct UnlockConfirmationView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("¿Desbloquear todos los niveles?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Esta acción desbloqueará todos los niveles del juego.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancelar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.blue.opacity(0.6))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onConfirm) {
                        Text("Desbloquear")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.green.opacity(0.6))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.7), .green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .green.opacity(0.5), radius: 20, x: 0, y: 0)
        }
    }
} 