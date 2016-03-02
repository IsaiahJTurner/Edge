//
//  ConnectViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController {
    
    var client = EdgeAPIClient();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        client.currentUser() { user in
            let storyboard = self.storyboard!
            var viewController = storyboard.instantiateViewControllerWithIdentifier("link")
            if let user = user {
                if let auths = user.auths {
                    if let array = auths.array {
                        if array.count > 0 {
                            viewController = storyboard.instantiateViewControllerWithIdentifier("home")
                        }
                    }
                }
            } else {
                viewController = storyboard.instantiateViewControllerWithIdentifier("auth")
            }
            if let nav = viewController as? UINavigationController {
                if let topVC = nav.topViewController {
                    if let vc = topVC as? LaunchViewController {
                        vc.client = self.client
                    }
                    if let vc = topVC as? PlaidLinkViewController {
                        vc.client = self.client
                    }
                    if let vc = topVC as? HomeViewController {
                        vc.client = self.client
                    }
                }
            }
            
            
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

