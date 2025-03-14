//
//  OrientationManager.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

// Clase para gestionar la orientación de la aplicación
class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var orientation: UIInterfaceOrientationMask = .portrait
    
    private init() {}
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        self.orientation = orientation
        self.setOrientation(orientation)
    }
    
    func setOrientation(_ orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            // En iOS 16 y posterior, usamos el nuevo método
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        } else {
            // En iOS 15 y anterior, usamos el método antiguo
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

// Modificador para aplicar la orientación a una vista
struct DeviceOrientationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                OrientationManager.shared.lockOrientation(.portrait)
            }
    }
}

extension View {
    func lockDeviceOrientation() -> some View {
        self.modifier(DeviceOrientationModifier())
    }
} 