//
//  Transactions.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import Alamofire


import Alamofire


class Transactions {
    
    private var endpoint = Constants.endpoint;
    private var common = Common()
    
    var array:Array<Transaction>?
    
    init() {
        
    }
    
    init(data: Array<AnyObject>) {
        var transactions = [Transaction]()
        for resource in data {
            let transaction = Transaction(data: resource as! Dictionary<String, AnyObject>)
            transactions.append(transaction)
        }
        self.array = transactions
    }
    
    func toJSON() -> Array<Dictionary<String, AnyObject>> {
        if let transactions = self.array {
            let transactionsJSON = transactions.map { (transaction: Transaction) -> Dictionary<String, AnyObject> in
                return transaction.toJSON()
            }
            return transactionsJSON
            
        } else {
            return []
        }
    }
    
    func get(callback: (response: Response<AnyObject, NSError>, data: AnyObject?, transactions: Transactions?, error: String?) -> ()) {
        Alamofire.request(.GET, "\(endpoint)/transactions")
            .responseJSON { response in
                switch response.result {
                case .Success: // returned json
                    let data = response.result.value!
                    let errors = data.objectForKey("errors")
                    if ((errors) != nil) { // but the json had an errors property
                        let error = self.common.jsonAPIErrorsToString(errors!)
                        callback(response: response, data: data, transactions: nil, error: error)
                    } else { // and the json was without errors
                        let transactions = Transactions(data: data.objectForKey("data") as! Array)
                        
                        callback(response: response, data: data, transactions: transactions, error: nil)
                    }
                    
                case .Failure(let error):
                    print(error)
                    callback(response: response, data: nil,transactions: nil, error: error.localizedDescription)
                }
        }
    }
}