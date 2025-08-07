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
    @Published var activeTask: TaskTimer? = nil;
    @Published var elapsedTimeSeconds: TimeInterval = 0
    
    private var db: Firestore
    var timer: Timer = Timer()
    private let userId: String
    private var didBecomeActiveObserver: NSObjectProtocol?
    
    init(userId: String) {
        self.userId = userId
        self.db = Firestore.firestore()
        Task {
            await self.loadActiveTaskTimer(for: userId)
        }
        self.setupDidBecomeActiveNotification()
    }

    deinit {
        if let observer = didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupDidBecomeActiveNotification() {
        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("app became active again")
            guard let self = self else {
                return }
            Task {
                await self.loadActiveTaskTimer(for: self.userId)
            }
        }
    }
    
    func loadActiveTaskTimer(for userId: String) async {
        do {
            print("Querying for active task timers")
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
                print("Found an active task, setting it to start: \(activeTask.title)")
                self.activeTask = activeTask
                self.elapsedTimeSeconds = Date().timeIntervalSince1970 - activeTask.startTime
                self.startTimer()
            } else {
                print("No active tasks found")
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    func delete(id: String) {
        // delete the task from the database
        db.collection("users")
            .document(userId)
            .collection("tasks")
            .document(id)
            .delete()
        
        // remove the task information from the local class
        self.activeTask = nil
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
        }

        if startNewTask {
            var newTaskCopy = newTask
            newTaskCopy.start()
            startTimer()
            
            activeTask = newTaskCopy
        }
    }
    
    func startTimer() {
        Task { @MainActor in
            timer.invalidate()
            print("starting timer")
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
                guard let self = self else { return }
                self.elapsedTimeSeconds += 1
                print("tick \(self.elapsedTimeSeconds)")
            })
        }
    }
    
    func resetTimer() {
        timer.invalidate()
        elapsedTimeSeconds = 0
    }
}
