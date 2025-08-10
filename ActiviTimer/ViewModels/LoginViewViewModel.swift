//
//  LoginViewViewModel.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 3/30/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

class LoginViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var currentNonce: String?
    
    init() {}
    
    func login() {
        guard validate() else {
            return
        }
        print("Validated inputs. Attempting to log user in.")
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            
            errorMessage = "Please fill in all fields"
            return false
        }
        
        return true
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        print("requesting sign in with apple")
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        print("handling sign in with apple completion result")
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("Authorization credential is not of type ASAuthorizationAppleIDCredential")
                return
            }
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken,
                    let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to fetch identity token")
                return
            }

            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            Auth.auth().signIn(with: credential) {
                (authResult, error) in
                if error != nil {
                    print("received error from firebase auth")
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(
                        error?.localizedDescription
                        as Any
                    )
                    return
                }
                guard
                    let email = Auth.auth().currentUser?.email,
                    let userId = Auth.auth().currentUser?.uid
                else {
                    print("email / userId was nil")
                    return
                }
                
                guard let name = Auth.auth().currentUser?.displayName
                else {
                    print("did not find display name")
                    return
                }
                print("found display name")
            
                
                print("signed in user email: \(email) (id = \(userId)")
                
                let db = Firestore.firestore()
                db.collection("users").document(userId).getDocument { snapshot, error in
                    guard error == nil else {
                        print("Error fetching user info from db: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    if snapshot?.exists ?? false {
                        print("User already exists")
                    } else {
                        self.insertUserRecord(id: userId, name: name, email: email, joined: Date().timeIntervalSince1970)
                    }
                }
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    private func insertUserRecord(id: String, name: String, email: String, joined: TimeInterval) {
        print("Creating new user data in db for: ", email)
        let newUser = User(id: id,
                           name: name,
                           email: email,
                           joined: Date().timeIntervalSince1970)
        
        let newUserDict = newUser.asDictionary()
        print("User dictionary: ", newUserDict)
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUserDict) { (error) in
                if let e = error {
                    print("Error saving: \(e)")
                } else {
                    print("Successfully saved to firestore db")
                }}
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(
            kSecRandomDefault,
            randomBytes.count,
            &randomBytes
        )
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
            Array(
                "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
            )

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
