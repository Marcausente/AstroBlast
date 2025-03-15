//
//  ContentView.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showSoundTest = false
    @State private var showDebugMenu = false
    @State private var showAudioVerifier = false
    
    var body: some View {
        ZStack {
            MenuView()
            
            // Menú de depuración (solo visible en modo desarrollo)
            if showDebugMenu {
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 15) {
                            Button(action: {
                                showSoundTest = true
                            }) {
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.blue.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            
                            Button(action: {
                                showAudioVerifier = true
                            }) {
                                Image(systemName: "waveform.badge.magnifyingglass")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.green.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showSoundTest) {
            SoundTest()
        }
        .sheet(isPresented: $showAudioVerifier) {
            VerifyAudioFiles()
        }
        .onAppear {
            // En un entorno de producción, esto debería estar desactivado
            #if DEBUG
            showDebugMenu = true
            #endif
            
            // Iniciar la música del menú
            AudioManager.shared.playBackgroundMusic(filename: "Sounds/menumusic.mp3")
        }
        // Gesto secreto para mostrar/ocultar el menú de depuración (triple tap en la esquina superior izquierda)
        .gesture(
            TapGesture(count: 3)
                .onEnded {
                    withAnimation {
                        showDebugMenu.toggle()
                    }
                }
        )
    }
}

#Preview {
    ContentView()
}
