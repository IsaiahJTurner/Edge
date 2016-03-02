//
//  HomeViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/18/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//


import UIKit
import Alamofire

class HomeViewController: UITableViewController {
    var client = EdgeAPIClient()
    var transactions:Transactions?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = 73
        self.navigationController!.navigationBar.barStyle = .Black;
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        var topFrame = self.tableView.bounds;
        topFrame.origin.y = -topFrame.size.height;
        let topView = UIView(frame: topFrame);
        topView.backgroundColor = UIColor(hex: "#FF5950", alpha: 1)
        self.tableView.insertSubview(topView, atIndex: 0)
        reloadData() {
            
        }
    }
    /*
        override func preferredStatusBarStyle() -> UIStatusBarStyle {
            return UIStatusBarStyle.LightContent
        }
    */
    @IBAction func refresh(sender: UIRefreshControl) {
        self.reloadData() {
            sender.endRefreshing()
        }
    }
    @IBAction func reset(sender: UIBarButtonItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("authsCount")
        defaults.removeObjectForKey("_user")
        defaults.removeObjectForKey("hasLaunched")
        
        Alamofire.request(.GET, "https://edge-development.herokuapp.com/reset")
        .responseJSON { response in
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

    func reloadData(callback: () -> Void) {
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
            callback()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("transaction") as? TransactionTableViewCell
        
        if cell == nil {
            cell = TransactionTableViewCell()
        }
        let row = indexPath.row
        let transaction = transactions!.array![row]
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let total = formatter.stringFromNumber(transaction.total!)
        
        cell?.amountLabel.text = total
        cell?.titleLabel.text = transaction.title!
        cell?.resultLabel.text = "successful"
        cell?.tipLabel.text = "unknown"
        if row % 2 == 0 {
            cell?.backgroundColor = UIColor(hex: "#F8F8F8", alpha: 1)
        } else {
            cell?.backgroundColor = UIColor(hex: "#FDFDFD", alpha: 1)
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showTransaction", sender: self)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let transactions = transactions {
            if let array = transactions.array {
                return array.count
            }
        }
        return 0
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? TransactionViewController {
            vc.client = self.client
            let indexPath = self.tableView.indexPathForSelectedRow!
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            vc.transaction = self.transactions!.array![indexPath.row]
        }
        if let vc = segue.destinationViewController as? SettingsViewController {
            vc.client = self.client
        }
        if let navVC = segue.destinationViewController as? UINavigationController {
            if let vc = navVC.topViewController as? EnableProtectionViewController {
                vc.client = self.client
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

