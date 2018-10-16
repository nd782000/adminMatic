//
//  UsageEntryViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol UsageDelegate{
    func editStart(row:Int,start:Date)
    func editStop(row:Int,stop:Date)
    func editBreak(row:Int,lunch:Int)
    func editQty(row:Int,qty:Double)
    func editVendor(row:Int,vendor:String)
    func editCost(row:Int,cost:Double)
    func showHistory()
}

class UsageEntryViewController: ViewControllerWithMenu, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,  UITableViewDelegate, UITableViewDataSource, UsageDelegate{
    
   
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    var indicator: SDevIndicator!
    
    var containerView:UIView!
    var startStopContainerView:UIView!
    
    var workOrderID:String!
    var woItem:WoItem!
    var usageCharge:String!
    
    
    
    var selectEmployeesTxtField:PaddedTextField!
    var employeePicker: Picker!
    
    var employeeValue:String!
    var employeeCode:String!
    var employeeID:Int!
    
    var empsOnWo:[Employee]!
    var usageToLog: [Usage] = []//data array
    var usageToLogJSON: [JSON] = []//data array
    
    var usageTableView: TableView!
    var startBtn:Button!
    var stopBtn:Button!
    var submitBtn:Button!
    
    var editsMade = false
    var editsMadeFromStart = false
    
    
    var dateFormatter:DateFormatter!
    
    var shortFormatter = DateFormatter()
    
    
    
    
    init(_workOrderID:String,_workOrderItem:WoItem,_empsOnWo:[Employee]){
        super.init(nibName:nil,bundle:nil)
        self.workOrderID = _workOrderID
        self.woItem = _workOrderItem
        self.empsOnWo = _empsOnWo
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.shortFormatter.dateFormat = "hh:mm a"

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Today's Usage"
        
        
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(UsageEntryViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
       
        
        //container view for auto layout
        self.containerView = UIView()
        self.containerView.backgroundColor = layoutVars.backgroundColor
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.containerView)
        
        
        
        if(self.woItem.type == "1"){
            //container view for start stop submit btns
            self.startStopContainerView = UIView()
            self.startStopContainerView.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(self.startStopContainerView)
            
            layoutViewsLabor()
        }else{
            layoutViewsMaterial()
        }
        
    }
    
    
    //layout for edit mode
    func layoutViewsLabor(){
        
        //employee picker
        self.employeePicker = Picker()
        self.employeePicker.delegate = self
        self.selectEmployeesTxtField = PaddedTextField(placeholder: "Add Employee(s)")
        self.selectEmployeesTxtField.textAlignment = NSTextAlignment.center
        self.selectEmployeesTxtField.tag = 1
        self.selectEmployeesTxtField.delegate = self
        self.selectEmployeesTxtField.tintColor = UIColor.clear
        self.selectEmployeesTxtField.inputView = employeePicker
        self.containerView.addSubview(self.selectEmployeesTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let addButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryViewController.addEmployee))
        
        toolBar.setItems([closeButton, spaceButton, addButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        selectEmployeesTxtField.inputAccessoryView = toolBar
        //employee table
        self.usageTableView =  TableView()
        self.usageTableView.delegate  =  self
        self.usageTableView.dataSource  =  self
        self.usageTableView.rowHeight = 80.0
        self.usageTableView.register(UsageEntryTableViewCell.self, forCellReuseIdentifier: "cell")
        self.containerView.addSubview(self.usageTableView)
        
        
        
        self.startBtn = Button(titleText: "Start")
        self.startBtn.backgroundColor = UIColor(hex:0x005100, op:1)
        self.startStopContainerView.addSubview(startBtn)
        self.startBtn.addTarget(self, action: #selector(UsageEntryViewController.startTime), for: UIControlEvents.touchUpInside)
        
        self.stopBtn = Button(titleText: "Stop")
        self.stopBtn.backgroundColor = UIColor(hex:0xff0000, op:1)
        self.startStopContainerView.addSubview(stopBtn)
        self.stopBtn.addTarget(self, action: #selector(UsageEntryViewController.stopTime), for: UIControlEvents.touchUpInside)
        
        self.submitBtn = Button(titleText: "Submit")
        self.submitBtn.backgroundColor = UIColor(hex:0xE09E43, op:1)
        self.startStopContainerView.addSubview(submitBtn)
        self.submitBtn.addTarget(self, action: #selector(UsageEntryViewController.submit), for: UIControlEvents.touchUpInside)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
    //auto layout group
        let viewsDictionary = [
            "container":self.containerView,
            "view1":self.selectEmployeesTxtField,
            "view2":self.usageTableView,
            "view3":self.startStopContainerView,
            "view4":self.startBtn,
            "view5":self.stopBtn,
            "submitBtn":self.submitBtn
            
        ] as [String:Any]
        let metricsDictionary = ["screenWidth": self.view.frame.size.width as AnyObject,"screenHeight": self.view.frame.size.height,"fullWidth": self.view.frame.size.width - 20,"halfWidth": (self.view.frame.size.width - 28)/2,"inputHeight":layoutVars.inputHeight,"doubleInputHeight":layoutVars.inputHeight*2 + 8] as [String : Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container(screenWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container(screenHeight)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view1(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view2(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view3(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[view1(inputHeight)]-[view2]-[view3(doubleInputHeight)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.startStopContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view4(halfWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.startStopContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view5(halfWidth)]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.startStopContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[submitBtn(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.startStopContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view4(inputHeight)]-[submitBtn(inputHeight)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.startStopContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view5(inputHeight)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        addActiveUsage()
        
    }
    
    
    func layoutViewsMaterial(){
        print("layoutViewsMaterial")
        
        self.usageTableView =  TableView()
        self.usageTableView.delegate  =  self
        self.usageTableView.dataSource  =  self
        self.usageTableView.rowHeight = 80.0
        self.usageTableView.register(UsageEntryTableViewCell.self, forCellReuseIdentifier: "cell")
        self.containerView.addSubview(self.usageTableView)
        
        
        self.submitBtn = Button(titleText: "Submit")
        self.submitBtn.backgroundColor = UIColor(hex:0x00ff00, op:1)
        self.containerView.addSubview(submitBtn)
        self.submitBtn.addTarget(self, action: #selector(UsageEntryViewController.submit), for: UIControlEvents.touchUpInside)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = [
            "container":self.containerView,
            "usageTable":self.usageTableView,
            "submitBtn":self.submitBtn
            
        ] as [String:AnyObject]
        let metricsDictionary = ["screenWidth": self.view.frame.size.width,"screenHeight": self.view.frame.size.height,"fullWidth": self.view.frame.size.width - 20,"halfWidth": (self.view.frame.size.width - 20)/2-5,"inputHeight":layoutVars.inputHeight,"doubleInputHeight":(layoutVars.inputHeight*2)+20] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container(screenWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container(screenHeight)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[usageTable(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[usageTable]-[submitBtn(inputHeight)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        addActiveUsage()
        
    }
    
    //picker view methods
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
         print(" 1numberOfComponents = \(appDelegate.employeeArray.count + 1)")
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("numberOfComponents = \(appDelegate.employeeArray.count + 1)")

        return appDelegate.employeeArray.count + 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(row == 0){
            return "Crew"
        }else{
            print("titleForRow = \(appDelegate.employeeArray[row-1].name)")
            return appDelegate.employeeArray[row-1].name
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.employeeValue = appDelegate.employeeArray[row-1].name

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func cancelPicker() {
        selectEmployeesTxtField.resignFirstResponder()
    }
    
    
    
    // table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(woItem.extraUsage! == "1"){
            return usageToLog.count + 1
        }else{
            return usageToLog.count
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        print("woItem.extraUsage = \(woItem.extraUsage!)")
        if(woItem.extraUsage! == "1" && indexPath.row > (usageToLog.count - 1)){
            print("show history cell")
            let cell:UsageEntryTableViewCell = usageTableView.dequeueReusableCell(withIdentifier: "cell") as! UsageEntryTableViewCell
        
            cell.delegate = self
            cell.displayHistoryMode()
            return cell
        }
        let usage = usageToLog[indexPath.row]
        
        let cell:UsageEntryTableViewCell = usageTableView.dequeueReusableCell(withIdentifier: "cell") as! UsageEntryTableViewCell
        
        cell.delegate = self
        cell.row = indexPath.row
        
        if(usage.type == "1"){
            cell.displayLaborMode()
            
            
            cell.imageView?.image = nil
            cell.empID = usage.empID
            cell.nameLbl.text = usage.empName
            if(usage.qty == ""){
                cell.qtyLbl.text = ""
            }else{
                cell.qtyLbl.text = "\(usage.qty!) hrs."
            }
            
            if(usage.start != nil){
                
                
                cell.startTxtField.text = shortFormatter.string(from: usage.start!)
                
                cell.startPickerView.date = usage.start!
                
            }else{
                cell.startTxtField.text = ""
            }
            if(usage.stop != nil){
                cell.stopTxtField.text = shortFormatter.string(from:usage.stop!)
                cell.stopPickerView.date = usage.stop!
            }else{
                cell.stopTxtField.text = ""
            }
            if(usage.lunch != nil){
                cell.breakTxtField.text = usage.lunch
            }else{
                cell.breakTxtField.text = ""
            }
            cell.startTxtField.isUserInteractionEnabled = !usage.locked!
            cell.stopTxtField.isUserInteractionEnabled = !usage.locked!
            cell.breakTxtField.isUserInteractionEnabled = !usage.locked!
            cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+usage.empPic!)
        }else{
            cell.displayMaterialMode()
            cell.vendorList = self.woItem.vendors
            if(usage.qty == ""){
                cell.qtyTxtField.text = ""
            }else{
                cell.qtyTxtField.text = "\(usage.qty!)"
            }
            if(woItem.unit == ""){
                cell.unitsLbl.text = ""
            }else{
                cell.unitsLbl.text = "\(woItem.unit!)(s)"
            }
            for vendor in self.woItem.vendors {
                if (vendor.ID == usage.vendor){
                    cell.vendorTxtField.text = "\(vendor.name!)"
                }
            }
            if(usage.unitCost == ""){
                cell.costTxtField.text = ""
            }else{
                cell.costTxtField.text = "\(usage.unitCost!)"
            }
            if(usage.totalCost == ""){
                cell.totalCostLbl.text = "Total Cost $0.00"
            }else{
                cell.totalCostLbl.text = "Total Cost $\(usage.totalCost!)"
            }
        }
        if(usage.locked == false){
            cell.locked = false
            cell.lockIcon.alpha = 0
        }else{
            cell.locked = true
            cell.lockIcon.alpha = 1
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.row != usageToLog.count){
            return true
        }else{
            return false
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if(usageToLog[indexPath.row].locked == false && usageToLog[indexPath.row].type == "1"){
                if(usageToLog[indexPath.row].ID == "0"){
                    usageToLog.remove(at: indexPath.row)
                    usageTableView.reloadData()
                }else{
                    usageToLog[indexPath.row].del = "1"
                    usageToLogJSON = []
                    let JSONString = usageToLog[indexPath.row].toJSONString(prettyPrint: true)
                    usageToLogJSON.append(JSON(JSONString ?? ""))
                    print("usage JSONString = \(String(describing: JSONString))")
                    callAlamoFire(_type: "delete")
                    usageToLog.remove(at: indexPath.row)
                    usageTableView.reloadData()
                }
            }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(),_title: "Can't Delete Saved Rows", _message: "")
                tableView.setEditing(false, animated: true)
            }
        }
    }
   
    

    func removeViews(){
        for view in containerView.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerView.frame = view.bounds
        
    }
    
       
    
    
    
    
    @objc func goBack(){
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                self.popView()
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            popView()
        }
    }
    
    
    func popView(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func displayHomeView() {
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                self.appDelegate.menuChange(100)//home
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            appDelegate.menuChange(100)//home
        }
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func addEmployee() {
       // print("Add Employee \(appDelegate.employeesJson)")
        let row = employeePicker.selectedRow(inComponent: 0)
        if(row == 0){
            for employee in self.empsOnWo {
                let usage:Usage = Usage(_ID: "0",
                                        _empID: employee.ID,
                                        _depID: employee.depID,
                                        _woID: self.workOrderID,
                                        _start: nil,
                                        _stop: nil,
                                        _lunch: "",
                                        _qty: "",
                                        _empName: employee.name,
                                        _type: self.woItem.type,
                                        _itemID: self.woItem.ID,
                                        _unitPrice: self.woItem.price,
                                        _totalPrice: self.woItem.total,
                                        _vendor: "",
                                        _unitCost: "",
                                        _totalCost: "",
                                        _chargeType: self.woItem.chargeID,
                                        _override: "1",
                                        _empPic: employee.pic,
                                        _locked: false,
                                        _addedBy: appDelegate.loggedInEmployee!.ID,
                                        _del: ""
                )
                usageToLog.insert(usage, at: 0)
            }
        }else{
            let usage:Usage = Usage(_ID: "0",
                                    _empID: appDelegate.employeeArray[row-1].ID!,
                                    _depID: appDelegate.employeeArray[row-1].depID!,
                                    _woID: self.workOrderID,
                                    _start: nil,
                                    _stop: nil,
                                    _lunch: "",
                                    _qty: "",
                                    _empName: appDelegate.employeeArray[row-1].name!,
                                    _type: self.woItem.type,
                                    _itemID: self.woItem.ID,
                                    _unitPrice: self.woItem.price,
                                    _totalPrice: self.woItem.total,
                                    _vendor: "",
                                    _unitCost: "",
                                    _totalCost: "",
                                    _chargeType: self.woItem.chargeID,
                                    _override: "1",
                                    _empPic: appDelegate.employeeArray[row-1].pic!,
                                    _locked: false,
                                    _addedBy: appDelegate.loggedInEmployee!.ID,
                                    _del: ""
            )
            usageToLog.insert(usage, at: 0)
        }
        self.usageTableView.reloadData()
    }
    
    
    func addActiveUsage(){
        //loop thru usage array and edit start time
        print("addActiveUsage()")
        var openUsage:Bool = false
        for usage in self.woItem.usages {
            print("usage.qty = \(String(describing: usage.qty))")
            usageToLog.append(usage)//append to your list
            if(usage.stop == nil){
                openUsage = true
            }
        }
        if(woItem.type == "1"){
            print("openUsage = \(openUsage)")
            if(openUsage == false){
                for employee in self.empsOnWo {
                    print("empName = \(employee.name)")
                    let usage:Usage = Usage(_ID: "0",
                                            _empID: employee.ID,
                                            _depID: employee.depID,
                                            _woID: self.workOrderID,
                                            _start: nil,
                                            _stop: nil,
                                            _lunch: "",
                                            _qty: "",
                                            _empName: employee.name,
                                            _type: self.woItem.type,
                                            _itemID: self.woItem.ID,
                                            _unitPrice: self.woItem.price,
                                            _totalPrice: self.woItem.total,
                                            _vendor: "",
                                            _unitCost: "",
                                            _totalCost: "",
                                            _chargeType: self.woItem.chargeID,
                                            _override: "1",
                                            _empPic: employee.pic,
                                            _locked: false,
                                            _addedBy: appDelegate.loggedInEmployee?.ID!,
                                            _del: ""
                    )
                    usageToLog.insert(usage, at: 0)
                }
                
            }
        }else{
            let usage:Usage = Usage(_ID: "0",
                                    _empID: nil,
                                    _depID: nil,
                                    _woID: self.workOrderID,
                                    _start: nil,
                                    _stop: nil,
                                    _lunch: "",
                                    _qty: "",
                                    _empName: nil,
                                    _type: self.woItem.type,
                                    _itemID: self.woItem.ID,
                                    _unitPrice: self.woItem.price,
                                    _totalPrice: self.woItem.total,
                                    _vendor: "",
                                    _unitCost: "",
                                    _totalCost: "",
                                    _chargeType: self.woItem.chargeID,
                                    _override: "1",
                                    _empPic: nil,
                                    _locked: false,
                                    _addedBy: appDelegate.loggedInEmployee!.ID!,
                                    _del: ""
            )
            usageToLog.insert(usage, at: 0)
            
        }
        self.usageTableView.reloadData()
        
        
    }
    
    func editStart(row:Int,start:Date){
        
        print("edit start \(start.description)")
        
        let stopDate = usageToLog[row].stop
        
        print("stopDate = \(String(describing: stopDate))")
        
        if(stopDate == nil){
            
            editOtherStartTimes(_row:row, _start: start)
            
            
            usageToLog[row].start = start
            self.editsMade = true
            setQty()
            
            
            
        }else if(stopDate! < start){
            usageTableView.reloadData()
            self.layoutVars.simpleAlert(_vc:self, _title: "Time Error", _message: "\(usageToLog[row].empName!)'s start time can not be later then their stop time.")
        }else{
            
            editOtherStartTimes(_row:row, _start: start)

            
            usageToLog[row].start = start
            
            self.editsMade = true
            setQty()
            
        }
        
        
    }
    
    
    func editOtherStartTimes(_row:Int,_start:Date){
        print("editOtherStartTimes usageToLog.count = \(usageToLog.count)")
        if(usageToLog.count > 1){
            print("show alert")
            let alertController = UIAlertController(title: "Edit Start Time for Others?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                for n in 0 ..< self.usageToLog.count {
                    if(n != _row && self.usageToLog[n].locked == false){
                        print("n != row")
                        let stopDate = self.usageToLog[n].stop
                        if(stopDate == nil){
                            self.usageToLog[n].start = _start
                        }else if(stopDate! < _start){
                            self.usageTableView.reloadData()
                            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(self.usageToLog[n].empName!)'s start time can not be later then their stop time.")
                        }else{
                            self.usageToLog[n].start = _start
                        }
                    }
                }
                self.usageTableView.reloadData()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            //self.present(alertController, animated: true, completion: nil)
            present(alertController, animated: true)
        }
    }
    
    
    
   
    
    
    
    func editStop(row:Int,stop:Date){
        print("edit stop \(stop.description)")
        if(usageToLog[row].start == nil){
            //no start time
            usageTableView.reloadData()
             self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usageToLog[row].empName!)'s has no start time.  Enter start time first.")
        }else if(stop<usageToLog[row].start!){
            //stop is before start
            usageTableView.reloadData()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usageToLog[row].empName!)'s stop time can not be earlier then their start time.")
        }else{
            
            editOtherStopTimes(_row:row, _stop: stop)
            
            
            usageToLog[row].stop = stop
            self.editsMade = true
            setQty()
        }
 
 
    }
    
    
    func editOtherStopTimes(_row:Int,_stop:Date){
        print("editOtherStopTimes")
        if(usageToLog.count > 1){
            let alertController = UIAlertController(title: "Edit Stop Time for Others?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                for n in 0 ..< self.usageToLog.count {
                    if(n != _row && self.usageToLog[n].locked == false){
                       // print("n != row")
                        
                        
                        
                        if(self.usageToLog[n].start == nil){
                            //no start time
                            self.usageTableView.reloadData()
                            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(self.usageToLog[n].empName!)'s has no start time.  Enter start time first.")
                        }else if(_stop<self.usageToLog[n].start!){
                            //stop is before start
                            self.usageTableView.reloadData()
                            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(self.usageToLog[n].empName!)'s stop time can not be earlier then their start time.")
                        }else{
                            self.usageToLog[n].stop = _stop
                            self.editsMade = true
                            self.setQty()
                        }
                        
                        
                        
                    }
                }
                self.usageTableView.reloadData()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    
    func editBreak(row:Int,lunch:Int){
        editOtherBreakTimes(_row: row, _break: lunch)
        usageToLog[row].lunch = String(lunch)
        self.editsMade = true
        setQty()
    }
    
    
    func editOtherBreakTimes(_row:Int,_break:Int){
        print("editOtherBreakTimes")
        if(usageToLog.count > 1){
            let alertController = UIAlertController(title: "Edit Break Time for Others?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                for n in 0 ..< self.usageToLog.count {
                    if(n != _row && self.usageToLog[n].locked == false){
                        // print("n != row")
                        
                        
                        self.usageToLog[n].lunch = String(_break)
                        self.setQty()
                    }
                }
                self.usageTableView.reloadData()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
    }

    
    
    
    
    
    //material usage functions
    func editQty(row:Int,qty:Double){
        usageToLog[row].qty = String(qty)
        self.editsMade = true
    }
    
    
    
    func editVendor(row:Int,vendor:String) {
        print("edit vendor \(vendor)")
        usageToLog[row].vendor = vendor
        self.editsMade = true
    }
    
    func editCost(row:Int,cost:Double){
        usageToLog[row].unitCost = String(cost)
        self.editsMade = true
    }
    
    
    func showHistory(){
        
        
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                let usageListViewController = UsageListViewController(_workOrderItemID: self.woItem.ID, _units: self.woItem.unit)
                self.navigationController?.pushViewController(usageListViewController, animated: true )            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            let usageListViewController = UsageListViewController(_workOrderItemID: self.woItem.ID, _units: self.woItem.unit)
            self.navigationController?.pushViewController(usageListViewController, animated: true )
        }
    }
    
    
    
    
    
    @objc func startTime() {
        print("startTime 1")
    //loop thru usage array and edit start time
        for usage in usageToLog {
            let usageStop = usage.stop
            if(usage.locked == false){
                //test if start is before stop or stop is nil
                if(usage.stop == nil){
                    usage.start = Date()
                    self.editsMade = true
                }else if(usageStop!  < Date()){
                    //start is after stop
                    self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usage.empName!)'s start time can not be later then their stop time.")
                }else{
                    
                    usage.start = Date()
                    
                    self.editsMade = true
                }
            }
            
        }
        //reload table
        usageTableView.reloadData()
        setQty()
    }
    
    
    @objc func stopTime() {
        //loop thru usage array and edit stop time
        for usage in usageToLog {
            if(usage.locked == false){
                //test if stop is after start or start is nil
                if(usage.start == nil){
                    //no start time
                    self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usage.empName!)'s has no start time.  Enter start time first.")
                }else if(Date() <  usage.start!){
                    //stop is before start
                     self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usage.empName!)'s stop time can not be earlier then their start time.")
                }else{
                    usage.stop =  Date()
                    self.editsMade = true
                }
            }
        }
        //reload table
        usageTableView.reloadData()
        setQty()
    }
    
    func setQty(){
        print("setQty")
        //loop thru usage array and edit qty if has both start and stop
        for usage in usageToLog {
            print("looping")
            if(usage.start == nil && usage.stop == nil){
                print("blank row")
            }else{
                
                if(usage.start == nil || usage.stop == nil){
                    print("start or stop is nil")
                    usage.qty = "0.0"
                    usageTableView.reloadData()
                    return
                }
                
                if(usage.start != nil && usage.stop != nil){
                    let qtySeconds = usage.stop?.timeIntervalSince(usage.start!)
                    var breakTime = 0.0
                    if(usage.lunch != "" && usage.lunch != "0"){
                        breakTime = Double(usage.lunch!)! * 60
                        if(breakTime >= qtySeconds!){
                            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usage.empName!)'s break time can not be equal or greater then their shift time.")
                            usage.lunch = "0"
                            breakTime = 0.0
                        }
                    }
                    let qtyHours = (qtySeconds! - breakTime) / 3600
                    usage.qty = String(format: "%.2f",qtyHours)
                }
            }
            
        }
        usageTableView.reloadData()
    }
    
    @objc func submit() {
        usageToLogJSON = []
        //loop thru usage array and build JSON array
        self.editsMade = false //resets edit checker
        for (index, usage) in usageToLog.enumerated() {
            var usageQty = 0.0
            print("usage.qty = \(String(describing: usage.qty))")
            if(usage.qty != nil && usage.qty != "0.0" && usage.qty != ""){
                print("set usage.qty to 0.0")
                usageQty = Double(usage.qty!)!
            }
            
            if(usage.locked == false){
                if(usage.type == "1"){
                    if(usage.start == nil){
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Time Error", _message: "\(usage.empName!)'s break time can not be equal or greater then their shift time.")
                    }else{
                        if(usageQty > 0.0){
                            if(Int(appDelegate.loggedInEmployee!.ID!)! > 0 &&  appDelegate.loggedInEmployee!.ID! == usage.addedBy){
                            }else{
                                self.usageToLog[index].locked = true
                                usage.locked = true
                            }
                        }
                        let JSONString = usage.toJSONString(prettyPrint: true)
                        usageToLogJSON.append(JSON(JSONString ?? ""))
                        print("usage JSONString = \(String(describing: JSONString))")
                    }
                }else{
                    if(usageQty > 0.0){
                        if(Int(appDelegate.loggedInEmployee!.ID!)! > 0 &&  appDelegate.loggedInEmployee!.ID! == usage.addedBy){
            
                        }else{
                            self.usageToLog[index].locked = true
                            usage.locked = true
                        }
                        
                        
                            
                            
                        usage.start = Date()
                        usage.stop = Date()
                        let JSONString = usage.toJSONString(prettyPrint: true)
                        usageToLogJSON.append(JSON(JSONString ?? ""))
                    }else{
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Qty Error", _message: "Qty needs to be added.")
                    }
                }
            }
        }
        callAlamoFire(_type: "new")
    }
    
    func callAlamoFire(_type:String){
        if(usageToLogJSON.count > 0){
            indicator = SDevIndicator.generate(self.view)!
            
              
                
            var parameters:[String:String]
            parameters = [
                "usageToLog": "\(usageToLogJSON)"
                
            ]
            
            print("parameters = \(parameters)")
            
            
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/usage.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("usage response = \(response)")
                }
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let updatedJSON = JSON(value)
                        self.indicator.dismissIndicator()
                        
                        
                        let usageCount = updatedJSON["usage"].count
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if(_type == "new"){
                            self.usageToLog = []
                            
                            for n in 0 ..< usageCount {
                               
                                
                                let start = dateFormatter.date(from: updatedJSON["usage"][n]["start"].string!)
                                let stop = dateFormatter.date(from: updatedJSON["usage"][n]["stop"].string!)
                                
                                var locked:Bool
                                let usageQty = Double(updatedJSON["usage"][n]["qty"].string!)
                                if(usageQty! > 0.0 && updatedJSON["usage"][n]["addedBy"].string != self.appDelegate.loggedInEmployee!.ID!){
                                    locked = true
                                }else{
                                    locked = false
                                }
                                
                                print("usage json = \(updatedJSON["usage"][n])")
                                let usage = Usage(_ID: updatedJSON["usage"][n]["ID"].stringValue,
                                                  _empID: updatedJSON["usage"][n]["empID"].stringValue,
                                                  _depID: updatedJSON["usage"][n]["depID"].stringValue,
                                                  _woID: updatedJSON["usage"][n]["woID"].stringValue,
                                                  _start: start,
                                                  _stop: stop,
                                                  _lunch: updatedJSON["usage"][n]["lunch"].stringValue,
                                                  _qty: updatedJSON["usage"][n]["qty"].stringValue,
                                                  _empName: updatedJSON["usage"][n]["empName"].stringValue,
                                                  _type: updatedJSON["usage"][n]["type"].stringValue,
                                                  _itemID: updatedJSON["usage"][n]["woItemID"].stringValue,
                                                  _unitPrice: updatedJSON["usage"][n]["unitPrice"].stringValue,
                                                  _totalPrice: updatedJSON["usage"][n]["totalPrice"].stringValue,
                                                  _vendor: updatedJSON["usage"][n]["vendor"].stringValue,
                                                  _unitCost: updatedJSON["usage"][n]["unitCost"].stringValue,
                                                  _totalCost: updatedJSON["usage"][n]["totalCost"].stringValue,
                                                  _chargeType: self.woItem.chargeID,
                                                  _override: "1",
                                                  _empPic: updatedJSON["usage"][n]["empPic"].stringValue,
                                                  _locked: locked,
                                                  _addedBy: updatedJSON["usage"][n]["addedBy"].stringValue,
                                                  _del: ""
                                )
                                self.usageToLog.append(usage)
                            }
                        }
                        if(_type == "new" && self.woItem.type == "2"){
                            
                           
                            
                            let usage:Usage = Usage(_ID: "0",
                                                    _empID: nil,
                                                    _depID: nil,
                                                    _woID: self.workOrderID,
                                                    _start: nil,
                                                    _stop: nil,
                                                    _lunch: "",
                                                    _qty: "",
                                                    _empName: nil,
                                                    _type: self.woItem.type,
                                                    _itemID: self.woItem.ID,
                                                    _unitPrice: self.woItem.price,
                                                    _totalPrice: self.woItem.total,
                                                    _vendor: "",
                                                    _unitCost: "",
                                                    _totalCost: "",
                                                    _chargeType: self.woItem.chargeID,
                                                    _override: "1",
                                                    _empPic: nil,
                                                    _locked: false,
                                                    _addedBy: self.appDelegate.loggedInEmployee!.ID!,
                                                    _del: ""
                            )
                            self.usageToLog.insert(usage, at: 0)
                        }
                        self.layoutVars.playSaveSound()
                        self.usageTableView.reloadData()
                    case .failure(let error):
                        self.indicator.dismissIndicator()
                        self.usageTableView.reloadData()
                        print("Error 4xx / 5xx: \(error)")
                    }
            }
        }else{
            //print("No Usage to Save")
        }
        
    }
    
    
    
}

