//
//  ProfileViewModel.swift
//  ShoofCinema
//
//  Created by mac on 8/3/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit



class ProfileViewModel: ObservableObject {
    
    @Published var user: ShoofAPI.User? = ShoofAPI.User.current
    @Published var status: ResponseStatus = .none
    @Published var fullName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var newPassword = ""
    
    lazy var hasDownloads = realm.objects(RDownload.self)
        .filter { $0.status != DownloadStatus.downloaded.rawValue }.count > 0
    
    init() {
        self.fullName = user?.name ?? ""
        self.email = user?.email ?? ""
        self.phone = user?.phone ?? ""
    }
    
    
    func loagout() {
        ShoofAPI.shared.signOut()
        self.user = ShoofAPI.User.current
    }
    
    
    func changeAvatar(avatar: UIImage) {
        self.status = .loading
        ShoofAPI.shared.updateUser(image: convertImageToString(avatar: avatar)) { [weak self] result in
            self?.handleUpdateUser(result: result)
        }
    }
    
    func updateInfo() {
        self.status = .loading
        ShoofAPI.shared.updateUser(name: fullName, email: email, phone: phone) { [weak self] result in
            self?.handleUpdateUser(result: result)
        }
    }
    
    func changePassword() {
        guard newPassword.isEmpty else {
            return
        }
        self.status = .loading
        ShoofAPI.shared.updateUser(password: newPassword) { [weak self] result in
            self?.handleUpdateUser(result: result)
        }
    }
    
    func deleteAccount() {
        if let currentUser = ShoofAPI.User.current {
            fakeDeletedAccounts.insert(currentUser)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            ShoofAPI.shared.signOut()
            self.user = ShoofAPI.User.current
        }
    }
    
    private func checkString(string: String) -> String? {
        return string.isEmpty ? nil : string
    }
    
    
    private func handleUpdateUser(result: Result<ShoofAPI.AccountEndpoint<ShoofAPI.User>.Response, Error>) {
        do {
            let response = try result.get()
            
            ShoofAPI.shared.currentUser { [weak self] result in
                self?.handleCurrentUser(result: result)
            }
            
        } catch(let error) {
            print("avatar", error)
        }

    }
    
    private func convertImageToString(avatar: UIImage) -> String {
        let avatarData: NSData = avatar.jpegData(compressionQuality: 0.50)! as NSData
        let avatarString = avatarData.base64EncodedString(options: .init(rawValue: 0))
        
        return avatarString
        
    }
    
    private func handleCurrentUser(result: Result<ShoofAPI.AccountEndpoint<ShoofAPI.User>.Response, Error>) {
        do {
            let response = try result.get()
            let user = response.body
            
            DispatchQueue.main.async {
                self.user = user
                self.status = .loaded
            }
        } catch {
            DispatchQueue.main.async {
                self.status = .failed
            }
        }
    }
    
    
}
