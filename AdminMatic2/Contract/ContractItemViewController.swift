//
//  ContractItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ContractItemViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate, EditLeadDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    var contractDelegate:EditContractDelegate!
    var leadDelegate:EditLeadDelegate!
    
    
    var editsMade:Bool = false
    
    var contract:Contract!
    var contractItem:ContractItem!
    
    //container views
    var itemView:UIView!
    var detailsView:UIView!
    
    var itemLbl:GreyLabel!
    
    var estLabel:Label!
    var estValueLabel:Label!
    
    var priceLabel:Label!
    var priceValueLabel:Label!
    
    var totalLabel:Label!
    var totalValueLabel:Label!
    
    var taxableLabel:Label!
    
    //details view

    var itemDetailsTableView:TableView = TableView()
    
    var tasksJson:JSON?
    var json:JSON!
    var lead:Lead?
    var leadTasksWaiting:String?
    var leadTasksWaitingBtn:Button = Button(titleText: "Open LeadTasks to Assign...")
    

    var imageUploadPrepViewController:ImageUploadPrepViewController!
    

    init(_contract:Contract,_contractItem:ContractItem){
        super.init(nibName:nil,bundle:nil)
        self.contract = _contract
        self.contractItem = _contractItem
        //self.tasks = _tasks
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        
        print("contractItem = \(self.contract.ID)")
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Contract Item #" + self.contractItem.ID
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(WoItemViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func layoutViews(){
        print("item view layoutViews 1")
        //////////   containers for different sections
        self.itemView = UIView()
        self.itemView.backgroundColor = layoutVars.backgroundColor
        self.itemView.layer.borderColor = layoutVars.borderColor
        self.itemView.layer.borderWidth = 1.0
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.itemView)
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.detailsView)
        
        
        ////print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemView,
            "view2":self.detailsView] as [String:AnyObject]
        
        let sizeVals = ["width": layoutVars.fullWidth as AnyObject,"height": 24  as AnyObject,"fullHeight":layoutVars.fullHeight - 224  as AnyObject]  as [String:AnyObject]
        
        //////////////////   auto layout position constraints   /////////////////////////////
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1(125)][view2]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        ///////////   wo item header section   /////////////
        
       
        
       
        self.itemLbl = GreyLabel()
        self.itemLbl.text = self.contractItem.name
        self.itemLbl.font = layoutVars.largeFont
        self.itemView.addSubview(self.itemLbl)
        
        self.estLabel = Label()
        self.estLabel.font = layoutVars.smallFont
        self.estLabel.text = "Estimated:"
        self.itemView.addSubview(self.estLabel)
        
        self.estValueLabel = Label()
        self.estValueLabel.font = layoutVars.smallBoldFont
        self.estValueLabel.text = self.contractItem.qty!
        self.itemView.addSubview(self.estValueLabel)
        
        
        self.priceLabel = Label()
        self.priceLabel.font = layoutVars.smallFont
        self.priceLabel.text = "Unit Price:"
        self.itemView.addSubview(self.priceLabel)
        
        self.priceValueLabel = Label()
        self.priceValueLabel.font = layoutVars.smallBoldFont
        self.priceValueLabel.text = layoutVars.numberAsCurrency(_number: self.contractItem.price!)
        self.itemView.addSubview(self.priceValueLabel)
        
        
        
        self.totalLabel = Label()
        self.totalLabel.font = layoutVars.smallFont
        self.totalLabel.text = "Total:"
        self.itemView.addSubview(self.totalLabel)
        
        self.totalValueLabel = Label()
        self.totalValueLabel.font = layoutVars.smallBoldFont
        self.totalValueLabel.text = layoutVars.numberAsCurrency(_number: self.contractItem.total!)
        self.itemView.addSubview(self.totalValueLabel)
        
        self.taxableLabel = Label()
        self.taxableLabel.font = layoutVars.smallFont
        self.taxableLabel.textAlignment = .right
        if self.contractItem.taxCode == "0"{
            self.taxableLabel.text = "Non-Taxable"
        }else{
            self.taxableLabel.text = "Taxable"
        }
        
        self.itemView.addSubview(self.taxableLabel)
        
       
        
        
        let itemNameViewsDictionary = ["itemLbl":self.itemLbl,"estLbl":self.estLabel,"estValueLbl":self.estValueLabel,"priceLbl":self.priceLabel,"priceValueLbl":self.priceValueLabel,"totalLbl":self.totalLabel,"totalValueLbl":self.totalValueLabel,"taxableLbl":self.taxableLabel]  as [String:AnyObject]
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[itemLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        //self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[estLbl(100)][estValueLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[estLbl(100)][estValueLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[priceLbl(100)][priceValueLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[totalLbl(100)][totalValueLbl][taxableLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(35)][estLbl(25)][priceLbl(25)][totalLbl(25)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(35)][estValueLbl(25)][priceValueLbl(25)][totalValueLbl(25)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(35)][estLbl(25)][priceLbl(25)][taxableLbl(25)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        
        
        
        ///////////   Item Details Section   /////////////
        
        self.leadTasksWaitingBtn.addTarget(self, action: #selector(ContractItemViewController.assignLeadTasks), for: UIControlEvents.touchUpInside)
        //self.detailsView.addSubview(self.leadTasksWaitingBtn)
        
        self.itemDetailsTableView.delegate  =  self
        self.itemDetailsTableView.dataSource = self
        
        self.itemDetailsTableView.rowHeight = UITableViewAutomaticDimension
        self.itemDetailsTableView.estimatedRowHeight = 100.0
        
        
        self.itemDetailsTableView.register(ContractTaskTableViewCell.self, forCellReuseIdentifier: "cell")
        //self.detailsView.addSubview(itemDetailsTableView)
        
        
        /*
        
        //auto layout group
        let itemDetailsViewsDictionary = [
            "view1":leadTasksWaitingBtn,
            "view2":itemDetailsTableView
            ]  as [String:AnyObject]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2]|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        
       */
        
        
        //print("leadTasksWaiting \(leadTasksWaiting)")
        //print("contractItem.type \(contractItem.type!)")
        
        if self.leadTasksWaiting! == "1" && self.contractItem.type! == "1"{
            
            showLeadTaskBtn()
            
            //print("leadTasksWaiting")
            
             //self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)][view2]|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            
            //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Lead Tasks To Assign", _message: ""
            //)
        }else{
            
            hideLeadTaskBtn()
            
             //self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view2(fullHeight)]", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        }
    }
    
    
    
    
    func showLeadTaskBtn(){
        print("showLeadTaskBtn")
        self.detailsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.detailsView.addSubview(self.leadTasksWaitingBtn)
        self.detailsView.addSubview(itemDetailsTableView)
        
        //auto layout group
        let itemDetailsViewsDictionary = [
            "view1":leadTasksWaitingBtn,
            "view2":itemDetailsTableView
            ]  as [String:AnyObject]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)][view2]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))


    }
    
    func hideLeadTaskBtn(){
        print("hideLeadTaskBtn")
        self.detailsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.detailsView.addSubview(itemDetailsTableView)
        
        let itemDetailsViewsDictionary = [
            "view1":itemDetailsTableView
            ]  as [String:AnyObject]
        
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
    
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
    }
    
    
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        count = self.contractItem.tasks.count + 1
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ContractTaskTableViewCell
        cell.prepareForReuse()
        
        
        if(indexPath.row == self.contractItem.tasks.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            
            cell.task = self.contractItem.tasks[indexPath.row]
            cell.layoutViews()
            cell.taskLbl.text = self.contractItem.tasks[indexPath.row].taskDescription
            
            if(self.contractItem.tasks[indexPath.row].images.count == 0){
                cell.imageQtyLbl.text = "No Images"
            }else{
                if(self.contractItem.tasks[indexPath.row].images.count == 1){
                    cell.imageQtyLbl.text = "1 Image"
                    
                }else{
                    cell.imageQtyLbl.text = "\(self.contractItem.tasks[indexPath.row].images.count) Images"
                }
            }
            
            
            
            print("image count = \(self.contractItem.tasks[indexPath.row].images.count)")
            
            if(self.contractItem.tasks[indexPath.row].images.count > 0){
                print("image path = \(self.contractItem.tasks[indexPath.row].images[0].thumbPath!)")
                cell.activityView.startAnimating()
                cell.setImageUrl(_url: "\(self.contractItem.tasks[indexPath.row].images[0].thumbPath!)")
            }else{
                print("set blank image")
                cell.setBlankImage()
            }
            
        }
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //////print("You selected cell #\(indexPath.row)!")
        
        if(indexPath.row == self.contractItem.tasks.count){
            self.addTask()
        }else{
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Contract Task", _contractItemID: self.contractItem.ID, _contractTaskID: self.contractItem.tasks[indexPath.row].ID, _customerID: self.contract.customer, _images: self.contractItem.tasks[indexPath.row].images)
            
            imageUploadPrepViewController.layoutViews()
            imageUploadPrepViewController.groupDescriptionTxt.text = self.contractItem.tasks[indexPath.row].taskDescription
            imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
            imageUploadPrepViewController.selectedID = self.contract.customer
            imageUploadPrepViewController.contractID = self.contract.ID
            imageUploadPrepViewController.groupImages = true
            imageUploadPrepViewController.attachmentDelegate = self
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        }
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //indexPath
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete task")
            self.deleteTask(_indexPath: indexPath)

        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    
    @objc func assignLeadTasks(){
        print("assign lead tasks")
        let leadTaskAssignViewController:LeadTaskAssignViewController = LeadTaskAssignViewController(_leadFromContractItem: self.lead!, _contractItem: self.contractItem)
        leadTaskAssignViewController.editDelegate = self
        self.navigationController?.pushViewController(leadTaskAssignViewController, animated: false)
    }
    
    
    @objc func deleteTask(_indexPath: IndexPath){
        
        print("delete task")
        
        
        
        let alertController = UIAlertController(title: "Delete Task?", message: "Are you sure you want to delete this task?", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
            return
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
            
            
            self.editsMade = true
            
            
            
            var parameters:[String:String]
            parameters = [
                "taskID":self.contractItem.tasks[_indexPath.row].ID
                
            ]
            self.contractItem.tasks.remove(at: _indexPath.row)
            
            print("parameters = \(parameters)")
            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/contractTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    
                    
                    self.itemDetailsTableView.reloadData()
                    
                    
                }
                }.responseString { response in
                    //print("response = \(response)")
            }
            
            
            
            
            
            
            
        }
 
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
  
    
    
    
    func addTask(){
        print("add task")
        
       
        
        
        let imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Contract Task", _contractItemID: self.contractItem.ID, _contractTaskID: "0", _customerID: self.contract.customer, _images: [])
        
        
        
        
        imageUploadPrepViewController.layoutViews()
        
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.attachmentDelegate = self
        
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    
    
    
    
    func updateTable(_points:Int){
        print("updateTable")
        editsMade = true
        getTasks()
    }
    
    
    
    
    func getTasks(){
        print("get tasks")
        
       
        
        let parameters:[String:String]
        parameters = ["contractItemID": self.contractItem.ID]
        
        print("parameters = \(parameters)")
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/contractTasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("get tasks response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                print(response.request ?? "")  // original URL request
                print(response.response ?? "") // URL response
                print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("Tasks Json = \(json)")
                    self.tasksJson = JSON(json)
                    
                    let ts = self.tasksJson?["tasks"]
                    
                    self.contractItem.tasks = []
                    print("Task Count = \(String(describing: ts?.count))")
                    
                    for n in 0 ..< Int((ts?.count)!) {
                        var taskImages:[Image]  = []
                        let imageCount = Int((ts?[n]["images"].count)!)
                        print("imageCount: \(imageCount)")
                        
                        
                        for i in 0 ..< imageCount {
                            
                            let fileName:String = (ts?[n]["images"][i]["fileName"].stringValue)!
                            
                            let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                            let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                            let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                            
                            //create a item object
                            print("create an image object \(i)")
                            
                            print("rawPath = \(rawPath)")
                            
                            let image = Image(_id: ts?[n]["images"][i]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: ts?[n]["images"][i]["name"].stringValue,_width: ts?[n]["images"][i]["width"].stringValue,_height: ts?[n]["images"][i]["height"].stringValue,_description: ts?[n]["images"][i]["description"].stringValue,_dateAdded: ts?[n]["images"][i]["dateAdded"].stringValue,_createdBy: ts?[n]["images"][i]["createdByName"].stringValue,_type: ts?[n]["images"][i]["type"].stringValue)
                            
                            image.customer = (ts?[n]["images"][i]["customer"].stringValue)!
                            image.tags = (ts?[n]["images"][i]["tags"].stringValue)!
                            
                            taskImages.append(image)
                            
                        }
                        let task = ContractTask(_ID: ts?[n]["ID"].stringValue, _contractItemID: self.contractItem.ID, _createDate: ts?[n]["createDate"].stringValue, _createdBy: ts?[n]["createdBy"].stringValue, _sort: ts?[n]["sort"].stringValue, _taskDescription: ts?[n]["taskDescription"].stringValue, _images: taskImages)
                        self.contractItem.tasks.append(task)
                        
                    }
                    
                    self.itemDetailsTableView.reloadData()
                    let indexPath = IndexPath(row: self.contractItem.tasks.count, section: 0)
                    self.itemDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
        }
        
    }
    
    
    
    
    
    func updateLead(_lead: Lead, _newStatusValue:String){
        print("update Lead")
        editsMade = true
        self.lead = _lead
        
        
        if self.lead?.statusId! == "3"{
            self.hideLeadTaskBtn()
        }
        
        
        getLead()
        
    }
    
    
    func getLead() {
        print(" GetLead  Lead Id \(self.contract.lead!.ID)")
        
        //get updated contractItem tasks
        self.getTasks()
        
        
        // Show Loading Indicator
        //indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.contract.lead!.tasksArray = []
        let parameters:[String:String]
        parameters = ["leadID": self.contract.lead!.ID]
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
                //self.indicator.dismissIndicator()
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
            self.lead!.tasksArray.append(task)
        }
        
    }
    
    
    

    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: true)
        if contractDelegate != nil && self.editsMade == true{
            contractDelegate.updateContract(_contract: self.contract)
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
