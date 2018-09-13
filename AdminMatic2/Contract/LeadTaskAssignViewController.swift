//
//  LeadTaskAssignViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/1/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON



class LeadTaskAssignViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    
    
    var multiButton:UIBarButtonItem!
    
    
    var lead:Lead!
    
    var editDelegate:EditLeadDelegate!
    
    var tasksArray:[Task] = []
    var json:JSON!
    var woItemsArray:[WoItem] = []
    var contractItemsArray:[WoItem] = []
    var selectedTasks:[Int] = []
    
    var taskCountLbl: UILabel! = UILabel()
    
    var tasksTableView: TableView!
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    
    //var addBtn:Button = Button(titleText: "Add Tasks")
    
    var scheduleBtn:Button = Button(titleText: "Schedule Tasks")
    
    var scheduleTxtField:PaddedTextField!
    var schedulePicker: Picker!
    
    var contractBtn:Button = Button(titleText: "Contract Tasks")
    
    var contractTxtField:PaddedTextField!
    var contractPicker: Picker!
    
    var multiSelectMode:Bool = false
    
    var editsMade:Bool = false
    var tasksToLog: [Task] = []//data array
    var tasksToLogJSON: [JSON] = []//data array
    
    var pickerMode: String = ""
    
    var woID:String = ""
    var contractID:String = ""
    
    var itemID:String = ""
    
    
    
    
    init(_lead:Lead, _tasks:[Task]){
        super.init(nibName:nil,bundle:nil)
        self.lead = _lead
        self.tasksArray = _tasks
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(LeadViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading Items..."
        getWoItems()
    }
    
    
    //sends request for lead tasks
    func getWoItems() {
        print(" GetItems  Cust Id \(self.lead.customer)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.woItemsArray = []
        let parameters: [String:String] = ["custID": self.lead.customer]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leadCustomerWoSearch.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("item response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    self.parseJSON()
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    
    func parseJSON(){
        //tasks
        let itemCount = self.json["items"].count
        for n in 0 ..< itemCount {
            
            let item = WoItem(_ID: self.json["items"][n]["itemID"].stringValue, _name: self.json["items"][n]["itemName"].stringValue, _woID: self.json["items"][n]["woID"].stringValue, _woTitle: self.json["items"][n]["woTitle"].stringValue)
            
            
            self.woItemsArray.append(item)
        }
        self.layoutViews()
    }
    
    
    func layoutViews(){
        print("layout views")
        title =  "Assign Tasks"
        
        multiButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(LeadTaskAssignViewController.displayMultiSelectView))
        navigationItem.rightBarButtonItem = multiButton
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        self.taskCountLbl.translatesAutoresizingMaskIntoConstraints = false
        self.taskCountLbl.font = layoutVars.buttonFont
        self.view.addSubview(self.taskCountLbl)
        
        updateTaskCountLabel()
        
       
        
        
        self.tasksTableView  =   TableView()
        self.tasksTableView.autoresizesSubviews = true
        self.tasksTableView.delegate  =  self
        self.tasksTableView.dataSource  =  self
        self.tasksTableView.layer.cornerRadius = 0
        self.tasksTableView.rowHeight = 90
        self.tasksTableView.register(LeadTaskTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tasksTableView)
        
        
        
        //self.addBtn.addTarget(self, action: #selector(LeadTaskAssignViewController.addTask), for: UIControlEvents.touchUpInside)
       // self.view.addSubview(self.addBtn)
        
        
        self.view.addSubview(self.scheduleBtn)
        
        
        //schedule picker
        self.schedulePicker = Picker()
        self.schedulePicker.tag = 1
       // print("statusValue : \(schedulePickerValue)")
        //print("set picker position : \(Int(self.statusValue)! - 1)")
        
        self.schedulePicker.delegate = self
        
        self.scheduleTxtField = PaddedTextField(placeholder: "")
        self.scheduleTxtField.textAlignment = NSTextAlignment.center
        self.scheduleTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.scheduleTxtField.tag = 1
        self.scheduleTxtField.delegate = self
        self.scheduleTxtField.tintColor = UIColor.clear
        self.scheduleTxtField.backgroundColor = UIColor.clear
        self.scheduleTxtField.inputView = schedulePicker
        self.scheduleTxtField.layer.borderWidth = 0
        self.view.addSubview(self.scheduleTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LeadTaskAssignViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Assign", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LeadTaskAssignViewController.handleItemSelect))
        
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        scheduleTxtField.inputAccessoryView = toolBar
        
        
        
        
        
        
       
        self.view.addSubview(self.contractBtn)
        
        
        //contract picker
        self.contractPicker = Picker()
        self.contractPicker.tag = 2
        self.contractPicker.delegate = self
        
        self.contractTxtField = PaddedTextField(placeholder: "")
        self.contractTxtField.textAlignment = NSTextAlignment.center
        self.contractTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.contractTxtField.tag = 2
        self.contractTxtField.delegate = self
        self.contractTxtField.tintColor = UIColor.clear
        self.contractTxtField.backgroundColor = UIColor.clear
        self.contractTxtField.inputView = contractPicker
        self.contractTxtField.layer.borderWidth = 0
        self.view.addSubview(self.contractTxtField)
        
        let contractToolBar = UIToolbar()
        contractToolBar.barStyle = UIBarStyle.default
        contractToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        contractToolBar.sizeToFit()
        
        let closeContractButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LeadTaskAssignViewController.cancelPicker))
        let setContractButton = UIBarButtonItem(title: "Assign", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LeadTaskAssignViewController.handleItemSelect))
        
        contractToolBar.setItems([closeContractButton, spaceButton, setContractButton], animated: false)
        contractToolBar.isUserInteractionEnabled = true
        
        contractTxtField.inputAccessoryView = contractToolBar
        
        
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30,"halfWidth": (layoutVars.fullWidth - 38)/2, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "countLbl":self.taskCountLbl,
            "table":self.tasksTableView,
            //"addBtn":self.addBtn,
            "scheduleBtn":self.scheduleBtn,
            "scheduleTxt":self.scheduleTxtField,
            "contractBtn":self.contractBtn,
            "contractTxt":self.contractTxtField
            ] as [String:AnyObject]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[countLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[table]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
         //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[addBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[scheduleBtn(halfWidth)]-[contractBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[scheduleTxt(halfWidth)]-[contractTxt]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[contractBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[contractTxt]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[countLbl(30)][table]-[scheduleBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[countLbl(30)][table]-[scheduleTxt(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[countLbl(30)][table]-[contractBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[countLbl(30)][table]-[contractTxt(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
       
        
    }
    
   
    func removeViews(){
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        if pickerMode == "WORKORDER"{
            return woItemsArray.count + 1
        }else{
            return contractItemsArray.count + 1
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:60))
        
        
        if pickerMode == "WORKORDER"{
            if row == woItemsArray.count{
                var woString = String()
                woString = "New Work Order"
                let woLabel = UILabel(frame: CGRect(x:0, y:0, width:pickerView.bounds.width, height:60 ))
                woLabel.font = layoutVars.smallFont
                woLabel.textAlignment = .center
                woLabel.text = woString
                myView.addSubview(woLabel)
                
            }else{
            
                var woString = String()
                woString = "W.O. #\(woItemsArray[row].woID!)  \(woItemsArray[row].woTitle!)"
                let woLabel = UILabel(frame: CGRect(x:0, y:0, width:pickerView.bounds.width, height:30 ))
                woLabel.font = layoutVars.smallFont
                woLabel.text = woString
                myView.addSubview(woLabel)
                
                
                var itemString = String()
                itemString = "\(woItemsArray[row].name!) Item"
                let itemLabel = UILabel(frame: CGRect(x:60, y:30, width:pickerView.bounds.width - 60, height:30 ))
                itemLabel.font = layoutVars.buttonFont
                itemLabel.text = itemString
                myView.addSubview(itemLabel)
            }
        }else{
            if row == contractItemsArray.count{
                var contractString = String()
                contractString = "New Contract"
                let contractLabel = UILabel(frame: CGRect(x:0, y:0, width:pickerView.bounds.width, height:60 ))
                contractLabel.font = layoutVars.smallFont
                contractLabel.textAlignment = .center
                contractLabel.text = contractString
                myView.addSubview(contractLabel)
                
            }else{
                
                var contractString = String()
                let contractLabel = UILabel(frame: CGRect(x:0, y:0, width:pickerView.bounds.width, height:30 ))
                contractLabel.font = layoutVars.smallFont
                contractLabel.text = contractString
                myView.addSubview(contractLabel)
                
                
                var itemString = String()
                itemString = "\(contractItemsArray[row].name!) Item"
                let itemLabel = UILabel(frame: CGRect(x:60, y:30, width:pickerView.bounds.width - 60, height:30 ))
                itemLabel.font = layoutVars.buttonFont
                itemLabel.text = itemString
                myView.addSubview(itemLabel)
            }
        }
       
        
        
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerMode == "WORKORDER"{
            if row == woItemsArray.count{
                print("new work order")
                
                
            }else{
                print("row \(row) selected")
            }
        }else{
            if row == woItemsArray.count{
                print("new contract")
                
                
            }else{
                print("row \(row) selected")
            }
        }
    }
    
    @objc func cancelPicker(){
        scheduleTxtField.resignFirstResponder()
        contractTxtField.resignFirstResponder()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        count = self.tasksArray.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
         print("cellForRowAt, selectTasks = \(selectedTasks)")
        
        let cell:LeadTaskTableViewCell = tasksTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTaskTableViewCell
        //if(indexPath.row == self.tasksArray.count){
       // if(indexPath.row == 0){
            //cell add btn mode
            //cell.layoutAddBtn()
        //}else{
            cell.task = self.tasksArray[indexPath.row]
            cell.layoutViews()
            
            if multiSelectMode {
                cell.setConstraintsWithCheckMark()
                if self.selectedTasks.contains(indexPath.row){
                    cell.setCheck()
                }else{
                    cell.unSetCheck()
                }
            }else{
                cell.setConstraints()
            }
            
        //}
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selectTasks = \(selectedTasks)")
       // if(indexPath.row == self.tasksArray.count){
            //self.addTask()
        //}else{
            if multiSelectMode {
                if self.selectedTasks.contains(indexPath.row) {
                    self.selectedTasks.remove(at: self.selectedTasks.index(of: indexPath.row)!)
                  
                    
                } else {
                    self.selectedTasks.append(indexPath.row)
                   
                }
                
                tasksTableView.reloadData()
            }else{
                
            
           
            
            
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Lead Task", _leadID: self.lead.ID, _leadTaskID: self.tasksArray[indexPath.row].ID, _customerID: self.lead.customer, _images: self.tasksArray[indexPath.row].images)
                imageUploadPrepViewController.layoutViews()
                imageUploadPrepViewController.groupDescriptionTxt.text = self.tasksArray[indexPath.row].task
                imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
                imageUploadPrepViewController.selectedID = self.lead.customer
                imageUploadPrepViewController.groupImages = true
                imageUploadPrepViewController.attachmentDelegate = self
                self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
            }
        //}
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        self.selectedTasks = []
        
        //indexPath
        let schedule = UITableViewRowAction(style: .normal, title: "Schedule") { action, index in
            self.selectedTasks.append(indexPath.row)
            self.scheduleTxtField.becomeFirstResponder()
            
        }
        schedule.backgroundColor = layoutVars.buttonColor1
        
        
        let contract = UITableViewRowAction(style: .normal, title: "Contract") { action, index in
            //print("progress button tapped")
            self.selectedTasks.append(indexPath.row)
           self.contractTxtField.becomeFirstResponder()
            
        }
        contract.backgroundColor = UIColor.darkGray
        
        let notNeeded = UITableViewRowAction(style: .normal, title: "N/A") { action, index in
            //print("progress button tapped")
           // self.selectedTasks.append(indexPath.row)
            //self.contractTxtField.becomeFirstResponder()
            
            self.editsMade = true
            
            var parameters:[String:String]
            parameters = ["id":self.tasksArray[indexPath.row].ID, "val":"2", "field":"status", "table":"leadTasks", "tableName":"projects"]
            
            print("parameters = \(parameters)")
            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/changeField.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                print(response.result)   // result of response serialization
                
                }.responseString() {
                    response in
                    print(response)  // original URL request
            }
            
            self.tasksArray[indexPath.row].status = "2"
            self.tasksTableView.reloadData()
            
            
            
            
        }
        notNeeded.backgroundColor = UIColor.orange
        
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("cancel button tapped")
            
            if(self.lead.createdBy == self.appDelegate.loggedInEmployee?.ID){
                if(self.tasksArray[indexPath.row].ID != "0"){
                    
                    
                    
                    
                    let alertController = UIAlertController(title: "Delete Task?", message: "Are you sure you want to delete this task?", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                        (result : UIAlertAction) -> Void in
                        
                        // self.getWorkOrder()
                        
                    }
                    
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        
                        
                       
                        print("delete lead task")
                        
                        
                        self.editsMade = true
                        
                        var parameters:[String:String]
                        parameters = [
                            "leadTaskID":self.tasksArray[indexPath.row].ID
                        ]
                        print("parameters = \(parameters)")
                        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/leadTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                            response in
                            print(response.request ?? "")  // original URL request
                            print(response.result)   // result of response serialization
                            
                            }.responseString() {
                                response in
                                print(response)  // original URL request
                        }
                        
                        self.tasksArray.remove(at: indexPath.row)
                        self.tasksTableView.reloadData()
                        
                        
                       
                        
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                    
                    
                   
                    
                    
                }
            }else{
                simpleAlert(_vc: self,_title: "Can't delete lead tasks you didn't create.", _message: "")
                tableView.setEditing(false, animated: true)
            }
            
            
            
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, notNeeded, contract, schedule]
        
    }
    
    
    
    
    
    
    /*
    func addTask(){
        print("add task")
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Lead Task", _leadID: self.lead.ID, _leadTaskID: "0", _customerID: self.lead.customer, _images: [])
        imageUploadPrepViewController.layoutViews()
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.attachmentDelegate = self
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    */
    
    
    
    @objc func displayMultiSelectView(){
        print("display Multi Select View")
        
        self.selectedTasks = []
        
        if multiSelectMode {
            multiButton.title = "Select"
            multiSelectMode = false
            
        }else{
            multiButton.title = "Done"
            multiSelectMode = true
            
        }
        tasksTableView.reloadData()
        
       
    }
    
  
    
    
    @objc func handleItemSelect(){
        print("handleItemSelect selectedrow = \(schedulePicker.selectedRow(inComponent: 0))")
        
        
        print("pickerMode = \(pickerMode)")
        
        
        
        if pickerMode == "WORKORDER"{
            if schedulePicker.selectedRow(inComponent: 0) == woItemsArray.count{
                print("needs new wo")
                
                self.editsMade = true
                
                let editWoViewController = NewEditWoViewController(_lead: self.lead,_tasks: self.tasksArray)
                navigationController?.pushViewController(editWoViewController, animated: false )
                
                return
                
                //simpleAlert(_vc: self, _title: "Make New Work Order", _message: "This feature is coming soon.")
                //return
            }
            woID = woItemsArray[schedulePicker.selectedRow(inComponent: 0)].woID!
            itemID = woItemsArray[schedulePicker.selectedRow(inComponent: 0)].ID!
            scheduleTxtField.resignFirstResponder()
        }else{
            
            if contractPicker.selectedRow(inComponent: 0) == contractItemsArray.count{
                print("needs new contract")
                //simpleAlert(_vc: self, _title: "Make New Contract", _message: "This feature is coming soon.")
                //return
                
                self.editsMade = true
                
                let editContractViewController = NewEditContractViewController(_lead: self.lead,_tasks: self.tasksArray)
                navigationController?.pushViewController(editContractViewController, animated: false )
                
                return
            }
            
            //contractID = contractItemsArray[contractPicker.selectedRow(inComponent: 0)].woID
            //itemID = contractItemsArray[contractPicker.selectedRow(inComponent: 0)].ID
            
            contractID = contractItemsArray[schedulePicker.selectedRow(inComponent: 0)].contractID!
            itemID = contractItemsArray[schedulePicker.selectedRow(inComponent: 0)].ID!
            
            contractTxtField.resignFirstResponder()
            
        }
        
        self.tasksToLog = []
        
        
        print("selectedTasks.count = \(selectedTasks.count)")
        for row in selectedTasks{
            self.tasksToLog.append(tasksArray[row])
            
            
            print("row = \(row)")
            //let indexPath = IndexPath(row: row, section: 0)
           // let cell:LeadTaskTableViewCell = tasksTableView.cellForRow(at: indexPath) as! LeadTaskTableViewCell
            //cell.unSetCheck()
            
            tasksArray[row].status = "1"
           // cell.task.status = "2"
            
            
        }
        
        selectedTasks = []
        tasksTableView.reloadData()
        
        print("tasksToLog count = \(self.tasksToLog.count)")
        
        
        
            tasksToLogJSON = []
            //loop thru usage array and build JSON array
            self.editsMade = false //resets edit checker
            for  (index,task) in tasksToLog.enumerated() {
                
                
                let JSONString = task.toJSONString(prettyPrint: true)
                tasksToLogJSON.append(JSON(JSONString ?? ""))
                print("task JSONString = \(String(describing: JSONString))")
                
                
             
                
            }
            callAlamoFire(_type: "new")
        }
        
        func callAlamoFire(_type:String){
            if(tasksToLogJSON.count > 0){
                indicator = SDevIndicator.generate(self.view)!
                
                
                
                self.editsMade = true
                
                var parameters:[String:String]
                parameters = [
                    "type":"1",
                    "itemID":"\(itemID)",
                    "leadTasks": "\(tasksToLogJSON)",
                    "createdBy":"\(self.appDelegate.loggedInEmployee!.ID!)"
                    
                    
                    
                ]
                
                print("parameters = \(parameters)")
                
                
                
                layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadTaskToItem.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("taskToItem response = \(response)")
                    }
                    .responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            //let updatedJSON = JSON(value)
                            self.indicator.dismissIndicator()
                            
                            
                            
                            self.tasksTableView.reloadData()
                        case .failure(let error):
                            self.indicator.dismissIndicator()
                            self.tasksTableView.reloadData()
                            print("Error: \(error)")
                        }
                        
                        self.updateTaskCountLabel()
                }
            }else{
                print("No Tasks to Link")
            }
            
        }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        if selectedTasks.count == 0{
            simpleAlert(_vc: self, _title: "Select Tasks", _message: "Tap select button at the top to multi select tasks or swipe to assign individual tasks.")
            textField.resignFirstResponder()
            return
        }
        
        if textField.tag == 1{
            pickerMode = "WORKORDER"
        }else{
            pickerMode = "CONTRACT"
        }
        
        print("pickermode = \(pickerMode)")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    
    
    
    func updateTaskCountLabel(){
        var assignedCount:Int = 0
        for task in tasksArray{
            if task.status == "1" || task.status == "2"{
                assignedCount += 1
            }
        }
        
        self.taskCountLbl.text = "\(tasksArray.count) Tasks, \(assignedCount) Assigned or Not Needed"
    }
    
   
    
   
    
    @objc func goBack(){
        var numberOfAssignedTasks:Int = 0
        for task in tasksArray{
            if task.status == "1"{
                numberOfAssignedTasks += 1
            }
        }
        
        
        
        
        _ = navigationController?.popViewController(animated: true)
        
        if self.editsMade == true{
            
            
            
            if numberOfAssignedTasks == 0{
                self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: "1")
            }else if numberOfAssignedTasks  < tasksArray.count{
                self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: "2")
            }else{
                self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: "3")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
   
    
    
   
    func updateTable(_points:Int){
        print("updateTable")
        //getLead()
    }
    
    
    
}

