//
//  SettingsViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 3/1/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var transactionNotificationsSwitch: UISwitch!
    @IBOutlet var pushNotificationsSwitch: UISwitch!
    @IBOutlet var emailNotificationsSwitch: UISwitch!
    @IBOutlet var textNotificationsSwitch: UISwitch!
    
    var isSaving = false
    var client = EdgeAPIClient()
    override func viewDidLoad() {
        self.navigationController!.interactivePopGestureRecognizer?.addTarget(self, action: "handlePopGesture:")
        if let me = client.me {
            self.nameTextField.text = me.name
            self.emailTextField.text = me.email
            self.phoneTextField.text = me.phone
        }
        saveButton.enabled = false
        saveButton.title = ""
        self.transactionNotificationsSwitch.addTarget(self, action: "toggleNotifications:", forControlEvents: .ValueChanged)
        self.pushNotificationsSwitch.addTarget(self, action: "toggleNotifications:", forControlEvents: .ValueChanged)
        self.emailNotificationsSwitch.addTarget(self, action: "toggleNotifications:", forControlEvents: .ValueChanged)
        self.textNotificationsSwitch.addTarget(self, action: "toggleNotifications:", forControlEvents: .ValueChanged)
    }
    func toggleNotifications(sender: UISwitch) {
        if sender == pushNotificationsSwitch {
            transactionNotificationsSwitch.setOn(sender.on, animated: true)
            transactionNotificationsSwitch.enabled = sender.on
        }
        if nameTextField.isFirstResponder() {
            nameTextField.resignFirstResponder()
        }
        if emailTextField.isFirstResponder() {
            emailTextField.resignFirstResponder()
        }
        if phoneTextField.isFirstResponder() {
            phoneTextField.resignFirstResponder()
        }
    }
    func handlePopGesture(gesture: UIGestureRecognizer) {
        if (gesture.state == .Began)
        {
            if nameTextField.isFirstResponder() {
                nameTextField.resignFirstResponder()
            }
            if emailTextField.isFirstResponder() {
                emailTextField.resignFirstResponder()
            }
            if phoneTextField.isFirstResponder() {
                phoneTextField.resignFirstResponder()
            }
        }
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if nameTextField.isFirstResponder() {
            nameTextField.resignFirstResponder()
        }
        if emailTextField.isFirstResponder() {
            emailTextField.resignFirstResponder()
        }
        if phoneTextField.isFirstResponder() {
            phoneTextField.resignFirstResponder()
        }
    }
    @IBAction func save(sender: AnyObject) {

        if let me = client.me {
            if nameTextField.isFirstResponder() {
                me.name = nameTextField.text
                nameTextField.resignFirstResponder()
            }
            if  emailTextField.isFirstResponder() {
                me.email = emailTextField.text
                emailTextField.resignFirstResponder()
            }
            if  phoneTextField.isFirstResponder() {
                me.phone = phoneTextField.text
                phoneTextField.resignFirstResponder()
            }
            me.save({ (response, data, user, error) -> () in
                if (error != nil) {
                    let alertController = UIAlertController(title: "Error", message:
                        error, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    return self.presentViewController(alertController, animated: true, completion: nil)
                }
                self.saveButton.enabled = false
                self.saveButton.title = ""
            })
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.save(textField)
        return false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField != phoneTextField {
            saveButton.enabled = true
            saveButton.title = "Save"
        }
        if (textField === phoneTextField) {
            if string.characters.count == 0 {
                if (textField.text! as NSString).substringWithRange(range) == ")" {
                    textField.text = String(textField.text!.characters.dropLast())
                }
                return true // allow deleting
            }
            if textField.text!.characters.count == 14 {
                self.phoneTextChanged(textField)
                return false
            }
            if (string.characters.count != 1) {
                return false // cant type more than 1 char at a time (i.e. paste)
            }
            if Int(string) == nil {
                return false
            }
        }
        return true
    }
    @IBAction func phoneTextChanged(sender: UITextField) {
        let numbers = sender.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        var formatted = numbers
        
        if numbers.characters.count != 0 {
            formatted.insert("(", atIndex: formatted.startIndex)
            if numbers.characters.count <= 3 {
                formatted.insert(")", atIndex: formatted.endIndex)
            } else {
                formatted.insert(")", atIndex: numbers.startIndex.advancedBy(4))
                formatted.insert(" ", atIndex: formatted.startIndex.advancedBy(5))
            }
            if numbers.characters.count > 6 {
                formatted.insert("-", atIndex: formatted.startIndex.advancedBy(9))
            }
        }
        
        sender.text = formatted
        
        if numbers.characters.count == 10 {
            let alertController = UIAlertController(title: "Verify Accuracy", message:
                "A confirmation text message will be sent to \(formatted).", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { (action) in
                if let me = self.client.me {
                    me.phone = formatted
                    me.save({ (response, data, user, error) -> () in
                        if (error != nil) {
                            let alertController = UIAlertController(title: "Error", message:
                                error, preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            return self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    })
                }
            })
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                nameTextField.becomeFirstResponder()
            }
            if indexPath.row == 1 {
                emailTextField.becomeFirstResponder()
            }
            if indexPath.row == 2 {
                phoneTextField.becomeFirstResponder()
            }
        }
        if indexPath.section != 0 {
            if nameTextField.isFirstResponder() {
                nameTextField.resignFirstResponder()
            }
            if emailTextField.isFirstResponder() {
                emailTextField.resignFirstResponder()
            }
            if phoneTextField.isFirstResponder() {
                phoneTextField.resignFirstResponder()
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                if transactionNotificationsSwitch.enabled {
                    transactionNotificationsSwitch.setOn(!transactionNotificationsSwitch.on, animated: true)
                }
            }
            if indexPath.row == 1 {
                pushNotificationsSwitch.setOn(!pushNotificationsSwitch.on, animated: true)
                self.toggleNotifications(pushNotificationsSwitch)
            }
            if indexPath.row == 2 {
                emailNotificationsSwitch.setOn(!emailNotificationsSwitch.on, animated: true)
            }
            if indexPath.row == 3 {
                textNotificationsSwitch.setOn(!textNotificationsSwitch.on, animated: true)
            }
        }
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("subscription")
                self.presentViewController(vc, animated: true, completion: nil)
            }
            if indexPath.row == 1 {
                let alertController = UIAlertController(title: "Are you sure?", message:
                    "Your bank account will be un-linked and you will be able to link a new account. No other data will be deleted.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { (action) in
                    if let me = self.client.me {
                        if let auths = me.auths {
                            if let array = auths.array {
                                if let auth = array.first {
                                    auth.remove({ (response, data, error) -> () in
                                        if (error != nil) {
                                            let alertController = UIAlertController(title: "Error", message:
                                                error, preferredStyle: UIAlertControllerStyle.Alert)
                                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                            return self.presentViewController(alertController, animated: true, completion: nil)
                                        }
                                    })
                                }
                            }
                        }
                    }
                    })
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            if indexPath.row == 2 {
                client.signOut({ (response, data, error) -> () in
                    if (error != nil) {
                        let alertController = UIAlertController(title: "Error", message:
                            error, preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        return self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    self.view.window!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
