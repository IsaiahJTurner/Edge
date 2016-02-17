//
//  SignUpTableViewController.swift
//  TipCheck
//
//  Created by Isaiah Turner on 2/7/16.
//  Copyright © 2016 TipCheck. All rights reserved.
//

import UIKit
import Alamofire

class SignUpTableViewContoller: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: TipTextField!
    @IBOutlet var stateTextField: TipTextField!
    @IBOutlet var cityTextField: TipTextField!
    @IBOutlet var addressTextField: TipTextField!
    @IBOutlet var nameTextField: TipTextField!
    @IBOutlet var zipTextField: TipTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        nameTextField.text = "Sarah Smith"
        emailTextField.text = "sarah.smith@isaiahjturner.com"
        stateTextField.text = "Maryland"
        cityTextField.text = "Maymes"
        zipTextField.text = "21122"
        addressTextField.text = "42069 John Cena Way"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

