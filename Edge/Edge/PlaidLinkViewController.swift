//
//  PlaidLinkViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit
import plaid_ios_link

class PlaidLinkViewController: UIViewController, PLDLinkNavigationControllerDelegate {
    var client = EdgeAPIClient();

    @IBOutlet var statusTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLinking()

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        self.startLinking()
    }
    func startLinking() {
        let plaidLink = PLDLinkNavigationViewController(environment: .Tartan, product: .Connect)
        plaidLink.linkDelegate = self
        plaidLink.providesPresentationContextTransitionStyle = true
        plaidLink.definesPresentationContext = true
        plaidLink.modalPresentationStyle = .Custom
        
        self.presentViewController(plaidLink, animated: true, completion: nil)
    }
    @IBAction func logout(sender: UIBarButtonItem) {
        client.signOut() { (response, data, error) in
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    @IBAction func retry(sender: UIBarButtonItem) {
        self.startLinking()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func linkNavigationContoller(navigationController: PLDLinkNavigationViewController!, didFinishWithAccessToken publicToken: String!) {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
        statusTextView.text = "Verifying your credentials..."
        let account = Account(publicToken: publicToken, owner: nil)
        account.save { (response, data, account, error) -> () in
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                self.statusTextView.text = error
            } else {
                self.performSegueWithIdentifier("showHome", sender: self);
            }
        }
        
    }
    func linkNavigationControllerDidFinishWithBankNotListed(navigationController: PLDLinkNavigationViewController!) {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
        statusTextView.text = "We may not support your bank. Try again?"
        
    }
    func linkNavigationControllerDidCancel(navigationController: PLDLinkNavigationViewController!) {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
        self.statusTextView.text = "Linking process cancelled.\nTap Retry above to continue."
    }
}

