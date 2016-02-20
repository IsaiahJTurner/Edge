//
//  Auths.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


import Alamofire


class Auths {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var array:Array<Auth>?
    
    init() {
        
    }
    
    init(data: Array<AnyObject>) {
        var auths = [Auth]()
        for resource in data {
            let auth = Auth(data: resource as! Dictionary<String, AnyObject>)
            auths.append(auth)
        }
        self.array = auths
    }

    func toJSON() -> Array<Dictionary<String, AnyObject>> {
        if let auths = self.array {
            let authsJSON = auths.map { (auth: Auth) -> Dictionary<String, AnyObject> in
                return auth.toJSON()
            }
            return authsJSON

        } else {
            return []
        }
    }
    
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, auths: Auths?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/auths")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, auths: nil, error: error)
                    } else { // and the json was without errors
                        let auths = Auths(data: data.objectForKey("data") as! Array)
                        
                        callback(response: response, data: data, auths: auths, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil,auths: nil, error: error.localizedDescription)
                }
        }
    }
}