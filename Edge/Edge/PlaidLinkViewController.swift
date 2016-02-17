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
        client.logout() { (response, data, error) in
            
        }
    }
    @IBAction func retry(sender: UIBarButtonItem) {
        self.startLinking()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func linkNavigationContoller(navigationController: PLDLinkNavigationViewController!, didFinishWithAccessToken accessToken: String!) {
        print("success \(accessToken)")
        statusTextView.text = "Verifying your credentials..."
        navigationController.dismissViewControllerAnimated(true, completion: nil)
    }
    func linkNavigationControllerDidFinishWithBankNotListed(navigationController: PLDLinkNavigationViewController!) {
        print("Manually enter bank info?")
    }
    func linkNavigationControllerDidCancel(navigationController: PLDLinkNavigationViewController!) {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
        self.statusTextView.text = "Linking process cancelled.\nTap Retry above to continue."
    }
}

