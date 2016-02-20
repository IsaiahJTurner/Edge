//
//  User.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


class User {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var id:String?
    var type = "users"
    var name:String?
    var email:String?
    var phone:String?
    var password:String?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    var auths:Auths?
    
    var isIdentifier:Bool
    
    init(data: Dictionary<String, AnyObject>) {
        self.id = data["id"] as? String
        self.isIdentifier = true
        if let attributes = data["attributes"] {
            self.isIdentifier = false
            self.name = attributes["name"] as? String
            self.email = attributes["email"] as? String
            self.phone = attributes["phone"] as? String
            self.password = attributes["password"] as? String
            self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["createdAt"] as! Int))
            self.updatedAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["updatedAt"] as! Int))
        }
        if let relationships = data["relationships"] {
            if let auths = relationships["auths"] {
                self.auths = Auths(data: auths!["data"] as! Array<AnyObject>)
            }
        }
    }
    
    init(id: String) {
        self.isIdentifier = true
        self.id = id
    }
    init(name: String, email: String, phone: String, password: String) {
        self.isIdentifier = false
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
    }
    func toJSON() -> Dictionary<String, AnyObject> {
        var attributes = [String : AnyObject]()
        if let name = self.name {
            attributes["name"] = name
        }
        if let email = self.email {
            attributes["email"] = email
        }
        if let password = self.password {
            attributes["password"] = password
        }
        if let phone = self.phone {
            attributes["phone"] = phone
        }
        var relationships = [String : AnyObject]()
        if let auths = self.auths {
            relationships["auths"] = auths.toJSON()
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
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, user: User?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/users/\(self.id!)")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, user: nil, error: error)
                    } else { // and the json was without errors
                        let user = User(data: data.objectForKey("data") as! Dictionary<String, AnyObject>)
                        callback(response: response, data: data, user: user, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, user: nil, error: error.localizedDescription)
                }
        }
    }
    
    func save(callback: (response: Response<AnyObject, NSError>?, data: AnyObject?, user: User?, error: String?) -> ()) {
        if (self.isIdentifier) {
            return callback(response: nil, data: nil, user: nil, error: "Identifiers can't be saved")
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
        
        Alamofire.request(method, "\(endpoint)/users\(path)", parameters: self.toJSON(), encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, user: nil, error: error)
                    } else { // and the json was without errors
                        let user = User(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        callback(response: response, data: data, user: user, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, user: nil, error: error.localizedDescription)
                }
        }
    }
}