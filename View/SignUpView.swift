//
//  SignUpView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 22.05.2025.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    	
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never) // iOS 15+
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
        
            SecureField("Password", text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            
            Button("Login") {
                authService.regularCreateAccount(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
