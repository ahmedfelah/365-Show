//
//  RRouter.swift
//  Repo
//
//  Created by Husam Aamer on 7/31/17.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

import Foundation
import Alamofire

protocol RErrorProtocol: Error {
    
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var code: Int { get }
}

struct RError:RErrorProtocol, LocalizedError {
    
    var localizedTitle: String
    var localizedDescription: String
    var code: Int
    
    init(localizedTitle: String?, localizedDescription: String, code: Int) {
        self.localizedTitle = localizedTitle ?? "Error"
        self.localizedDescription = localizedDescription
        self.code = code
    }
    
    var errorDescription: String? {
        get {
            return localizedDescription
        }
    }
//    override var description: String {
//        get {
//            return "MyError: \(desc)"
//        }
//    }
//    //You need to implement `errorDescription`, not `localizedDescription`.
//    var errorDescription: String? {
//        get {
//            return self.description
//        }
//    }
}

enum JWTExceptions {
    static let UserNotDefined = "UserNotDefinedException"
    static let TokenExpired = "TokenExpiredException"
    static let TokenInvalid = "TokenInvalidException"
    static let TokenBlacklisted = "TokenBlacklistedException"
    static let JWTException = "JWTException"
}




