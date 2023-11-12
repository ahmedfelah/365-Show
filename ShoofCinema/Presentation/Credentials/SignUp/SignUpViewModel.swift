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
    @Published var password = ""
    
    func signUp() {
        self.isLoading = true
        guard !email.isEmpty, !password.isEmpty , !name.isEmpty else{
            HapticFeedback.error()
            return
        }
        
        ShoofAPI.shared.register(withEmail: email, userName: name, name: name, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = true
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
        } catch {
            print("Errors")
        }
    }
}
