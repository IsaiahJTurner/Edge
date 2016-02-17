//
//  EnterTipViewController.swift
//  TipCheck
//
//  Created by Isaiah Turner on 2/7/16.
//  Copyright © 2016 TipCheck. All rights reserved.
//

import UIKit

class EnterTipViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false;
    }
    @IBAction func `continue`(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

