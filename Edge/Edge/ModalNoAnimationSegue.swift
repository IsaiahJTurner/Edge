//
//  ModalNoAnimationSegue.swift
//  Edge
//
//  Created by Isaiah Turner on 2/20/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit

class ModalNoAnimationSegue: UIStoryboardSegue {
    
    override func perform() {
        let source = sourceViewController as UIViewController
            source.presentViewController(destinationViewController, animated: false, completion: nil)
    }
    
}