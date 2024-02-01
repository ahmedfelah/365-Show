//
//  SignUpViewModel.swift
//  ShoofCinema
//
//  Created by mac on 8/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


class SignUpViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isLogged: Bool = false
    @Published var email = ""
    @Published var name = ""
    @Published var username = ""
    @Published var password = ""
    @Published var errors = ""
    
    func signUp() {
        
        guard !email.isEmpty, !password.isEmpty , !name.isEmpty else{
            HapticFeedback.error()
            return
        }
        
        self.isLoading = true
        
        ShoofAPI.shared.register(withEmail: email, userName: username, name: name, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            self?.handleAuthentication(result: result)
        }
        
    }
    
    
    private func handleAuthentication(result: Result<ShoofAPI.AccountEndpoint<ShoofAPI.User>.Response, Error>) {
        do {
            let response = try result.get()
            let user = response.body
                        
            guard !fakeDeletedAccounts.contains(user) else {
                ShoofAPI.shared.signOut()
                return
            }
            
            DispatchQueue.main.async {
                self.isLogged = true
            }
            
        } catch ShoofAPI.Error.authenticationCancelled {
            print("Cancelled")
        } catch(let errors) {
            DispatchQueue.main.async {
                self.errors = errors.localizedDescription
            }
            print("Errors", errors)
        }
    }
}
