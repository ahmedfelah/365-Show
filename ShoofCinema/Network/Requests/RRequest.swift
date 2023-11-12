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
import SwiftyJSON

class RRequests: NSObject {
    typealias completionBlock = (_ result:JSON?,_ error:Error?) -> Swift.Void
    static private let manager = Session.default
    
    
    static func startRequest (baseURL:String? = nil,
                      path:String,
                      method:HTTPMethod,
                      params:[String:Any],
                      completion: @escaping completionBlock) {
        
        guard let req = makeRequest(baseURL: baseURL,path: path, method: method, params: params) else {
            fatalError("Couldn't make request with : \(["path" : path ,"params" : params])")
        }
        
        
        rrequestListener.broadcast(For: path)
        rrequestListener.set(State: .loading, For: path)
        req.responseJSON { (resp) in
            handleResponseJSON(
                path: path,
                resp: resp,
                completion: completion,
                retryRequest: {
                    startRequest(
                        path: path,
                        method: method,
                        params: params,
                        completion: completion)
            })
        }
    }
    
    struct FileToUpload {
        enum MimeType:String {
            case png = "image/png"
            case jpeg = "image/jpeg"
            case gif = "image/gif"
        }
        var serverFileKey:String
        var data:Data
        var saveName:String
        var mimeType:MimeType
        
        init?(JPEGImage:UIImage, quality:CGFloat,serverFileKey:String,saveName:String) {
            self.serverFileKey = serverFileKey
            self.saveName = saveName + ".jpg"
            self.mimeType = .jpeg
            if let d = JPEGImage.jpegData(compressionQuality: quality) {
                self.data = d
            } else {
                return nil
            }
        }
        init?(PNGImage:UIImage,serverFileKey:String,saveName:String) {
            self.serverFileKey = serverFileKey
            self.saveName = saveName + ".png"
            self.mimeType = .png
            if let d = PNGImage.pngData() {
                self.data = d
            } else {
                return nil
            }
        }
        init(data:Data,serverFileKey:String,saveName:String,mimeType:MimeType) {
            self.data = data
            self.serverFileKey = serverFileKey
            self.saveName = saveName + ".png"
            self.mimeType = mimeType
        }
    }
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - method: <#method description#>
    ///   - params: <#params description#>
    ///   - images: <#images description#>
    ///   - withCompanyID: <#withCompanyID description#>
    ///   - withToken: <#withToken description#>
    ///   - uploadProgress: <#uploadProgress description#>
    ///   - completion: <#completion description#>
    static func startUpload (path:String,
                            method:HTTPMethod,
                            params:[String:Any],
                            files:[FileToUpload],
                            uploadProgress:((Progress)->())? = nil,
                            completion:@escaping completionBlock)
    {
        guard let url = url(for: path) else {
            return
        }
        
        manager.upload(multipartFormData: { (mpfd) in
            for (key,value) in params {
                if value is String || value is Int {
                    mpfd.append("\(value)".data(using: .utf8)! , withName: key)
                }
            }
            for im in files {
                //name is "File[]" or "File" or so on
                mpfd.append(im.data,
                    withName: im.serverFileKey,
                    fileName: im.saveName,
                    mimeType: im.mimeType.rawValue)
            }
        }, to: url)
        .uploadProgress(queue: .main, closure: { (progress) in
            uploadProgress?(progress)
        })
        .responseJSON { (resp) in
            
            if let err = resp.error{
                completion(nil, err)
                return
            }
            handleResponseJSON(path: path, resp: resp, completion: completion) {
                startUpload(path: path, method: method, params: params, files: files, completion: completion)
            }
        }

    }
    
    /// Examine, Check, Broadcast completion, Check token for responseJSON block
    /// This is used for Normal and Upload requests
    /// - Parameters:
    ///   - path: server path
    ///   - resp: responseJSON from alamofire
    ///   - completion: completionBlock
    ///   - retryRequest: retry block if token renewed
    static private func handleResponseJSON (path:String,
                                    resp:AFDataResponse<Any>,
                                    completion:@escaping completionBlock,
                                    retryRequest:@escaping () -> ())
    {
        let examined = examine(Response : resp)
        
        /*
         Check alamofire error
         */
        if let error = examined.error {
            rrequestListener.set(State: .error, For: path)
            //alert(title: "Error", body: "Error in \(path)  : \(error.localizedDescription)", cancel: "Cancel")
            completion(nil, error)
            //fatalError("Error in \(path)  : \(error.localizedDescription)")
            return
        }
        
        /*
         Check api error
         */
        if let json = examined.json {
            //print(json)
            var api_error:RError?
            
            let responseCode = resp.response?.statusCode ?? 0
            let hasError   = json["code"].stringValue == "error"
            let exception = json["exception"].string
            var msg       = json["message"].string
            //let data      = json["data"]
            
            /*
             Check api errors with known exception
             */
            if hasError , responseCode == 401, Account.shared.token != nil {
                Account.shared.token = nil
            }
            /*
             Check api errors
             */
            if hasError {
                if msg == nil {
                    // Validation errors received as dictionary
                    /*
                     "message" : {
                        "token" : [
                            "The selected token is invalid."
                        ]
                     }
                    */
                    var errorsAsMessage: [String] = []
                    if let dic = json["message"].dictionaryObject as? [String:[String]] {
                        for (_,value) in dic {
                            errorsAsMessage.append(value.joined(separator: ", "))
                        }
                        msg = errorsAsMessage.joined(separator: "\n")
                    }
                }
                api_error = RError(localizedTitle: "Error",
                                   localizedDescription: (msg ?? "No message to show") + " . " + (exception ?? ""),
                                   code: responseCode)
            }
            
            /*
             Check laravel exceptions
             */
            
            
            
            
            /*
             Finish
             */
            completion(json , api_error)
            
            
            /* Broadcast */
            if let error = api_error {
                rrequestListener.set(State: .finishWithAPIError, For: path)
                //fatalError("+++ Error in \(path)  : \(error.localizedDescription)")
            } else {
                rrequestListener.set(State: .finishWithSuccess, For: path)
            }
        }
    }
    /// Generate request
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - method: <#method description#>
    ///   - params: <#params description#>
    ///   - withToken: <#withToken description#>
    /// - Returns: <#return value description#>
    static func makeRequest(baseURL:String? = nil,path:String,
                     method:HTTPMethod,
                     params:[String:Any]) -> DataRequest?
    {
        guard let url = url(baseURL: baseURL,for: path) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if path == Routes.netword {
            urlRequest.setValue("no-store", forHTTPHeaderField: "cache-control")
        }
        if let token = Account.shared.token {
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        
        do {
            let urlReq = try encoding.encode(urlRequest, with: params)
            print(urlReq.urlRequest?.url)
            print(urlReq.allHTTPHeaderFields)
            
            return manager.request(urlReq)
        } catch {
            return nil
        }
    }
    /// Url from path
    ///
    /// - Parameters:
    ///   - path: Repo backend path from enum
    ///   - withToken: is token required ?
    /// - Returns: URL
    static func url (baseURL:String? = nil, for path:String) -> URL?
    {
        return URL(string: (baseURL ?? Routes.cinemaAPI) + path)
    }
    /// Examine response and return JSON object or errors
    ///
    static func examine (Response resp:Alamofire.AFDataResponse<Any>) -> (json:JSON?,error:Error?) {
        var json:JSON?
        var error:Error?
        
        if let response_error = resp.error {
            error = response_error
        }
        
        if let result = resp.value {
            json = JSON(result)
        }
        
        return (json,error)
    }
}
