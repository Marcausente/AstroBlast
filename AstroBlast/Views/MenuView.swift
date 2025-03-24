//
//  MenuView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI
import AVFoundation

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var showUnlockConfirmation = false
    
    var body: some View {
        ZStack {
            // Fondo animado
            AnimatedBackground()
            
            // Campo de estrellas
            AnimatedStarField()
            
            // Contenido del menú
            VStack {
                // Título
                MenuTitle(title: "ASTROBLAST")
                    .padding(.top, 40)
                
                Spacer()
                
                // Contenido según el estado actual
                switch viewModel.menuModel.currentMenuState {
                case .main:
                    mainMenuView()
                case .options:
                    optionsView()
                case .credits:
                    creditsView()
                default:
                    EmptyView()
                }
                
                Spacer()
            }
            
            // Diálogo de confirmación para salir
            if viewModel.showExitConfirmation {
                exitConfirmationView()
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
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .fullScreenCover(isPresented: $viewModel.showGameView) {
            GameView(level: 1)
        }
        .onAppear {
            viewModel.startAnimations()
            
            // Reproducir música de fondo del menú
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
        }
        .gesture(
            // Gesto secreto para desbloquear todos los niveles (triple tap)
            TapGesture(count: 3)
                .onEnded {
                    showUnlockConfirmation = true
                }
        )
    }
    
    // Vista del menú principal
    private func mainMenuView() -> some View {
        VStack(spacing: 20) {
            // Botón grande para jugar
            Button(action: {
                viewModel.startGame(level: .level1)
            }) {
                Text("JUGAR")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 60)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: .blue.opacity(0.7), radius: 10, x: 0, y: 0)
            }
            .padding(.bottom, 40)
            
            // Opciones del menú
            MenuButton(title: "Opciones", iconName: "gearshape.fill") {
                viewModel.navigateTo(.options)
            }
            
            MenuButton(title: "Créditos", iconName: "person.3.fill") {
                viewModel.navigateTo(.credits)
            }
            
            MenuButton(title: "Salir", iconName: "door.left.hand.open") {
                viewModel.confirmExit()
            }
        }
        .padding(.bottom, 30)
    }
    
    // Vista de opciones
    private func optionsView() -> some View {
        VStack {
            Text("OPCIONES")
                .font(.title)
                .foregroundColor(.white)
                .padding()
            
            Spacer()
            
            VStack(spacing: 20) {
                CustomToggle(title: "Sonidos", isOn: Binding(
                    get: { viewModel.menuModel.options.soundEnabled },
                    set: { viewModel.updateOptions(soundEnabled: $0) }
                ))
                
                CustomToggle(title: "Música", isOn: Binding(
                    get: { viewModel.menuModel.options.musicEnabled },
                    set: { viewModel.updateOptions(musicEnabled: $0) }
                ))
                
                CustomToggle(title: "Vibración", isOn: Binding(
                    get: { viewModel.menuModel.options.vibrationEnabled },
                    set: { viewModel.updateOptions(vibrationEnabled: $0) }
                ))
            }
            
            Spacer()
            
            BackButton {
                viewModel.backToMain()
            }
            .padding(.bottom, 20)
        }
    }
    
    // Vista de créditos
    private func creditsView() -> some View {
        VStack {
            Text("CRÉDITOS")
                .font(.title)
                .foregroundColor(.white)
                .padding()
            
            Spacer()
            
            VStack(spacing: 15) {
                Text(viewModel.menuModel.credits.title)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Versión \(viewModel.menuModel.credits.version)")
                    .foregroundColor(.gray)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 10)
                
                Text("Desarrollado por")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(viewModel.menuModel.credits.developer)
                    .foregroundColor(.white)
                
                Text(viewModel.menuModel.credits.year)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                Text(viewModel.menuModel.credits.artCredits)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                Text(viewModel.menuModel.credits.musicCredits)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.5))
            )
            .padding()
            
            Spacer()
            
            BackButton {
                viewModel.backToMain()
            }
            .padding(.bottom, 20)
        }
    }
    
    // Vista de confirmación para salir
    private func exitConfirmationView() -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("¿Estás seguro que quieres salir?")
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack(spacing: 30) {
                    Button("No") {
                        viewModel.cancelExit()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Button("Sí") {
                        viewModel.exitGame()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding()
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.8), Color.black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
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