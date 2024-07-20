//
//  AuthService.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

final class AuthService {
    
    public static let shared = AuthService()
    
    private init() {}
    
    func sendSignInLink(with userRequest: EmailLinkRequest, completion: @escaping (Bool, Error?) -> Void) {
        let email = userRequest.email
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.url = URL(string: "TODO")
        
        
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                completion(false, error)
                return
            }
            
            UserDefaults.standard.set(email, forKey: "userEmail")
            
            completion(true, nil)
        }
    }
    
    func registerUser(with userRequest: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        let username = userRequest.username
        let email = userRequest.email
        let password = userRequest.password
    
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let resultUser = result?.user else {
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            
            db.collection("users")
                .document(resultUser.uid)
                .setData([
                    "username": username,
                    "email": email
                ]) { error in
                    if let error = error {
                        completion(false, error)
                        return
                    }
                    
                    completion(true, nil)
                }
        }
    }
    
    func signIn(with userRequest: LoginUserRequest, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: userRequest.email, password: userRequest.password) { result, error in
            if let error = error {
                completion(error)
                return
            } else {
                completion(nil)
            }
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    func forgotPassword(with email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    func fetchUser(completion: @escaping (User?, Error?) -> Void) {
        
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userUID)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let username = snapshotData["username"] as? String,
                   let email = snapshotData["email"] as? String,
                   let image = snapshotData["image"] as? String? {
                    let user = User(username: username, email: email, userUID: userUID, image: image)
                    completion(user, nil)
                }
            }
    }
    
    func signInWithGoogle(completion: @escaping (Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            completion(nil)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { userAuthentication, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = userAuthentication?.user,
                  let idToken = user.idToken else {
                completion(nil)
                return
            }
            
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(error)
                }
                
                guard let firebaseUser = authResult?.user else {
                    completion(nil)
                    return
                }
                
                let db = Firestore.firestore()
                db.collection("users").whereField("email", isEqualTo: firebaseUser.email ?? "Unknown").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    if let documents = querySnapshot?.documents, !documents.isEmpty {
                        completion(nil)
                        return
                    } else {
                        db.collection("users").document(firebaseUser.uid).setData([
                            "username": firebaseUser.displayName ?? "Unknown",
                            "email": firebaseUser.email ?? "Unknown",
                            "image": firebaseUser.photoURL?.absoluteString ?? "Unknown"
                        ]) { error in
                            if let error = error {
                                completion(error)
                            } 
                        }
                    }
                }
            }
        }
    }
}
