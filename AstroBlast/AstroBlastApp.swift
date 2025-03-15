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
        // Forzar orientación vertical para toda la aplicación
        return .portrait
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Copiar archivos de audio al iniciar la aplicación
        CopyAudioFiles.copyFilesToBundle()
        return true
    }
}

@main
struct AstroBlastApp: App {
    // Registrar el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Configurar la sesión de audio al iniciar la aplicación
        print("Iniciando AstroBlast...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
