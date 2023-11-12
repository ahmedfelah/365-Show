//
//  Endpoint.swift
//  
//
//  Created by Zaid Rahhawi on 11/7/21.
//

import Foundation
import TBKNetworking

extension ShoofAPI {
    struct Endpoint<ResponseBody : Decodable> : TBKNetworking.Endpoint {
        let scheme: Scheme = .https
        let host: String = ShoofAPI.shared.apiUrl
        let path: String
        let queryItems: [URLQueryItem]
        let method: TBKNetworking.HTTPMethod
        let headers: [HTTPHeader] = [Header(field: "Mode", value: ShoofAPI.User.ramadanTheme ? "2" : "0")]
        
        struct Response : Decodable {
            let body : ResponseBody
            let numberOfPages: Int
            let currentPage: Int
            
            var isOnLastPage: Bool {
                numberOfPages == currentPage
            }
            
            private enum CodingKeys: String, CodingKey {
                case error, message // API Error
                case data
                case currentPage
                case numberOfPages = "pagesCount"
            }
            
            private enum SectionsResponseKeys : String, CodingKey {
                case sections, inNetwork
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                let currentPage = try container.decode(Int.self, forKey: .currentPage)
                let numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
                
                // MARK: - API bug...
                if currentPage == 0 {
                    self.currentPage = 1
                } else {
                    self.currentPage = currentPage
                }
                
                if numberOfPages == 0 {
                    self.numberOfPages = 1
                } else {
                    self.numberOfPages = numberOfPages
                }
                                
                self.body = try container.decode(ResponseBody.self, forKey: .data)
            }
        }
        
        init(method: TBKNetworking.HTTPMethod = .get, path: String, @ArrayBuilder queryItems: () -> [URLQueryItem] = { [] }) {
            self.method = method
            self.path = path
            self.queryItems = queryItems()
        }
        
        func parse(_ data: Data) throws -> Response {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            return try decoder.decode(Response.self, from: data)
        }
        
        func prepare(request: inout URLRequest) {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(User.language, forHTTPHeaderField: "Content-Language")
            
            if case .post = method {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            if let token = User.current?.token {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
    }
    
    struct NoValueEndpoint : TBKNetworking.Endpoint {
        let scheme: Scheme = .http
        let host: String = "cinema-dev-api.shoofnetwork.net"
        let path: String
        let queryItems: [URLQueryItem]
        let method: TBKNetworking.HTTPMethod
        
        struct Response : Decodable {
            let numberOfPages: Int
            let currentPage: Int
            
            var isOnLastPage: Bool {
                numberOfPages == currentPage
            }
            
            private enum CodingKeys: String, CodingKey {
                case error, message // API Error
                case data
                case currentPage
                case numberOfPages = "pagesCount"
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                guard !(try container.decode(Bool.self, forKey: .error)) else {
                    throw Error.apiError
                }
                
                let currentPage = try container.decode(Int.self, forKey: .currentPage)
                let numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
                
                // MARK: - API bug...
                if currentPage == 0 {
                    self.currentPage = 1
                } else {
                    self.currentPage = currentPage
                }
                
                if numberOfPages == 0 {
                    self.numberOfPages = 1
                } else {
                    self.numberOfPages = numberOfPages
                }
            }
        }
        
        init(method: TBKNetworking.HTTPMethod = .get, path: String, @ArrayBuilder queryItems: () -> [URLQueryItem] = { [] }) {
            self.method = method
            self.path = path
            self.queryItems = queryItems()
        }
    }
}
