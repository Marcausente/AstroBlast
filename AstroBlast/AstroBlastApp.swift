//
//  AstroBlastApp.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

@main
struct AstroBlastApp: App {
    init() {
        // Bloquear la orientación en modo vertical (portrait)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        // Notificar a la aplicación sobre el cambio de orientación
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Configurar las orientaciones permitidas (solo portrait)
                    AppDelegate.orientationLock = .portrait
                }
        }
    }
}

// Clase auxiliar para manejar la orientación
class AppDelegate: NSObject {
    static var orientationLock = UIInterfaceOrientationMask.portrait
}

// Extensión para manejar la orientación a nivel de aplicación
extension UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
