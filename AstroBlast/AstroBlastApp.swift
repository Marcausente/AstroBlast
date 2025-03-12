//
//  AstroBlastApp.swift
//  AstroBlast
//
//  Created by Marc Fernández on 10/3/25.
//

import SwiftUI

// Clase para manejar la orientación a nivel de aplicación
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Solo permitir orientación vertical (portrait)
        return .portrait
    }
}

@main
struct AstroBlastApp: App {
    // Registrar el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Forzar la orientación vertical
        AppUtility.lockOrientation(.portrait)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Utilidad para bloquear la orientación
struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}
