//
//  LoginView.swift
//  ToDoList
//
//  Created by Jeffrey Zhou on 3/30/24.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(
                    title: "Activitimer",
                    subtitle: "Time your Activities",
                    angle: 15,
                    background: .pink
                )

                // Login form
                Form {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }

                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization( /*@START_MENU_TOKEN@*/
                            .none /*@END_MENU_TOKEN@*/
                        )
                        .autocorrectionDisabled()

                    TextField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TLButton(
                        title: "Log In",
                        background: .blue
                    ) {
                        viewModel.login()
                    }

                    SignInWithAppleButton(
                        onRequest: { request in
                            viewModel.handleSignInWithAppleRequest(request)
                        },
                        onCompletion: { result in
                            viewModel.handleSignInWithAppleCompletion(result)
                        }
                    )

                }.offset(y: -60)

                // Create Account
                VStack {
                    Text("New around here?")

                    NavigationLink(
                        "Create An Account",
                        destination: RegisterView()
                    )
                }
                .padding(.bottom, 50)

                Spacer()
            }
        }
    }

}

#Preview {
    LoginView()
}
