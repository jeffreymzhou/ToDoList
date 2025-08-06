//
//  TimerTaskListViewViewModel.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 10/26/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class TaskTimerListViewViewModel: ObservableObject {
    @Published var showingNewTaskTimerView = false;
    @Published var activeTaskId: String? = nil;
    @Published var activeTask: TaskTimer? = nil;
    @Published var activeTaskName: String? = nil;
    @Published var elapsedTimeSeconds: TimeInterval = 0
    
    private var db: Firestore
    var timer: Timer = Timer()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self.db = Firestore.firestore()
        Task {
            do {
                print("trying to query for snapshot of all active task timers")
                let querySnapshot = try await self.db.collection("users").document(userId).collection("tasks").whereField("isActive", isEqualTo: true)
                    .getDocuments()

                let activeTaskTimers: [TaskTimer] = try querySnapshot.documents.compactMap { document in
                        try document.data(as: TaskTimer.self)  // Decode document data as TaskTimer
                    }
                
                if activeTaskTimers.count > 1 {
                    print("Error: More than one active timer found in db")
                    return
                }
                
                if let activeTask = activeTaskTimers.first {
                    
                    self.activeTaskId = activeTask.id
                    self.activeTaskName = activeTask.title
                    self.elapsedTimeSeconds = Date().timeIntervalSince1970 - activeTask.startTime
                    self.startTimer()

                } else {
                    print("No documents found in querySnapshot.")
                }
                
                print("Found all docs with active status: " + querySnapshot.documents.count.description)
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
    
    func delete(id: String) {
        db.collection("users")
            .document(userId)
            .collection("tasks")
            .document(id)
            .delete()
    }
    
    func fetchTaskFromDatabase(id: String, completion: @escaping (TaskTimer?) -> Void) {
        let docRef = db.collection("users")
            .document(userId)
            .collection("tasks")
            .document(id)

        docRef.getDocument(as: TaskTimer.self) { result in
            switch result {
            case .success(let task):
              // A Book value was successfully initialized from the DocumentSnapshot.
                completion(task)
            case .failure(let error):
                print("Error decoding document: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    
    func switchTask(newTask: TaskTimer) {
        // Determine whether the start a new task based on if the newly requested task
        // is equal to the currently active task or not
        let startNewTask = (newTask.id != activeTask?.id)
        print("Switching task ", newTask.title)
        print("Start new task bool: " + startNewTask.description)
        
        if var activeTask = activeTask {
            print("Stopping: \(activeTask.title)")
            let newTimeSegment = TaskTimeSegment(
                id: UUID().uuidString,
                start: activeTask.startTime,
                end: Date().timeIntervalSince1970,
                parentTaskId: activeTask.id
            )
            activeTask.stop()
            newTimeSegment.save()
            resetTimer()
            
            self.activeTask = nil
            self.activeTaskId = nil
            self.activeTaskName = "none"
        }
        
        if startNewTask {
            var newTaskCopy = newTask
            newTaskCopy.start()
            startTimer()
            
            activeTask = newTaskCopy
            activeTaskId = newTaskCopy.id
            activeTaskName = newTaskCopy.title
        }
    }
    
    func startTimer() {
        timer.invalidate()
        print("starting timer")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in
            self.elapsedTimeSeconds += 1
            print("tick")
        })
    }
    
    func resetTimer() {
        timer.invalidate()
        elapsedTimeSeconds = 0
    }

}
