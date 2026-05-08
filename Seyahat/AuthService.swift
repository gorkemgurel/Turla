//
//  AuthService.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 22.05.2025.
//

import FirebaseAuth


class AuthService: ObservableObject {
    
    //@Published var signedIn:Bool = false
    @Published var authState: AuthState = .unknown
    
    enum AuthState {
            case unknown
            case signedIn
            case signedOut
        }
    
    init() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.authState = .signedIn
                print("Auth state changed, is signed in")
            } else {
                self.authState = .signedOut
                print("Auth state changed, is signed out")
            }
        }
    }
    
    // MARK: - Password Account
    func regularCreateAccount(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e.localizedDescription)
                
            } else {
                print("Successfully created password account")
            }
        }
    }
    
    //MARK: - Traditional sign in
    // Traditional sign in with password and email
    func regularSignIn(email:String, password:String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            if let e = error {
                completion(e)
            } else {
                print("Login success")
                completion(nil)
            }
        }
    }
    
    // Regular password acount sign out.
    // Closure has whether sign out was successful or not
    func regularSignOut(completion: @escaping (Error?) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(nil)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
          completion(signOutError)
        }
    }
    
}
