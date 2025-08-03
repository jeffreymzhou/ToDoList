//
//  TimeFormatUtils.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 11/4/24.
//

import Foundation

public func formatTimeInterval(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second] // Specify the units you want
    formatter.unitsStyle = .positional // Use positional style, e.g., "1:01:05"
    formatter.zeroFormattingBehavior = .pad // Pads with zeros, e.g., "01:01:05"

    return formatter.string(from: interval) ?? interval.formatted()
}

public func formatDuration(_ interval: TimeInterval) -> String {
    // Handle durations less than a minute, showing seconds only
    if interval < 60 {
        return "\(Int(interval.rounded()))s"
    }
    
    // Round to the nearest minute for any duration longer than 1 minute
    let days = Int(interval) / 86400
    let hours = (Int(interval) % 86400) / 3600
    let minutes = (Int(interval) % 3600) / 60

    // Build the output string based on non-zero components
    var components: [String] = []
    if days > 0 {
        components.append("\(days)d")
    }
    if hours > 0 {
        components.append("\(hours)h")
    }
    if minutes > 0 || components.isEmpty { // Ensure at least "0m" if all other units are zero
        components.append("\(minutes)m")
    }

    return components.joined(separator: " ")
}


public func formatDate(_ interval: TimeInterval?) -> String {
    if let interval = interval {
        // Convert TimeInterval to Date
        let date = Date(timeIntervalSince1970: interval)
        
        // Format the Date as "yyyy-MM-dd HH:mm:ss"
        return date.formatted(.dateTime
            .year(.defaultDigits)
            .month(.twoDigits)
            .day(.twoDigits)
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .second(.twoDigits))
        
    } else {
        return "nil date"
    }
}

