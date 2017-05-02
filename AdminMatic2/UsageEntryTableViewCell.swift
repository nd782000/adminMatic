
//
//  EmployeeTableViewCell.swift
//  Atlantic_Blank
//
//  Created by Nicholas Digiando on 8/9/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import Foundation
import UIKit
import Nuke

class UsageEntryTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate {
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var delegate:UsageDelegate!
    
    var row:Int!
    var empID:String!
    var empName:String!
    var itemType:String!
    
    var vendorList:[Vendor] = []
    var vendorValue:String!
    
    
    var nameLbl: UILabel! = UILabel()
    
    var empPic:String!
    var employeeImageView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    
    var qtyLbl:Label!
    
    
    var startLbl:Label!
    var startTxtField: PaddedTextField!
    var startPickerView :DatePicker!//edit mode
    
    var stopLbl:Label!
    var stopTxtField: PaddedTextField!
    var stopPickerView :DatePicker!//edit mode
    
    var startStopFormatter = DateFormatter()
    
    var breakLbl:Label!
    var breakTxtField: PaddedTextField!
    
    //material mode
    var qtyTxtField: PaddedTextField!
    
    var unitsLbl:Label!
    var vendorLbl:Label!
    var vendorTxtField: PaddedTextField!
    var vendorPicker :Picker!//edit mode
    
    var costLbl:Label!
    var costTxtField: PaddedTextField!
    var costPickerView :DatePicker!//edit mode
    
    
    var totalCostLbl:Label!
    
    var historyBtn:Button!
    
    var locked:Bool = false
    var lockIcon:UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func displayLaborMode(){
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        self.employeeImageView.layer.cornerRadius = 10.0
        self.employeeImageView.layer.borderWidth = 1
        self.employeeImageView.layer.borderColor = layoutVars.borderColor
        self.employeeImageView.clipsToBounds = true
        self.employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.employeeImageView)
        
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        //activityView.center = CGPoint(x: self.employeeImageView.frame.size.width / 2, y: self.employeeImageView.frame.size.height / 2)
        employeeImageView.addSubview(activityView)
        
        
        
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //start
        self.qtyLbl = Label(text: "qty")
        self.contentView.addSubview(self.qtyLbl)
        
        lockIcon = UIImageView()
        lockIcon.backgroundColor = UIColor.clear
        lockIcon.contentMode = .scaleAspectFill
        let lockImg = UIImage(named:"lockIcon.png")
        lockIcon.image = lockImg
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(lockIcon)
        
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        //start
        self.startLbl = Label(text: "Start")
        self.contentView.addSubview(self.startLbl)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePickerMode.time
        startStopFormatter.dateFormat = "MM/dd/yyyy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:"---",attributes:[NSForegroundColorAttributeName: layoutVars.buttonColor1])
        self.contentView.addSubview(self.startTxtField)
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Time", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        self.stopLbl = Label(text: "Stop")
        self.contentView.addSubview(self.stopLbl)
        
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePickerMode.time
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:"---",attributes:[NSForegroundColorAttributeName: layoutVars.buttonColor1])
        self.contentView.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Time", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar
        
        //break
        self.breakLbl = Label(text: "Break")
        self.contentView.addSubview(self.breakLbl)
        
        
        self.breakTxtField = PaddedTextField()
        self.breakTxtField.returnKeyType = UIReturnKeyType.next
        self.breakTxtField.delegate = self
        
        self.breakTxtField.keyboardType = UIKeyboardType.numberPad
        self.breakTxtField.tag = 8
        
        self.contentView.addSubview(self.breakTxtField)
        
        let breakToolBar = UIToolbar()
        breakToolBar.barStyle = UIBarStyle.default
        breakToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        breakToolBar.sizeToFit()
        let setBreakButton = UIBarButtonItem(title: "Set Break Time", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleBreakTime))
        breakToolBar.setItems([spaceButton, setBreakButton], animated: false)
        breakToolBar.isUserInteractionEnabled = true
        breakTxtField.inputAccessoryView = breakToolBar
        
        
        
        contentView.addSubview(nameLbl)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl,"qty":qtyLbl,"lockIcon":lockIcon,"startLbl":startLbl,"startTxtField":startTxtField,"stopLbl":stopLbl,"stopTxtField":stopTxtField,"breakLbl":breakLbl,"breakTxtField":breakTxtField] as [String:AnyObject]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(40)]-10-[name]-10-[qty]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[lockIcon(20)]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[startLbl(40)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[startLbl][startTxtField(70)][stopLbl][stopTxtField(70)][breakLbl][breakTxtField(50)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
        
    }
    
    func displayMaterialMode(){
        print("displayMaterialMode")
        
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        
        //qty
        self.qtyLbl = Label(text: "Qty")
        self.contentView.addSubview(self.qtyLbl)
        
        self.qtyTxtField = PaddedTextField()
        self.qtyTxtField.delegate = self
        
        self.qtyTxtField.keyboardType = UIKeyboardType.decimalPad
        self.qtyTxtField.tag = 10
        
        self.contentView.addSubview(self.qtyTxtField)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let qtyToolBar = UIToolbar()
        qtyToolBar.barStyle = UIBarStyle.default
        qtyToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        qtyToolBar.sizeToFit()
        let setQtyButton = UIBarButtonItem(title: "Set Qty", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleQty))
        qtyToolBar.setItems([spaceButton, setQtyButton], animated: false)
        qtyToolBar.isUserInteractionEnabled = true
        qtyTxtField.inputAccessoryView = qtyToolBar
        
        self.unitsLbl = Label(text: "Units")
        self.contentView.addSubview(self.unitsLbl)
        
        
        lockIcon = UIImageView()
        lockIcon.backgroundColor = UIColor.clear
        lockIcon.contentMode = .scaleAspectFill
        let lockImg = UIImage(named:"lockIcon.png")
        lockIcon.image = lockImg
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(lockIcon)
        
        //vendor
        self.vendorLbl = Label(text: "Vendor")
        self.contentView.addSubview(self.vendorLbl)
        
        self.vendorTxtField = PaddedTextField()
        self.vendorTxtField.returnKeyType = UIReturnKeyType.next
        self.vendorTxtField.delegate = self
        
        //vendor picker
        self.vendorPicker = Picker()
        self.vendorPicker.delegate = self
        
        self.vendorTxtField.inputView = vendorPicker
        self.vendorTxtField.tag = 8
        
        self.contentView.addSubview(self.vendorTxtField)
        
        
        let vendorToolBar = UIToolbar()
        vendorToolBar.barStyle = UIBarStyle.default
        vendorToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        vendorToolBar.sizeToFit()
        let setVendorButton = UIBarButtonItem(title: "Set Vendor", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleVendor))
        vendorToolBar.setItems([spaceButton, setVendorButton], animated: false)
        vendorToolBar.isUserInteractionEnabled = true
        vendorTxtField.inputAccessoryView = vendorToolBar
        
        
        //cost
        self.costLbl = Label(text: "Unit Cost")
        self.contentView.addSubview(self.costLbl)
        
        self.costTxtField = PaddedTextField()
        self.costTxtField.returnKeyType = UIReturnKeyType.next
        self.costTxtField.delegate = self
        
        self.costTxtField.keyboardType = UIKeyboardType.decimalPad
        self.costTxtField.tag = 11
        
        self.contentView.addSubview(self.costTxtField)
        
        
        let costToolBar = UIToolbar()
        costToolBar.barStyle = UIBarStyle.default
        costToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        costToolBar.sizeToFit()
        let setCostButton = UIBarButtonItem(title: "Set Cost", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleCost))
        costToolBar.setItems([spaceButton, setCostButton], animated: false)
        costToolBar.isUserInteractionEnabled = true
        costTxtField.inputAccessoryView = costToolBar
        
        
        //total cost
        self.totalCostLbl = Label(text: "Total Cost")
        self.contentView.addSubview(self.totalCostLbl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UsageEntryTableViewCell.keyboardWillShow(sender:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["qtyLbl":qtyLbl,"qtyText":qtyTxtField,"unitsLbl":unitsLbl, "lockIcon":lockIcon,"vendorLbl":vendorLbl,"vendorTxtField":vendorTxtField,"costLbl":costLbl,"costTxtField":costTxtField,"totalCostLbl":totalCostLbl] as [String:AnyObject]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[qtyLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[qtyLbl]-[qtyText(80)]-[unitsLbl(60)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[lockIcon(20)]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[vendorLbl(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[vendorLbl][vendorTxtField(120)]-[costLbl][costTxtField(80)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[totalCostLbl(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[totalCostLbl(220)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    func displayHistoryMode(){
        //print("displayHistoryMode")
    
        self.isUserInteractionEnabled = true
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        let cornerRadius : CGFloat = 5.0
        
        self.historyBtn = Button(titleText: "Show All Usage")
        self.contentView.addSubview(historyBtn)
        
        historyBtn.setTitleColor(UIColor(hex:0x005100, op:1), for: UIControlState.normal)
        historyBtn.backgroundColor = UIColor.clear
        historyBtn.layer.borderWidth = 1.0
        historyBtn.layer.borderColor = UIColor(hex:0x005100, op:1).cgColor
        historyBtn.layer.cornerRadius = cornerRadius
        
        self.historyBtn.addTarget(self, action:#selector(UsageEntryTableViewCell.handleShowHistory), for: UIControlEvents.touchUpInside)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["historyBtn":historyBtn] as [String:AnyObject]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[historyBtn]-15-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[historyBtn]-20-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
    }

    
    
    func setImageUrl(_url:String){
        let imgURL:URL = URL(string: _url)!
        Nuke.loadImage(with: imgURL, into: self.employeeImageView){ [weak contentView] in
            //print("nuke loadImage")
            self.employeeImageView.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
        }
    }
    
    
    /*
    func setImageUrl(_url:String){
        
        let url = URL(string: _url)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.employeeImageView.image = UIImage(data: data!)
            }
        }
    }
    
    */
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    
    func handleStartPicker()
    {
        //print("handle start picker")
        self.startTxtField.resignFirstResponder()
        let theDateFormat = DateFormatter.Style.none
        let theTimeFormat = DateFormatter.Style.short
        startStopFormatter.dateStyle = theDateFormat
        startStopFormatter.timeStyle = theTimeFormat
        self.startTxtField.text =  startStopFormatter.string(from: startPickerView.date)
        let startDate = startPickerView.date
        //print("call delegate \(self.row)  \(startPickerView.date)")
        self.delegate.editStart(row: self.row, start: startDate)
    }
    
    
    func handleStopPicker()
    {
       // print("handle stop picker")
        self.stopTxtField.resignFirstResponder()
        let theDateFormat = DateFormatter.Style.none
        let theTimeFormat = DateFormatter.Style.short
        startStopFormatter.dateStyle = theDateFormat
        startStopFormatter.timeStyle = theTimeFormat
        self.stopTxtField.text =  startStopFormatter.string(from: stopPickerView.date)
        let stopDate = stopPickerView.date
       // print("call delegate \(self.row)  \(stopPickerView.date)")
        self.delegate.editStop(row: self.row, stop: stopDate)
    }
    
    
    func handleBreakTime()
    {
        self.breakTxtField.resignFirstResponder()
        if(Int(breakTxtField.text!) == nil){
            
        }else{
            let breakTime = Int(breakTxtField.text!)
            //print("call delegate \(self.row)  \(breakTime)")
            self.delegate.editBreak(row: self.row, lunch: breakTime!)
        }
        
        
    }
    
    func handleShowHistory()
    {
       //print("handleShowHistory")
            self.delegate.showHistory()
        
        
        
    }
    
    //material mode
    
    
    
    
    func handleQty()
    {
        //print("handle qty")
        if(Double(qtyTxtField.text!) == nil){
            self.qtyTxtField.resignFirstResponder()
        }else{
            let qty = Double(qtyTxtField.text!)
            //print("call delegate \(self.row)  \(qty)")
            self.delegate.editQty(row: self.row, qty: qty!)
            self.qtyTxtField.resignFirstResponder()
        }
        
        
    }
    
    func handleVendor()
    {
        let row = self.vendorPicker.selectedRow(inComponent: 0)
        let vendor = vendorList[row]
        if(vendor.ID == nil){
            self.delegate.editVendor(row: self.row, vendor: "0")
        }else{
            self.delegate.editVendor(row: self.row, vendor: String(vendor.ID))
            
        }
        self.vendorTxtField.text = String(vendor.name)
        self.vendorTxtField.resignFirstResponder()
        
        if(vendor.itemCost != ""){
            costTxtField.text = vendor.itemCost
            let cost = Double(costTxtField.text!)
            if(cost != nil){
                //print("call delegate \(self.row)  \(cost)")
                self.delegate.editCost(row: self.row, cost: cost!)
            }
        }
    }
    
    func handleCost()
    {
        if(Double(costTxtField.text!) == nil){
            self.costTxtField.resignFirstResponder()
        }else{
            let cost = Double(costTxtField.text!)
            //print("call delegate \(self.row)  \(cost)")
            self.delegate.editCost(row: self.row, cost: cost!)
            self.costTxtField.resignFirstResponder()
        }
        
        
    }
    
    
    
    
    func keyboardWillShow(sender: NSNotification) {
        //print("keyboard will show")
        
        if(self.locked == false){
            if(Double(qtyTxtField.text!) != nil){
                
                let qty = Double(qtyTxtField.text!)
                // print("call delegate \(self.row)  \(qty)")
                self.delegate.editQty(row: self.row, qty: qty!)
            }
            if(Double(costTxtField.text!) != nil){
                
                let cost = Double(costTxtField.text!)
                //print("call delegate \(self.row)  \(cost)")
                self.delegate.editCost(row: self.row, cost: cost!)
            }
        }
        
    }

    
    //picker view delegate methods
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        
        return self.vendorList.count
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.vendorList[row].name
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        self.vendorValue = self.vendorList[row].name
        
    }
    
    /*
    func checkForUnSetValues(_usageQty:String,_vendor:String,_unitCost:String,_totalCost:String){
        //print("checkForUnSetValues")
        //print("qty = \(_usageQty) vendor = \(_vendor) unitCost = \(_unitCost) totalCost = \(_totalCost)")
        
    }
 */
}
