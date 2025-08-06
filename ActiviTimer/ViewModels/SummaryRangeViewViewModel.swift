//
//  SummaryViewViewModel.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/5/24.
//

import Foundation

import FirebaseAuth
import FirebaseFirestore

class SummaryRangeViewViewModel: ObservableObject {
    @Published var taskSummaries: [TaskSummary] = []
    @Published var taskSegments: [TaskTimeSegment] = []
    @Published var tasks: [TaskTimer] = []
    private var userId: String = ""
    private var summaryRange: SummaryRangeEnum
    private let db = Firestore.firestore()
    
    init(summaryRange: SummaryRangeEnum) {
        self.summaryRange = summaryRange
    }
    
    func getStartOfRange(now: TimeInterval, summaryRange: SummaryRangeEnum) -> TimeInterval? {
        let oneDayInterval: TimeInterval = 24 * 60 * 60
        let sevenDayInterval: TimeInterval = 7 * oneDayInterval
        let thirtyDayInterval: TimeInterval = 30 * oneDayInterval
        let threeSixtyFiveDayInterval: TimeInterval = 365 * oneDayInterval
        switch summaryRange {
            case SummaryRangeEnum.day:
                return now - oneDayInterval
            case SummaryRangeEnum.week:
                return now - sevenDayInterval
            case SummaryRangeEnum.month:
                return now - thirtyDayInterval
            case SummaryRangeEnum.year:
                    return now - threeSixtyFiveDayInterval
            case SummaryRangeEnum.allTime:
                    return nil
        }
    }
    
    func getSummaries() async {
        let tasks = await fetchTasks()
        
        let now = Date().timeIntervalSince1970
        let start = getStartOfRange(now: now, summaryRange: summaryRange)
        let end = now
        let taskSegments = await fetchTaskTimerSegmentsInTimeRange(rangeStart: start, rangeEnd: end)
        
        // Step 1: Build a dictionary of tasks based on their `id`
        var taskDictionary = [String: TaskTimer]()
        for task in tasks {
            taskDictionary[task.id] = task
        }
        
        // Step 2: Build a dictionary of TaskSummary objects, keyed by `parentTaskId`
        var summaryDictionary = [String: TaskSummary]()
        
        for segment in taskSegments {
            if let task = taskDictionary[segment.parentTaskId] {
                if var summary = summaryDictionary[segment.parentTaskId] {
                    summary.addSegment(segment: segment)
                    summaryDictionary[segment.parentTaskId] = summary
                } else {
                    summaryDictionary[segment.parentTaskId] = TaskSummary(
                        id: UUID().uuidString,
                        task: task,
                        segments: [segment],
                        start: start ?? TimeInterval(0),
                        end: end
                    )
                }
            }
        }
        
        self.taskSummaries = Array(summaryDictionary.values).sorted(by: { (a: TaskSummary, b: TaskSummary) in
            a.totalDuration < b.totalDuration
        })
    }
    
    func fetchTasks() async -> [TaskTimer] {
        let query = db.collection("users")
                .document(userId)
                .collection("tasks")

        do {
            
            let snapshot = try await query.getDocuments()
            print("Performed query in Firestore, got tasks: \(snapshot.documents.count)")
            
            return snapshot.documents.compactMap { document in
                try? document.data(as: TaskTimer.self)
            }
            
        } catch let error as NSError {
            // Handle Firestore-specific errors here
            print("Firestore error: \(error.localizedDescription)")
        } catch {
            // Handle unexpected errors
            print("Unexpected error: \(error.localizedDescription)")
        }
        
        return []
    }
    
    func fetchTaskTimerSegmentsInTimeRange(rangeStart: TimeInterval?, rangeEnd: TimeInterval) async -> [TaskTimeSegment] {
        let db = Firestore.firestore()
        
        let ref = db.collection("users").document(userId).collection("segments")
        var query: Query = ref
        // Add optional start of query range
        // rangeStart can be nil if we are searching for all segments before a certain time
        if let rangeStart = rangeStart {
            query = query.whereField("start", isGreaterThan: rangeStart)
        }
        // Add required end of query range
        query = query.whereField("end", isLessThan: rangeEnd)
        
        do {
            
            let snapshot = try await query.getDocuments()
            print("Performed query in Firestore, got this number of results: \(snapshot.documents.count)")
            
            return snapshot.documents.compactMap { document in
                try? document.data(as: TaskTimeSegment.self)
            }
            
        } catch let error as NSError {
            // Handle Firestore-specific errors here
            print("Firestore error: \(error.localizedDescription)")
        } catch {
            // Handle unexpected errors
            print("Unexpected error: \(error.localizedDescription)")
        }
        
        return []
    }

    
    func getTaskSegments() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        self.userId = userId
        
        let now = Date().timeIntervalSince1970
        let start = getStartOfRange(now: now, summaryRange: summaryRange)
        let end = now
        
        print("summary range: " + summaryRange.rawValue)
        print("calculated start of range: " + formatDate(start) + " - " + (start?.description ?? "nil"))
        print("calculated end of range: " + formatDate(end) + " - " + end.description)
        
        self.taskSegments = await fetchTaskTimerSegmentsInTimeRange(rangeStart: start, rangeEnd: end)
        
        print("number of task segments in range: " + self.taskSegments.count.description)
    }
    
    
}
