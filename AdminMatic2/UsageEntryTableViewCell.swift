
//
//  EmployeeTableViewCell.swift
//  Atlantic_Blank
//
//  Created by Nicholas Digiando on 8/9/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
 

class UsageEntryTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var delegate:UsageDelegate!
    var receiptDelegate:UpdateReceiptImageDelegate!
    
    
    var row:Int!
    var empID:String!
    var empName:String!
    var itemType:String!
    
    var vendorList:[Vendor2] = []
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
    var totalCostTxtField: PaddedTextField!
    
    var historyBtn:Button!
    
    var locked:Bool = false
    var lockIcon:UIImageView!
    
    //images for receipts
    var receiptLbl:Label!
    //var receiptLbl2:Label!
    var receiptView:UIImageView = UIImageView()
    
    var tapBtn:Button!
    @objc var tapAction : ((UITableViewCell) -> Void)?
    
    var imageUploadPrepViewController:ImageUploadPrepViewController!

    var usage:Usage2?
    var index:Int?
    
    var addUsageLbl:Label = Label()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    func buttonTap(sender:AnyObject){
        tapAction?(self)
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
        
        
        activityView = UIActivityIndicatorView(style: .gray)
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
        
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        //start
        self.startLbl = Label(text: "Start")
        self.contentView.addSubview(self.startLbl)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePicker.Mode.time
        
        
        
       
        
        
        
        startStopFormatter.dateFormat = "MM/dd/yyyy"
        
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:"---",attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        self.contentView.addSubview(self.startTxtField)
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let closeStartButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.closeStartPicker))
        let setStartButton = BarButtonItem(title: "Set Start Time", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([closeStartButton, spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        self.stopLbl = Label(text: "Stop")
        self.contentView.addSubview(self.stopLbl)
        
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePicker.Mode.time
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:"---",attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        self.contentView.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let closeStopButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.closeStopPicker))
        let setStopButton = BarButtonItem(title: "Set Stop Time", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([closeStopButton, spaceButton, setStopButton], animated: false)
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
        let closeBreakButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.closeBreak))
        let setBreakButton = BarButtonItem(title: "Set Break Time", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleBreakTime))
        breakToolBar.setItems([closeBreakButton, spaceButton, setBreakButton], animated: false)
        breakToolBar.isUserInteractionEnabled = true
        breakTxtField.inputAccessoryView = breakToolBar
        
        
        
        contentView.addSubview(nameLbl)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl,"qty":qtyLbl,"lockIcon":lockIcon,"startLbl":startLbl,"startTxtField":startTxtField,"stopLbl":stopLbl,"stopTxtField":stopTxtField,"breakLbl":breakLbl,"breakTxtField":breakTxtField] as [String:AnyObject]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(40)]-10-[name]-10-[qty]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[lockIcon(20)]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[startLbl(40)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[startLbl][startTxtField(70)][stopLbl][stopTxtField(70)][breakLbl][breakTxtField(50)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
        
    }
    
    func displayMaterialMode(){
        print("displayMaterialMode")
        
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        
        //qty
        self.qtyLbl = Label(text: "Quantity:")
        self.qtyLbl.textAlignment = .right
        self.contentView.addSubview(self.qtyLbl)
        
        self.qtyTxtField = PaddedTextField()
        self.qtyTxtField.delegate = self
        
        self.qtyTxtField.keyboardType = UIKeyboardType.decimalPad
        self.qtyTxtField.tag = 10
        
        self.contentView.addSubview(self.qtyTxtField)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let qtyToolBar = UIToolbar()
        qtyToolBar.barStyle = UIBarStyle.default
        qtyToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        qtyToolBar.sizeToFit()
        let closeQtyButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.closeQty))
        let setQtyButton = BarButtonItem(title: "Set Qty", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleQty))
        qtyToolBar.setItems([closeQtyButton, spaceButton, setQtyButton], animated: false)
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
        self.vendorLbl = Label(text: "Vendor:")
        self.vendorLbl.textAlignment = .right
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
        let closeVendorButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.closeVendor))
        let setVendorButton = BarButtonItem(title: "Set Vendor", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleVendor))
        vendorToolBar.setItems([closeVendorButton, spaceButton, setVendorButton], animated: false)
        vendorToolBar.isUserInteractionEnabled = true
        vendorTxtField.inputAccessoryView = vendorToolBar
        
        
        //cost
        self.costLbl = Label(text: "Unit Cost: $")
        self.costLbl.textAlignment = .right
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
        let closeCostButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.closeCost))
        
        let setCostButton = BarButtonItem(title: "Set Cost", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleCost))
        costToolBar.setItems([closeCostButton, spaceButton, setCostButton], animated: false)
        costToolBar.isUserInteractionEnabled = true
        costTxtField.inputAccessoryView = costToolBar
        
        
        //total cost
        self.totalCostLbl = Label(text: "Total Cost: $")
        self.totalCostLbl.textAlignment = .right
        self.contentView.addSubview(self.totalCostLbl)
        
        self.totalCostTxtField = PaddedTextField()
        self.totalCostTxtField.isEnabled = false
        self.totalCostTxtField.alpha = 0.5
        self.contentView.addSubview(self.totalCostTxtField)
        
        //images for receipts
        
        self.receiptLbl = Label(text: "Receipt:")
        self.receiptLbl.textAlignment = .right
        self.contentView.addSubview(self.receiptLbl)
        
        
        self.receiptView.clipsToBounds = true
        self.receiptView.layer.borderWidth = 1
        self.receiptView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.receiptView.layer.cornerRadius = 4.0
        self.receiptView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.receiptView)
        self.setBlankImage()
        
        //self.receiptLbl2 = Label(text: "Swipe to Manage")
        //self.receiptLbl2.textAlignment = .left
       // self.contentView.addSubview(self.receiptLbl2)
        
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        //activityView.center = CGPoint(x: self.thumbView.frame.size.width, y: self.thumbView.frame.size.height)
        receiptView.addSubview(activityView)
        
        self.tapBtn = Button()
        tapBtn.backgroundColor = UIColor.clear
        //self.tapBtn.addTarget(self, action: #selector(getter: self.tapAction), for: UIControl.Event.allTouchEvents)
        self.tapBtn.addTarget(self, action: #selector(self.receiptTap), for: UIControl.Event.touchUpInside)
        contentView.addSubview(tapBtn)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(UsageEntryTableViewCell.keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        //print("1")
        let viewsDictionary = ["qtyLbl":qtyLbl,"qtyText":qtyTxtField,"unitsLbl":unitsLbl, "lockIcon":lockIcon,"vendorLbl":vendorLbl,"vendorTxtField":vendorTxtField,"costLbl":costLbl,"costTxtField":costTxtField,"totalCostLbl":totalCostLbl,"totalCostTxtField":totalCostTxtField,"receiptLbl":receiptLbl,"receipt":receiptView,"tapBtn":tapBtn] as [String:AnyObject]
        
       
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[vendorLbl(100)]-[vendorTxtField(200)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        //print("2")
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[qtyLbl(100)]-[qtyText(80)]-[unitsLbl(100)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[costLbl(100)]-[costTxtField(80)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[totalCostLbl(100)]-[totalCostTxtField(80)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[vendorLbl(40)][qtyLbl(40)][costLbl(40)][totalCostLbl(40)]", options: [], metrics: nil, views: viewsDictionary))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[receipt(50)]-36-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[receiptLbl(100)]-[receipt(80)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[receiptLbl(100)]-[tapBtn(80)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[receiptLbl(40)]-28-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[receipt(80)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[tapBtn(80)]-|", options: [], metrics: nil, views: viewsDictionary))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[receiptLbl2(40)]-28-|", options: [], metrics: nil, views: viewsDictionary))
        //print("4")
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[lockIcon(20)]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        //print("5")
        receiptView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        receiptView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        
    }
    
    
    func layoutAddBtn(){
        
        print("layoutAddBtn")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // self.selectedImageView.image = nil
        
        self.addUsageLbl.text = "Add Usage"
        self.addUsageLbl.textColor = UIColor.white
        self.addUsageLbl.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        //self.addUsageLbl.backgroundColor = UIColor.clear
        
        self.addUsageLbl.layer.cornerRadius = 4.0
        self.addUsageLbl.clipsToBounds = true
        self.addUsageLbl.textAlignment = .center
        contentView.addSubview(self.addUsageLbl)
        
        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["addBtn":self.addUsageLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
    /*
    func displayHistoryMode(){
        //print("displayHistoryMode")
    
        self.isUserInteractionEnabled = true
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        let cornerRadius : CGFloat = 5.0
        
        self.historyBtn = Button(titleText: "Show All Usage")
        self.contentView.addSubview(historyBtn)
        
        historyBtn.setTitleColor(UIColor(hex:0x005100, op:1), for: UIControl.State.normal)
        historyBtn.backgroundColor = UIColor.clear
        historyBtn.layer.borderWidth = 1.0
        historyBtn.layer.borderColor = UIColor(hex:0x005100, op:1).cgColor
        historyBtn.layer.cornerRadius = cornerRadius
        
        self.historyBtn.addTarget(self, action:#selector(UsageEntryTableViewCell.handleShowHistory), for: UIControl.Event.touchUpInside)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["historyBtn":historyBtn] as [String:AnyObject]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[historyBtn]-15-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[historyBtn]-20-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
    }
*/
    
    
    @objc func receiptTap(){
        self.receiptDelegate.receiptBtnTapped(_usage: self.usage!, _index: self.index!)
    }
    
    func setImageUrl(_url:String){
        
        
        
        Alamofire.request(_url).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                self.employeeImageView.image = image
                
                
                
                //self.activityView.stopAnimating()
                
                
            }
        }
        
        
        
        
    }
    
    func setReceiptUrl(_url:String){
        
        print("set receipt url \(_url)")
        
        Alamofire.request(_url).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                self.receiptView.image = image
                
                
                
                //self.activityView.stopAnimating()
                
                
            }
        }
        
        
        
        
    }
    
    func setBlankImage(){
        self.receiptView.image = layoutVars.defaultImage
    }
    
    
    
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    @objc func closeStartPicker(){
        self.startTxtField.resignFirstResponder()
    }
    
    @objc func handleStartPicker()
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
    
    
    @objc func handleStopPicker()
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
    
    @objc func closeStopPicker(){
        self.stopTxtField.resignFirstResponder()
    }
    
    
    @objc func handleBreakTime()
    {
        self.breakTxtField.resignFirstResponder()
        
        if Int(breakTxtField.text!) != nil{
            let breakTime = Int(breakTxtField.text!)
            //print("call delegate \(self.row)  \(breakTime)")
            self.delegate.editBreak(row: self.row, lunch: breakTime!)
        }
        
        
    }
    
    @objc func closeBreak(){
        self.breakTxtField.resignFirstResponder()
    }

    
    @objc func handleShowHistory()
    {
       //print("handleShowHistory")
            self.delegate.showHistory()
        
        
        
    }
    
    //material mode
    
    
    @objc func closeQty(){
        self.qtyTxtField.resignFirstResponder()
    }
    
    @objc func handleQty()
    {
        //print("handle qty")
        if(Double(qtyTxtField.text!) == nil){
            self.qtyTxtField.resignFirstResponder()
        }else{
            let qty = Double(qtyTxtField.text!)
            //print("call delegate \(self.row)  \(qty)")
            self.delegate.editQty(row: self.row, qty: qty!)
            self.qtyTxtField.resignFirstResponder()
            
            if costTxtField.text != ""{
                self.totalCostTxtField.text =    String(format: "%.2f", qty! * Double(costTxtField.text!)!)
            }
            
           
            
            
        }
        
        
    }
    
    @objc func closeVendor(){
        self.vendorTxtField.resignFirstResponder()
    }
    
    @objc func handleVendor()
    {
        let row = self.vendorPicker.selectedRow(inComponent: 0)
        let vendor = vendorList[row]
        //if(vendor.ID == nil){
            //self.delegate.editVendor(row: self.row, vendor: "0",_unitCost:0.00)
        //}else{
        print("vendor.itemCost = \(String(describing: vendor.itemCost))")
       if vendor.itemCost != nil{
            self.delegate.editVendor(row: self.row, vendor: String(vendor.ID),_unitCost: Double(vendor.itemCost!)!)
        }else{
            self.delegate.editVendor(row: self.row, vendor: String(vendor.ID),_unitCost: 0.00)
        }
        
            
        //}
        self.vendorTxtField.text = String(vendor.name)
        self.vendorTxtField.resignFirstResponder()
        
        if(vendor.itemCost != nil){
            costTxtField.text = vendor.itemCost
            let cost = Double(costTxtField.text!)
            if(cost != nil){
                //print("call delegate \(self.row)  \(cost)")
                self.delegate.editCost(row: self.row, cost: cost!)
                
                
               
                if qtyTxtField.text != ""{
                    self.totalCostTxtField.text =    String(format: "%.2f", cost! * Double(qtyTxtField.text!)!)
                }
                    
                    
              
                
                
                
            }
        }
    }
    
    @objc func closeCost(){
        self.costTxtField.resignFirstResponder()
    }
    
    @objc func handleCost()
    {
        if(Double(costTxtField.text!) == nil){
            self.costTxtField.resignFirstResponder()
        }else{
            let cost = Double(costTxtField.text!)
            //print("call delegate \(self.row)  \(cost)")
            self.delegate.editCost(row: self.row, cost: cost!)
            self.costTxtField.resignFirstResponder()
            
            if qtyTxtField.text != ""{
                self.totalCostTxtField.text =    String(format: "%.2f", cost! * Double(qtyTxtField.text!)!)
            }
            
            
            
        }
        
       
        
            
            
            
        
        
        
        
    }
    
    
    
    
    @objc func keyboardWillShow(sender: NSNotification) {
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

    
    
    
    //picker view methods
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
       // print(" 1numberOfComponents = \(appDelegate.employeeArray.count + 1)")
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return self.vendorList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return self.vendorList[row].name
            
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.vendorValue = self.vendorList[row].name
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        print("tag = \(textField.tag)")
        if textField.tag == 8{
            
           textField.selectAll(nil)
        }
        
        
        
    }
    

    
    
    func updateReceipt(_image:Image2){
        print("update image")
        
        
        activityView.startAnimating()
        self.usage?.receipt = _image
        //self.equipment.pic = _image.thumbPath
        let imgURL:URL = URL(string: (self.usage?.receipt!.thumbPath)!)!
        
        
        Alamofire.request(imgURL).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
               // self.usage?.receipt = image
                
                
                
                self.activityView.stopAnimating()
                
                
                /*
                if(self.title == "New Equipment"){
                    self.delegate.reDrawEquipmentList()
                }else{
                    self.editDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                
                if self.imageAddedAfterSubmit {
                    
                    self.editsMade = false
                    self.goBack()
                }
                */
                
            }
        }
        
        
       
        
    }
    
    
    

}
