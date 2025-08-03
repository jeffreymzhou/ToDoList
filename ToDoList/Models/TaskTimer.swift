//
//  TaskItem.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 10/26/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct TaskTimer : Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let createdDate: TimeInterval
    
    var isActive: Bool
    var startTime: TimeInterval
    var totalTimeSpent: TimeInterval
    
    mutating func start() {
        isActive = true
        startTime = Date().timeIntervalSince1970
        save()
    }
    
    mutating func stop() {
//        guard startTime != nil && isActive else {
//            print("Could not stop task - the task is not active or startTime is nil")
//            return
//        }
//        let now = Date()
//        let timeSpent = now.timeIntervalSince(startTime)
//        totalTimeSpent = totalTimeSpent + timeSpent
        print("About to stop active task:", self)
        let timeSpent = Date().timeIntervalSince1970 - startTime
        print("time spent", timeSpent, Date().timeIntervalSince1970, startTime)
        totalTimeSpent = totalTimeSpent + timeSpent
        isActive = false
        startTime = 0.0
        save()
    }
    
    func save() {
        // Get current user id
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uId)
            .collection("tasks")
            .document(id)
            .setData(self.asDictionary())
    }
}
