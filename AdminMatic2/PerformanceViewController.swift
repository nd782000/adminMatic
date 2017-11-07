//
//  PerformanceViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/9/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol PerformanceDelegate{
    func reDrawList(_index:Int, _status:String)
    
}



class PerformanceViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, PerformanceDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!

    var empID:String!
   // var units:String!
    //var total:String!
    var screenHeaderLbl: Label!
    var toLbl: Label!
    var startTxtField: PaddedTextField!
    var startPickerView :DatePicker!//edit mode
    
    var stopTxtField: PaddedTextField!
    var stopPickerView :DatePicker!//edit mode
    
    var startStopFormatter = DateFormatter()
    
    
    var performanceTableView: TableView!
    var usageJSON: JSON!
    var usages: [Usage] = []
    var usageTotalLbl: Label!
    let shortDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let tableHead:UIView! = UIView()
    let stsTH: THead = THead(text: "Sts")
    let nameTH: THead = THead(text: "Customer")
    let dateTH: THead = THead(text: "Date")
    let startTH: THead = THead(text: "Start")
    let stopTH: THead = THead(text: "Stop")
    let qtyTH: THead = THead(text: "Qty")
    let priceTH: THead = THead(text: "Rev")
    
    var total:String!
    var totalPrice:String!
    
    var startDate:String!
    var endDate:String!
    var startDateDB:String!
    var endDateDB:String!

    
    init(_empID:String){
        super.init(nibName:nil,bundle:nil)
        self.empID = _empID
        //self.units = _units
        //self.total = _total
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = layoutVars.backgroundColor
        title = "Performance"
        
        self.shortDateFormatter.dateFormat = "M/dd"
        self.timeFormatter.dateFormat = "h:mm a"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        let now = Date()
        
        startDate = dateFormatter.string(from: now)
        endDate = dateFormatter.string(from: now)
        
        startDateDB = dateFormatterDB.string(from: now)
        endDateDB = dateFormatterDB.string(from: now)
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(PerformanceViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        
        
        
        
        getPerformance()
        
    }
    
    
    
    
    func getPerformance(){
        print("get all usage")
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        
         
        let parameters = ["startDate":  startDateDB,"endDate": endDateDB,"empID":(appDelegate.loggedInEmployee?.ID)!] as [String : Any]
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/usageByEmp.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("usageByEmp response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    //self.images = JSON(json)
                    self.usageJSON = JSON(json)
                    self.parseUsageJSON()
                    
                }
                
                self.indicator.dismissIndicator()
        }

        
        
        
        
    }
    
    func parseUsageJSON(){
        
        
        print("parse usageJSON: \(self.usageJSON)")
        
        self.usages = []
        
        let usageCount = self.usageJSON["usage"].count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        for n in 0 ..< usageCount {
            let startDate = dateFormatter.date(from: self.usageJSON["usage"][n]["start"].string!)!
            
            
            let usage:Usage!
            
            
            if(self.usageJSON["usage"][n]["stop"].string != "0000-00-00 00:00:00"){
                let stopDate = dateFormatter.date(from: self.usageJSON["usage"][n]["stop"].string!)!
                
                usage = Usage(_ID: self.usageJSON["usage"][n]["ID"].stringValue,
                              _empID: self.usageJSON["usage"][n]["empID"].stringValue,
                              _depID: self.usageJSON["usage"][n]["depID"].stringValue,
                              _woID: self.usageJSON["usage"][n]["woID"].stringValue,
                              _start: startDate,
                              _stop: stopDate,
                              _lunch: self.usageJSON["usage"][n]["lunch"].stringValue,
                              _qty: self.usageJSON["usage"][n]["qty"].stringValue,
                              _empName: self.usageJSON["usage"][n]["empName"].stringValue,
                              _type: self.usageJSON["usage"][n]["type"].stringValue,
                              _itemID: self.usageJSON["usage"][n]["woItemID"].stringValue,
                              _unitPrice: self.usageJSON["usage"][n]["unitPrice"].stringValue,
                              _totalPrice: self.usageJSON["usage"][n]["totalPrice"].stringValue,
                              _vendor: self.usageJSON["usage"][n]["vendor"].stringValue,
                              _unitCost: self.usageJSON["usage"][n]["unitCost"].stringValue,
                              _totalCost: self.usageJSON["usage"][n]["totalCost"].stringValue,
                              _chargeType: self.usageJSON["usage"][n]["chargeID"].stringValue,
                              _override: self.usageJSON["usage"][n]["override"].stringValue,
                              _empPic: self.usageJSON["usage"][n]["empPic"].stringValue,
                              _locked: true,
                              _addedBy: self.usageJSON["usage"][n]["addedBy"].stringValue,
                              _del: ""
                )
                
            }else{
                
                usage = Usage(_ID: self.usageJSON["usage"][n]["ID"].stringValue,
                              _empID: self.usageJSON["usage"][n]["empID"].stringValue,
                              _depID: self.usageJSON["usage"][n]["depID"].stringValue,
                              _woID: self.usageJSON["usage"][n]["woID"].stringValue,
                              _start: startDate,
                              _lunch: self.usageJSON["usage"][n]["lunch"].stringValue,
                              _qty: self.usageJSON["usage"][n]["qty"].stringValue,
                              _empName: self.usageJSON["usage"][n]["empName"].stringValue,
                              _type: self.usageJSON["usage"][n]["type"].stringValue,
                              _itemID: self.usageJSON["usage"][n]["woItemID"].stringValue,
                              _unitPrice: self.usageJSON["usage"][n]["unitPrice"].stringValue,
                              _totalPrice: self.usageJSON["usage"][n]["totalPrice"].stringValue,
                              _vendor: self.usageJSON["usage"][n]["vendor"].stringValue,
                              _unitCost: self.usageJSON["usage"][n]["unitCost"].stringValue,
                              _totalCost: self.usageJSON["usage"][n]["totalCost"].stringValue,
                              _chargeType: self.usageJSON["usage"][n]["chargeID"].stringValue,
                              _override: self.usageJSON["usage"][n]["override"].stringValue,
                              _empPic: self.usageJSON["usage"][n]["empPic"].stringValue,
                              _locked: true,
                              _addedBy: self.usageJSON["usage"][n]["addedBy"].stringValue,
                              _del: ""
                )
                
                
            }
            usage.custName = self.usageJSON["usage"][n]["custName"].stringValue
            usage.woStatus = self.usageJSON["usage"][n]["woStatus"].stringValue
            
            self.usages.append(usage)
        }
        
        
        print("usage count \(self.usages.count)")
        self.total = self.usageJSON["usageTotalHrs"].stringValue
        self.totalPrice = self.usageJSON["usageTotalPrice"].stringValue
        
        
        
        
        
        if (UIDevice.current.orientation.isLandscape == true) {
            print("Landscape")
            self.layoutViewsLandscape()
        } else {
            print("Portrait")
            self.layoutViewsPortrait()
        }
        
       
        
        
        self.performanceTableView.reloadData()
    }
    
    
    
    
    func layoutViewsPortrait(){
        print("layoutViewsPortrait")
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        for view in self.tableHead.subviews{
            view.removeFromSuperview()
        }
        
        
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "Your Usage from:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.left
        self.view.addSubview(self.screenHeaderLbl)
        
        self.toLbl = Label()
        self.toLbl.text = "to:"
        self.toLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.toLbl.textAlignment = NSTextAlignment.left
        self.view.addSubview(self.toLbl)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePickerMode.date
        startStopFormatter.dateFormat = "MM/dd/yy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:startDate,attributes:[NSAttributedStringKey.foregroundColor: layoutVars.buttonColor1])
        self.view.addSubview(self.startTxtField)
        
        
        
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Date", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePickerMode.date
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:endDate,attributes:[NSAttributedStringKey.foregroundColor: layoutVars.buttonColor1])
        self.view.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Date", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar

        
        
        
        
        
        
        
        
        
        
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableHead)
        
        self.performanceTableView =  TableView()
        self.performanceTableView.delegate  =  self
        self.performanceTableView.dataSource  =  self
        self.performanceTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.performanceTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.text = "Totals -  Jobs:\(self.usages.count), Hours: \(self.total!)"
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        self.view.addSubview(self.usageTotalLbl)
        

        tableHead.addSubview(stsTH)
        tableHead.addSubview(nameTH)
        tableHead.addSubview(dateTH)
        tableHead.addSubview(qtyTH)
        
        
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            "sts":stsTH,
            "name":nameTH,
            "date":dateTH,
            "qty":qtyTH
            ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[sts(30)]-[name]-[date(60)]-[qty(40)]-5-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[sts(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[name(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[qty(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        let usageViewsDictionary = ["headerLbl": self.screenHeaderLbl,"start": self.startTxtField,"toLbl":self.toLbl,"stop": self.stopTxtField, "th":self.tableHead,"view1": self.performanceTableView,"view2": self.usageTotalLbl] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLbl]-[start(80)]-[toLbl(25)]-[stop(80)]", options: [], metrics: metricsDictionary, views:usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[headerLbl(30)]-[th(40)][view1]-[view2(30)]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[start(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[toLbl(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[stop(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
    }
    
    
    
    func layoutViewsLandscape(){
        print("layoutViewsPortrait")
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        for view in self.tableHead.subviews{
            view.removeFromSuperview()
        }
        
        
        
        
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "Your Usage from:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.left
        self.view.addSubview(self.screenHeaderLbl)
        
        self.toLbl = Label()
        self.toLbl.text = "to:"
        self.toLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.toLbl.textAlignment = NSTextAlignment.left
        self.view.addSubview(self.toLbl)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePickerMode.date
        startStopFormatter.dateFormat = "MM/dd/yy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:startDate,attributes:[NSAttributedStringKey.foregroundColor: layoutVars.buttonColor1])
        self.view.addSubview(self.startTxtField)
        
        
        
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Date", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePickerMode.date
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:endDate,attributes:[NSAttributedStringKey.foregroundColor: layoutVars.buttonColor1])
        self.view.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Date", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar
        
        
        
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableHead)
        
        self.performanceTableView =  TableView()
        self.performanceTableView.delegate  =  self
        self.performanceTableView.dataSource  =  self
        self.performanceTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.performanceTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.text = "Totals - Jobs:\(self.usages.count), Hours: \(self.total!) , Revenue: \(self.totalPrice!)"
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        self.view.addSubview(self.usageTotalLbl)
        
        
        tableHead.addSubview(stsTH)
        tableHead.addSubview(nameTH)
        tableHead.addSubview(dateTH)
        tableHead.addSubview(startTH)
        tableHead.addSubview(stopTH)
        tableHead.addSubview(qtyTH)
        tableHead.addSubview(priceTH)

        
        
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            "sts":stsTH,
            "name":nameTH,
            "date":dateTH,
            "start":startTH,
            "stop":stopTH,
            "qty":qtyTH,
            "price":priceTH
            ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[sts(30)]-[name]-[date(60)]-[start(80)]-[stop(80)]-[qty(40)]-[price(60)]-5-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[sts(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[name(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[start(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[stop(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[qty(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[price(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        let usageViewsDictionary = ["headerLbl": self.screenHeaderLbl,"start": self.startTxtField,"toLbl":self.toLbl,"stop": self.stopTxtField, "th":self.tableHead,"view1": self.performanceTableView,"view2": self.usageTotalLbl] as [String:Any]
        
        
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLbl]-|", options: [], metrics: metricsDictionary, views:usageViewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLbl]-[start(80)]-[toLbl(25)]-[stop(80)]", options: [], metrics: metricsDictionary, views:usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[headerLbl(30)]-[th(40)][view1]-[view2(30)]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[start(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[toLbl(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[stop(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("usages.count = \(usages.count)")
        return self.usages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UsageTableViewCell = performanceTableView.dequeueReusableCell(withIdentifier: "cell") as! UsageTableViewCell
       
        
        
        if (UIDevice.current.orientation.isLandscape == true) {
            print("Landscape")
            
            cell.usage = usages[indexPath.row]
            cell.layoutLandscape()
            cell.usageNameLbl.text = usages[indexPath.row].custName
            cell.usageDateLbl.text = self.shortDateFormatter.string(from: usages[indexPath.row].start!)
            cell.usageStartLbl.text = self.timeFormatter.string(from: usages[indexPath.row].start!)
            cell.usageStopLbl.text = self.timeFormatter.string(from: usages[indexPath.row].stop!)
            cell.usageTotalLbl.text = "\(usages[indexPath.row].qty!) "
            if(usages[indexPath.row].woStatus! != "3"){
                 cell.usagePriceLbl.text =  "---"
            }else{
                 cell.usagePriceLbl.text =  "$\(usages[indexPath.row].totalPrice!) "
            }
           
            cell.setStatus(status: usages[indexPath.row].woStatus!)
            
            
        } else {
            print("Portrait")
            cell.usage = usages[indexPath.row]
             cell.layoutPortrait()
            cell.usageNameLbl.text = usages[indexPath.row].custName
            cell.usageDateLbl.text = self.shortDateFormatter.string(from: usages[indexPath.row].start!)
            cell.usageTotalLbl.text = "\(usages[indexPath.row].qty!) "
            cell.setStatus(status: usages[indexPath.row].woStatus!)
            
           
        }
        
        
        return cell;
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        

    
    
    
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! UsageTableViewCell;
        
        
        let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.usage.woID!,_customerName: currentCell.usage.custName!)
        
        workOrderViewController.tableCellID = indexPath?.row
        workOrderViewController.performanceDelegate = self
        
        navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
        
       // workOrderViewController.scheduleDelegate = self
        //workOrderViewController.scheduleIndex = indexPath?.row
        

    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
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
    */
    
    //picker view delegate methods
    /*
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
    
    */
    
    
    
    func handleStartPicker()
    {
        //print("handle start picker")
        self.startTxtField.resignFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        self.startTxtField.text = dateFormatter.string(from: startPickerView.date)
        startDate = dateFormatter.string(from: startPickerView.date)
         startDateDB = dateFormatterDB.string(from: startPickerView.date)
        getPerformance()
    }
    
    
    func handleStopPicker()
    {
        // print("handle stop picker")
        self.stopTxtField.resignFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        self.stopTxtField.text = dateFormatter.string(from: stopPickerView.date)
        endDate = dateFormatter.string(from: stopPickerView.date)
        endDateDB = dateFormatterDB.string(from: stopPickerView.date)
        getPerformance()
    }
    

    
    
    
    func reDrawList(_index:Int, _status:String){
        print("reDraw List")
        self.usages[_index].woStatus = _status
        self.performanceTableView.reloadData()
    }

    
    
    
    func goBack(){
        print("back")
        displayHomeView()
       // _ = appDelegate.navigationController.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func canRotate() -> Void {}
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if (UIDevice.current.orientation.isLandscape == true) {
            print("Landscape")
            self.layoutViewsLandscape()
        } else {
            print("Portrait")
            self.layoutViewsPortrait()
        }
    }
    
    
    
    
    
    
    
}
