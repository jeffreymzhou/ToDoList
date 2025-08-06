//
//  TimeSegment.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/4/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct TaskTimeSegment : Codable, Identifiable, Equatable {
    let id: String
    let start: TimeInterval
    let end: TimeInterval
    let parentTaskId: String
    
    func save() {
        print("save time segment", self.asDictionary())
        // Get current user id
        guard let uId = Auth.auth().currentUser?.uid else {
            print("not logged in, skipping")
            return
        }
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uId)
            .collection("segments")
            .document(id)
            .setData(self.asDictionary()) { error in
                if let error = error {
                    print("Error setting data: \(error.localizedDescription)")
                } else {
                    print("Data successfully written!")
                }
            }
    }
}

