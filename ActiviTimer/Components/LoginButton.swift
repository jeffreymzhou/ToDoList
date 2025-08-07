//
//  LoginButton.swift
//  ActiviTimer
//
//  Created by Jeffrey Zhou on 8/6/25.
//

import SwiftUI

struct LoginButton: View {
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }.padding()
        }
    }
}

#Preview {
    LoginButton(title: "Button", background: .blue) {
        // Action
    }
}
