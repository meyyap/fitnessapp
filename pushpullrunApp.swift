//
//  pushpullrunApp.swift
//  pushpullrun
//
//  Created by Meyyappan Thenappan on 3/5/25.
//

import SwiftUI
import Firebase

@main
struct pushpullrunApp: App {
    // Initialize Firebase
    init() {
        // FirebaseApp.configure() is already called in FirebaseManager.shared
        // Removing to avoid "Default app has already been configured" error
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
