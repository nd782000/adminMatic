//
//  EquipmentServiceListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/31/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import Nuke


protocol ServiceListDelegate{
    func updateServiceList()
    func updateEquipmentStatus(_equipment:Equipment)
}

class EquipmentServiceListViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ServiceListDelegate {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var equipmentDelegate:EquipmentListDelegate!
    var editEquipmentDelegate:EditEquipmentDelegate!
    var equipmentIndex:Int!
    
    var equipmentServiceJSON: JSON!
    var equipmentHistoryJSON: JSON!
    
    var equipment:Equipment!
    
    var keyBoardShown:Bool = false
    var tableViewMode:String = "CURRENT"
    let items = ["Current","History"]
    
    var serviceCurrentArray:[EquipmentService] = []
    //var serviceCurrent:JSON!
    
    var serviceHistoryArray:[EquipmentService] = []
    //var serviceHistory:JSON!
    
    var equipmentImage:UIImageView!
    //var activityView:UIActivityIndicatorView!
    
    var tapBtn:Button!
    
    var mileageLbl:GreyLabel!
    var mileageTxtField:PaddedTextField!
    var mileageButton:Button = Button(titleText: "Check")
    var currentValue:String = "0"
    
    
    
    var serviceSC:SegmentedControl!
    var serviceTableView:TableView! // = TableView()
    var addServiceButton:Button = Button(titleText: "Add Service")
    
   // var shouldUpdateTable:Bool = false
    
    let dateFormatter = DateFormatter()
    
    var imageFullViewController:ImageFullViewController!
    
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        //print("init Service List with equipmentID = \(_equipment.ID)")
        //print("init Service List with equipment status = \(_equipment.status)")
        self.equipment = _equipment
        
        
        print("view will appear")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Service List"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        dateFormatter.dateFormat = "MM/dd/yy"
        
        
        getEquipmentServiceInfo()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    
    func getEquipmentServiceInfo(){
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        self.serviceCurrentArray = []
        self.serviceHistoryArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get service lists
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)",
            "equipmentID":"\(equipment.ID!)"]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/equipment.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("equipment service response = \(response)")
            }
            .responseJSON() {
                response in
                
                
                
                
                //native way
               
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let currentServices = json["services"] as? [[String: Any]],
                    let serviceHistory = json["serviceHistory"] as? [[String: Any]] {
                        
                        
                       
                        
                        let currentServiceCount = currentServices.count
                        //print("currentServices count = \(currentServices)")
                        
                        
                        for i in 0 ..< currentServiceCount{
                            
                            let equipmentService = EquipmentService(_ID: currentServices[i]["ID"] as? String, _name: currentServices[i]["name"] as? String, _type: currentServices[i]["type"] as? String, _typeName: currentServices[i]["typeName"] as? String, _frequency: currentServices[i]["frequency"] as? String, _instruction: currentServices[i]["instructions"] as? String, _creationDate: currentServices[i]["createDate"] as? String, _createdBy: currentServices[i]["addedByName"] as? String, _completionDate: currentServices[i]["completionDate"] as? String, _completionMileage: currentServices[i]["completionMileage"] as? String, _completedBy: currentServices[i]["completedByName"] as? String, _notes: currentServices[i]["completionNotes"] as? String, _status: currentServices[i]["status"] as? String, _currentValue: currentServices[i]["currentValue"] as? String, _nextValue: currentServices[i]["nextValue"] as? String, _equipmentID: currentServices[i]["equipmentID"] as? String)
                            
                            self.serviceCurrentArray.append(equipmentService)
                        }
                    
                    
                    
                    let serviceHistoryCount = serviceHistory.count
                    //print("serviceHistoryCount = \(serviceHistoryCount)")
                    
                    
                    for i in 0 ..< serviceHistoryCount{
                        
                        let equipmentService = EquipmentService(_ID: serviceHistory[i]["ID"] as? String, _name: serviceHistory[i]["name"] as? String, _type: serviceHistory[i]["type"] as? String, _typeName: serviceHistory[i]["typeName"] as? String, _frequency: serviceHistory[i]["frequency"] as? String, _instruction: serviceHistory[i]["instructions"] as? String, _creationDate: serviceHistory[i]["createDate"] as? String, _createdBy: serviceHistory[i]["addedByName"] as? String, _completionDate: serviceHistory[i]["completionDate"] as? String, _completionMileage: serviceHistory[i]["completionMileage"] as? String, _completedBy: serviceHistory[i]["completedByName"] as? String, _notes: serviceHistory[i]["completionNotes"] as? String, _status: serviceHistory[i]["status"] as? String, _currentValue: serviceHistory[i]["currentValue"] as? String, _nextValue: serviceHistory[i]["nextValue"] as? String, _equipmentID: serviceHistory[i]["equipmentID"] as? String)
                        
                        self.serviceHistoryArray.append(equipmentService)
                    }
                
                    
                    }
                    
                    
                    
                 
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                    
                    
                  
                    
                    
                    
                    
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
                
                
                
                
                
        }
        
    }
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        //image
        self.equipmentImage = UIImageView()
        
        
        Alamofire.request(self.equipment.image.thumbPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                self.imageFullViewController = ImageFullViewController(_image: self.equipment.image)
                // cell.imageView.image = image
                self.equipmentImage.image = image
            }
        }
        
        
        
        
        self.equipmentImage.layer.cornerRadius = 5.0
        self.equipmentImage.layer.borderWidth = 2
        self.equipmentImage.layer.borderColor = layoutVars.borderColor
        self.equipmentImage.clipsToBounds = true
        self.equipmentImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.equipmentImage)
        
        
        self.tapBtn = Button()
        self.tapBtn.translatesAutoresizingMaskIntoConstraints = false
        if equipment.image.ID != "0" {
            self.tapBtn.addTarget(self, action: #selector(EquipmentServiceListViewController.showFullScreenImage), for: UIControl.Event.touchUpInside)
        }
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControl.State.normal)
        self.view.addSubview(self.tapBtn)
        
        
        
        
        //serviceLbl
        self.mileageLbl = GreyLabel()
        self.mileageLbl.text = "Current Mileage/Hours"
        self.mileageLbl.font = layoutVars.smallFont
        self.view.addSubview(self.mileageLbl)
        
        self.mileageTxtField = PaddedTextField(placeholder: "Mileage/Hours...")
        self.mileageTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.mileageTxtField.delegate = self
        self.mileageTxtField.keyboardType = UIKeyboardType.numberPad
        self.mileageTxtField.returnKeyType = .done
        self.view.addSubview(self.mileageTxtField)
        
        
        
        
        let mileageToolBar = UIToolbar()
        mileageToolBar.barStyle = UIBarStyle.default
        mileageToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        mileageToolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setMileageButton = UIBarButtonItem(title: "Set Mileage", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceListViewController.handleSetMileage))
        mileageToolBar.setItems([spaceButton, setMileageButton], animated: false)
        mileageToolBar.isUserInteractionEnabled = true
        mileageTxtField.inputAccessoryView = mileageToolBar
        
        
        
        
        self.mileageButton.addTarget(self, action: #selector(EquipmentServiceListViewController.checkForServices), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.mileageButton)
        
        
        
        //service
        serviceSC = SegmentedControl(items: items)
        serviceSC.selectedSegmentIndex = 0
        
        serviceSC.addTarget(self, action: #selector(self.changeServiceView(sender:)), for: .valueChanged)
        self.view.addSubview(serviceSC)
        
        
        self.serviceTableView = TableView()
        self.serviceTableView.delegate  =  self
        self.serviceTableView.dataSource = self
        self.serviceTableView.rowHeight = 60.0
        self.serviceTableView.register(EquipmentServiceTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(serviceTableView)
        //if shouldUpdateTable {
            //self.serviceTableView.reloadData()
           // shouldUpdateTable = false
       // }
        
        
        self.addServiceButton.addTarget(self, action: #selector(EquipmentServiceListViewController.addService), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addServiceButton)
        
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            "image":self.equipmentImage,
            "tapBtn":self.tapBtn,
            "mileageLbl":self.mileageLbl,
            "mileageTxt":self.mileageTxtField,
            "mileageBtn":self.mileageButton,
            "serviceSegmentedControl":self.serviceSC,
            "serviceTable":self.serviceTableView,
            "addServiceBtn":self.addServiceButton
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(40)]-[mileageLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mileageTxt]-[mileageBtn(80)]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceSegmentedControl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceTable]-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addServiceBtn]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[tapBtn(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[mileageLbl(40)]-[mileageTxt(40)]-20-[serviceSegmentedControl(40)]-[serviceTable]-[addServiceBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[mileageLbl(40)]-[mileageBtn(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    @objc func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        print("show full screen")
        
        navigationController?.pushViewController(imageFullViewController, animated: false )
    }
    
    @objc func handleSetMileage(){
        self.mileageTxtField.resignFirstResponder()
    
    }
    
    
    
    @objc func checkForServices(){
        print("check for services")
        mileageTxtField.resignFirstResponder()
        if mileageTxtField.text == ""{
            currentValue = "0"
        }else{
            currentValue = mileageTxtField.text!
        }
        
        var n:Int = 0 //number of services that are due
        //loop through all current services
         for i in 0 ..< serviceCurrentArray.count {
            //check if they are of type 2 or 3
            
            if serviceCurrentArray[i].type == "0" {
                n += 1
            }
            
            if serviceCurrentArray[i].type == "1"{
                //let date = dateFormatter.date(from: determineUpcomingDate(_equipmentService: serviceCurrentArray[i]))
                let date = dateFormatter.date(from:layoutVars.determineUpcomingDate(_equipmentService: serviceCurrentArray[i]))
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MM/dd/yy"
                let date2 = dateFormatter2.string(from: date!)
                
                print("date = \(date2)")
                //dueByValueLbl.text = date2
                if date! < Date()  {
                    print("date1 is earlier than Now")
                    
                   n += 1
                }
                
                
            }
            
            if serviceCurrentArray[i].type == "2" || serviceCurrentArray[i].type == "3"{
                //check if the current value is greater then their nextValue
                if Int(currentValue)! >= Int(serviceCurrentArray[i].nextValue)!{
                    
                    serviceCurrentArray[i].serviceDue = true
                    n += 1
                }else{
                    serviceCurrentArray[i].serviceDue = false
                }
                //if greater, color their next lbl red
            }
            
            
        }//end of loop
        
        switch n {
        case let x where x == 0:
            //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Services Due Now", _message: "")
            
            
            if self.equipment.status == "1" || self.equipment.status == "2"{
                print("update equipment status")
                
                let alertController = UIAlertController(title: "No Services Due Now", message: "\(self.equipment.name!) looks good, would you like to update its status to \"Online\"?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.equipment.status = "0"
                    self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                
            }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Services Due Now", _message: "")
            }
            
            
            
            
            
            break
        case let x where x == 1:
            
            if self.equipment.status == "0"{
                print("update equipment status")
                
                let alertController = UIAlertController(title: "1 Service Due Now", message: "\(self.equipment.name!) needs service now, would you like to update its status to \"Needs Service\"?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.equipment.status = "1"
                    self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                
            }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Service Due Now", _message: "There is 1 service due now.")
            }
            
            
            
            self.serviceSC.selectedSegmentIndex = 0
            self.tableViewMode = "CURRENT"
            
            //need to set equipment status to Needs Repair/Service
            break
        case let x where x > 1:
            
            if self.equipment.status == "0"{
                print("update equipment status")
                
                let alertController = UIAlertController(title: "\(n) Services Due Now", message: "\(self.equipment.name!) needs service now, would you like to update its status to \"Needs Service\"?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.equipment.status = "1"
                    self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                
            }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Services Due Now", _message: "There are \(n) services due now.")
            }
            self.serviceSC.selectedSegmentIndex = 0
            self.tableViewMode = "CURRENT"
            self.serviceTableView.reloadData()
            
            //need to set equipment status to Needs Repair/Service
            break
        default:
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Services Due Now", _message: "")
            break
        }
        
        
        
        serviceTableView.reloadData()
        
        
    }
    
   
    
   
    
    
    
    
    
    @objc func addService(){
        print("add service")
       
        if self.mileageTxtField.text == ""{
            self.currentValue = "0"
        }else{
            self.currentValue = self.mileageTxtField.text!
        }
        
        let newEditEquipmentServiceViewController = NewEditEquipmentServiceViewController(_equipmentID: self.equipment.ID,_currentValue:self.currentValue)
        navigationController?.pushViewController(newEditEquipmentServiceViewController, animated: false )
        newEditEquipmentServiceViewController.serviceListDelegate = self
        
    }
    

    @objc func changeServiceView(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
        case 0://current
            self.tableViewMode = "CURRENT"
            
            break
        case 1://history
            self.tableViewMode = "HISTORY"
            break
            
        default:
            self.tableViewMode = "CURRENT"
            break
        }
        
        serviceTableView.reloadData()
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if(!keyBoardShown){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.view.frame.origin.y -= keyboardFrame.height
                    
                }, completion: { finished in
                })
            }
        }
        keyBoardShown = true
    }
    
    
    @objc func keyboardDidHide(notification: NSNotification) {
        keyBoardShown = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y = 0
            
        }, completion: { finished in
        })
        
    }
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        switch self.tableViewMode{
        case "CURRENT":
            count = self.serviceCurrentArray.count
            break
        case "HISTORY":
            count = self.serviceHistoryArray.count
            break
            
        default:
            count = self.serviceCurrentArray.count
            break
        }
        
        return count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serviceTableView.dequeueReusableCell(withIdentifier: "cell") as! EquipmentServiceTableViewCell
        switch self.tableViewMode{
        case "CURRENT":
            
            cell.equipmentService = self.serviceCurrentArray[indexPath.row]
            cell.layoutViews()
            break
        case "HISTORY":
            
            cell.equipmentService = self.serviceHistoryArray[indexPath.row]
            cell.layoutViews()
        default:
            
            break
        }
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
       
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentServiceTableViewCell
        
        if self.mileageTxtField.text == ""{
            currentCell.equipmentService.currentValue = "0"
        }else{
            currentCell.equipmentService.currentValue = self.mileageTxtField.text
        }
        
        
        if(currentCell.equipmentService.frequency != "0" && currentCell.equipmentService.currentValue != "0" && Int(currentCell.equipmentService.type)! > 1){
            currentCell.equipmentService.nextValue = "\(Int(currentCell.equipmentService.frequency)! + Int(currentCell.equipmentService.currentValue)!)"
            //print("next value = \(currentCell.equipmentService.nextValue)")
        }
 
        if currentCell.equipmentService.type == "4"{
            let equipmentInspectionViewController = EquipmentInspectionViewController(_equipment: self.equipment,_equipmentService:currentCell.equipmentService)
            navigationController?.pushViewController(equipmentInspectionViewController, animated: false )
            equipmentInspectionViewController.serviceListDelegate = self
        }else{
            let equipmentServiceViewController = EquipmentServiceViewController(_equipmentService: currentCell.equipmentService)
            navigationController?.pushViewController(equipmentServiceViewController, animated: false )
            equipmentServiceViewController.serviceListDelegate = self
        }
        
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
    }
    
    /*
    func determineUpcomingDate(_equipmentService:EquipmentService)->String{
        print("determineUpcomingDate")
        
        
        //var dateString = "2014-07-15" // change to your date format
        
        let dbDateFormatter = DateFormatter()
        dbDateFormatter.dateFormat = "MM/dd/yy"
        
        let dbDate = dbDateFormatter.date(from: _equipmentService.creationDate)
        print("equipmentService.nextValue = \(_equipmentService.nextValue)")
        print("equipmentService.creationDate = \(_equipmentService.creationDate)")
        print("dbDate = \(dbDate)")
        
        
        
        let daysToAdd = Int(_equipmentService.nextValue)!
        let futureDate = Calendar.current.date(byAdding:
            .day, // updated this params to add hours
            value: daysToAdd,
            to: dbDate!)
        
        print(dateFormatter.string(from: futureDate!))
        return dateFormatter.string(from: futureDate!)
        
    }
    */
    
    
    
    
    func updateServiceList() {
        print("updateServiceList")
       // shouldUpdateTable = true
        getEquipmentServiceInfo()
    }
    
    func updateEquipmentStatus(_equipment:Equipment){
        print("updateEquipmentStatus \(String(describing: _equipment.status))")
        self.equipment = _equipment
        
        self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
        
    }
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
    
}


