//
//  ShoofAPIAccountEndpoint.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/19/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation
import TBKNetworking

extension ShoofAPI {
    struct AccountEndpoint<ResponseBody : Decodable> : TBKNetworking.Endpoint {
        let host: String
        let path: String
        let method: TBKNetworking.HTTPMethod
        let token: String?
        
        var scheme: Scheme {
            .http
        }
        
        struct Error : LocalizedError {
            let errorDescription: String?
        }
        
        struct Response : Decodable {
            let body: ResponseBody
            
            private enum CodingKeys : String, CodingKey {
                case body = "data"
                case status, message
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                guard try container.decode(Bool.self, forKey: .status) else {
                    let message = try container.decodeIfPresent(String.self, forKey: .message)
                    throw Error(errorDescription: message)
                }
                
                self.body = try container.decode(ResponseBody.self, forKey: .body)
            }
        }
            
        init(host: String = "account-api.shoofnetwork.net", path: String, method: TBKNetworking.HTTPMethod, token: String? = nil) {
            self.host = host
            self.path = path
            self.method = method
            self.token = token
        }
        
        func prepare(request: inout URLRequest) {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(User.language, forHTTPHeaderField: "Content-Language")
            
            if let token = ShoofAPI.User.current?.token {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                if let token = token {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
            }
        }
        
        func parse(_ data: Data) throws -> Response {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            return try decoder.decode(Response.self, from: data)
        }
        
        init<Form : Encodable>(path: String, form: Form, type: MethodType = .post, token: String? = nil) {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(form)
            self.init(path: path, method: type == .post ? .post(data: data) : .put(data: data), token: token)
        }
    }
}

extension ShoofAPI.AccountEndpoint {
    
    @propertyWrapper
    struct NullEncodable<T>: Encodable where T: Encodable {
        
        var wrappedValue: T?

        init(wrappedValue: T?) {
            self.wrappedValue = wrappedValue
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch wrappedValue {
            case .some(let value): try container.encode(value)
            case .none: try container.encodeNil()
            }
        }
    }
    
    enum MethodType {
        case post
        case put
    }
    
    struct Claim : Encodable {
        let name: String
        let value: String
    }
    
    struct ForgetPassword : Encodable {
        let email: String
    }
    
    struct ChangePassword : Encodable {
        let code: String
        let password: String
    }
    
    struct Login : Encodable {
        let email: String
        let password: String
    }
    
    struct Update: Encodable {
        let name: String?
        let username: String?
        let email: String?
        let password: String?
        let phone: String?
        let image: String?
    }
    
    struct Register : Encodable {
        let email: String
        let userName: String
        let name: String
        let password: String
        let claims: [Claim] = []
        let role = "User"
    }
    
    struct SasUserInfo: Encodable {
        let token: String?
        let deviceType: Int
        let baseUrl: String
    }
    
    struct GoogleSignIn : Codable {
        let userUID: String
        
        private enum CodingKeys : String, CodingKey {
            case userUID = "key"
        }
    }
    
    struct Topic : Encodable {
        let topic: String
        let userID: String
        
        private enum CodingKeys : String, CodingKey {
            case topic
            case userID = "userId"
        }
    }
}

extension Endpoint where Self == ShoofAPI.AccountEndpoint<ShoofAPI.User> {
    static func login(withEmail email: String, password: String) -> Self {
        let form = Self.Login(email: email, password: password)
        return Self(path: "/api/User/Login", form: form)
    }
    
    static func register(withEmail email: String, userName: String, name: String, password: String) -> Self {
        let form = Self.Register(email: email, userName: userName, name: name, password: password)
        return Self(path: "/api/User", form: form)
    }
    
    static func signInWithShoof(userUID: String) -> Self {
        let form = Self.GoogleSignIn(userUID: userUID)
        return Self(path: "/api/User/FirebaseLogin", form: form)
    }
    
    static func updateUser(name: String?, username: String?, email: String?, password: String?, phone: String?, image: String?) -> Self {
        let form = Self.Update(name: name, username: username, email: email, password: password, phone: phone, image: image)
        return Self(path: "/api/User/Current", form: form, type: .put)
    }
    
    static func currentUser() -> Self {
        return Self(path: "/api/User/Current", method: .get)
    }
    

}

extension Endpoint where Self == ShoofAPI.AccountEndpoint<String> {
    static func forgetPassword(email: String) -> Self {
        let form = Self.ForgetPassword(email: email)
        return Self(path: "/api/Password/Forget", form: form)
    }
    
    static func changePassword(code: String, password: String, token: String) -> Self {
        let form = Self.ChangePassword(code: code, password: password)
        return Self(path: "/api/Password/Update", form: form, type: .put, token: token)
    }

}

extension Endpoint where Self == ShoofAPI.AccountEndpoint<Bool> {
    static func addTopic(_ topic: String, forUserWithID userID: String) -> Self {
        let form = Self.Topic(topic: topic, userID: userID)
        return Self(path: "/api/User/AddTopic", form: form)
    }
}

extension Endpoint where Self == ShoofAPI.AccountEndpoint<Bool> {
    static func autoLogin(token: String?, deviceType: Int, baseUrl: String) -> Self {
        let form = self.SasUserInfo(token: token, deviceType: deviceType, baseUrl: baseUrl)
        return Self(path: "/api/MobileV3/SasUserInformation/SaveInfo", form: form)
    }
}

extension Endpoint where Self == ShoofAPI.AccountEndpoint<ShoofAPI.AutoLogin> {
    static func checkReseller(host: String, path: String) -> Self {
        return Self(host: host,  path: path, method: .get)
    }
}
