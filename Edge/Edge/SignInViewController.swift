//
//  SignInViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    var client = EdgeAPIClient();
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var buttonSubmit: UIButton!
    @IBOutlet var barSubmit: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signIn(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        self.setButtons(false)
        client.signIn(email, password: password) { (response, data, user, error) -> () in
            self.setButtons(true)
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                if let user = user {
                    if let auths = user.auths {
                        if let array = auths.array {
                            if array.count > 0 {
                                return self.performSegueWithIdentifier("skipBankAccount", sender: self);
                            }
                        }
                    }
                }
                self.performSegueWithIdentifier("checkBankAccount", sender: self);
            }
        };
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
            if let vc = nav.topViewController as? HomeViewController {
                vc.client = self.client
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

