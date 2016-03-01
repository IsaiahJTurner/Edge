//
//  Auth.swift
//  Edge
//
//  Created by Isaiah Turner on 2/17/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


import Alamofire


class Auth {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var id:String?
    var type = "auths"
    var owner:User?
    var publicToken:String?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    
    var isIdentifier:Bool
    
    init(data: Dictionary<String, AnyObject>) {
        self.id = data["id"] as? String
        self.isIdentifier = true;
        if let attributes = data["attributes"] {
            self.isIdentifier = false;
            self.publicToken = attributes["publicToken"] as? String
            self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["createdAt"] as! Double / 1000.0))
            self.updatedAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["updatedAt"] as! Double / 1000.0))
        }
        if let relationships = data["relationships"] {
            self.isIdentifier = false;
            self.owner = User(data: relationships["owner"] as! Dictionary<String, AnyObject>)
        }
    }
    
    init(id: String) {
        self.isIdentifier = true
        self.id = id
    }
    init(publicToken: String, owner: User?) {
        self.isIdentifier = false
        self.publicToken = publicToken
        if ((owner) != nil) {
            self.owner = owner
        }
    }
    func toJSON() -> Dictionary<String, AnyObject> {
        var attributes = [String : AnyObject]()
        if ((self.publicToken) != nil) {
            attributes["publicToken"] = self.publicToken
        }
        var relationships = [String : AnyObject]()
        if ((self.owner) != nil) {
            relationships["owner"] = owner?.toJSON()
        }
        var resource : [String : AnyObject] = [
            "type": self.type,
            "attributes": attributes,
            "relationships": relationships
        ]
        if ((self.id) != nil) {
            resource["id"] = self.id
        }
        let data = [
            "data": resource
        ];
        
        return data
    }
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, auth: Auth?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/auths/\(self.id)")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, auth: nil, error: error)
                    } else { // and the json was without errors
                        let auth = Auth(data: data.objectForKey("data") as! Dictionary<String, AnyObject>)
                        
                        callback(response: response, data: data, auth: auth, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, auth: nil, error: error.localizedDescription)
                }
        }
    }
    
    func save(callback: (response: Response<AnyObject, NSError>?, data: AnyObject?, auth: Auth?, error: String?) -> ()) {
        if (self.isIdentifier) {
            return callback(response: nil, data: nil, auth: nil, error: "Identifiers can't be saved")
        }
        let method:Alamofire.Method
        let path:String
        if ((self.id) != nil) {
            method = Alamofire.Method.PATCH
            path = "/\(self.id)"
        } else {
            method = Alamofire.Method.POST
            path = ""
        }
        
        Alamofire.request(method, "\(endpoint)/auths\(path)", parameters: self.toJSON(), encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, auth: nil, error: error)
                    } else { // and the json was without errors
                        let auth = Auth(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        callback(response: response, data: data, auth: auth, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, auth: nil, error: error.localizedDescription)
                }
        }
    }
}