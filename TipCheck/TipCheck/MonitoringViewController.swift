//
//  MonitoringViewController.swift
//  TipCheck
//
//  Created by Isaiah Turner on 2/7/16.
//  Copyright © 2016 TipCheck. All rights reserved.
//

import UIKit

class MonitoringViewController: UIViewController {
    var appearances = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.467, green: 0.29, blue: 0.62, alpha: 1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barStyle = .BlackTranslucent
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    @IBAction func triggerTransaction(sender: UIButton) {
        sender.enabled = false;
        appearances = 0
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow:15)
        notification.alertBody = "Update your tip for Vapianos"
        notification.alertAction = "Update"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        delay(15) {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("enterTipVC") as! EnterTipViewController
            self.presentViewController(vc, animated: true, completion: nil)
            sender.enabled = true;

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
