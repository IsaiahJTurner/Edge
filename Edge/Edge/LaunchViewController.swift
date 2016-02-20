//
//  ViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    var client = EdgeAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nav = segue.destinationViewController as? UINavigationController {
            if let vc = nav.topViewController as? SignInViewController {
                vc.client = self.client
            }
            if let vc = nav.topViewController as? SignUpViewController {
                vc.client = self.client
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

