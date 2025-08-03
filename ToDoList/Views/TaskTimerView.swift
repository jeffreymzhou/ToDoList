//
//  TaskItemView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 10/26/24.
//

import Foundation
import SwiftUI

struct TaskTimerView: View {
    let switchTaskCallback: (TaskTimer) -> Void
    @Binding var activeTask: TaskTimer?
    @Binding var elapsedTimeSeconds: TimeInterval
    @StateObject var viewModel = TaskTimerViewViewModel()
    let task: TaskTimer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.body)
                    .bold()
                Text("Total time: " + formatTimeInterval(task.totalTimeSpent))
                if task.id == activeTask?.id {
                    Text("Task has started: " + formatTimeInterval(elapsedTimeSeconds))
                }
            }
            
            Spacer()
            
            Button {
                switchTaskCallback(task)
            } label : {
                Image(systemName: task.isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color.blue)
            }
        }
    }
}

#Preview {
    TaskTimerView(
        switchTaskCallback: {task in
            // Define what should happen when switchTask is called
            print("Switch task function called with task: \(task)")
        },
        activeTask: .constant(nil), // Use .constant for Binding in previews
        elapsedTimeSeconds: .constant(0),
        task: TaskTimer(
            id: "123",
            title: "Get milk",
            createdDate: Date().timeIntervalSince1970,
            isActive: true,
            startTime: 0,
            totalTimeSpent: 100
        )
    )
}
