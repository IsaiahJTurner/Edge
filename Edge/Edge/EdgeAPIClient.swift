//
//  EdgeAPIClient.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire

class EdgeAPIClient {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var me:User?;

    private func getCurrentUser(callback: (Response<AnyObject, NSError>, AnyObject?, User?, String?) -> ()) {
        User(id: "me").get { (response, data, user, error) -> () in
            self.me = user
            self.common.updateDefaults(self.me)
            callback(response, data, user, error)
        }
    }

    func currentUser(callback: (User?) -> ()) {
        if ((self.me) != nil) {
            return callback(self.me)
        }
        self.getCurrentUser() { (response, data, user, error) -> () in
            callback(user);
        }
    }
    
    func signOut(callback: (Response<AnyObject, NSError>, AnyObject?, String?) -> ()) {
        Alamofire.request(.POST, "\(endpoint)/signout")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response, data, error)
                    } else { // and the json was without errors
                        self.me = nil;
                        self.common.updateDefaults(self.me)
                        callback(response, data, nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response, nil, error.localizedDescription)
                }
        }
    }
    
    func signIn(email: String, password: String, callback: (Response<AnyObject, NSError>, AnyObject?, User?, String?) -> ()) {
        Alamofire.request(.POST, "\(endpoint)/signin", parameters: [
                "email": email,
                "password": password
            ], encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response, data, nil, error)
                    } else { // and the json was without errors
                        let user = User(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        self.me = user;
                   self.common.updateDefaults(self.me)
                        callback(response, data, user, nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response, nil, nil, error.localizedDescription)
                }
        }
    }
}