//
//  AddTransactionViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 4/29/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class AddTransactionTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var tipTextField: UITextField!
    @IBOutlet var subtotalTextField: UILabel!
    @IBOutlet var locationTextField: UITextField!
    var tip:Int = 0
    var subtotal:Int = 0
    var client = EdgeAPIClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController!.navigationBar.barStyle = .Black;
        // self.navigationController!.navigationBar.tintColor = UIColor(hex: "#00A24E", alpha: 1)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            if string.characters.count == 0 {
                if (textField.text! as NSString).substringWithRange(range) == "$" {
                    textField.text = String(textField.text!.characters.dropLast())
                }
                return true // allow deleting
            }
            if textField.text!.characters.count > 8 {
                self.costTextChanged(textField)
                return false
            }
            if (string.characters.count != 1) {
                return false // cant type more than 1 char at a time (i.e. paste)
            }
            if Int(string) == nil {
                return false
            }
        return true;
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        let transaction = Transaction(title: locationTextField.text, subtotal: Double(subtotal) / 100, tip: Double(tip) / 100)
        transaction.save { (response, data, transaction, error) in
            if (error != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                return self.presentViewController(alertController, animated: true, completion: nil)
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func costTextChanged(sender: UITextField) {
        if let intValue = Int(sender.text!.stringByReplacingOccurrencesOfString(".", withString: "").componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")) {
            if (sender == tipTextField) {
                tip = intValue
            } else {
                subtotal = intValue
            }
            var formatted = String(intValue)
            let count = formatted.characters.count
            if count != 0 {
                formatted.insert("$", atIndex: formatted.startIndex)
                if count <= 2 {
                    formatted.insert("0", atIndex: formatted.startIndex.advancedBy(1))
                    formatted.insert(".", atIndex: formatted.startIndex.advancedBy(2))
                    if count == 1 {
                        formatted.insert("0", atIndex: formatted.startIndex.advancedBy(3))
                    }
                } else {
                    formatted.insert(".", atIndex: formatted.endIndex.advancedBy(-2))
                }
            }
            
            sender.text = formatted
        } else {
            if (sender == tipTextField) {
                tip = 0
            } else {
                subtotal = 0
            }
        }
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        totalLabel.text = formatter.stringFromNumber((Double(tip) + Double(subtotal)) / 100)
    }
    override func viewDidAppear(animated: Bool) {
        self.locationTextField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
