//
//  RegisterViewViewModel.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 3/30/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    init() {}
    
    func register() {
        print("Attempting to register user")
        guard validate() else {
            print("invalid attempt!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            
            guard let userId = result?.user.uid else {
                print("Error: User id was not found after registering")
                return
            }
            
            print("Found user id: " + userId)
            
            self?.insertUserRecord(id: userId)
        }
    }
    
    private func insertUserRecord(id: String) {
        print("Inserting user record id: ", id)
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
    
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        
        guard password.count > 6 else {
            return false
        }
        
        return true
    }
}
