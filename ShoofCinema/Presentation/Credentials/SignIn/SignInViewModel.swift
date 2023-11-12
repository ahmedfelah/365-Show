//
//  SignInViewModel.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


@MainActor
class SignInViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isLogged: Bool = false
    
    func submit(email: String, password: String) {
        
        guard !email.isEmpty, !password.isEmpty else {
            HapticFeedback.error()
            return
        }
        
        ShoofAPI.shared.login(withEmail: email, password: password) { [weak self] result in
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
    
    func signInWithGoogle() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        isLoading = true
        
        ShoofAPI.shared.signInWithGoogle(on: presentingViewController) { [weak self] result in
            self?.handleAuthentication(result: result)
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }
}
