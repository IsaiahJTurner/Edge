//
//  HomeViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//


import UIKit

class HomeViewController: UITableViewController {
    var client = EdgeAPIClient()
    var transactions:Transactions?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        reloadData()
    }
    @IBAction func reset(sender: UIBarButtonItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("authsCount")
        defaults.removeObjectForKey("_user")
        defaults.removeObjectForKey("hasLaunched")
        delay(0.5) {
            var crashWithMissingValueInDicitonary = Dictionary<Int,Int>()
            _ = crashWithMissingValueInDicitonary[1]!
        }
    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func reloadData() {
        Transactions().get { (response, data, transactions, error) -> () in
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.transactions = transactions
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func reloadTransactions(sender: UIBarButtonItem) {
        reloadData()
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("transaction") as? TransactionTableViewCell
        
        if cell == nil {
            cell = TransactionTableViewCell()
        }
        let transaction = transactions!.array![indexPath.row]
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let total = formatter.stringFromNumber(transaction.total!)
        
        cell?.amountLabel.text = total
        cell?.titleLabel.text = transaction.title!
        
        return cell!
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(transactions?.array)
        if let transactions = transactions {
            if let array = transactions.array {
                return array.count
            }
        }
        return 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

