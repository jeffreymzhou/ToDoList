//
//  AllTimerTasksView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 10/26/24.
//

import SwiftUI
import Foundation
import FirebaseFirestoreSwift

struct TaskTimerListView: View {
    @StateObject var viewModel: TaskTimerListViewViewModel
    @FirestoreQuery var tasks: [TaskTimer]

    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._tasks = FirestoreQuery(
            collectionPath: "users/\(userId)/tasks"
        )
        
        // Initialize _viewModel with a placeholder first
        self._viewModel = StateObject(wrappedValue: TaskTimerListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(self.tasks) { task in
                    TaskTimerView(
                                switchTaskCallback: { task in
                                    viewModel.switchTask(newTask: task)
                                    // Define what should happen when switchTask is called
                                    print("Switch task function called")
                                },
                                activeTask: $viewModel.activeTask,
                                elapsedTimeSeconds: $viewModel.elapsedTimeSeconds,
                                task: task // Provide an instance of TaskTimer
                            )
                        .swipeActions {
                            Button("Delete") {
                               viewModel.delete(id: task.id)
                            }
                            .tint(.red)
                        }
                }

            }
            .navigationTitle("Tasks")
            .toolbar {
                Button {
                    viewModel.showingNewTaskTimerView = true
                } label : {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewTaskTimerView) {
                NewTaskItemView(visible: $viewModel.showingNewTaskTimerView)
            }
        }
    }
}

struct TimerTaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskTimerListView(userId: "Ob1mIAlkElam46mu24bllKBhsvo2")
    }
}
