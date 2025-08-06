//
//  SummaryView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/5/24.
//

import Foundation

import SwiftUI
import FirebaseFirestoreSwift

struct SummaryView: View {
    @State var selected: String = "day"
    
    init() {}
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $selected, label: Text("Picker"), content: {
                    Text("1-day").tag("day")
                    Text("7-day").tag("week")
                    Text("30-day").tag("month")
                    Text("All Time").tag("allTime")
                })
                .padding()
                .pickerStyle(SegmentedPickerStyle())
                
                if (selected == "day") {
                    SummaryRangeView(summaryRange: SummaryRangeEnum.day)
                } else if (selected == "week") {
                    SummaryRangeView(summaryRange: SummaryRangeEnum.week)
                } else if (selected == "month") {
                    SummaryRangeView(summaryRange: SummaryRangeEnum.month)
                } else if (selected == "year") {
                    SummaryRangeView(summaryRange: SummaryRangeEnum.year)
                } else if (selected == "allTime") {
                    SummaryRangeView(summaryRange: SummaryRangeEnum.allTime)
                }
            }
            
        }
        .navigationTitle("Summary View")
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
