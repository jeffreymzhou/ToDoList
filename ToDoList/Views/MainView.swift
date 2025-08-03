//
//  ContentView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 3/30/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            accountView
        } else {
            LoginView()
        }
    }
    
    @ViewBuilder
    var accountView: some View {
        TabView {
            TaskTimerListView(userId: viewModel.currentUserId)
                .tabItem{
                    Label("Task Timers", systemImage: "house")
                }
            SummaryView()
                .tabItem{
                    Label("Summary", systemImage: "house")
                }
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainView()
}
