//
//  PayrollViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView
 
import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class PayrollSummaryViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var empID:String!
    var empFirstName:String!
    var screenHeaderLbl: Label!
    
    var weekTxtField: PaddedTextField!
    var weekPicker: Picker!
    var weekArray = ["This Week","Last Week"]
    
    var payrollTableView: TableView!
    var payrollJSON: JSON!
    var payroll: [Payroll] = []
    var payrollTotalLbl: Label!
    let shortDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let tableHead:UIView! = UIView()
    let dateTH: THead = THead(text: "Date")
    let startTH: THead = THead(text: "Start")
    let stopTH: THead = THead(text: "Stop")
    let breakTH: THead = THead(text: "Break")
    let qtyTH: THead = THead(text: "Qty")
    
    var totalHours:String!
    var numberOfValidShifts: Int = 0
    
    var startDate:String!
    var endDate:String!
    var startDateDB:String!
    var endDateDB:String!
    
    var startOfRange:Date!
    
    var viewsLayedOut:Bool = false
    
    var totalPending:Bool = false

    
    
    init(_empID:String,_empFirstName:String){
        super.init(nibName:nil,bundle:nil)
        self.empID = _empID
        self.empFirstName = _empFirstName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "\(self.empFirstName!)'s Payroll"
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(PayrollSummaryViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        self.weekPicker = Picker()
        self.weekPicker.delegate = self
        self.weekPicker.dataSource = self
        self.weekPicker.tag = 1
        self.weekPicker.selectRow(0, inComponent: 0, animated: false)
        
        self.weekTxtField = PaddedTextField(textValue: weekArray[0])
        
        getPayroll()
        
    }
    
    
    func getPayroll(){
        //print("get payroll")
        
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        self.shortDateFormatter.dateFormat = "M/dd"
        self.timeFormatter.dateFormat = "h:mm a"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        self.weekTxtField.leftMargin = 0.0
        self.weekTxtField.text = weekArray[weekPicker.selectedRow(inComponent: 0)]
        
        if self.weekPicker.selectedRow(inComponent: 0) == 0{
            //this week
            startOfRange = Date().startOfWeek
            startDate = dateFormatter.string(from: Date().startOfWeek)
            endDate = dateFormatter.string(from: Date().endOfWeek)
            
            startDateDB = dateFormatterDB.string(from: Date().startOfWeek)
            endDateDB = dateFormatterDB.string(from: Date().endOfWeek)
            
        }else{
            //last week
            //print("last week")
            
            //print("startOfWeek = \(Date().startOfWeek)")
            //print("endOfWeek = \(Date().endOfWeek)")
            
            //print("startOfLastWeek = \(Date().startOfLastWeek)")
            //print("endOfLastWeek = \(Date().endOfLastWeek)")
            
            
            startOfRange = Date().startOfLastWeek
            startDate = dateFormatter.string(from: Date().startOfLastWeek)
            endDate = dateFormatter.string(from: Date().endOfLastWeek)
            startDateDB = dateFormatterDB.string(from: Date().startOfLastWeek)
            endDateDB = dateFormatterDB.string(from: Date().endOfLastWeek)
            
            
        }
        
       // print("start date = \(startDate)")
        //print("end date = \(endDate)")
        
        
        
        
        let parameters = ["endDate": endDateDB,"empID":self.empID] as [String : String]
        
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/payroll.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("payroll response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.payrollJSON = JSON(json)
                    self.parsePayrollJSON()
                    
                }
                
                self.indicator.dismissIndicator()
        }
    }
    
    func parsePayrollJSON(){
        
        
        //print("parse payrollJSON: \(self.payrollJSON)")
        
        self.payroll = []
        numberOfValidShifts = 0
        totalPending = false
        
        let payrollCount = self.payrollJSON["payroll"].count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
       // print("shift count = \(payrollCount)")
        
        
        
        for day in 0 ..< 7 {
            
            print("day = \(day)")
            if self.payrollJSON["payroll"]["\(day)"] != nil{
                
                let payrollShiftCount = self.payrollJSON["payroll"]["\(day)"].count
                
                print("payrollShiftCount = \(payrollShiftCount)")
                
                for i in 0 ..< payrollShiftCount {
                    
                    if self.payrollJSON["payroll"]["\(day)"][i]["dayType"].string! == "0" && self.payrollJSON["payroll"]["\(day)"][i]["startTime"].string != "No Time"{
                        
                        
                        print("startTime = \(self.payrollJSON["payroll"]["\(day)"][i]["startTime"].string!)")
                    
                    
                    
                    
                        
                    
                        let startTime = dateFormatter.date(from: self.payrollJSON["payroll"]["\(day)"][i]["startTime"].string!)!
                        
                        
                    
                    
                    
                    
                    
                        let stopTime:Date
                        var noStop:Bool = false
                        if self.payrollJSON["payroll"]["\(day)"][i]["stopTime"].string == "No Time"{
                            stopTime = startTime
                            //print("stopTime = nil")
                            noStop = true
                            
                        }else{
                            stopTime = dateFormatter.date(from: self.payrollJSON["payroll"]["\(day)"][i]["stopTime"].string!)!
                            print("stopTime = \(stopTime)")
                        }
                    
                    
                    
                    
                        let date = dateFormatter.date(from: "\(self.payrollJSON["payroll"]["\(day)"][i]["date"].string!) 00:00:00")!
                    
                    
                        let payroll:Payroll!
                    
                        payroll = Payroll(_ID: self.payrollJSON["payroll"]["\(day)"][i]["ID"].string!, _empID: self.payrollJSON["payroll"]["\(day)"][i]["empID"].string!, _startTime: startTime, _stopTime: stopTime, _lunch: self.payrollJSON["payroll"]["\(day)"][i]["lunch"].string!, _date: date, _total: self.payrollJSON["payroll"]["\(day)"][i]["total"].string!, _verified: self.payrollJSON["payroll"]["\(day)"][i]["verified"].string!, _appCreatedBy: self.payrollJSON["payroll"]["\(day)"][i]["appCreatedBy"].string!)
                        payroll.noStop = noStop
                    
                    
                    
                        self.payroll.append(payroll)
                        if Float(self.payrollJSON["payroll"]["\(day)"][i]["total"].string!)! > 0.0{
                            numberOfValidShifts += 1
                        }
                    
                        if self.payrollJSON["payroll"]["\(day)"][i]["verified"].string == "0"{
                            self.totalPending = true
                        }
                    }
                    
                    
                    
                }
                
                
            }else{
                print("payroll = nil")
                let startTime = startOfRange.addNumberOfDaysToDate(_numberOfDays: day)
                
                
                let payroll:Payroll!
                
                payroll = Payroll(_ID: "0", _empID: "0", _startTime: startTime, _stopTime: startTime, _lunch: "0", _date: startTime, _total: "0.00", _verified: "0", _appCreatedBy: appDelegate.loggedInEmployee?.ID)
                self.payroll.append(payroll)
                
            }
        }
        
        
        //print("payroll count \(self.payroll.count)")
        
        
        
        self.totalHours = self.payrollJSON["week"]["combinedTotal"].stringValue
        
        
        
        if (UIDevice.current.orientation.isLandscape == true) {
            //print("Landscape")
            //self.layoutViewsLandscape()
            
            if viewsLayedOut == false{
                self.layoutViewsLandscape()
            }else{
                self.payrollTableView.reloadData()
                if totalPending {
                    self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: Pending"
                }else{
                    self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: \(self.totalHours!)"
                }
            }
            
        } else {
            //print("Portrait")
            //self.layoutViewsPortrait()
            
            if viewsLayedOut == false{
                self.layoutViewsPortrait()
            }else{
                self.payrollTableView.reloadData()
                if totalPending {
                    self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: Pending"
                }else{
                    self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: \(self.totalHours!)"
                }
            }
            
        }
        
        
        
        
        
       
    }
    
    
    
    
    func layoutViewsPortrait(){
        //print("layoutViewsPortrait")
        
        viewsLayedOut = true
        
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
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "\(self.empFirstName!)'s payroll for:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.right
        self.view.addSubview(self.screenHeaderLbl)
        
        
        
        
        self.weekTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.weekTxtField.delegate = self
        self.weekTxtField.textAlignment = .center
        self.weekTxtField.inputView = weekPicker
        self.view.addSubview(self.weekTxtField)
        
        
        let weekToolBar = UIToolbar()
        weekToolBar.barStyle = UIBarStyle.default
        weekToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        weekToolBar.sizeToFit()
        let closeWeekButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PayrollSummaryViewController.cancelWeekInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let setWeekButton = BarButtonItem(title: "Set Week", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PayrollSummaryViewController.handleWeekChange))
        weekToolBar.setItems([closeWeekButton, spaceButton, setWeekButton], animated: false)
        weekToolBar.isUserInteractionEnabled = true
        weekTxtField.inputAccessoryView = weekToolBar
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableHead)
        
        self.payrollTableView =  TableView()
        self.payrollTableView.delegate  =  self
        self.payrollTableView.dataSource  =  self
        self.payrollTableView.register(PayrollSummaryTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.payrollTableView)
        
        self.payrollTotalLbl = Label()
        if totalPending {
            self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: Pending"
        }else{
            self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: \(self.totalHours!)"
        }
        
        self.payrollTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.payrollTotalLbl.textAlignment = NSTextAlignment.right
        self.view.addSubview(self.payrollTotalLbl)
        
        
        tableHead.addSubview(dateTH)
        tableHead.addSubview(startTH)
        tableHead.addSubview(stopTH)
        tableHead.addSubview(qtyTH)
        
        
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            "date":dateTH,
            "start":startTH,
            "stop":stopTH,
            "qty":qtyTH
            ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[date]-[start(72)]-[stop(72)]-[qty(55)]|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[start(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[stop(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[qty(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        let viewsDictionary = ["headerLbl": self.screenHeaderLbl,"weekTxt": self.weekTxtField, "th":self.tableHead,"table": self.payrollTableView,"total": self.payrollTotalLbl] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[headerLbl]-3-[weekTxt(120)]-|", options: [], metrics: metricsDictionary, views:viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[total]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[headerLbl(30)]-[th(40)][table]-[total(30)]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[weekTxt(30)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
    }
    
    
    
    func layoutViewsLandscape(){
        //print("layoutViewsLandscape")
        
        viewsLayedOut = true
        
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
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "\(self.empFirstName!)'s payroll for:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.screenHeaderLbl)
        
        
        
        
        self.weekTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.weekTxtField.delegate = self
        self.weekTxtField.textAlignment = .center
        self.weekTxtField.inputView = weekPicker
        safeContainer.addSubview(self.weekTxtField)
        
        
        let weekToolBar = UIToolbar()
        weekToolBar.barStyle = UIBarStyle.default
        weekToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        weekToolBar.sizeToFit()
        let closeWeekButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PayrollSummaryViewController.cancelWeekInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let setWeekButton = BarButtonItem(title: "Set Week", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PayrollSummaryViewController.handleWeekChange))
        weekToolBar.setItems([closeWeekButton, spaceButton, setWeekButton], animated: false)
        weekToolBar.isUserInteractionEnabled = true
        weekTxtField.inputAccessoryView = weekToolBar
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        safeContainer.addSubview(tableHead)
        
        self.payrollTableView =  TableView()
        self.payrollTableView.delegate  =  self
        self.payrollTableView.dataSource  =  self
        self.payrollTableView.register(PayrollSummaryTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.payrollTableView)
        
        self.payrollTotalLbl = Label()
        if totalPending {
            self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: Pending"
        }else{
            self.payrollTotalLbl.text = "Totals -  Payroll Shifts:\(self.numberOfValidShifts), Hours: \(self.totalHours!)"
        }
        
        self.payrollTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.payrollTotalLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.payrollTotalLbl)
        
        
        tableHead.addSubview(dateTH)
        tableHead.addSubview(startTH)
        tableHead.addSubview(stopTH)
        tableHead.addSubview(breakTH)
        tableHead.addSubview(qtyTH)
        
        
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            "date":dateTH,
            "start":startTH,
            "stop":stopTH,
            "break":breakTH,
            "qty":qtyTH
            ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[date]-[start(72)]-[stop(72)]-[break(72)]-[qty(55)]|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[start(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[stop(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[break(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[qty(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        let viewsDictionary = ["headerLbl": self.screenHeaderLbl,"weekTxt": self.weekTxtField, "th":self.tableHead,"table": self.payrollTableView,"total": self.payrollTotalLbl] as [String:Any]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[headerLbl]-3-[weekTxt(120)]-|", options: [], metrics: metricsDictionary, views:viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[total]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[headerLbl(30)]-[th(40)][table]-[total(30)]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[weekTxt(30)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
    }
    
    
    
    
    
    
    
    @objc func cancelWeekInput(){
        self.weekTxtField.resignFirstResponder()
    }
    
    @objc func handleWeekChange(){
        self.weekTxtField.resignFirstResponder()
        getPayroll()
    }
    
    
    //picker methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let count:Int = self.weekArray.count
        return count
        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return self.weekArray[row]
    }
    
    //func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // self.employeeValue = appDelegate.employeeArray[row].name
   // }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("payroll.count = \(payroll.count)")
        return self.payroll.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:PayrollSummaryTableViewCell = payrollTableView.dequeueReusableCell(withIdentifier: "cell") as! PayrollSummaryTableViewCell
        
        
        cell.payroll = payroll[indexPath.row]
        
        if (UIDevice.current.orientation.isLandscape == true) {
            //print("Landscape")
            cell.layoutViewsLandscape()
        } else {
            //print("Portrait")
            cell.layoutViewsPortrait()
        }
        
        
        
        
        let dayOfWeek:Int
        
        dayOfWeek = Calendar.current.component(.weekday, from: payroll[indexPath.row].startTime!)
        
        let trivialDayStringsORDINAL = ["", "SUN","MON","TUE","WED","THU","FRI","SAT"]
        
        cell.dateLbl.text = "\(self.shortDateFormatter.string(from: payroll[indexPath.row].startTime!)) (\(trivialDayStringsORDINAL[dayOfWeek]))"
        
        
        if (UIDevice.current.orientation.isLandscape == true) {
            //print("Landscape table")
            
            if payroll[indexPath.row].noStop == true{
                cell.startLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].startTime!)
                cell.stopLbl.text = "-----"
                cell.breakLbl.text =  payroll[indexPath.row].lunch!
                cell.totalLbl.text = "-----"
            }else{
                if payroll[indexPath.row].total == "0.00"{
                    cell.startLbl.text = "-----"
                    cell.stopLbl.text = "-----"
                    cell.breakLbl.text = "-----"
                    cell.totalLbl.text = "-----"
                    
                }else{
                    cell.startLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].startTime!)
                    cell.stopLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].stopTime!)
                    cell.breakLbl.text =  payroll[indexPath.row].lunch!
                    cell.totalLbl.text = "\(payroll[indexPath.row].total!)"
                }
            }
            
            
            /*
            if payroll[indexPath.row].total == "0.00"{
                cell.startLbl.text = "-----"
                cell.stopLbl.text = "-----"
                cell.breakLbl.text = "-----"
                cell.totalLbl.text = "-----"
            }else{
                if payroll[indexPath.row].startTime == payroll[indexPath.row].stopTime{
                    cell.startLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].startTime!)
                    cell.stopLbl.text = "-----"
                    cell.breakLbl.text =  payroll[indexPath.row].lunch!
                    cell.totalLbl.text = "-----"
                }else{
                    cell.startLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].startTime!)
                    cell.stopLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].stopTime!)
                    cell.breakLbl.text =  payroll[indexPath.row].lunch!
                    cell.totalLbl.text = "\(payroll[indexPath.row].total!)"
                }
                
            }
 */
            
        } else {
            //print("Portrait table")
            //if payroll[indexPath.row].total == "0.00"{
               // cell.startLbl.text = "-----"
                //cell.stopLbl.text = "-----"
               // cell.totalLbl.text = "-----"
           // }else{
                if payroll[indexPath.row].noStop == true{
                   cell.startLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].startTime!)
                    cell.stopLbl.text = "-----"
                    cell.totalLbl.text = "-----"
                }else{
                    if payroll[indexPath.row].total == "0.00"{
                        cell.startLbl.text = "-----"
                        cell.stopLbl.text = "-----"
                        cell.totalLbl.text = "-----"
                    }else{
                        cell.startLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].startTime!)
                        cell.stopLbl.text = self.timeFormatter.string(from: payroll[indexPath.row].stopTime!)
                        cell.totalLbl.text = "\(payroll[indexPath.row].total!)"
                    }
                }
                
           // }
        }
        
        
        
        
        
        
        return cell;
    }
    
    
    @objc func goBack(){
        //print("back")
        _ = navigationController?.popViewController(animated: false)
    }
    
    
    func canRotate() -> Void {}
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if (UIDevice.current.orientation.isLandscape == true) {
            //print("Landscape")
            self.layoutViewsLandscape()
        } else {
            //print("Portrait")
            self.layoutViewsPortrait()
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


