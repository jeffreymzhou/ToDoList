//
//  TaskSummary.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/5/24.
//

import Foundation

struct TaskSummary : Codable, Equatable, Identifiable {
    let id: String
    let task: TaskTimer
    let segments: [TaskTimeSegment]
    let start: TimeInterval
    let end: TimeInterval
    
    var totalDuration: TimeInterval {
        var totalDuration = TimeInterval(0)
        
        for segment in segments {
                    let duration = segment.end - segment.start
                    totalDuration += duration
                }
        
        return totalDuration
    }
    var averageDuration: TimeInterval {
        return numSegments > 0 ? totalDuration / Double(numSegments) : 0
    }
    
    var numSegments: Int {
        return segments.count
    }
    var durationPercentage: Int {
        let rangeDuration = end - start
        guard rangeDuration > 0 else { return 0 }  // Avoid division by zero
        
        let percentage = (totalDuration / rangeDuration) * 100
        return Int(percentage.rounded())
    }
    
    mutating func addSegment(segment: TaskTimeSegment) {
        // Create a copy of `segments` with the new segment added
        var newSegments = segments
        newSegments.append(segment)

        // Calculate the new start and end times
        let newStart = min(start, segment.start)
        let newEnd = max(end, segment.end)

        // Assign the modified copy back to self
        self = TaskSummary(
            id: self.id,
            task: task,
            segments: newSegments,
            start: newStart,
            end: newEnd
        )
    }
    
}
