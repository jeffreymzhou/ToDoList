//
//  TimeSegmentListView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/4/24.
//

import Foundation

import SwiftUI
import FirebaseFirestoreSwift

struct TimeSegmentListView: View {
//    @StateObject var viewModel: TaskTimerListViewViewModel
    @FirestoreQuery var timeSegments: [TaskTimeSegment]

    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._timeSegments = FirestoreQuery(
            collectionPath: "users/\(userId)/segments"
        )
        
        // Initialize _viewModel with a placeholder first
//        self._viewModel = StateObject(wrappedValue: TimeSegmentListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(self.timeSegments) { timeSegment in
                    VStack {
                        Text(timeSegment.parentTaskId)
                        Text("start: " + formatDate(timeSegment.start))
                        Text("end: " + formatDate(timeSegment.end))
                    }
                }
            }
            .navigationTitle("Time Segments")
        }
    }
}

//struct TimerTaskListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskTimerListView(userId: "Ob1mIAlkElam46mu24bllKBhsvo2")
//    }
//}
