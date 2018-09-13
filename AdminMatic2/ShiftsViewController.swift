//
//  ShiftsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/18/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class ShiftsViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var empID:String!
    var empFirstName:String!
    var screenHeaderLbl: Label!
    
    var weekTxtField: PaddedTextField!
    var weekPicker: Picker!
    var weekArray = ["This Week","Next Week"]
    
    var shiftsTableView: TableView!
    var shiftsJSON: JSON!
    var shifts: [Shift] = []
    var shiftsTotalLbl: Label!
    let shortDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let tableHead:UIView! = UIView()
    let dateTH: THead = THead(text: "Date")
    let startTH: THead = THead(text: "Start")
    let stopTH: THead = THead(text: "Stop")
    let qtyTH: THead = THead(text: "Qty")

    var totalHours:String!
    var numberOfValidShifts: Int = 0

    var startDate:String!
    var endDate:String!
    var startDateDB:String!
    var endDateDB:String!
    
    var startOfRange:Date!
    
    
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
        title = "\(self.empFirstName!)'s Shifts"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ShiftsViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.weekPicker = Picker()
        self.weekPicker.delegate = self
        self.weekPicker.tag = 2
        self.weekPicker.selectRow(0, inComponent: 0, animated: false)
        
        self.weekTxtField = PaddedTextField(textValue: weekArray[0])
        
        getShifts()
        
    }
    

    func getShifts(){
        print("get shifts")
        
        
        
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
            //next
            print("next week")
            
            print("startOfWeek = \(Date().startOfWeek)")
            print("endOfWeek = \(Date().endOfWeek)")
            
            print("startOfNextWeek = \(Date().startOfNextWeek)")
            print("endOfNextWeek = \(Date().endOfNextWeek)")
            
            
            startOfRange = Date().startOfNextWeek
            startDate = dateFormatter.string(from: Date().startOfNextWeek)
            endDate = dateFormatter.string(from: Date().endOfNextWeek)
            startDateDB = dateFormatterDB.string(from: Date().startOfNextWeek)
            endDateDB = dateFormatterDB.string(from: Date().endOfNextWeek)
            
            
        }
        
        print("start date = \(startDate)")
        print("end date = \(endDate)")

        
        
        
        let parameters:[String:String]
            parameters = ["startDate":  startDateDB,"endDate": endDateDB,"empID":self.empID]
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/shifts.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("shifts response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.shiftsJSON = JSON(json)
                    self.parseShiftsJSON()
                    
                }
                
                self.indicator.dismissIndicator()
        }
    }
    
    func parseShiftsJSON(){
        
        
        print("parse shiftsJSON: \(self.shiftsJSON)")
        
        self.shifts = []
        numberOfValidShifts = 0
        
        let shiftsCount = self.shiftsJSON["shifts"].count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        print("shift count = \(shiftsCount)")
            
            for day in 0 ..< 7 {
                
            print("day = \(day)")
                if self.shiftsJSON["shifts"]["\(day)"] != nil{
                
                print("startTime = \(self.shiftsJSON["shifts"]["\(day)"]["startTime"].string!)")
                

                let startTime = dateFormatter.date(from: self.shiftsJSON["shifts"]["\(day)"]["startTime"].string!)!
                
                let stopTime = dateFormatter.date(from: self.shiftsJSON["shifts"]["\(day)"]["endTime"].string!)!
                
                
                let shift:Shift!
            
                shift = Shift(_ID: self.shiftsJSON["shifts"]["\(day)"]["ID"].string!, _empID: self.shiftsJSON["shifts"]["\(day)"]["empID"].string!, _startTime: startTime, _stopTime: stopTime, _status: self.shiftsJSON["shifts"]["\(day)"]["status"].string!, _comment: self.shiftsJSON["shifts"]["\(day)"]["comment"].string!, _qty: self.shiftsJSON["shifts"]["\(day)"]["shiftQty"].string!)
                
                
                self.shifts.append(shift)
                    if Float(self.shiftsJSON["shifts"]["\(day)"]["shiftQty"].string!)! > 0.0{
                        numberOfValidShifts += 1
                    }
                
                
            }else{
                print("shift = nil")
                let startTime = startOfRange.addNumberOfDaysToDate(_numberOfDays: day)
                
                let stopTime = startOfRange.addNumberOfDaysToDate(_numberOfDays: day)
                
                let shift:Shift!
                
                shift = Shift(_ID: "0", _empID: "0", _startTime: startTime, _stopTime: stopTime, _status: "0", _comment:"", _qty: "0.00")
                self.shifts.append(shift)
                
            }
        }
        
        
        print("shift count \(self.shifts.count)")
        
        self.totalHours = self.shiftsJSON["shiftTotalHrs"].stringValue
        
        self.layoutViews()
        
        self.shiftsTableView.reloadData()
    }
    
    
    
    
    func layoutViews(){
        print("layoutViews")
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        for view in self.tableHead.subviews{
            view.removeFromSuperview()
        }
        
        self.screenHeaderLbl = Label()
        self.screenHeaderLbl.text = "\(self.empFirstName!)'s shifts for:"
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
        let closeWeekButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ShiftsViewController.cancelWeekInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        let setWeekButton = UIBarButtonItem(title: "Set Week", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ShiftsViewController.handleWeekChange))
        weekToolBar.setItems([closeWeekButton, spaceButton, setWeekButton], animated: false)
        weekToolBar.isUserInteractionEnabled = true
        weekTxtField.inputAccessoryView = weekToolBar
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableHead)
        
        self.shiftsTableView =  TableView()
        self.shiftsTableView.delegate  =  self
        self.shiftsTableView.dataSource  =  self
        self.shiftsTableView.register(ShiftTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.shiftsTableView)
        
        self.shiftsTotalLbl = Label()
        self.shiftsTotalLbl.text = "Totals -  Shifts:\(self.numberOfValidShifts), Hours: \(self.totalHours!)"
        self.shiftsTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.shiftsTotalLbl.textAlignment = NSTextAlignment.right
        self.view.addSubview(self.shiftsTotalLbl)
        
        
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
        
        
        let viewsDictionary = ["headerLbl": self.screenHeaderLbl,"weekTxt": self.weekTxtField, "th":self.tableHead,"table": self.shiftsTableView,"total": self.shiftsTotalLbl] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[headerLbl]-3-[weekTxt(120)]-|", options: [], metrics: metricsDictionary, views:viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[total]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[headerLbl(30)]-[th(40)][table]-[total(30)]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[weekTxt(30)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
    }
    

    @objc func cancelWeekInput(){
        self.weekTxtField.resignFirstResponder()
    }
    
    @objc func handleWeekChange(){
        self.weekTxtField.resignFirstResponder()
        getShifts()
    }
    
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        let count:Int = self.weekArray.count
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.weekArray[row]
    }
   
    /*
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        getShifts()
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("shifts.count = \(shifts.count)")
        return self.shifts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:ShiftTableViewCell = shiftsTableView.dequeueReusableCell(withIdentifier: "cell") as! ShiftTableViewCell
        
    
        cell.shift = shifts[indexPath.row]
        cell.layoutViews()
        
        let dayOfWeek:Int
        
        dayOfWeek = Calendar.current.component(.weekday, from: shifts[indexPath.row].startTime!)
        
        let trivialDayStringsORDINAL = ["", "SUN","MON","TUE","WED","THU","FRI","SAT"]
        
        cell.dateLbl.text = "\(self.shortDateFormatter.string(from: shifts[indexPath.row].startTime!)) (\(trivialDayStringsORDINAL[dayOfWeek]))"
        
        if shifts[indexPath.row].qty == "0.00"{
            cell.startLbl.text = "-----"
            cell.stopLbl.text = "-----"
            cell.totalLbl.text = "-----"
        }else{
            cell.startLbl.text = self.timeFormatter.string(from: shifts[indexPath.row].startTime!)
            cell.stopLbl.text = self.timeFormatter.string(from: shifts[indexPath.row].stopTime!)
            cell.totalLbl.text = "\(shifts[indexPath.row].qty!)"
        }
        
        
        
        return cell;
    }
    
    
    @objc func goBack(){
        print("back")
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

