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
}