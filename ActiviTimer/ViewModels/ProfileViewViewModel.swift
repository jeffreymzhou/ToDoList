//
//  ProfileViewViewModel.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 3/30/24.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class ProfileViewViewModel: ObservableObject {
    
    init() {}
    
    @Published var user: User? = nil
    
    func fetchUser() {
        print("fetch user called")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("no user id found")
            return
        }
        let db = Firestore.firestore()
        
        print("fetching user from db (user id \(userId))")
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("failed to get user from db")
                print(error)
                return
            }
            
            print("found user in db - setting user info")
            DispatchQueue.main.async {
                self?.user = User(
                    id: data["id"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    joined: data["joined"] as? TimeInterval ?? 0)
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
