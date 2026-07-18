//
//  DistrictApp.swift
//  District
//
//  Created by Aditya Chauhan on 18/07/26.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct DistrictApp: App {
    @State private var showSplash = true
    @State private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView(authViewModel: authViewModel) {
                        showSplash = false
                    }
                } else {
                    RootNavigationView(authViewModel: authViewModel)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
