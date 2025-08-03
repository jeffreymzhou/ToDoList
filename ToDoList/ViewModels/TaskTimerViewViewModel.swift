//
//  TaskItemViewViewModel().swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 10/26/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class TaskTimerViewViewModel: ObservableObject {
    @Published var currentTimeSpent: TimeInterval = 0
    var timer = Timer()
    var startTime: Date? = nil
    @Published var elapsedTimeSeconds: TimeInterval = 0
    
    init() {}
}
