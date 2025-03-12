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
        // Usar la orientación configurada en OrientationManager
        return OrientationManager.shared.orientation
    }
}

@main
struct AstroBlastApp: App {
    // Registrar el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Forzar la orientación vertical
        OrientationManager.shared.lockOrientation(.portrait)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .lockDeviceOrientation()
        }
    }
}
