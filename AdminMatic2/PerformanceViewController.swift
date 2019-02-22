//
//  PerformanceViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/9/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol PerformanceDelegate{
    func reDrawList(_index:Int, _status:String)
    
}

 

class PerformanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, PerformanceDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!

    var empID:String!
   
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
    var usageLoaded:Bool = false
    
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

    
    var methodStart:Date!
    var methodFinish:Date!
    
    
    
    init(_empID:String){
        super.init(nibName:nil,bundle:nil)
        self.empID = _empID
        
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
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(PerformanceViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
        
        
        
        //getPerformance()
        
    }
    
    
    override func viewWillLayoutSubviews() {
        //print("viewWillLayoutSubviews")
        
        if usageLoaded == false{
            self.getPerformance()
        }else{
            if (UIDevice.current.orientation.isLandscape == true) {
                //print("Landscape")
                self.layoutViewsLandscape()
            } else {
                //print("Portrait")
                self.layoutViewsPortrait()
            }
        }
        
    }
    
    
    
    
    
    
    func getPerformance(){
        //print("get all usage")
        
        methodStart = Date()
        indicator = SDevIndicator.generate(self.view)!
        
        
        let parameters:[String:String]
        parameters = ["startDate":  startDateDB,"endDate": endDateDB,"empID":appDelegate.loggedInEmployee?.ID] as! [String : String]
        
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/usageByEmp.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("usageByEmp response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                
                
                /*
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    //self.images = JSON(json)
                    self.usageJSON = JSON(json)
                    self.parseUsageJSON()
                    
                }
 */
                
                self.usages = []
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let usages = json["usage"] as? [[String: Any]] {
                        
                        
                        self.total = json["usageTotalHrs"] as? String
                        self.totalPrice = json["usageTotalPrice"] as! String
                        
                        let usageCount = usages.count
                        //print("usage count = \(usageCount)")
                        
                        
                        for n in 0 ..< usageCount {
                            let startDate = dateFormatter.date(from: usages[n]["start"] as! String)!
                            
                            
                            let usage:Usage!
                            
                            
                            if(usages[n]["stop"] as! String != "0000-00-00 00:00:00"){
                                let stopDate = dateFormatter.date(from: usages[n]["stop"] as! String)!
                                
                                usage = Usage(_ID: usages[n]["ID"] as? String,
                                              _empID: usages[n]["empID"] as? String,
                                              _depID: usages[n]["depID"] as? String,
                                              _woID: usages[n]["woID"] as? String,
                                              _start: startDate,
                                              _stop: stopDate,
                                              _lunch: usages[n]["lunch"] as? String,
                                              _qty: usages[n]["qty"] as? String,
                                              _empName: usages[n]["empName"] as? String,
                                              _type: usages[n]["type"] as? String,
                                              _itemID: usages[n]["woItemID"] as? String,
                                              _unitPrice: usages[n]["unitPrice"] as? String,
                                              _totalPrice: usages[n]["totalPrice"] as? String,
                                              _vendor: usages[n]["vendor"] as? String,
                                              _unitCost: usages[n]["unitCost"] as? String,
                                              _totalCost: usages[n]["totalCost"] as? String,
                                              _chargeType: usages[n]["chargeID"] as? String,
                                              _override: usages[n]["override"] as? String,
                                              _empPic: usages[n]["empPic"] as? String,
                                              _locked: true,
                                              _addedBy: usages[n]["addedBy"] as? String,
                                              _del: ""
                                )
                                
                            }else{
                                
                                usage = Usage(_ID: usages[n]["ID"] as? String,
                                              _empID: usages[n]["empID"] as? String,
                                              _depID: usages[n]["depID"] as? String,
                                              _woID: usages[n]["woID"] as? String,
                                              _start: startDate,
                                              _lunch: usages[n]["lunch"] as? String,
                                              _qty: usages[n]["qty"] as? String,
                                              _empName: usages[n]["empName"] as? String,
                                              _type: usages[n]["type"] as? String,
                                              _itemID: usages[n]["woItemID"] as? String,
                                              _unitPrice: usages[n]["unitPrice"] as? String,
                                              _totalPrice: usages[n]["totalPrice"] as? String,
                                              _vendor: usages[n]["vendor"] as? String,
                                              _unitCost: usages[n]["unitCost"] as? String,
                                              _totalCost: usages[n]["totalCost"] as? String,
                                              _chargeType: usages[n]["chargeID"] as? String,
                                              _override: usages[n]["override"] as? String,
                                              _empPic: usages[n]["empPic"] as? String,
                                              _locked: true,
                                              _addedBy: usages[n]["addedBy"] as? String,
                                              _del: ""
                                )
                                
                                
                            }
                            usage.custName = usages[n]["custName"] as? String
                            usage.woStatus = usages[n]["woStatus"] as? String
                            
                            self.usages.append(usage)
                        }
                        
                        self.usageLoaded = true
                    }
                    
                    
                    
                    
                    
                    
                    self.methodFinish = Date()
                    let executionTime = self.methodFinish.timeIntervalSince(self.methodStart)
                    //print("Execution time: \(executionTime)")
                    
                    
                    self.indicator.dismissIndicator()
                    
                    
                    //self.layoutViews()
                    
                    //print("usage count \(self.usages.count)")
                    
                    
                    
                    
                    
                    
                    if (UIDevice.current.orientation.isLandscape == true) {
                        //print("Landscape")
                        self.layoutViewsLandscape()
                    } else {
                        //print("Portrait")
                        self.layoutViewsPortrait()
                    }
                    
                    
                    
                    
                    self.performanceTableView.reloadData()
                    
                   
                    
                } catch {
                    //print("Error deserializing JSON: \(error)")
                }
                
                
                
                
                
                
                
                self.indicator.dismissIndicator()
        }

        
        
        
        
    }
    
    
    
    
    
    func layoutViewsPortrait(){
        //print("layoutViewsPortrait")
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        for view in self.tableHead.subviews{
            view.removeFromSuperview()
        }
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "Your usage from:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.left
        safeContainer.addSubview(self.screenHeaderLbl)
        
        self.toLbl = Label()
        self.toLbl.text = "to:"
        self.toLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.toLbl.textAlignment = NSTextAlignment.left
        safeContainer.addSubview(self.toLbl)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        //start
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePicker.Mode.date
        startStopFormatter.dateFormat = "MM/dd/yy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:startDate,attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        safeContainer.addSubview(self.startTxtField)
        
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PerformanceViewController.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        
        
        //stop
        
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePicker.Mode.date
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:endDate,attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        safeContainer.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PerformanceViewController.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar

        
        
        
        
        
        
        
        
        
        
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        safeContainer.addSubview(tableHead)
        
        self.performanceTableView =  TableView()
        self.performanceTableView.delegate  =  self
        self.performanceTableView.dataSource  =  self
        self.performanceTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.performanceTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.text = "Totals -  Jobs:\(self.usages.count), Hours: \(self.total!)"
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.usageTotalLbl)
        

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
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLbl]-[start(80)]-[toLbl(25)]-[stop(80)]", options: [], metrics: metricsDictionary, views:usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[headerLbl(30)]-[th(40)][view1]-[view2(30)]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[start(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[toLbl(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stop(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
    }
    
    
    
    func layoutViewsLandscape(){
        //print("layoutViewsPortrait")
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        for view in self.tableHead.subviews{
            view.removeFromSuperview()
        }
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "Your usage from:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.left
        safeContainer.addSubview(self.screenHeaderLbl)
        
        self.toLbl = Label()
        self.toLbl.text = "to:"
        self.toLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.toLbl.textAlignment = NSTextAlignment.left
        safeContainer.addSubview(self.toLbl)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePicker.Mode.date
        startStopFormatter.dateFormat = "MM/dd/yy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:startDate,attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        safeContainer.addSubview(self.startTxtField)
        
        
        
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PerformanceViewController.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePicker.Mode.date
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:endDate,attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        safeContainer.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar
        
        
        
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        safeContainer.addSubview(tableHead)
        
        self.performanceTableView =  TableView()
        self.performanceTableView.delegate  =  self
        self.performanceTableView.dataSource  =  self
        self.performanceTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.performanceTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.text = "Totals - Jobs:\(self.usages.count), Hours: \(self.total!) , Revenue: \(self.totalPrice!)"
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.usageTotalLbl)
        
        
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
        
        
       // safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLbl]-|", options: [], metrics: metricsDictionary, views:usageViewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLbl]-[start(80)]-[toLbl(25)]-[stop(80)]", options: [], metrics: metricsDictionary, views:usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[headerLbl(30)]-[th(40)][view1]-[view2(30)]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[start(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[toLbl(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stop(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("usages.count = \(usages.count)")
        return self.usages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UsageTableViewCell = performanceTableView.dequeueReusableCell(withIdentifier: "cell") as! UsageTableViewCell
       
        
        
        if (UIDevice.current.orientation.isLandscape == true) {
            //print("Landscape")
            
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
            //print("Portrait")
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
        
        
        let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.usage.woID!)
        
        workOrderViewController.tableCellID = indexPath?.row
        workOrderViewController.performanceDelegate = self
        
        navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
        
       // workOrderViewController.scheduleDelegate = self
        //workOrderViewController.scheduleIndex = indexPath?.row
        

    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    @objc func handleStartPicker()
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
    
    
    @objc func handleStopPicker()
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
        //print("reDraw List")
        self.usages[_index].woStatus = _status
        self.performanceTableView.reloadData()
    }

    
    
    
    @objc func goBack(){
        //print("go back")
        _ = navigationController!.popViewController(animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func canRotate() -> Void {}
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            //print("Landscape")
            self.layoutViewsLandscape()
        } else {
            //print("Portrait")
            self.layoutViewsPortrait()
            
        }
    }
    
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //print("view will transition")
        if (UIDevice.current.orientation.isLandscape == true) {
            //print("Landscape")
            self.layoutViewsLandscape()
        } else {
            //print("Portrait")
            self.layoutViewsPortrait()
        }
    }
    */
    
    
    
    
    
    
}
