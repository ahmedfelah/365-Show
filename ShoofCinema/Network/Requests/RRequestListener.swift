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

enum RRequestState {
    case notBroadcasted,loading,finishWithSuccess, finishWithAPIError , error
}
protocol RRequestListenerProtocol : class {
    func rrequest_stateDidChange (For router:String, newState:RRequestState)
}
extension RRequestListenerProtocol {
    /// cache object index in listeners dictionary
    var rout_index:[String:Int] {get { return [:]} set {}}
}


struct RRequestInfo {
    var state:RRequestState
}
let rrequestListener = RRequestListener()
class RRequestListener: NSObject {
    private var broadcasts : [String:RRequestInfo] = [:]
    private var listeners  : [String:[RRequestListenerProtocol]] = [:]
    
    
    /// <#Description#>
    ///
    /// - Parameter router: <#router description#>
    func broadcast(For router:String) {
        broadcasts[router] = RRequestInfo(state: .loading)
    }
    func set(State newState:RRequestState, For router:String) {
        if var castedRouter = broadcasts[router] {
            castedRouter.state = newState
            broadcasts[router] = castedRouter
            
            if let objects = listeners[router] {
                for obj in objects {
                    obj.rrequest_stateDidChange(For: router, newState: newState)
                }
            }
            
        }
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - Listener: <#Listener description#>
    ///   - rout: <#rout description#>
    func add (Listener:RRequestListenerProtocol, to rout:String) {
        if var objects = listeners[rout] {
            //Add to existing listeners
            objects.append(Listener)
            Listener.rout_index[rout] = objects.count - 1
            listeners[rout] = objects
        } else {
            // The only listener
            listeners[rout] = [Listener]
            Listener.rout_index[rout] = 0
        }
        
    }
    func stop( Listening Listener:RRequestListenerProtocol, To rout:String? = nil) {
        if let rout = rout {
            if let objects = listeners[rout] {
                for (_,obj) in objects.enumerated() {
                    listeners[rout]!.remove(at: obj.rout_index[rout]!)
                }
            }
        } else {
            for (rout,_) in listeners {
                listeners[rout]!.remove(at: Listener.rout_index[rout]!)
            }
        }
    }
}
