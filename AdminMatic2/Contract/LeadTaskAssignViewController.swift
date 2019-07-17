//
//  LeadTaskAssignViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/1/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

 

class LeadTaskAssignViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate, LeadTaskDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    
    
    var multiButton:UIBarButtonItem!
    
    
    var lead:Lead2!
    
    var editDelegate:EditLeadDelegate!
    
    var json:JSON!
    var tasksArray:[Task2] = []
    var woItemsJson:JSON!
    var contractItemsJson:JSON!
    var woItemsArray:[WoItem2] = []
    var contractItemsArray:[ContractItem2] = []
    var selectedTasks:[Int] = []
    var selectedRow:Int!
    
    var taskCountLbl: UILabel! = UILabel()
    
    var tasksTableView: TableView!
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    
    var scheduleBtn:Button = Button(titleText: "Schedule Tasks")
    
    var scheduleTxtField:PaddedTextField!
    var schedulePicker: Picker!
    
    var contractBtn:Button = Button(titleText: "Contract Tasks")
    
    var contractTxtField:PaddedTextField!
    var contractPicker: Picker!
    
    var multiSelectMode:Bool = false
    
    var editsMade:Bool = false
    var tasksToLog: [Task2] = []//data array
    var tasksToLogJSON: [JSON] = []//data array
    
    var pickerMode: String = ""
    
    var woID:String = ""
    var contractID:String = ""
    
    var itemID:String = ""
    
    var fromContractItem:Bool = false
    var contractItem:ContractItem2?
    var fromWorkOrderItem:Bool = false
    var workOrderItem:WoItem2?
    
    var type:String = "1"
    
    //var setToItemBtn:Button = Button(titleText: "")
    
    var leadTaskDelegate:LeadTaskDelegate!
    
    init(_leadFromContractItem:Lead2, _contractItem:ContractItem2){
        super.init(nibName:nil,bundle:nil)
        
       // print("_leadFromContractItem")
        
        
        self.lead = _leadFromContractItem
        self.fromContractItem = true
        self.contractItem = _contractItem
        self.itemID = (self.contractItem?.ID)!
        self.type = "2"
        self.multiSelectMode = true
        //self.setToItemBtn.setTitle("Assign to \(String(describing: self.contractItem!.name!)) Item", for: .normal)
        //self.tasksArray = _tasks
        getLead()
    }
    
    init(_leadFromWorkOrderItem:Lead2, _workOrderItem:WoItem2){
        super.init(nibName:nil,bundle:nil)
        
        //print("_leadFromWorkOrderItem")
        
        self.lead = _leadFromWorkOrderItem
        self.fromWorkOrderItem = true
        self.workOrderItem = _workOrderItem
        self.itemID = (self.workOrderItem?.ID)!
        self.type = "1"
        self.multiSelectMode = true
        //print("workOrderItem Name = \(String(describing: self.workOrderItem!.name!))")
        //self.setToItemBtn.setTitle("Assign to \(String(describing: self.workOrderItem!.name!)) Item", for: .normal)
        //self.tasksArray = _tasks
        getLead()
    }
    
    init(_lead:Lead2, _tasks:[Task2]){
        super.init(nibName:nil,bundle:nil)
        
        //print("Basic init")
        
        self.lead = _lead
        self.tasksArray = _tasks
        
        indicator = SDevIndicator.generate(self.view)!
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(LeadViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
    }
   
    
    //sends request for lead tasks
    func getLead() {
        //print(" GetLead  Lead Id \(self.lead.ID)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.tasksArray = []
        let parameters:[String:String]
        parameters = ["leadID": self.lead.ID]
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leadTasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("lead response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    self.json = JSON(json)
                    self.parseTaskJSON()
                }
                //print(" dismissIndicator")
                //self.indicator.dismissIndicator()
        }
    }
    
    
    func parseTaskJSON(){
        //tasks
        let taskCount = self.json["leadTasks"].count
        for n in 0 ..< taskCount {
            var taskImages:[Image] = []
            
            let imageCount = Int((self.json["leadTasks"][n]["images"].count))
            //print("imageCount: \(imageCount)")
            for p in 0 ..< imageCount {
                let fileName:String = (self.json["leadTasks"][n]["images"][p]["fileName"].stringValue)
                let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                //print("rawPath = \(rawPath)")
                
                let image = Image(_id: self.json["leadTasks"][n]["images"][p]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["leadTasks"][n]["images"][p]["name"].stringValue,_width: self.json["leadTasks"][n]["images"][p]["width"].stringValue,_height: self.json["leadTasks"][n]["images"][p]["height"].stringValue,_description: self.json["leadTasks"][n]["images"][p]["description"].stringValue,_dateAdded: self.json["leadTasks"][n]["images"][p]["dateAdded"].stringValue,_createdBy: self.json["leadTasks"][n]["images"][p]["createdByName"].stringValue,_type: self.json["leadTasks"][n]["images"][p]["type"].stringValue)
                image.customer = (self.json["leadTasks"][n]["images"][p]["customer"].stringValue)
                image.tags = (self.json["leadTasks"][n]["images"][p]["tags"].stringValue)
                //print("appending image")
                taskImages.append(image)
            }
            
            let task = Task2(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue)
            
            
            
            
            
            
            //task.images = taskImages
            
            
            
            
            
            
            //let task = Task(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue, _images:taskImages)
            self.tasksArray.append(task)
        }
        //getStack()
        //self.layoutViews()
        
        getWoItems()
    }
    
    
    
    
    
    //sends request for lead tasks
    func getWoItems() {
        
        //print(" GetItems  Cust Id \(self.lead.customer)")
        
        title = "Loading Items..."
        
        // Show Loading Indicator
        //reset task array
        self.woItemsArray = []
        let parameters: [String:String] = ["custID": self.lead.customerID!]
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leadCustomerWoSearch.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("item response = \(response)")
            }
            .responseJSON(){
                response in
                if let woItemsJson = response.result.value {
                    //print("woItemsJson: \(woItemsJson)")
                    self.woItemsJson = JSON(woItemsJson)
                    self.parseWoItemsJSON()
                }
                //print(" dismissIndicator")
                //self.indicator.dismissIndicator()
        }
    }
    
    
    func parseWoItemsJSON(){
        //tasks
        let itemCount = self.woItemsJson["items"].count
        for n in 0 ..< itemCount {
            
           // let item = WoItem(_ID: self.woItemsJson["items"][n]["itemID"].stringValue, _name: self.woItemsJson["items"][n]["itemName"].stringValue, _woID: self.woItemsJson["items"][n]["woID"].stringValue, _woTitle: self.woItemsJson["items"][n]["woTitle"].stringValue)
            let item = WoItem2(_ID: self.woItemsJson["items"][n]["itemID"].stringValue, _name: self.woItemsJson["items"][n]["itemName"].stringValue, _type: self.woItemsJson["items"][n]["type"].stringValue, _sort: self.woItemsJson["items"][n]["sort"].stringValue, _status: self.woItemsJson["items"][n]["status"].stringValue, _charge: self.woItemsJson["items"][n]["charge"].stringValue, _total: self.woItemsJson["items"][n]["total"].stringValue)
            item.woID = self.woItemsJson["items"][n]["woID"].stringValue
            
            self.woItemsArray.append(item)
        }
        self.getContractItems()
    }
    
    
    //sends request for lead tasks
    func getContractItems() {
        
        //print(" GetContractItems  Cust Id \(self.lead.customer)")
        
        title = "Loading Items..."
        
        // Show Loading Indicator
        //indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.contractItemsArray = []
        let parameters: [String:String] = ["custID": self.lead.customerID!]
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leadCustomerContractSearch.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("item response = \(response)")
            }
            .responseJSON(){
                response in
                if let contractItemsJson = response.result.value {
                    //print("contractItemsJson: \(contractItemsJson)")
                    self.contractItemsJson = JSON(contractItemsJson)
                    self.parseContractItemsJSON()
                }
                //print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    
    func parseContractItemsJSON(){
        //tasks
        let itemCount = self.contractItemsJson["items"].count
        for n in 0 ..< itemCount {
            
           
           // let item = ContractItem(_ID: self.contractItemsJson["items"][n]["itemID"].stringValue, _contractID: self.contractItemsJson["items"][n]["contractID"].stringValue, _name: self.contractItemsJson["items"][n]["itemName"].stringValue, _contractTitle: self.contractItemsJson["items"][n]["contractTitle"].stringValue)
            
            let item = ContractItem2(_ID: self.contractItemsJson["items"][n]["itemID"].stringValue, _chargeType: self.contractItemsJson["items"][n]["chargeType"].stringValue, _contractID: self.contractItemsJson["items"][n]["contractID"].stringValue, _itemID: self.contractItemsJson["items"][n]["item"].stringValue, _name: self.contractItemsJson["items"][n]["itemName"].stringValue, _qty: self.contractItemsJson["items"][n]["qty"].stringValue)
            
            
            self.contractItemsArray.append(item)
        }
        self.layoutViews()
    }
    
    
    
    
    
    func layoutViews(){
        //print("layout views")
        title =  "Assign Tasks"
        
       
        
        if multiSelectMode == false{
            multiButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(LeadTaskAssignViewController.displayMultiSelectView))
            navigationItem.rightBarButtonItem = multiButton
        }
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.taskCountLbl.translatesAutoresizingMaskIntoConstraints = false
        self.taskCountLbl.font = layoutVars.buttonFont
        safeContainer.addSubview(self.taskCountLbl)
        
        updateTaskCountLabel()
        
       
        
        
        self.tasksTableView  =   TableView()
        self.tasksTableView.autoresizesSubviews = true
        self.tasksTableView.delegate  =  self
        self.tasksTableView.dataSource  =  self
        self.tasksTableView.layer.cornerRadius = 0
        self.tasksTableView.rowHeight = 90
        self.tasksTableView.register(LeadTaskTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.tasksTableView)
        
        
        /*
        self.addBtn.addTarget(self, action: #selector(LeadTaskAssignViewController.addTask), for: UIControlEvents.touchUpInside)
       safeContainer.addSubview(self.addBtn)
        */
        
        safeContainer.addSubview(self.scheduleBtn)
        
        
        //schedule picker
        self.schedulePicker = Picker()
        self.schedulePicker.tag = 1
       // print("statusValue : \(schedulePickerValue)")
        //print("set picker position : \(Int(self.statusValue)! - 1)")
        
        self.schedulePicker.delegate = self
        self.schedulePicker.dataSource = self
        
        self.scheduleTxtField = PaddedTextField(placeholder: "")
        self.scheduleTxtField.textAlignment = NSTextAlignment.center
        self.scheduleTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.scheduleTxtField.tag = 1
        self.scheduleTxtField.delegate = self
        self.scheduleTxtField.tintColor = UIColor.clear
        self.scheduleTxtField.backgroundColor = UIColor.clear
        self.scheduleTxtField.inputView = schedulePicker
        self.scheduleTxtField.layer.borderWidth = 0
        safeContainer.addSubview(self.scheduleTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadTaskAssignViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = BarButtonItem(title: "Assign", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadTaskAssignViewController.handleItemSelect))
        
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        scheduleTxtField.inputAccessoryView = toolBar
        
        safeContainer.addSubview(self.contractBtn)
        
        
        //contract picker
        self.contractPicker = Picker()
        self.contractPicker.tag = 2
        self.contractPicker.delegate = self
        self.contractPicker.dataSource = self
        
        self.contractTxtField = PaddedTextField(placeholder: "")
        self.contractTxtField.textAlignment = NSTextAlignment.center
        self.contractTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.contractTxtField.tag = 2
        self.contractTxtField.delegate = self
        self.contractTxtField.tintColor = UIColor.clear
        self.contractTxtField.backgroundColor = UIColor.clear
        self.contractTxtField.inputView = contractPicker
        self.contractTxtField.layer.borderWidth = 0
        safeContainer.addSubview(self.contractTxtField)
        
        let contractToolBar = UIToolbar()
        contractToolBar.barStyle = UIBarStyle.default
        contractToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        contractToolBar.sizeToFit()
        
        let closeContractButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadTaskAssignViewController.cancelPicker))
        let setContractButton = BarButtonItem(title: "Assign", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadTaskAssignViewController.handleItemSelect))
        
        contractToolBar.setItems([closeContractButton, spaceButton, setContractButton], animated: false)
        contractToolBar.isUserInteractionEnabled = true
        
        contractTxtField.inputAccessoryView = contractToolBar

        /*
        self.setToItemBtn.addTarget(self, action: #selector(LeadTaskAssignViewController.setToItem), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.setToItemBtn)
 */
 
        /////////  Auto Layout   //////////////////////////////////////
        
        let fullWidth = layoutVars.fullWidth - 30
        let halfWidth = (layoutVars.fullWidth - 38)/2
        let nameWidth = layoutVars.fullWidth - 150
        
        
        let metricsDictionary = ["fullWidth": fullWidth,"halfWidth": halfWidth, "nameWidth": nameWidth] as [String:Any]
        
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
        
        //,"setToItemBtn":self.setToItemBtn
        
        
        //print("1")
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[countLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[table]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        //print("2")
        
        // safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[addBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        if fromContractItem == true || fromWorkOrderItem == true{
            
            print("fromContractItem == true || fromWorkOrderItem == true")
           safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[contractBtn(halfWidth)]-[scheduleBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }else{
           
            //print("3")
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[contractBtn(halfWidth)]-[scheduleBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[contractTxt(halfWidth)]-[scheduleTxt]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }
        
        
        if fromContractItem == true || fromWorkOrderItem == true{
            print("4")
            
          // safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countLbl(30)][table]-[setToItemBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countLbl(30)][table]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }else{
           
            
            //print("5")
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countLbl(30)][table]-[scheduleBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countLbl(30)][table]-[scheduleTxt(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countLbl(30)][table]-[contractBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countLbl(30)][table]-[contractTxt(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }
       
        
    }
    
   
    func removeViews(){
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
  
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
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
                woLabel.textAlignment = .center
                woLabel.text = woString
                myView.addSubview(woLabel)
                
                
                var itemString = String()
                itemString = "\(woItemsArray[row].item) Item"
                let itemLabel = UILabel(frame: CGRect(x:60, y:30, width:pickerView.bounds.width - 60, height:30 ))
                itemLabel.font = layoutVars.buttonFont
                itemLabel.textAlignment = .center
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
                contractString =  "Contract #\(contractItemsArray[row].contractID)  \(contractItemsArray[row].contractTitle!)"
                
               
                
                let contractLabel = UILabel(frame: CGRect(x:0, y:0, width:pickerView.bounds.width, height:30 ))
                contractLabel.font = layoutVars.smallFont
                contractLabel.textAlignment = .center
                contractLabel.text = contractString
                myView.addSubview(contractLabel)
                
                
                var itemString = String()
                itemString = "\(contractItemsArray[row].name) Item # \(contractItemsArray[row].ID)"
                let itemLabel = UILabel(frame: CGRect(x:60, y:30, width:pickerView.bounds.width - 60, height:30 ))
                itemLabel.font = layoutVars.buttonFont
                itemLabel.textAlignment = .center
                itemLabel.text = itemString
                myView.addSubview(itemLabel)
            }
        }
       
        
        
        
        return myView
    }
 
 
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerMode == "WORKORDER"{
            self.type = "1"
            if row == woItemsArray.count{
                //print("new work order")
                
                
            }else{
                //print("row \(row) selected")
            }
        }else{
            self.type = "2"
            if row == woItemsArray.count{
                //print("new contract")
                
                
            }else{
                //print("row \(row) selected")
            }
        }
        
        self.selectedRow = row
        
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
        
         //print("cellForRowAt, selectTasks = \(selectedTasks)")
        
        let cell:LeadTaskTableViewCell = tasksTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTaskTableViewCell
        
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
            
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("selectTasks = \(selectedTasks)")
       
            if multiSelectMode {
                if self.selectedTasks.contains(indexPath.row) {
                    self.selectedTasks.remove(at: self.selectedTasks.index(of: indexPath.row)!)
                  
                    
                } else {
                    self.selectedTasks.append(indexPath.row)
                   
                }
                
                tasksTableView.reloadData()
            }else{
                
            
           /*
            
            
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Lead Task", _leadID: self.lead.ID, _leadTaskID: self.tasksArray[indexPath.row].ID, _customerID: self.lead.customerID!, _images: self.tasksArray[indexPath.row].images!)
                imageUploadPrepViewController.layoutViews()
                imageUploadPrepViewController.groupDescriptionTxt.text = self.tasksArray[indexPath.row].task
                imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
                imageUploadPrepViewController.selectedID = self.lead.customerID!
                imageUploadPrepViewController.groupImages = true
                imageUploadPrepViewController.attachmentDelegate = self
                self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
 
 */
 
 
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var editablity:Bool = true
        if multiSelectMode == true{
            editablity = false
        }
        
        return editablity
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
           
            
            self.editsMade = true
            
            var parameters:[String:String]
            parameters = ["id":self.tasksArray[indexPath.row].ID, "val":"2", "field":"status", "table":"leadTasks", "tableName":"projects"]
            
            //print("parameters = \(parameters)")
            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/changeField.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                //print(response.request ?? "")  // original URL request
                //print(response.result)   // result of response serialization
                
                }.responseString() {
                    response in
                    //print(response)  // original URL request
            }
            
            self.tasksArray[indexPath.row].status = "2"
            self.tasksTableView.reloadData()
            
            
            
            
        }
        notNeeded.backgroundColor = UIColor.orange
        
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("cancel button tapped")
            
            if(self.lead.createdBy == self.appDelegate.loggedInEmployee?.ID){
                if(self.tasksArray[indexPath.row].ID != "0"){
                    
                    
                    
                    
                    let alertController = UIAlertController(title: "Delete Task?", message: "Are you sure you want to delete this task?", preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                        (result : UIAlertAction) -> Void in
                        
                        // self.getWorkOrder()
                        
                    }
                    
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        
                        
                       
                        //print("delete lead task")
                        
                        
                        self.editsMade = true
                        
                        var parameters:[String:String]
                        parameters = [
                            "leadTaskID":self.tasksArray[indexPath.row].ID
                        ]
                        //print("parameters = \(parameters)")
                        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/leadTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                            response in
                            //print(response.request ?? "")  // original URL request
                            //print(response.result)   // result of response serialization
                            
                            }.responseString() {
                                response in
                                //print(response)  // original URL request
                        }
                        
                        self.tasksArray.remove(at: indexPath.row)
                        self.tasksTableView.reloadData()
                        
                        
                       
                        
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                    
                    
                    
                    
                    
                   
                    
                    
                }
            }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(),_title: "Can't delete lead tasks you didn't create.", _message: "")
                tableView.setEditing(false, animated: true)
            }
            
            
            
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, notNeeded, contract, schedule]
        
    }
    
    
    
    
    
    
    
    
    @objc func displayMultiSelectView(){
        //print("display Multi Select View")
        
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
    
  
    @objc func setToItem(){
        //print("set to item")
        //scheduleTxtField.resignFirstResponder()
        //contractTxtField.resignFirstResponder()
        
        self.tasksToLog = []
        
        
        //print("selectedTasks.count = \(selectedTasks.count)")
        for row in selectedTasks{
            self.tasksToLog.append(tasksArray[row])
            
            
            //print("row = \(row)")
            //let indexPath = IndexPath(row: row, section: 0)
            // let cell:LeadTaskTableViewCell = tasksTableView.cellForRow(at: indexPath) as! LeadTaskTableViewCell
            //cell.unSetCheck()
            
            tasksArray[row].status = "1"
            // cell.task.status = "2"
            
            
        }
        
        selectedTasks = []
        tasksTableView.reloadData()
        
        //print("tasksToLog count = \(self.tasksToLog.count)")
        
        
        
        tasksToLogJSON = []
        //loop thru usage array and build JSON array
        self.editsMade = true
        for  (_,task) in tasksToLog.enumerated() {
            
            
            let JSONString = task.toJSONString(prettyPrint: true)
            tasksToLogJSON.append(JSON(JSONString ?? ""))
            //print("task JSONString = \(String(describing: JSONString))")
            
            
            
            
        }
        callAlamoFire()
        
        
        
    }
    
    
    
    @objc func handleItemSelect(){
       // print("handleItemSelect selectedrow = \(schedulePicker.selectedRow(inComponent: 0))")
        
        //print("handleItemSelect selectedrow = \(self.selectedRow)")
        
        
        //print("pickerMode = \(pickerMode)")
        
        
        
        if pickerMode == "WORKORDER"{
            if self.selectedRow == woItemsArray.count || woItemsArray.count == 0{
                //print("needs new wo")
                
                //self.editsMade = true
                
                let editWoViewController = NewEditWoViewController(_lead: self.lead,_tasks: self.tasksArray)
                editWoViewController.leadTaskDelegate = self
                navigationController?.pushViewController(editWoViewController, animated: false )
                scheduleTxtField.resignFirstResponder()
                return
                
                //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Make New Work Order", _message: "This feature is coming soon.")
                //return
            }
            woID = woItemsArray[self.selectedRow].woID!
            itemID = woItemsArray[self.selectedRow].ID
            scheduleTxtField.resignFirstResponder()
        }else{
            
            if self.selectedRow == contractItemsArray.count || contractItemsArray.count == 0{
                //print("needs new contract")
                //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Make New Contract", _message: "This feature is coming soon.")
                //return
                
                //self.editsMade = true
                
                let editContractViewController = NewEditContractViewController(_lead: self.lead,_tasks: self.tasksArray)
                editContractViewController.leadTaskDelegate = self
                navigationController?.pushViewController(editContractViewController, animated: false )
                contractTxtField.resignFirstResponder()
                return
            }
            
          
            contractID = contractItemsArray[self.selectedRow].contractID
            itemID = contractItemsArray[self.selectedRow].ID
            
            contractTxtField.resignFirstResponder()
            
        }
        
        self.tasksToLog = []
        
        
        //print("selectedTasks.count = \(selectedTasks.count)")
        for row in selectedTasks{
            self.tasksToLog.append(tasksArray[row])
            
            
            //print("row = \(row)")
            //let indexPath = IndexPath(row: row, section: 0)
           // let cell:LeadTaskTableViewCell = tasksTableView.cellForRow(at: indexPath) as! LeadTaskTableViewCell
            //cell.unSetCheck()
            
            tasksArray[row].status = "1"
           // cell.task.status = "2"
            
            
        }
        
        selectedTasks = []
        tasksTableView.reloadData()
        
        //print("tasksToLog count = \(self.tasksToLog.count)")
        
        
        
            tasksToLogJSON = []
            //loop thru usage array and build JSON array
            //self.editsMade = false //resets edit checker
            for  (_,task) in tasksToLog.enumerated() {
                
                
                let JSONString = task.toJSONString(prettyPrint: true)
                tasksToLogJSON.append(JSON(JSONString ?? ""))
                //print("task JSONString = \(String(describing: JSONString))")
                
                
             
                
            }
            callAlamoFire()
        }
        
        func callAlamoFire(){
            if(tasksToLogJSON.count > 0){
                indicator = SDevIndicator.generate(self.view)!
                
                
                
                self.editsMade = true
                
                var parameters:[String:String] = [:]
                
                if pickerMode == "WORKORDER"{
                    
                    parameters = [
                        "type":self.type,
                        "itemID":"\(itemID)",
                        "leadTasks": "\(tasksToLogJSON)",
                        "createdBy":"\(self.appDelegate.loggedInEmployee!.ID!)",
                        "leadID":self.lead.ID,
                        "linkID":self.woID
                    ]
                }else{
                    parameters = [
                        "type":self.type,
                        "itemID":"\(itemID)",
                        "leadTasks": "\(tasksToLogJSON)",
                        "createdBy":"\(self.appDelegate.loggedInEmployee!.ID!)",
                        "leadID":self.lead.ID,
                        "linkID":self.contractID
                    ]
                }
                
                //print("parameters = \(parameters)")
                
                
                
                layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadTaskToItem.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        //print("taskToItem response = \(response)")
                    }
                    .responseJSON { response in
                        switch response.result {
                        case .success(_):
                            //let updatedJSON = JSON(value)
                            self.indicator.dismissIndicator()
                            
                            self.layoutVars.playSaveSound()
                            
                            self.tasksTableView.reloadData()
                        case .failure(_):
                            self.indicator.dismissIndicator()
                            self.tasksTableView.reloadData()
                            //print("Error: \(error)")
                            
                            self.layoutVars.playErrorSound()
                        }
                        
                        self.updateTaskCountLabel()
                }
            }else{
                //print("No Tasks to Link")
                
                
                    self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Select Tasks", _message: "Tap select button at the top to multi select tasks or swipe to assign individual tasks.")
                    //textField.resignFirstResponder()
                
               
                
                
            }
            
        }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        /*
        if selectedTasks.count == 0{
            simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Select Tasks", _message: "Tap select button at the top to multi select tasks or swipe to assign individual tasks.")
            textField.resignFirstResponder()
            return
        }
 */
        
        
        if textField.tag == 1{
            pickerMode = "WORKORDER"
        }else{
            pickerMode = "CONTRACT"
        }
        
        //print("pickermode = \(pickerMode)")
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
        
        
        
        
        //print("editsMade = \(editsMade)")
        
        if self.editsMade == true{
            
            
            var newStatusValue:String!
            
            if numberOfAssignedTasks == 0{
                newStatusValue = "1"
                //self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: "1")
            }else if numberOfAssignedTasks  < tasksArray.count{
                
                newStatusValue = "2"
                //self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: "2")
            }else{
                
                newStatusValue = "3"
                //self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: "3")
            }
            
            
            
            if(self.lead.statusID != newStatusValue && newStatusValue != "na"){
                //print("should update status _newStatusValue = \(newStatusValue)")
                
                var statusName = ""
                switch (newStatusValue) {
                case "1":
                    statusName = "Un-Done"
                    break;
                case "2":
                    statusName = "In Progress"
                    break;
                case "3":
                    statusName = "Done"
                    break;
                case "4":
                    statusName = "Cancel"
                    break;
                    
                default:
                    statusName = ""
                    break;
                }
                
                
                
                
                let alertController = UIAlertController(title: "Set Lead to \(statusName)", message: "", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    
                    
                    
                    self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: self.lead.statusID)
                    
                    _ = self.navigationController?.popViewController(animated: false)
                    
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    
                    
                    var parameters:[String:String]
                    
                    
                    parameters = [
                        "leadID":self.lead!.ID,
                        "status":"\(newStatusValue!)"
                    ]
                    //print("parameters = \(parameters)")
                    self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                        response in
                        //print(response.request ?? "")  // original URL request
                        //print(response.result)   // result of response serialization
                        //self.editsMade = true
                        //self.statusValue = self.statusValueToUpdate
                        //self.setStatus(status: _newStatusValue)
                        self.lead.statusID = newStatusValue
                        }.responseString() {
                            response in
                            //print(response)  // original URL request
                            
                            // self.getLead()
                            
                            self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: self.lead.statusID)
                            _ = self.navigationController?.popViewController(animated: false)
                    }
                    
                    
                    
                    
                    
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                
            }else{
                self.editDelegate.updateLead(_lead: self.lead, _newStatusValue: self.lead.statusID)
                 _ = navigationController?.popViewController(animated: false)
            }
            
            
            
            
            
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
   
    
    
   
    func updateTable(_points:Int){
        //print("updateTable")
        //getLead()
    }
    
    
   
    
    func handleNewContract(_contract: Contract2) {
        //print("handle new contract in assign view contract.ID: \(_contract.ID)")
        
        _ = self.navigationController?.popViewController(animated: false)
        
        self.leadTaskDelegate.handleNewContract(_contract:_contract)
        
        
    }
    
    func handleNewWorkOrder(_workOrder: WorkOrder2) {
       // print("handle new work order in assign view workOrder.ID: \(_workOrder.ID)")
        
    
        _ = self.navigationController?.popViewController(animated: false)
        
        self.leadTaskDelegate.handleNewWorkOrder(_workOrder: _workOrder)
    }
 
    
}

