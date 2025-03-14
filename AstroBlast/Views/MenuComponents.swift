//
//  MenuComponents.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

// Fondo animado para el menú
struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.0, blue: 0.3),
                Color(red: 0.0, green: 0.0, blue: 0.2),
                Color(red: 0.0, green: 0.0, blue: 0.1)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// Campo de estrellas animado
struct AnimatedStarField: View {
    let starsCount: Int
    @State private var stars: [Star] = []
    @State private var animate = false
    
    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
        let speed: Double
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
                        .position(
                            x: star.x,
                            y: animate ? 
                                (star.y + geometry.size.height) : 
                                (star.y - star.size)
                        )
                        .opacity(star.opacity)
                }
            }
            .onAppear {
                stars = (0..<starsCount).map { _ in
                    Star(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: -geometry.size.height...0),
                        size: CGFloat.random(in: 1...3),
                        opacity: Double.random(in: 0.3...1.0),
                        speed: Double.random(in: 1...3)
                    )
                }
                
                withAnimation(Animation.linear(duration: 15).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
        }
    }
}

// Botón personalizado para el menú
struct MenuButton: View {
    let title: String
    let iconName: String
    let action: () -> Void
    let isLocked: Bool
    
    init(title: String, iconName: String, isLocked: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.isLocked = isLocked
        self.action = action
    }
    
    var body: some View {
        Button(action: isLocked ? {} : action) {
            HStack {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: isLocked ? 
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
                                    colors: isLocked ? 
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] : 
                                        [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

// Botón de navegación para volver atrás
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title2)
                Text("Volver")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.6))
                    .overlay(
                        Capsule()
                            .stroke(Color.blue.opacity(0.8), lineWidth: 2)
                    )
            )
        }
    }
}

// Título del menú con efecto de brillo
struct MenuTitle: View {
    let title: String
    @State private var animateGlow = false
    
    var body: some View {
        Text(title)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: animateGlow ? .blue.opacity(0.7) : .purple.opacity(0.7), 
                    radius: animateGlow ? 20 : 10, 
                    x: 0, 
                    y: 0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animateGlow.toggle()
                }
            }
    }
}

// Toggle personalizado para opciones
struct CustomToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
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
}

// Selector personalizado para opciones
struct CustomPicker<T: Hashable & Identifiable & CustomStringConvertible>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Picker(title, selection: $selection) {
                ForEach(options) { option in
                    Text(option.description)
                        .tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
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
    }
}

// Extensión para hacer que Difficulty sea CustomStringConvertible
extension MenuModel.GameOptions.Difficulty: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
} 