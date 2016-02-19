//
//  Accounts.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


import Alamofire


class Accounts {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var array:Array<Account>?
    
    init() {
        
    }
    
    init(data: Array<AnyObject>) {
        var accounts = [Account]()
        for resource in data {
            let account = Account(data: resource as! Dictionary<String, AnyObject>)
            accounts.append(account)
        }
        self.array = accounts
    }

    func toJSON() -> Array<Dictionary<String, AnyObject>> {
        if let accounts = self.array {
            let accountsJSON = accounts.map { (account: Account) -> Dictionary<String, AnyObject> in
                return account.toJSON()
            }
            return accountsJSON

        } else {
            return []
        }
    }
    
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, accounts: Accounts?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/accounts")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, accounts: nil, error: error)
                    } else { // and the json was without errors
                        let accounts = Accounts(data: data.objectForKey("data") as! Array)
                        
                        callback(response: response, data: data, accounts: accounts, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil,accounts: nil, error: error.localizedDescription)
                }
        }
    }
}