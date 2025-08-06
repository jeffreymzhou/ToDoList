//
//  SummaryRangeView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/5/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SummaryRangeView: View {
    @StateObject private var viewModel: SummaryRangeViewViewModel
    @State var selected = 1
    
    init(summaryRange: SummaryRangeEnum) {
        self._viewModel = StateObject(wrappedValue: SummaryRangeViewViewModel(summaryRange: summaryRange))
    }
    
    var body: some View {
        List(viewModel.taskSummaries) { summary in
            VStack(alignment: .leading) {
                Text(summary.task.title)
                Text("Duration: " + formatDuration(summary.totalDuration))
            }
        }
        .onAppear {
            Task {
                await viewModel.getTaskSegments()
                await viewModel.getSummaries()
            }
        }
    }
}
