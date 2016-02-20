//
//  SignUpViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    var client = EdgeAPIClient();
    
    @IBOutlet var buttonSubmit: UIButton!
    @IBOutlet var barSubmit: UIBarButtonItem!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signUp(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        self.setButtons(false)
        let user = User(name: "", email: email, phone: "", password: password)
        user.save { (response, data, user, error) -> () in
            self.setButtons(true)
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.performSegueWithIdentifier("linkBankAccount", sender: self);
            }
        }
    }
    func setButtons(enabled: Bool) {
        barSubmit.enabled = enabled
        buttonSubmit.enabled = enabled
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nav = segue.destinationViewController as? UINavigationController {
            if let vc = nav.topViewController as? PlaidLinkViewController {
                vc.client = self.client
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

