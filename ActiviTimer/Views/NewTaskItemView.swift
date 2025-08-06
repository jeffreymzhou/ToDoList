//
//  NewTaskItemView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 10/26/24.
//

import SwiftUI

struct NewTaskItemView: View {
    @StateObject var viewModel = NewTaskItemViewViewModel()
    @Binding var visible: Bool
    
    var body: some View {
        VStack {
            Text("New Task")
                .font(.system(size:32))
                .bold()
                .padding(.top, 100)
            
            Form {
                // Title
                TextField("Title", text: $viewModel.title)
                
                // Button
                TLButton(title: "Save",
                         background: .pink) {
                    if viewModel.canSave {
                        viewModel.save()
                        visible = false
                    } else {
                        viewModel.showAlert = true
                    }
                                        
                }
                .padding()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text("Please fill in all fields and select due date that is today or newer."))
            }
        }
    }
}

struct NewTaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskItemView(visible: Binding(get: {
            return true
        }, set: {_ in
            
        }))
    }
}
