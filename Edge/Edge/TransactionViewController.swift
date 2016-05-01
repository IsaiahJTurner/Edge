//
//  TransactionViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/25/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//


import UIKit

class TransactionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var subtotalExpected: UILabel!
    
    @IBOutlet var tipExpected: UILabel!
    
    @IBOutlet var totalExpected: UILabel!
    
    @IBOutlet var subtotalActual: UILabel!
    
    @IBOutlet var tipActual: UILabel!
    
    @IBOutlet var totalActual: UILabel!
    
    var client = EdgeAPIClient()
    var transaction = Transaction(id: "undefined");
    var image:UIImage?
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var transactionDateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = transaction.title
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        self.transactionDateLabel.text = dateFormatter.stringFromDate(transaction.createdAt!)
        self.selectImageButton.imageView?.contentMode = .ScaleAspectFit
        self.selectImageButton.adjustsImageWhenHighlighted = false
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        if let tip = transaction.tip {
            self.tipExpected.text = formatter.stringFromNumber(tip);
        } else {
            self.tipExpected.text = "???";
        }
        if let subtotal = transaction.subtotal {
            self.subtotalExpected.text = formatter.stringFromNumber(subtotal);
        } else {
            self.subtotalExpected.text = "???";
        }
        if let total = transaction.total {
            self.totalExpected.text = formatter.stringFromNumber(total);
        } else {
            self.totalExpected.text = "???";
        }
        
    }
    
    func colorizeImage(image: UIImage, withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        let area: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextScaleCTM(context, 1, -1)
        CGContextTranslateCTM(context, 0, -area.size.height)
        CGContextSaveGState(context)
        CGContextClipToMask(context, area, image.CGImage)
        color.set()
        CGContextFillRect(context, area)
        CGContextRestoreGState(context)
        CGContextSetBlendMode(context, .Multiply)
        CGContextDrawImage(context, area, image.CGImage)
        let colorizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colorizedImage
    }
    
    @IBAction func selectImage(sender: UIButton) {
        let optionMenu = UIAlertController(title: "Attach Receipt", message: "Collect evidence in case fraud occurs.", preferredStyle: .ActionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        })
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(photoLibraryAction)
        if (!Constants.DEVICE_IS_SIMULATOR) {
            optionMenu.addAction(takePhotoAction)
        }
        
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.selectImageButton.setImage(image, forState: .Normal)
        self.selectImageButton.setImage(image, forState: .Highlighted)
        self.image = image

        //self.selectImageButton.setImage(self.colorizeImage(image, withColor: UIColor(white: 0, alpha: 0.5)), forState: .Highlighted)
        self.selectImageButton.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ReceiptViewController {
            vc.image = self.image
        }
    }
}

