//
//  ResellerAPI.swift
//  365Show
//
//  Created by ممم on 05/01/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import Foundation


enum DataError: Error {
    case invalidData
    case invalidResponse
    case message(_ error: Error?)
}

class ResellerAPI {
    static let shared = ResellerAPI()
    private init() { }
    
    //let url = URL(fileURLWithPath: "anyURL")
    
    func getToken(url: URL, completion: @escaping (Result<Reseller, DataError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299  ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // JSONDecoder() converts data to model
            do {
                let reseller = try JSONDecoder().decode(Reseller.self, from: data)
                completion(.success(reseller))
            }
            catch {
                completion(.failure(.message(error)))
            }
        }.resume()
    }
}
