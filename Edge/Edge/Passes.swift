//
//  Passes.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire

class Passes {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var array:Array<Pass>?
    var type = "passes"

    init() {
        
    }
    
    init(data: Array<AnyObject>) {
        var passes = [Pass]()
        for resource in data {
            let pass = Pass(data: resource as! Dictionary<String, AnyObject>)
            passes.append(pass)
        }
        self.array = passes
    }
    
    func toJSON() -> Array<Dictionary<String, AnyObject>> {
        if let passes = self.array {
            let passesJSON = passes.map { (pass: Pass) -> Dictionary<String, AnyObject> in
                return pass.toJSON()
            }
            return passesJSON
            
        } else {
            return []
        }
    }
    
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, passes: Passes?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/\(self.type)")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, passes: nil, error: error)
                    } else { // and the json was without errors
                        let passes = Passes(data: data.objectForKey("data") as! Array)
                        
                        callback(response: response, data: data, passes: passes, error: nil)
                    }
                    
                case .Failure(let error):
                    callback(response: response, data: nil, passes: nil, error: error.localizedDescription)
                }
        }
    }
}