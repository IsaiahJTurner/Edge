//
//  User.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


class User {
    private var endpoint = "http://localhost:3002";
    var name:String?
    var email:String!
    var phone:String?
    var password:String?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    
    init(data: Dictionary<String, AnyObject>) {
        let attributes = data["attributes"]!
        self.name = attributes["name"] as? String
        self.email = attributes["email"] as! String
        self.phone = attributes["phone"] as? String
        self.password = attributes["password"] as? String
        self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["createdAt"] as! Int))
        self.updatedAt = NSDate(timeIntervalSince1970: NSTimeInterval(attributes["updatedAt"] as! Int))
    }
}