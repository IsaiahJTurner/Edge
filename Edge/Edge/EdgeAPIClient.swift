//
//  EdgeAPIClient.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


class EdgeAPIClient {
    private var endpoint = "http://localhost:3002";
    
    private var me:User? = nil;
    
    private func jsonAPIErrorsToString(errors: AnyObject) -> String {
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

    private func getCurrentUser(callback: (Response<AnyObject, NSError>, AnyObject?, User?, String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/users/me")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.jsonAPIErrorsToString(errors!)
                        callback(response, data, nil, error)
                    } else { // and the json was without errors
                        let user = User(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        self.me = user;
                        callback(response, data, user, nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response, nil, nil, "Unable to fetch your account details.")
                }
        }
    }
    
    func currentUser(callback: (User?) -> ()) {
        if ((self.me) != nil) {
            return callback(self.me)
        }
        self.getCurrentUser() { (response, data, user, error) -> () in
            print(error)
            callback(user);
        }
    }
    
    func logout(callback: (Response<AnyObject, NSError>, AnyObject?, String?) -> ()) {
        
    }
    func signUp(email: String, password: String, callback: (Response<AnyObject, NSError>, AnyObject?, User?, String?) -> ()) {
        Alamofire.request(.POST, "\(endpoint)/users", parameters: [
            "data": [
                "type": "users",
                "attributes": [
                    "email": email,
                    "password": password
                ]
            ]
        ], encoding: .JSON)
        .responseJSON { response in
            switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.jsonAPIErrorsToString(errors!)
                        callback(response, data, nil, error)
                    } else { // and the json was without errors
                        let user = User(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        self.me = user;
                        callback(response, data, user, nil)
                    }
                
                case .Failure(let error):
                    print(error)
                    callback(response, nil, nil, "An error occured while trying to create your account.")
            }
        }
    }
    
    func signIn(email: String, password: String, callback: (Response<AnyObject, NSError>, AnyObject?, User?, String?) -> ()) {
        Alamofire.request(.POST, "\(endpoint)/login", parameters: [
                "email": email,
                "password": password
            ], encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.jsonAPIErrorsToString(errors!)
                        callback(response, data, nil, error)
                    } else { // and the json was without errors
                        let user = User(data: data.objectForKey("data") as! Dictionary<String, AnyObject>);
                        self.me = user;
                        callback(response, data, user, nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response, nil, nil, "An error occured while trying to sign in.")
                }
        }
    }
}