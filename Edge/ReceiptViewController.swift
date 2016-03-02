//
//  ReceiptViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 3/1/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class ReceiptViewController: UIViewController {
    @IBOutlet var image: UIImageView!
    @IBAction func showOptions(sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: "Image Options", message: nil, preferredStyle: .ActionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Save to Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in

            
        })
        let removeAction = UIAlertAction(title: "Remove Image", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in

            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(removeAction)
        
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
}
