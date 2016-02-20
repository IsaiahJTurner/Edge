//
//  Common.swift
//  Edge
//
//  Created by Isaiah Turner on 2/17/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Foundation

internal class Common {
    internal func jsonAPIErrorsToString(errors: AnyObject) -> String {
        var errorString = ""
        if let errorsArray = errors as? Array<Dictionary<String, AnyObject>> {
            for error in errorsArray {
                if let title = error["title"] as? String {
                    errorString += title
                }
            }
        }
        return errorString
    }
    internal func updateDefaults(user: User?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var values:Dictionary<String, AnyObject?> = [
            "authsCount": nil,
            "_user": nil
        ]
        
        if let user = user {
            if let auths = user.auths {
                if let array = auths.array {
                    values["authsCount"] = array.count
                }
            }
            values["_user"] = user.id
        }
        for (key, value) in values {
            if let intValue = value as? Int {
               defaults.setInteger(intValue, forKey: key)
            } else if (value != nil) {
                defaults.setObject(value, forKey: key)
            } else {
                defaults.removeObjectForKey(key)
            }
        }
    }
}
