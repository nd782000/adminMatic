//
//  LeadViewController.swift
//  AdminMatic2
//
//  Created by Nick on 11/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol EditLeadDelegate{
    func updateLead(_lead:Lead)
    
}


class LeadViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate, EditLeadDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    //var scrollView: UIScrollView!
    var json:JSON!
    var lead:Lead!
    var delegate:LeadListDelegate!
    
    var editButton:UIBarButtonItem!
    var editsMade:Bool = false
    var statusIcon:UIImageView = UIImageView()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Un-Done","In Progress","Done","Cancel","Waiting"]
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
    var tasksArray:[Task] = []
    var tasksTableView: TableView!
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    
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
        title = "Loading..."
        getLead()
    }
    

    //sends request for lead tasks
    func getLead() {
        print(" GetLead  Lead Id \(self.lead.ID)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.tasksArray = []
        let parameters = ["leadID": self.lead.ID as AnyObject]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leadTasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("lead response = \(response)")
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
            let taskCount = self.json["leadTasks"].count
            for n in 0 ..< taskCount {
                var taskImages:[Image] = []
                
                let imageCount = Int((self.json["leadTasks"][n]["images"].count))
                print("imageCount: \(imageCount)")
                for p in 0 ..< imageCount {
                    let fileName:String = (self.json["leadTasks"][n]["images"][p]["fileName"].stringValue)
                    let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                    let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                    let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                    print("rawPath = \(rawPath)")
                    
                    let image = Image(_id: self.json["leadTasks"][n]["images"][p]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["leadTasks"][n]["images"][p]["name"].stringValue,_width: self.json["leadTasks"][n]["images"][p]["width"].stringValue,_height: self.json["leadTasks"][n]["images"][p]["height"].stringValue,_description: self.json["leadTasks"][n]["images"][p]["description"].stringValue,_dateAdded: self.json["leadTasks"][n]["images"][p]["dateAdded"].stringValue,_createdBy: self.json["leadTasks"][n]["images"][p]["createdByName"].stringValue,_type: self.json["leadTasks"][n]["images"][p]["type"].stringValue)
                    image.customer = (self.json["leadTasks"][n]["images"][p]["customer"].stringValue)
                    image.tags = (self.json["leadTasks"][n]["images"][p]["tags"].stringValue)
                    print("appending image")
                    taskImages.append(image)
                }
                let task = Task(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue, _images:taskImages)
                self.tasksArray.append(task)
            }
        self.layoutViews()
    }
    
    
    func layoutViews(){
        print("layout views")
        title =  "Lead #" + self.lead.ID
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(LeadViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
      
        
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        self.view.addSubview(statusIcon)
        setStatus(status: lead.statusId)
        
        //picker
        self.statusPicker = Picker()
        print("statusValue : \(lead.statusId)")
        print("set picker position : \(Int(lead.statusId)! - 1)")
        
        self.statusPicker.delegate = self
        
        //self.statusPicker.selectRow(Int(lead.statusId)! - 1, inComponent: 0, animated: false)
        
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
        self.view.addSubview(self.statusTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(WorkOrderViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Set Status", style: UIBarButtonItemStyle.plain, target: self, action: #selector(WorkOrderViewController.handleStatusChange))
        
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
        self.customerBtn.addTarget(self, action: #selector(WorkOrderViewController.showCustInfo), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(customerBtn)
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.infoView.layer.cornerRadius = 4
        self.view.addSubview(infoView)
        
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
        self.tasksTableView.layer.cornerRadius = 0
        self.tasksTableView.rowHeight = 70
        self.tasksTableView.register(LeadTaskTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tasksTableView)
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "tasksLbl":self.tasksLbl,
            "table":self.tasksTableView,
            ] as [String:AnyObject]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusIcon(40)]-15-[customerBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[info]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tasksLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[table]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[customerBtn(40)]-[info(200)]-[tasksLbl(22)][table]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        
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
        }
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[salesRepLbl(80)]-[salesRep]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[reqByCustLbl(200)][reqByCust]-|", options: NSLayoutFormatOptions.alignAllTop, metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: NSLayoutFormatOptions.alignAllTop, metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[description]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scheduleLbl(22)][deadlineLbl(22)][salesRepLbl(22)][reqByCustLbl(22)][descriptionLbl(22)][description]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[schedule(22)][deadline(22)][salesRep(22)][reqByCust(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        if(self.lead.urgent == "1"){
            self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[schedule(22)][urgentLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        }
    }
    
    func showCustInfo() {
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
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    

    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        return self.statusArray.count - 2
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
            break
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
    
    func cancelPicker(){
        //self.statusValueToUpdate = self.statusValue
        self.statusTxtField.resignFirstResponder()
    }
    
    func handleStatusChange(){
        self.statusTxtField.resignFirstResponder()
        var parameters:[String:String]
         parameters = [
         "leadID":self.lead.ID,
         "status":"\(self.statusPicker.selectedRow(inComponent: 0))",
         "empID":(self.appDelegate.loggedInEmployee?.ID)!
         ]
        print("parameters = \(parameters)")
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            print(response.result)   // result of response serialization
            self.statusValue = self.statusValueToUpdate
            self.setStatus(status: self.statusValue)
            self.lead.statusId = self.statusValue
            }.responseString() {
                response in
                print(response)  // original URL request
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        count = self.tasksArray.count + 1
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:LeadTaskTableViewCell = tasksTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTaskTableViewCell
        if(indexPath.row == self.tasksArray.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            cell.task = self.tasksArray[indexPath.row]
            cell.layoutViews()
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == self.tasksArray.count){
            self.addTask()
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
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      
            return true
       
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            
            if(lead.createdBy == appDelegate.loggedInEmployee?.ID){
                if(tasksArray[indexPath.row].ID != "0"){
                    
                
                    print("delete lead task")
                    
                    var parameters:[String:String]
                    parameters = [
                        "leadTaskID":tasksArray[indexPath.row].ID
                    ]
                    print("parameters = \(parameters)")
                    layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/leadTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                        response in
                        print(response.request ?? "")  // original URL request
                        print(response.result)   // result of response serialization
                        
                        }.responseString() {
                            response in
                            print(response)  // original URL request
                    }
                    
                    tasksArray.remove(at: indexPath.row)
                    tasksTableView.reloadData()
                    
                    
                    
                    
                    /*
                    usageToLog[indexPath.row].del = "1"
                    usageToLogJSON = []
                    let JSONString = usageToLog[indexPath.row].toJSONString(prettyPrint: true)
                    usageToLogJSON.append(JSON(JSONString ?? ""))
                    print("usage JSONString = \(String(describing: JSONString))")
                    callAlamoFire(_type: "delete")
                    usageToLog.remove(at: indexPath.row)
                    usageTableView.reloadData()
 */
                    
                }
            }else{
                simpleAlert(_vc: self,_title: "Can't delete lead tasks you didn't create.", _message: "")
                tableView.setEditing(false, animated: true)
            }
            
            
        }
    }
    
    
    
    
    
    func addTask(){
        print("add task")
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Lead Task", _leadID: self.lead.ID, _leadTaskID: "0", _customerID: self.lead.customer, _images: [])
         imageUploadPrepViewController.layoutViews()
         imageUploadPrepViewController.groupImages = true
         imageUploadPrepViewController.attachmentDelegate = self
         self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    
    /*
    func handleDatePicker()
    {
        ////print("DATE: \(dateFormatter.stringFromDate(datePickerView.date))")
        // self.dateTxtField.text =  dateFormatter.string(from: datePickerView.date)
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //let offset = (textField.frame.origin.y - 150)
        //let scrollPoint : CGPoint = CGPoint(x: 0, y: offset)
        //self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    */
    
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
        print("display Edit View")
        let editLeadViewController = NewEditLeadViewController(_lead: self.lead,_tasks: self.tasksArray)
        editLeadViewController.editDelegate = self
        navigationController?.pushViewController(editLeadViewController, animated: false )
    }
    
    
    @objc func goBack(){
        if(editsMade == true){
            delegate.getLeads()
        }
        _ = navigationController?.popViewController(animated: true)
        
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
        print("set status \(status)")
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
    
    func updateLead(_lead: Lead){
        print("update Lead")
        editsMade = true
        self.lead = _lead
        self.layoutViews()
        
    }
    
    func updateTable(_points:Int){
        print("updateTable")
        getLead()
    }
    
    func updateLeadTable(){
        print("updateLeadTable")
        delegate.getLeads()
        goBack()
        
    }
    
    
}
