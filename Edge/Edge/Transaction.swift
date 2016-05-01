//
//  Transaction.swift
//  Edge
//
//  Created by Isaiah Turner on 2/1/816.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


import Alamofire


class Transaction {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var id:String?
    var type = "transactions"
    var owner:User?
    var auth:Auth?
    var pendingTransaction:Transaction?
    
    
    var title:String?
    var subtotal:Double?
    var tip:Double?
    var total:Double?
    
    var plaid_id:String?
    var plaidPending:Bool?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    
    var isIdentifier:Bool
    
    init(data: Dictionary<String, AnyObject>) {
        self.id = data["id"] as? String
        self.isIdentifier = true;
        if let attributes = data["attributes"] {
            self.isIdentifier = false;
            self.title = attributes["title"] as? String
            self.plaid_id = attributes["plaid_id"] as? String
            self.plaidPending = attributes["plaidPending"] as? Bool
            self.subtotal = attributes["subtotal"] as? Double
            self.tip = attributes["tip"] as? Double
            self.total = attributes["total"] as? Double
            self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["createdAt"] as! Double / 1000.0))
            self.updatedAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["updatedAt"] as! Double / 1000.0))
        }
        if let relationships = data["relationships"] {
            self.isIdentifier = false;
            self.owner = User(data: relationships["owner"] as! Dictionary<String, AnyObject>)
            if let auth = relationships["auth"] as? Dictionary<String, AnyObject> {
                self.auth = Auth(data: auth);
            }
            if let pendingTransaction = relationships["pendingTransaction"] as? Dictionary<String, AnyObject> {
                self.pendingTransaction = Transaction(data: pendingTransaction);
            }
        }
    }
    
    init(id: String) {
        self.isIdentifier = true
        self.id = id
    }
    init(title: String?, subtotal: Double?, tip: Double?) {
        self.isIdentifier = false
        self.title = title
        self.subtotal = subtotal
        self.tip = tip
    }
    func toJSON() -> Dictionary<String, AnyObject> {
        var attributes = [String : AnyObject]()
        if ((self.title) != nil) {
            attributes["title"] = self.title
        }
        if ((self.subtotal) != nil) {
            attributes["subtotal"] = self.subtotal
        }
        if ((self.tip) != nil) {
            attributes["tip"] = self.tip
        }
        if ((self.plaid_id) != nil) {
            attributes["plaid_id"] = self.plaid_id
        }
        if ((self.plaidPending) != nil) {
            attributes["plaidPending"] = self.plaidPending
        }
        if ((self.total) != nil) {
            attributes["total"] = self.total
        }
        var relationships = [String : AnyObject]()
        if ((self.owner) != nil) {
            relationships["owner"] = owner?.toJSON()
        }
        if ((self.auth) != nil) {
            relationships["auth"] = auth?.toJSON()
        }
        if ((self.pendingTransaction) != nil) {
            relationships["pendingTransaction"] = pendingTransaction?.toJSON()
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
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, transaction: Transaction?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/\(self.type)/\(self.id)")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, transaction: nil, error: error)
                    } else { // and the json was without errors
                        let transaction = Transaction(data: data.objectForKey("data") as! Dictionary<String, AnyObject>)
                        callback(response: response, data: data, transaction: transaction, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, transaction: nil, error: error.localizedDescription)
                }
        }
    }
    
    func save(callback: (response: Response<AnyObject, NSError>?, data: AnyObject?, transaction: Transaction?, error: String?) -> ()) {
        if (self.isIdentifier) {
            return callback(response: nil, data: nil, transaction: nil, error: "Identifiers can't be saved")
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
        
        Alamofire.request(method, "\(endpoint)/\(self.type)\(path)", parameters: self.toJSON(), encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, transaction: nil, error: error)
                    } else { // and the json was without errors
                        let transaction = Transaction(data: data.objectForKey("data") as! Dictionary<String, AnyObject>)
                        callback(response: response, data: data, transaction: transaction, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, transaction: nil, error: error.localizedDescription)
                }
        }
    }
    
    func remove(callback: (response: Response<AnyObject, NSError>?, data: AnyObject?, error: String?) -> ()) {
        Alamofire.request(.DELETE, "\(endpoint)/\(self.type)/\(self.id!)")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, error: error)
                    } else { // and the json was without errors
                        callback(response: response, data: data, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, error: error.localizedDescription)
                }
        }
    }
}