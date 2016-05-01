//
//  AddTipViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 5/1/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class AddTipViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func save(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
