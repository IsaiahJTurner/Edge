//
//  EnableProtectionViewController.swift
//  Edge
//
//  Created by Isaiah Turner on 2/25/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//



import UIKit

class EnableProtectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var client = EdgeAPIClient()
    
    @IBOutlet var tableContainer: UIView!
    @IBOutlet var headerContainer: UIView!
    @IBOutlet var optionsTable: UITableView!
    
    @IBOutlet var payButton: UIButton!
    var selectedCell:StoreItemTableViewCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barStyle = .Black;
        self.navigationController!.navigationBar.tintColor = UIColor(hex: "#00A24E", alpha: 1)
        self.automaticallyAdjustsScrollViewInsets = false

        let rectShape = CAShapeLayer()
        rectShape.bounds = self.tableContainer.frame
        rectShape.position = self.tableContainer.center
        rectShape.path = UIBezierPath(roundedRect: self.tableContainer.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 5, height: 5)).CGPath
        
        self.tableContainer.layer.backgroundColor = UIColor.greenColor().CGColor
        self.tableContainer.layer.mask = rectShape
        
        let rectShape2 = CAShapeLayer()
        rectShape2.bounds = self.headerContainer.frame
        rectShape2.position = self.headerContainer.center
        rectShape2.path = UIBezierPath(roundedRect: self.headerContainer.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 5, height: 5)).CGPath
        
        self.headerContainer.layer.mask = rectShape2
        
        self.headerContainer.layer.borderColor = UIColor(hex: "#FFFFFF", alpha: 0.82).CGColor
        self.headerContainer.layer.borderWidth = 1
        self.headerContainer.layer.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func pay(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func close(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("pass") as? StoreItemTableViewCell
        
        if cell == nil {
            cell = StoreItemTableViewCell()
        }
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StoreItemTableViewCell {
            if let selected = self.selectedCell {
                selected.passCheckmarkImage.image = UIImage(named: "Check-No")
            }
            cell.passCheckmarkImage.image = UIImage(named: "Check-Yes")
            self.selectedCell = cell
        }
    }
    
}

