//
//  GameView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo negro para el espacio
                Color.black.edgesIgnoringSafeArea(.all)
                
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
                        .frame(width: 10, height: 10)
                        .position(projectile.position)
                }
                
                // Nave del jugador
                Image("Nave")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .position(x: viewModel.gameModel.playerPosition, y: geometry.size.height - 50)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.movePlayer(to: value.location.x)
                            }
                    )
                
                // Botón de disparo
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
            .onAppear {
                // Inicializar la posición del jugador en el centro
                viewModel.movePlayer(to: geometry.size.width / 2)
            }
        }
    }
} 