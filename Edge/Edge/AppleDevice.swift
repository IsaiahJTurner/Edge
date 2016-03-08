//
//  AppleDevice.swift
//  Edge
//
//  Created by Isaiah Turner on 2/23/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


class AppleDevice {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var id:String?
    var type = "appledevices"
    var token:String?
    var alert:Bool?
    var badge:Bool?
    var sound:Bool?
    var transactionNotifications:Bool?
    var allNotifications:Bool?
    var deviceId:String?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    var owner:User?
    
    var isIdentifier:Bool
    
    init(data: Dictionary<String, AnyObject>) {
        self.id = data["id"] as? String
        self.isIdentifier = true
        if let attributes = data["attributes"] {
            self.isIdentifier = false
            self.alert = attributes["alert"] as? Bool
            self.badge = attributes["badge"] as? Bool
            self.sound = attributes["sound"] as? Bool
            self.transactionNotifications = attributes["transactionNotifications"] as? Bool
            self.allNotifications = attributes["allNotifications"] as? Bool
            self.token = attributes["token"] as? String
            self.deviceId = attributes["deviceId"] as? String
            self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["createdAt"] as! Double / 1000.0))
            self.updatedAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["updatedAt"] as! Double / 1000.0))
        }
        if let relationships = data["relationships"] {
            if let owner = relationships["owner"] {
                self.owner = User(data: owner!["data"] as! Dictionary<String, AnyObject>)
            }
        }
    }
    
    init(id: String) {
        self.isIdentifier = true
        self.id = id
    }
    init(token: String, alert: Bool, badge: Bool, sound: Bool, deviceId: String, transactionNotifications: Bool, allNotifications: Bool, owner: User?) {
        self.isIdentifier = false
        self.token = token
        self.alert = alert
        self.badge = badge
        self.sound = sound
        self.deviceId = deviceId
        self.transactionNotifications = transactionNotifications
        self.allNotifications = allNotifications
        self.owner = owner
    }
    func toJSON() -> Dictionary<String, AnyObject> {
        var attributes = [String : AnyObject]()
        if let token = self.token {
            attributes["token"] = token
        }
        if let alert = self.alert {
            attributes["alert"] = alert
        }
        if let badge = self.badge {
            attributes["badge"] = badge
        }
        if let sound = self.sound {
            attributes["sound"] = sound
        }
        if let deviceId = self.deviceId {
            attributes["deviceId"] = deviceId
        }
        if let transactionNotifications = self.transactionNotifications {
            attributes["transactionNotifications"] = transactionNotifications
        }
        if let allNotifications = self.allNotifications {
            attributes["allNotifications"] = allNotifications
        }
        var relationships = [String : AnyObject]()
        if let owner = self.owner {
            relationships["owner"] = owner.toJSON()
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
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, appledevice: AppleDevice?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/appledevices/\(self.id!)", headers: [
            "Device": UIDevice.currentDevice().identifierForVendor!.UUIDString
            ])
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, appledevice: nil, error: error)
                    } else { // and the json was without errors
                        let appledevice = AppleDevice(data: data.objectForKey("data") as! Dictionary<String, AnyObject>)
                        callback(response: response, data: data, appledevice: appledevice, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, appledevice: nil, error: error.localizedDescription)
                }
        }
    }
    
    func save(callback: (response: Response<AnyObject, NSError>?, data: AnyObject?, appledevice: AppleDevice?, error: String?) -> ()) {
        let method:Alamofire.Method
        let path:String
        if let id = self.id {
            method = Alamofire.Method.PATCH
            path = "/\(id)"
        } else {
            method = Alamofire.Method.POST
            path = ""
        }
        
        Alamofire.request(method, "\(endpoint)/appledevices\(path)", parameters: self.toJSON(), encoding: .JSON, headers: [
            "Device": UIDevice.currentDevice().identifierForVendor!.UUIDString
            ])
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, appledevice: nil, error: error)
                    } else { // and the json was without errors
                        let appledevice = AppleDevice(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        callback(response: response, data: data, appledevice: appledevice, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil, appledevice: nil, error: error.localizedDescription)
                }
        }
    }
}