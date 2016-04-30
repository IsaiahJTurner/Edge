//
//  Pass.swift
//  Edge
//
//  Created by Isaiah Turner on 4/29/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire
//
//  Auth.swift
//  Edge
//
//  Created by Isaiah Turner on 2/17/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire

class Pass {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var id:String?
    var type = "passes"
    var title:String?
    var description:String?
    var cost:Double?
    var isIdentifier:Bool
    
    init(data: Dictionary<String, AnyObject>) {
        self.id = data["id"] as? String
        self.isIdentifier = true;
        if let attributes = data["attributes"] {
            self.isIdentifier = false;
            self.title = attributes["title"] as? String
            self.description = attributes["description"] as? String
            self.cost = attributes["cost"] as? Double
            if let cost = self.cost {
                self.cost = cost / 100
            }
        }
    }
    
    init(id: String) {
        self.isIdentifier = true
        self.id = id
    }
    func toJSON() -> Dictionary<String, AnyObject> {
        var attributes = [String : AnyObject]()
        if ((self.title) != nil) {
            attributes["title"] = self.title
        }
        if ((self.description) != nil) {
            attributes["description"] = self.description
        }
        if ((self.cost) != nil) {
            attributes["cost"] = self.cost
        }
        var resource : [String : AnyObject] = [
            "type": self.type,
            "attributes": attributes
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
        Alamofire.request(.GET, "\(endpoint)/passes/\(self.id)")
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
}