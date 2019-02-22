//
//  PayrollEntryViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/21/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView
 
import Foundation
import UIKit
import Alamofire
import SwiftyJSON




protocol PayrollDelegate{
    func editStart(row:Int,start:Date)
    func editStop(row:Int,stop:Date)
    func editBreak(row:Int,lunch:Int)
    func resetShift(row: Int)
}





class PayrollEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PayrollDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    //var empID:String!
    var empFirstName:String!
    var screenHeaderLbl: Label!
    
    var employeeTxtField: PaddedTextField!
    var employeePicker: Picker!
    
    var employee:Employee!
    var employeeID:String!
    var employeeValue:String!
    var employeeCode:String!
    
    
    var payrollTableView: TableView!
    var payrollJSON: JSON?
    var payroll: [Payroll] = []
    
    
    
    var payrollTotalLbl: Label = Label()
    let dateFormatter = DateFormatter()
    let dateFormatterDB = DateFormatter()
    let timeFormatterDisplay = DateFormatter()
    let timeFormatterDB = DateFormatter()
    
   
    
    var totalHours:Float = 0.0
    var numberOfValidShifts: Int = 0
    
    
    var date:String!
    var dateDB:String!
    
    var tableCellCounter: Int = 0 //counter var to set table cells to either start or stop style
    var payrollArrayCounter: Int = 0 //counter var to set table cells to either start or stop style
    var viewsLayedOut:Bool = false
    
    init(_employee:Employee){
        super.init(nibName:nil,bundle:nil)
        self.employee = _employee
        //self.empID = self.employee.ID
        
        //print("payroll entry view init ID = \(self.employee.ID!)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Payroll Entry"
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(PayrollEntryViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
        
        
        let summaryButton:UIBarButtonItem = UIBarButtonItem(title: "Summary", style: .plain, target: self, action: #selector(PayrollEntryViewController.displayPayrollSummary))
        navigationItem.rightBarButtonItem = summaryButton

        
        
        self.timeFormatterDisplay.dateFormat = "h:mm a"
        self.timeFormatterDB.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.dateFormatter.dateFormat = "MM-dd-yy"
        self.dateFormatterDB.dateFormat = "yyyy-MM-dd"
       
        
        
        
        getPayroll()
        
    }
    
    
    func getPayroll(){
        //print("get payroll")
        
        
        
        indicator = SDevIndicator.generate(self.view)!
        
       
        
        let endDateDB = dateFormatterDB.string(from: Date().endOfWeek)
       
    
        let parameters:[String:String]
            parameters = ["endDate": endDateDB,"empID":self.employee.ID]
        
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
                    
                    //error handling
                    if (self.payrollJSON!["errorArray"][0]["error"].stringValue.count) > 0{
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Error", _message: self.payrollJSON!["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                    
                    
                    self.parsePayrollJSON()
                    
                }
                
                self.indicator.dismissIndicator()
        }
    }
    
    func parsePayrollJSON(){
        
        
       // //print("parse payrollJSON: \(self.payrollJSON)")
        
        self.payroll = []
        numberOfValidShifts = 0
        self.totalHours = 0.0
        
       // let payrollCount = self.payrollJSON!["payroll"].count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        ////print("shift count = \(payrollCount)")
        
        
        let dayOfWeek = layoutVars.getDayOfWeek(self.dateFormatterDB.string(from: Date()))!
        
        //print("dayOfWeek = \(String(describing: dayOfWeek))")
        
        
        for day in 0 ..< 7 {
            
            //print("day = \(day)")
            if dayOfWeek == day{
                
                
                let i = 0
                
                
                if self.payrollJSON?["payroll"]["\(day)"][i]["date"].string != nil{
                    
                    // following code for multiple shifts
                    
                  
                    
                    let date = dateFormatter.date(from: "\( self.payrollJSON!["payroll"]["\(day)"][i]["date"].string!) 00:00:00")!
                    
                    
                   
                    let payroll:Payroll!
                    
                    payroll = Payroll(_ID: self.payrollJSON!["payroll"]["\(day)"][i]["ID"].string!, _empID: self.payrollJSON!["payroll"]["\(day)"][i]["empID"].string!, _lunch: self.payrollJSON!["payroll"]["\(day)"][i]["lunch"].string!, _date: date, _total: self.payrollJSON!["payroll"]["\(day)"][i]["total"].string!, _verified: self.payrollJSON!["payroll"]["\(day)"][i]["verified"].string!, _appCreatedBy: self.payrollJSON!["payroll"]["\(day)"][i]["appCreatedBy"].string!)
                    
                    
                    
                    var startTime:Date!
                    var stopTime:Date!
                    if self.payrollJSON!["payroll"]["\(day)"][i]["startTime"].string != "No Time"{
                        startTime = dateFormatter.date(from: (self.payrollJSON!["payroll"]["\(day)"][i]["startTime"].string!))!
                        //print("startTime = \(startTime)")
                        payroll.startTime = startTime
                    }
                    if self.payrollJSON!["payroll"]["\(day)"][i]["stopTime"].string! != "No Time"{
                        stopTime = dateFormatter.date(from: (self.payrollJSON!["payroll"]["\(day)"][i]["stopTime"].string!))!
                        //print("stopime = \(stopTime)")
                        payroll.stopTime = stopTime
                    }
                    
                        
                    
                        
                    
                    
                    
                        
                        
                        self.payroll.append(payroll)
                   // var payrollTotal:String = (self.payrollJSON!["payroll"]["\(day)"][i]["total"].string!)!
                    if Float((self.payrollJSON!["payroll"]["\(day)"][i]["total"].floatValue)) > 0.0{
                            numberOfValidShifts += 1
                            
                        self.totalHours += Float((self.payrollJSON!["payroll"]["\(day)"][i]["total"].floatValue))
                        }
                    //}
                    
                    
                }else{
                    //shifts for day do not exist, create a blank one
                    //print("payroll = nil")
                    
                    
                    
                    let payroll:Payroll!
                    
                    payroll = Payroll(_ID: "0", _empID: "0", _startTime: nil, _stopTime: nil, _lunch: "0", _date: nil, _total: "0.00", _verified: "0", _appCreatedBy: self.appDelegate.loggedInEmployee?.ID)
                    self.payroll.append(payroll)
                    
                }
            }
            
        }
        
        
        //print("payroll count \(self.payroll.count)")
        if self.payrollJSON!["week"]["pending"].stringValue == "1"{
            self.payrollTotalLbl.text = "Today's total hours: Pending"
        }else{
            self.payrollTotalLbl.text = "Today's total hours: \(self.totalHours)"
        }
        
        //self.totalHours = "Need This Still"
        if viewsLayedOut == false{
            self.layoutViews()
        }else{
            tableCellCounter = 0
            payrollArrayCounter = 0
            self.payrollTableView.reloadData()
        }
    }
    
    
    
    
    func layoutViews(){
        //print("layoutViews")
        
        
        viewsLayedOut = true
        
        for view in self.view.subviews{
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
        self.screenHeaderLbl.text = "Today's payroll for:"
        self.screenHeaderLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.screenHeaderLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.screenHeaderLbl)
        
        
        
        //employee picker
        self.employeePicker = Picker()
        self.employeePicker.delegate = self
        self.employeePicker.dataSource = self
        self.employeeTxtField = PaddedTextField()
        self.employeeTxtField.leftMargin = 0.0
        self.employeeTxtField.text = self.employee.name
        self.employeeTxtField.textAlignment = NSTextAlignment.center
        self.employeeTxtField.tag = 1
        self.employeeTxtField.delegate = self
        
        self.employeeTxtField.tintColor = UIColor.clear
        self.employeeTxtField.inputView = employeePicker
        safeContainer.addSubview(self.employeeTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PayrollEntryViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let selectButton = UIBarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PayrollEntryViewController.selectEmployee))
        
        toolBar.setItems([closeButton, spaceButton, selectButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        employeeTxtField.inputAccessoryView = toolBar
        
        self.payrollTableView =  TableView()
        self.payrollTableView.layer.cornerRadius = 0
        self.payrollTableView.delegate  =  self
        self.payrollTableView.dataSource  =  self
        self.payrollTableView.rowHeight = 60
        self.payrollTableView.isScrollEnabled = false
        self.payrollTableView.register(PayrollEntryTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.payrollTableView)
        
    
        //self.payrollTotalLbl = Label()
        //self.payrollTotalLbl.text = "Total hours: \(self.totalHours!)"
        self.payrollTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.payrollTotalLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.payrollTotalLbl)
        
        
        
        let viewsDictionary = ["headerLbl": self.screenHeaderLbl,"empTxt": self.employeeTxtField, "table": self.payrollTableView,"total": self.payrollTotalLbl] as [String:Any]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[headerLbl]-3-[empTxt(160)]-|", options: [], metrics: nil, views:viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: nil, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[total]-15-|", options: [], metrics: nil, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerLbl(30)]-[table]-[total(30)]-15-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[empTxt(30)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    @objc func cancelPicker(){
        self.employeeTxtField.resignFirstResponder()
    }
    
    @objc func selectEmployee(){
        //print("selectEmployee")
        self.employeeTxtField.resignFirstResponder()
        
        let row = employeePicker.selectedRow(inComponent: 0)
        
        self.employee = appDelegate.employeeArray[row]
        //self.empID = appDelegate.employeeArray[row].ID!
        
        self.employeeTxtField.text = appDelegate.employeeArray[row].name!
        
        
        getPayroll()
    }
    
   @objc func displayPayrollSummary(){
        //print("display Summary View")
        let payrollSummaryViewController = PayrollSummaryViewController(_empID: self.employee.ID, _empFirstName: self.employee.fname!)
        navigationController?.pushViewController(payrollSummaryViewController, animated: false )
    }
    
    //picker methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return pickerData.count
        //print("picker count = \(self.weekArray.count)")
        
        return appDelegate.employeeArray.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return pickerData[row]
       // print("picker title = \(self.weekArray[row])")
        return appDelegate.employeeArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.employeeValue = appDelegate.employeeArray[row].name
    }
    
    
    /*
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("numberOfComponents = \(appDelegate.employeeArray.count + 1)")
        
        return appDelegate.employeeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
 
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appDelegate.employeeArray[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.employeeValue = appDelegate.employeeArray[row].name
        
    }
    
    */
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("payroll.count = \(payroll.count)")
        //var count:Int = 0
        //if self.payroll.count >= 2{
           // count = self.payroll.count * 3 //no add button
        //}else{
            //count = 4 //start, stop, break and add
        //}
        
        //print("count = \((self.payroll.count * 3) + 1)")
        return (self.payroll.count * 3) + 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print("payroll.count = \(payroll.count)")
        //print("indexPath.row = \(indexPath.row)")
        //print("tableCellCounter = \(tableCellCounter)")
        //print("payrollArrayCounter = \(payrollArrayCounter)")
        let cell:PayrollEntryTableViewCell = payrollTableView.dequeueReusableCell(withIdentifier: "cell") as! PayrollEntryTableViewCell
        
       /* if indexPath.row == (self.payroll.count * 3){
            cell.layoutAddViews()
        }else{*/
            
            switch (tableCellCounter) {
            case 0:
                cell.payroll = payroll[payrollArrayCounter]
                cell.layoutStartViews()
                if payroll[payrollArrayCounter].startTime != nil{
                    cell.startTxtField.text =   self.timeFormatterDisplay.string(from: payroll[payrollArrayCounter].startTime)
                }
                tableCellCounter += 1
                break;
            case 1:
                cell.payroll = payroll[payrollArrayCounter]
                cell.layoutStopViews()
                if payroll[payrollArrayCounter].stopTime != nil{
                    cell.stopTxtField.text =   self.timeFormatterDisplay.string(from: payroll[payrollArrayCounter].stopTime)
                }
                tableCellCounter += 1
                break;
            case 2:
                cell.payroll = payroll[payrollArrayCounter]
                cell.layoutBreakViews()
                if payroll[payrollArrayCounter].lunch != nil{
                    cell.breakTxtField.text =    payroll[payrollArrayCounter].lunch
                }
                tableCellCounter += 1
                break;
            case 3:
                cell.payroll = payroll[payrollArrayCounter]
                cell.layoutResetViews()
                //if payroll[payrollArrayCounter].lunch != nil{
                    //cell.breakTxtField.text =    payroll[payrollArrayCounter].lunch
               // }
                tableCellCounter = 0
                payrollArrayCounter += 1
                break;
            default:
                //print("default in switch statement")
                break;
            }
            
       
        
        cell.delegate = self
        cell.parentVC = self
        cell.row = indexPath.row
        
        return cell;
    }
    
    
    
    func editStart(row:Int,start:Date){
        
        //need userLevel greater then 1 to access this
        
        
        //print("row = \(row)")
        //print("edit start \(start)")
        
        //print("start for \(row) =  \(payroll[row].startTime)")
        //print("stop for \(row) =  \(payroll[row].stopTime)")
        //print("break for \(row) =  \(payroll[row].lunch)")
        
        
        let startIndexPath = IndexPath(row: row, section: 0)
        let stopIndexPath = IndexPath(row: row + 1, section: 0)
        let breakIndexPath = IndexPath(row: row + 2, section: 0)
        /*
        let startCell = payrollTableView.cellForRow(at: startIndexPath) as! PayrollEntryTableViewCell!
        let stopCell = payrollTableView.cellForRow(at: stopIndexPath) as! PayrollEntryTableViewCell!
        let breakCell = payrollTableView.cellForRow(at: breakIndexPath) as! PayrollEntryTableViewCell!
 */
        
        let startCell:PayrollEntryTableViewCell = payrollTableView.cellForRow(at: startIndexPath) as! PayrollEntryTableViewCell
        let stopCell:PayrollEntryTableViewCell = payrollTableView.cellForRow(at: stopIndexPath) as! PayrollEntryTableViewCell
        let breakCell:PayrollEntryTableViewCell = payrollTableView.cellForRow(at: breakIndexPath) as! PayrollEntryTableViewCell
        
        
        startCell.startTxtField.reset()
        stopCell.stopTxtField.reset()
        breakCell.breakTxtField.reset()
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            startCell.startTxtField.text = ""
            return
        }
        
        //if row < 3{
        
            // make sure there is a stop time
            if payroll[row].stopTime != nil{
                
                //check for start greater then stop
                if start  >  payroll[row].stopTime{
                    //start is after stop
                    
                    startCell.startTxtField.error()
                    stopCell.stopTxtField.error()
                    
                    self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Start time can not be later then stop time.")
                    
                    
                    return
                }
                
                // check if break time is greater then qty
                let qtySeconds = payroll[row].stopTime.timeIntervalSince(start)
                //print("qtySeconds = \(qtySeconds)")
                var breakTime = 0.0
                if payroll[row].lunch != "" && payroll[row].lunch != "0"{
                    breakTime = Double(payroll[row].lunch)! * 60
                    if(breakTime >= qtySeconds){
                        
                        startCell.startTxtField.error()
                        breakCell.breakTxtField.error()
                        
                        payroll[row].lunch = "0"
                        breakTime = 0.0
                        
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Break time can not be equal or greater then total shift time.")
                        return
                    }
                }
                
                
            }
            
            
        //payrollToLog.empID = self.empID
       // payrollToLog.startTime = start
        payroll[row].startTime = start
        //payrollTableView.reloadData()
        submitPayroll()
        
            
            
            
            
            
                
           /*
        }else{
            //second shift entry
            
            print("start for \(row - 2) =  \(payroll[row - 2].startTime)")
            print("stop for \(row - 2) =  \(payroll[row - 2].stopTime)")
            print("break for \(row - 2) =  \(payroll[row - 2].lunch)")
            
            
            
            // make sure there is a stop time
            if payroll[row - 2].stopTime != nil{
                
                //check for start greater then stop
                if start  >=  payroll[row - 2].stopTime{
                    //start is after stop
                    
                    cell?.startTxtField.error()
                    
                    simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Start time can not be later then  stop time.")
                    
                    
                    return
                }
                
                // check if break time is greater then qty
                let qtySeconds = payroll[row - 2].stopTime.timeIntervalSince(start)
                print("qtySeconds = \(qtySeconds)")
                var breakTime = 0.0
                if payroll[row - 2].lunch != "" && payroll[row - 2].lunch != "0"{
                    breakTime = Double(payroll[row - 2].lunch)! * 60
                    if(breakTime >= qtySeconds){
                        
                        cell?.startTxtField.error()
                        
                        payroll[row - 2].lunch = "0"
                        breakTime = 0.0
                        
                        simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Break time can not be equal or greater then total shift time.")
                        
                    }
                }
                
                
            }
            
            //check to see if second shift start lands before start or stop of first shift
            if start  <=  payroll[row - 2].startTime || start  <=  payroll[row - 2].stopTime{
                cell?.startTxtField.error()
                
                simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Second shift start time can not be before or within first shift.")
                
                
                return
                
            }
            
            
            
            
        }*/
        
        
       // if(usageStop!  < Date()){
        
    }
    
    func editStop(row:Int,stop:Date){
        
       
        
        //print("row = \(row)")
        //print("edit stop \(stop)")
        //print("start for \(row - 1) =  \(payroll[row - 1].startTime)")
        //print("stop for \(row - 1 ) =  \(payroll[row - 1].stopTime)")
        //print("break for \(row - 1) =  \(payroll[row - 1].lunch)")
        
        
        let startIndexPath = IndexPath(row: row - 1, section: 0)
        let stopIndexPath = IndexPath(row: row, section: 0)
        let breakIndexPath = IndexPath(row: row + 1, section: 0)
        let startCell:PayrollEntryTableViewCell = payrollTableView.cellForRow(at: startIndexPath) as! PayrollEntryTableViewCell
        let stopCell:PayrollEntryTableViewCell = payrollTableView.cellForRow(at: stopIndexPath) as! PayrollEntryTableViewCell
        let breakCell:PayrollEntryTableViewCell = payrollTableView.cellForRow(at: breakIndexPath) as! PayrollEntryTableViewCell
        startCell.startTxtField.reset()
        stopCell.stopTxtField.reset()
        breakCell.breakTxtField.reset()
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            stopCell.stopTxtField.text = ""
            return
        }
        
        //if row < 3{
        
        // make sure there is a stop time
        if payroll[row - 1].startTime != nil{
            
            //check for start greater then stop
            if stop  <  payroll[row - 1].startTime{
                //start is after stop
                
                startCell.startTxtField.error()
                stopCell.stopTxtField.error()
                
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Stop time can not be before the start time.")
                
                return
            }
            
            // check if break time is greater then qty
            let qtySeconds = stop.timeIntervalSince(payroll[row - 1].startTime)
            //print("qtySeconds = \(qtySeconds)")
            var breakTime = 0.0
            if payroll[row - 1].lunch != "" && payroll[row - 1].lunch != "0"{
                breakTime = Double(payroll[row - 1].lunch)! * 60
                if(breakTime >= qtySeconds){
                    
                    stopCell.stopTxtField.error()
                    breakCell.breakTxtField.error()
                    
                    payroll[row - 1].lunch = "0"
                    breakTime = 0.0
                    
                    self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Break time can not be equal or greater then total shift time.")
                    return
                }
            }
            
            
        }
        
        
        //payrollToLog.empID = self.empID
        //payrollToLog.stopTime = stop
        payroll[row - 1].stopTime = stop
       // payrollTableView.reloadData()
        submitPayroll()
        
        
        
        
        
    }
    
    func editBreak(row: Int, lunch: Int) {
        
        
        
        
        
        //print("row = \(row)")
        //print("edit break \(lunch)")
       // print("start for \(row - 2) =  \(String(describing: payroll[row - 2].startTime))")
       // print("stop for \(row - 2 ) =  \(payroll[row - 2].stopTime)")
       // print("break for \(row - 2) =  \(payroll[row - 2].lunch)")
        
        
        let startIndexPath = IndexPath(row: row - 2, section: 0)
        let stopIndexPath = IndexPath(row: row - 1, section: 0)
        let breakIndexPath = IndexPath(row: row, section: 0)
        let startCell = payrollTableView.cellForRow(at: startIndexPath) as! PayrollEntryTableViewCell
        let stopCell = payrollTableView.cellForRow(at: stopIndexPath) as! PayrollEntryTableViewCell
        let breakCell = payrollTableView.cellForRow(at: breakIndexPath) as! PayrollEntryTableViewCell
        startCell.startTxtField.reset()
        stopCell.stopTxtField.reset()
        breakCell.breakTxtField.reset()
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            breakCell.breakTxtField.text = "0"
            return
        }
        
        
        
        //if row < 3{
        
        // make sure there is a stop time
        if payroll[row - 2].startTime != nil && payroll[row - 2].stopTime != nil{
            
            
            
            // check if break time is greater then qty
            let qtySeconds = payroll[row - 2].stopTime.timeIntervalSince(payroll[row - 2].startTime)
            //print("qtySeconds = \(qtySeconds)")
            var breakTime = 0.0
            
            if lunch != 0{
                breakTime = Double(lunch) * 60
                if(breakTime >= qtySeconds){
                    
                    
                    breakCell.breakTxtField.error()
                    
                    payroll[row - 2].lunch = "0"
                    breakTime = 0.0
                    
                    self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "Break time can not be equal or greater then total shift time.")
                    return
                }
            }
            
            
        }
        
        
        //payrollToLog.empID = self.empID
        //payrollToLog.lunch = "\(lunch)"
        payroll[row - 2].lunch = "\(lunch)"
        // payrollTableView.reloadData()
        submitPayroll()
       
    }
    
    func resetShift(row: Int){
        //print("resetShift")

        //print("row = \(row)")
        //print("start for \(row - 3) =  \(String(describing: payroll[row - 3].startTime))")
        //print("stop for \(row - 3 ) =  \(String(describing: payroll[row - 3].stopTime))")
        //print("break for \(row - 3) =  \(String(describing: payroll[row - 3].lunch))")
        
        
        let startIndexPath = IndexPath(row: row - 3, section: 0)
        let stopIndexPath = IndexPath(row: row - 2, section: 0)
        let breakIndexPath = IndexPath(row: row - 1, section: 0)
        let startCell = payrollTableView.cellForRow(at: startIndexPath) as! PayrollEntryTableViewCell
        let stopCell = payrollTableView.cellForRow(at: stopIndexPath) as! PayrollEntryTableViewCell
        let breakCell = payrollTableView.cellForRow(at: breakIndexPath) as! PayrollEntryTableViewCell
        startCell.startTxtField.reset()
        stopCell.stopTxtField.reset()
        breakCell.breakTxtField.reset()
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        startCell.startTxtField.text = ""
        stopCell.stopTxtField.text = ""
        breakCell.breakTxtField.text = "0"
        
        payroll[row - 3].del = "1"
        
        
        submitPayroll()
    }
    
    func submitPayroll(){
        //print("submitPayroll")
        
        
        
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        
        let todaysDate = dateFormatterDB.string(from: Date())
        var start:String = ""
        if self.payroll[0].startTime != nil{
            start  = "\(timeFormatterDB.string(from:self.payroll[0].startTime!))"
        }
        var stop:String = ""
        if self.payroll[0].stopTime != nil{
            stop  = "\(timeFormatterDB.string(from:self.payroll[0].stopTime!))"
        }
        var lunch:String = "0"
        if self.payroll[0].lunch != nil{
            lunch  = "\(self.payroll[0].lunch!))"
        }
        var del:String = "0"
        if self.payroll[0].del != nil{
            del  = "\(self.payroll[0].del!)"
        }
        
        let parameters:[String:String]
        parameters = ["ID": self.payroll[0].ID, "appCreatedBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), "empID": self.employee.ID, "startTime": start, "stopTime": stop, "lunch": lunch, "date": todaysDate, "del": del] as! [String : String]
        
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/payroll.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("payroll response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    let returnJson = JSON(json)
                    
                    if returnJson["errorArray"][0]["error"].stringValue.count > 0{
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Error with Save", _message: returnJson["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                    
                    
                    
                    //print("del = \(del)")
                    if del == "1" {
                        let payroll:Payroll!
                        
                        payroll = Payroll(_ID: "0", _empID: "0", _startTime: nil, _stopTime: nil, _lunch: "0", _date: nil, _total: "0.00", _verified: "0", _appCreatedBy: self.appDelegate.loggedInEmployee?.ID)
                        self.payroll.append(payroll)
                    }else{
                        
                    
                        self.payroll = []
                        
                        
                        
                        let date = self.timeFormatterDB.date(from: "\(returnJson["shift"]["date"].string!) 00:00:00")!
                        
                        
                        //print("date = \(date)")
                        //print("ID = \(returnJson["shift"]["ID"].string!)")
                        //print("empID = \(returnJson["shift"]["empID"].string!)")
                        //print("lunch = \(returnJson["shift"]["lunch"].string!)")
                        //print("total = \(returnJson["shift"]["total"].string!)")
                        //print("verified = \(returnJson["shift"]["verified"].string!)")
                        //print("appCreatedBy = \(returnJson["shift"]["appCreatedBy"].string!)")
                        
                        
                        let payroll:Payroll!
                        
                        
                        
                         payroll = Payroll(_ID: returnJson["shift"]["ID"].string!, _empID: returnJson["shift"]["empID"].string!, _lunch: returnJson["shift"]["lunch"].string!, _date: date, _total: returnJson["shift"]["total"].string!, _verified: returnJson["shift"]["verified"].string!, _appCreatedBy: returnJson["shift"]["appCreatedBy"].string!)
                        
                        
                        if returnJson["shift"]["startTime"].string! != "No Time"{
                            let startTime = self.timeFormatterDB.date(from: returnJson["shift"]["startTime"].string!)!
                            //print("startTime = \(startTime)")
                            
                            payroll.startTime = startTime
                        }
                        if returnJson["shift"]["stopTime"].string! != "No Time"{
                            let stopTime = self.timeFormatterDB.date(from: returnJson["shift"]["stopTime"].string!)!
                            //print("stopime = \(stopTime)")
                            payroll.stopTime = stopTime
                        }
                        
                        
                        
                        self.numberOfValidShifts = 0
                        self.totalHours = 0.0
                        
                        self.payroll.append(payroll)
                        
                      
                        
                        
                        if returnJson["shift"]["verified"].string! == "0"{
                            self.payrollTotalLbl.text = "Today's total hours: Pending"
                        }else{
                            self.payrollTotalLbl.text = "Today's total hours: \(Float(returnJson["shift"]["total"].floatValue))"
                        }
                    
                    }
                    
                    self.indicator.dismissIndicator()
                    
                    
                }
                
        }
        
        
        
        
        
        
        
    }
    
    
    
    
    @objc func goBack(){
        //print("back")
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}



