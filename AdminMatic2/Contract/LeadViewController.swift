//
//  LeadViewController.swift
//  AdminMatic2
//
//  Created by Nick on 11/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol EditLeadDelegate{
    func updateLead(_lead:Lead,_newStatusValue:String)
    //func updateStack()
    
}

 
protocol LeadTaskDelegate{
    func handleNewContract(_contract:Contract)
    func handleNewWorkOrder(_workOrder:WorkOrder)
    
}





class LeadViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate, EditLeadDelegate, StackDelegate, LeadTaskDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
   
    var lead:Lead!
    var delegate:LeadListDelegate!
    
    var editButton:UIBarButtonItem!
    var editsMade:Bool = false
    
    var stackController:StackController!
    
    var statusIcon:UIImageView = UIImageView()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Not Started", "In Progress","Done","Cancel","Waiting"]
    var statusValue: String!
    var statusValueToUpdate: String!
    var customerBtn: Button!
    var infoView: UIView! = UIView()
    var scheduleLbl:GreyLabel!
    var schedule:GreyLabel!
    var scheduleDateFormatter:DateFormatter!
    var deadlineLbl:GreyLabel!
    var deadline:GreyLabel!
    var salesRepLbl:GreyLabel!
    var salesRep:GreyLabel!
    var urgentLbl:GreyLabel!
    var reqByCustLbl:GreyLabel!
    var reqByCust:GreyLabel!
    var descriptionLbl:GreyLabel!
    var descriptionView:UITextView!
    var tasksLbl:GreyLabel!
    var tasks: JSON!
    var tasksTableView: TableView!
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    
    var addBtn:Button = Button(titleText: "Add Tasks")
    var assignBtn:Button = Button(titleText: "Assign Tasks")
    
    
    
    init(_lead:Lead){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        self.lead = _lead
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
        
        
        
        showLoadingScreen()
    }
    
    
   
    
    
    func showLoadingScreen(){
        title = "Loading..."
        getLead()
    }
    

    //sends request for lead tasks
    func getLead() {
        //print(" GetLead  Lead Id \(self.lead.ID)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.lead.tasksArray = []
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
                
                
                
                
                //swifty way
                
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    self.json = JSON(json)
                    self.parseJSON()
                }
 
                 //print(" dismissIndicator")
                
                
                
        }
    }
    
    
    func parseJSON(){
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
                let task = Task(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue, _images:taskImages)
                self.lead.tasksArray.append(task)
            }
        self.indicator.dismissIndicator()
        self.layoutViews()
    }
    
    
   
    func layoutViews(){
        //print("layout views")
        title =  "Lead #" + self.lead.ID
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(LeadViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
      
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        stackController = StackController()
        stackController.delegate = self
        stackController.getStack(_type:0,_ID:self.lead.ID)
        safeContainer.addSubview(stackController)
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        setStatus(status: lead.statusId)
        
        //picker
        self.statusPicker = Picker()
        //print("statusValue : \(lead.statusId)")
        //print("set picker position : \(Int(lead.statusId)!)")
        
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
        
        
        self.statusPicker.selectRow(Int(lead.statusId)! - 1, inComponent: 0, animated: false)
      
        self.statusTxtField = PaddedTextField(placeholder: "")
        self.statusTxtField.textAlignment = NSTextAlignment.center
        self.statusTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.statusTxtField.tag = 1
        self.statusTxtField.delegate = self
        self.statusTxtField.tintColor = UIColor.clear
        self.statusTxtField.backgroundColor = UIColor.clear
        self.statusTxtField.inputView = statusPicker
        self.statusTxtField.layer.borderWidth = 0
        safeContainer.addSubview(self.statusTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = BarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadViewController.handleStatusChange))
        
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        statusTxtField.inputAccessoryView = toolBar
    
        self.customerBtn = Button(titleText: "\(self.lead.customerName!)")
        self.customerBtn.contentHorizontalAlignment = .left
        let custIcon:UIImageView = UIImageView()
        custIcon.backgroundColor = UIColor.clear
        custIcon.contentMode = .scaleAspectFill
        custIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        let custImg = UIImage(named:"custIcon.png")
        custIcon.image = custImg
        self.customerBtn.addSubview(custIcon)
        self.customerBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.customerBtn.addTarget(self, action: #selector(self.showCustInfo), for: UIControl.Event.touchUpInside)
        
        safeContainer.addSubview(customerBtn)
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        //self.infoView.layer.cornerRadius = 4
        self.infoView.layer.borderWidth = 1
        self.infoView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.infoView.layer.cornerRadius = 4.0
        safeContainer.addSubview(infoView)
        
        //date
        self.scheduleLbl = GreyLabel()
        self.scheduleLbl.text = "Schedule:"
        self.scheduleLbl.textAlignment = .left
        self.scheduleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(scheduleLbl)
        
        self.schedule = GreyLabel()
        self.schedule.text = self.lead.dateNice
        self.schedule.font = layoutVars.labelBoldFont
        self.schedule.textAlignment = .left
        self.schedule.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(schedule)
        
        //deadline
        self.deadlineLbl = GreyLabel()
        self.deadlineLbl.text = "Deadline:"
        self.deadlineLbl.textAlignment = .left
        self.deadlineLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(deadlineLbl)
        
        self.deadline = GreyLabel()
        self.deadline.text = self.lead.deadline
        self.deadline.font = layoutVars.labelBoldFont
        self.deadline.textAlignment = .left
        self.deadline.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(deadline)
        
        //sales rep
        self.salesRepLbl = GreyLabel()
        self.salesRepLbl.text = "Sales Rep:"
        self.salesRepLbl.textAlignment = .left
        self.salesRepLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRepLbl)
        
        self.salesRep = GreyLabel()
        self.salesRep.text = self.lead.repName
        self.salesRep.font = layoutVars.labelBoldFont
        self.salesRep.textAlignment = .left
        self.salesRep.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRep)
        
        //urgent
        self.urgentLbl = GreyLabel()
        self.urgentLbl.text = "\u{22C6}URGENT\u{22C6}"
        self.urgentLbl.textColor = UIColor.red
        self.urgentLbl.textAlignment = .left
        self.urgentLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(urgentLbl)
        
        
        //req by cust
        self.reqByCustLbl = GreyLabel()
        self.reqByCustLbl.text = "Requsted By Customer:"
        self.reqByCustLbl.textAlignment = .left
        self.reqByCustLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(reqByCustLbl)
        
        self.reqByCust = GreyLabel()
        if(self.lead.requestedByCust == "0"){
            self.reqByCust.text = "NO"
        }else{
            self.reqByCust.text = "YES"
        }
        self.reqByCust.font = layoutVars.labelBoldFont
        self.reqByCust.textAlignment = .left
        self.reqByCust.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(reqByCust)
        
        
        //description
        self.descriptionLbl = GreyLabel()
        self.descriptionLbl.text = "Description:"
        self.descriptionLbl.textAlignment = .left
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(descriptionLbl)
        
        self.descriptionView = UITextView()
        self.descriptionView.text = self.lead.description
        self.descriptionView.font = layoutVars.textFieldFont
        self.descriptionView.isEditable = false
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(descriptionView)
        
        //tasks
        self.tasksLbl = GreyLabel()
        self.tasksLbl.text = "Tasks:"
        self.tasksLbl.textAlignment = .left
        self.tasksLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(tasksLbl)
        
        self.tasksTableView  =   TableView()
        self.tasksTableView.autoresizesSubviews = true
        self.tasksTableView.delegate  =  self
        self.tasksTableView.dataSource  =  self
        self.tasksTableView.layer.cornerRadius = 4
        self.tasksTableView.rowHeight = 90
        self.tasksTableView.register(LeadTaskTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.tasksTableView)
        
        
        self.addBtn.addTarget(self, action: #selector(LeadViewController.addTask), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.addBtn)
        
        
        self.assignBtn.addTarget(self, action: #selector(LeadViewController.assignTasks), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.assignBtn)
        
        
        if lead.tasksArray.count == 0{
            newLeadMessage()
        }
        /////////  Auto Layout   //////////////////////////////////////
        
        let fullWidth = layoutVars.fullWidth - 30
        let halfWidth = (layoutVars.fullWidth - 38)/2
        let nameWidth = layoutVars.fullWidth - 150
        
        let metricsDictionary = ["fullWidth": fullWidth,"halfWidth": halfWidth, "nameWidth": nameWidth] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "stackController":self.stackController,
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "tasksLbl":self.tasksLbl,
            "table":self.tasksTableView,
            "assignBtn":self.assignBtn,
            "addBtn":self.addBtn
            ] as [String:AnyObject]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackController]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusIcon(40)]-15-[customerBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[info]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tasksLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[table]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[addBtn(halfWidth)]-[assignBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(180)]-[tasksLbl(22)][table]-[addBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[assignBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        
        //auto layout group
        let infoDictionary = [
            "scheduleLbl":self.scheduleLbl,
            "schedule":self.schedule,
            "deadlineLbl":self.deadlineLbl,
            "deadline":self.deadline,
            "salesRepLbl":self.salesRepLbl,
            "salesRep":self.salesRep,
            "urgentLbl":self.urgentLbl,
            "reqByCustLbl":self.reqByCustLbl,
            "reqByCust":self.reqByCust,
            "descriptionLbl":self.descriptionLbl,
            "description":self.descriptionView
            ] as [String:AnyObject]
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[scheduleLbl(85)][schedule]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        if(self.lead.urgent == "1"){
            self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[deadlineLbl(80)][deadline]-[urgentLbl(120)]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        }else{
             self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[deadlineLbl(80)]-[deadline]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
            self.urgentLbl.isHidden = true;
        }
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[salesRepLbl(80)]-[salesRep]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[reqByCustLbl(200)][reqByCust]-|", options: NSLayoutConstraint.FormatOptions.alignAllTop, metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllTop, metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[description]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scheduleLbl(22)][deadlineLbl(22)][salesRepLbl(22)][reqByCustLbl(22)][descriptionLbl(22)][description]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[schedule(22)][deadline(22)][salesRep(22)][reqByCust(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        if(self.lead.urgent == "1"){
            self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[schedule(22)][urgentLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        }
    }
    
    func newLeadMessage(){
        
        let alertController = UIAlertController(title: "Add Tasks/Images Now?", message: "This lead has no tasks or images added.", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            //print("No")
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            //print("Yes")
            
            self.addTask()
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    @objc func showCustInfo() {
        ////print("SHOW CUST INFO")
        let customerViewController = CustomerViewController(_customerID: self.lead.customer,_customerName: self.lead.customerName)
        navigationController?.pushViewController(customerViewController, animated: false )
    }
    
    func removeViews(){
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //picker methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    */

    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        return self.statusArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:60))
        let myImageView = UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
        var rowString = String()
        rowString = statusArray[row]
        
        switch row {
        case 0:
            myImageView.image = UIImage(named:"unDoneStatus.png")
            break;
        case 1:
            myImageView.image = UIImage(named:"inProgressStatus.png")
            break
        case 2:
            myImageView.image = UIImage(named:"doneStatus.png")
            break
        case 3:
            myImageView.image = UIImage(named:"cancelStatus.png")
            break
        case 4:
            myImageView.image = UIImage(named:"waitingStatus.png")
            break
        default:
            myImageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
        myLabel.font = layoutVars.smallFont
        myLabel.text = rowString
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.statusValueToUpdate = "\(row + 1)"
    }
    
    @objc func cancelPicker(){
        self.statusTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        self.statusTxtField.resignFirstResponder()
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            var parameters:[String:String]
            
           
            
            
             parameters = [
             "leadID":self.lead.ID,
             "status":"\(self.statusPicker.selectedRow(inComponent: 0) + 1)"
             ]
            //print("parameters = \(parameters)")
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                //print(response.request ?? "")  // original URL request
                //print(response.result)   // result of response serialization
                self.editsMade = true
                self.statusValue = self.statusValueToUpdate
                self.setStatus(status: self.statusValue)
                self.lead.statusId = self.statusValue
                }.responseString() {
                    response in
                    //print(response)  // original URL request
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        count = self.lead.tasksArray.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:LeadTaskTableViewCell = tasksTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTaskTableViewCell
        //if(indexPath.row == self.tasksArray.count){
        
            cell.task = self.lead.tasksArray[indexPath.row]
            cell.layoutViews()
            cell.setConstraints()
       // }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == self.lead.tasksArray.count){
            self.addTask()
        }else{
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Lead Task", _leadID: self.lead.ID, _leadTaskID: self.lead.tasksArray[indexPath.row].ID, _customerID: self.lead.customer, _images: self.lead.tasksArray[indexPath.row].images)
            imageUploadPrepViewController.layoutViews()
            imageUploadPrepViewController.groupDescriptionTxt.text = self.lead.tasksArray[indexPath.row].task
            imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
            imageUploadPrepViewController.selectedID = self.lead.customer
            imageUploadPrepViewController.groupImages = true
            imageUploadPrepViewController.attachmentDelegate = self
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      
            return true
       
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
            
            if(lead.createdBy == appDelegate.loggedInEmployee?.ID){
                if(lead.tasksArray[indexPath.row].ID != "0"){
                    
                
                    //print("delete lead task")
                    
                    var parameters:[String:String]
                    parameters = [
                        "leadTaskID":lead.tasksArray[indexPath.row].ID
                    ]
                    //print("parameters = \(parameters)")
                    layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/leadTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                        response in
                        //print(response.request ?? "")  // original URL request
                        //print(response.result)   // result of response serialization
                        
                        }.responseString() {
                            response in
                            //print(response)  // original URL request
                    }
                    
                    lead.tasksArray.remove(at: indexPath.row)
                    tasksTableView.reloadData()
                    
                    
                }
            }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(),_title: "Can't delete lead tasks you didn't create.", _message: "")
                tableView.setEditing(false, animated: true)
            }
            
            
        }
    }
    
    
    
    
    
    @objc func addTask(){
        //print("add task")
        
        //if(delegate != nil){
           // delegate.cancelSearch()
       // }
        
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Lead Task", _leadID: self.lead.ID, _leadTaskID: "0", _customerID: self.lead.customer, _images: [])
         imageUploadPrepViewController.layoutViews()
         imageUploadPrepViewController.groupImages = true
         imageUploadPrepViewController.attachmentDelegate = self
         self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    
    
    @objc func assignTasks(){
        //print("Assign Tasks")
        
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            if lead.tasksArray.count == 0{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Tasks to Assign", _message: "You need to add some tasks to assign them to a work order or contract")
                return
            }
            
            let leadTaskAssignViewController = LeadTaskAssignViewController(_lead: self.lead, _tasks: self.lead.tasksArray)
            leadTaskAssignViewController.editDelegate = self
            leadTaskAssignViewController.leadTaskDelegate = self
            leadTaskAssignViewController.getWoItems()
            
            //editLeadViewController.delegate = self
            navigationController?.pushViewController(leadTaskAssignViewController, animated: false )
        }
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
    
    @objc func displayEditView(){
        //print("display Edit View")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            let editLeadViewController = NewEditLeadViewController(_lead: self.lead,_tasks: self.lead.tasksArray)
            editLeadViewController.editDelegate = self
            navigationController?.pushViewController(editLeadViewController, animated: false )
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    // This triggers the textFieldDidEndEditing method that has the textField within it.
    //  This then triggers the resign() method to remove the keyboard.
    //  We use this in the "done" button action.
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    
    func setStatus(status: String) {
        //print("set status \(status)")
        switch (status) {
        case "1":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "4":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        case "5":
            let statusImg = UIImage(named:"waitingStatus.png")
            statusIcon.image = statusImg
            break;
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    
    
    func updateLead(_lead: Lead, _newStatusValue:String){
        //print("update Lead")
        editsMade = true
        self.lead = _lead
        
        
        self.setStatus(status: self.lead.statusId)
        
        
        if(self.lead.statusId != _newStatusValue && _newStatusValue != "na"){
            //print("should update status _newStatusValue = \(_newStatusValue)")
        
            var statusName = ""
            switch (_newStatusValue) {
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
                
                
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                
                var parameters:[String:String]
                
                
                parameters = [
                    "leadID":self.lead.ID,
                    "status":"\(_newStatusValue)"
                ]
                //print("parameters = \(parameters)")
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    //print(response.request ?? "")  // original URL request
                    //print(response.result)   // result of response serialization
                    self.editsMade = true
                    self.setStatus(status: _newStatusValue)
                    self.lead.statusId = _newStatusValue
                    }.responseString() {
                        response in
                        //print(response)  // original URL request
                }
                
                
                
               
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
        }
        
        getLead()
        
    }
    
    
    //Stack Delegates
    func displayAlert(_title: String) {
        //print("_title = \(_title)")
        //print("top vc = \(self.layoutVars.getTopController())")
        layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: _title, _message: "")
    }
    
    
    func newLeadView(_lead:Lead){
        
        //let leadViewController:LeadViewController = LeadViewController(_lead: lead)
        //leadViewController
        //self.navigationController?.pushViewController(leadViewController, animated: false )
        
    }
    
    
    func newContractView(_contract:Contract){
        
        let contractViewController:ContractViewController = ContractViewController(_contract: _contract)
        //contractViewController.
        contractViewController.editLeadDelegate = self
        self.navigationController?.pushViewController(contractViewController, animated: false )
        
    }
    
    func newWorkOrderView(_workOrder:WorkOrder){
        
        //self.navigationController?.pushViewController(_view, animated: false )
        let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrderID: _workOrder.ID)
        workOrderViewController.editLeadDelegate = self
        self.navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
    }
    
    func newInvoiceView(_invoice:Invoice){
        
        
        let invoiceViewController:InvoiceViewController = InvoiceViewController(_invoice: _invoice)
        self.navigationController?.pushViewController(invoiceViewController, animated: false )
        
        //self.navigationController?.pushViewController(_view, animated: false )
        
    }
    
    
    func setLeadTasksWaiting(_leadTasksWaiting:String){
        
    }
    /*
    func getLead(_lead:Lead){
        
    }
    */
    
    
    func suggestNewContractFromLead(){
        //print("suggestNewContractFromLead")
        
        
        let alertController = UIAlertController(title: "No Contract Exists", message: "Would you like to link a new Contract now?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            //print("No")
            //_ = self.navigationController?.popViewController(animated: true)
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            //print("Yes")
            
            if self.layoutVars.grantAccess(_level: 1,_view: self) {
                return
            }else{
                let editContractViewController = NewEditContractViewController(_lead: self.lead,_tasks: self.lead.tasksArray)
                editContractViewController.leadTaskDelegate = self
                self.navigationController?.pushViewController(editContractViewController, animated: false )
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
        
        
       
        
    }
    
    func suggestNewWorkOrderFromLead(){
        //print("suggestNewWorkOrderFromLead")
        
        
        let alertController = UIAlertController(title: "No WorkOrder Exists", message: "Would you like to link a new WorkOrder now?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            //print("No")
            //_ = self.navigationController?.popViewController(animated: true)
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            //print("Yes")
            if self.layoutVars.grantAccess(_level: 1,_view: self) {
                return
            }else{
                let editWoViewController = NewEditWoViewController(_lead: self.lead,_tasks: self.lead.tasksArray)
                editWoViewController.leadTaskDelegate = self
            
                self.navigationController?.pushViewController(editWoViewController, animated: false )
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
        
        
        
       
    
    }
    
    
    //following not needed for this vc
    func suggestNewWorkOrderFromContract(){
        //print("suggestNewWorkOrderFromContract")
    }
    
    
    
    
    
    
    func updateTable(_points:Int){
        //print("updateTable")
        getLead()
    }
    
    func updateLeadTable(){
        //print("updateLeadTable")
        delegate.getLeads(_openNewLead: false)
        goBack()
        
    }
    
    
    
    //leadTaskDelegate Methods
    func handleNewContract(_contract: Contract) {
        //print("handle new contract in lead view")
        
        //print("handle new contract in lead view contract.ID: \(_contract.ID)")
        
        
        
        let contractViewController:ContractViewController = ContractViewController(_contract: _contract)
        contractViewController.contract.lead = self.lead
        
        self.navigationController?.pushViewController(contractViewController, animated: false )
        
        
        updateLead(_lead: self.lead, _newStatusValue: self.lead.statusId)
        
    }
    
    func handleNewWorkOrder(_workOrder: WorkOrder) {
       // print("handle new work order in lead view")
       // print("handle new work order in lead view workOrder.ID: \(_workOrder.ID)")

        
        let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrderID: _workOrder.ID)
       // workOrderViewController.workOrder.lead = self.lead
        
        self.navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
    }
    
   
    
    
    @objc func goBack(){
        if(editsMade == true){
            if delegate != nil{
                delegate.getLeads(_openNewLead: false)
            }
        }
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    
    
}
