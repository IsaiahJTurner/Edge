//
//  AddTransactionViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 4/29/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class AddTransactionTableViewController: UITableViewController {

    var client = EdgeAPIClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController!.navigationBar.barStyle = .Black;
        // self.navigationController!.navigationBar.tintColor = UIColor(hex: "#00A24E", alpha: 1)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
