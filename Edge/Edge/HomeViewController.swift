//
//  HomeViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//


import UIKit

class HomeViewController: UIViewController {
    
    var client = EdgeAPIClient();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Transactions().get { (response, data, transactions, error) -> () in
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                print(transactions!.toJSON())
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

