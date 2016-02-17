//
//  ViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    var client = EdgeAPIClient();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        client.currentUser() { user in
            print(user)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

