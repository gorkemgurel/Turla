//
//  ContentView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 22.05.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    var body: some View {
        switch authService.authState {
                case .unknown:
                    //ProgressView()
                    Color.white
                case .signedIn:
                    //MainView()
                    //ProvinceListView()
                DashboardView()
                case .signedOut:
                    LoginView()
                }
    }
}

#Preview {
    ContentView()
}
