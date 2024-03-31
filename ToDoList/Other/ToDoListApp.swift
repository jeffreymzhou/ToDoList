//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 3/30/24.
//

import FirebaseCore
import SwiftUI

@main
struct ToDoListApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
