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
import Nuke


protocol ServiceListDelegate{
    func updateServiceList()
}

class EquipmentServiceListViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ServiceListDelegate {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var equipmentDelegate:EquipmentListDelegate!
    var editEquipmentDelegate:EditEquipmentDelegate!
    var equipmentIndex:Int!
    
    var equipmentJSON: JSON!
    
    var equipment:Equipment!
    
    var keyBoardShown:Bool = false
    var tableViewMode:String = "CURRENT"
    let items = ["Current","History"]
    
    var serviceCurrentArray:[EquipmentService] = []
    var serviceCurrent:JSON!
    
    var serviceHistoryArray:[EquipmentService] = []
    var serviceHistory:JSON!
    
    var equipmentImage:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var tapBtn:Button!
    
    var mileageLbl:GreyLabel!
    var mileageTxtField:PaddedTextField!
    var mileageButton:Button = Button(titleText: "Check")
    var currentValue:String = "0"
    
    
    
    var serviceSC:SegmentedControl!
    var serviceTableView:TableView = TableView()
    var addServiceButton:Button = Button(titleText: "Add Service")
    
    var shouldUpdateTable:Bool = false
    
    let dateFormatter = DateFormatter()
    
    var imageFullViewController:ImageFullViewController!
    
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        print("init Service List with equipmentID = \(_equipment.ID)")
        print("init Service List with equipment status = \(_equipment.status)")
        self.equipment = _equipment
        
        
        print("view will appear")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Service List"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
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
                if let json = response.result.value {
                    
                    self.serviceCurrent = JSON(json)
                    
                    let currentJsonCount = self.serviceCurrent["services"].count
                    print("currentJsonCount: \(currentJsonCount)")
                    for i in 0 ..< currentJsonCount {
                        
                        let equipmentService = EquipmentService(_ID: self.serviceCurrent["services"][i]["ID"].stringValue, _name: self.serviceCurrent["services"][i]["name"].stringValue, _type: self.serviceCurrent["services"][i]["type"].stringValue, _typeName: self.serviceCurrent["services"][i]["typeName"].stringValue, _frequency: self.serviceCurrent["services"][i]["frequency"].stringValue, _instruction: self.serviceCurrent["services"][i]["instructions"].stringValue, _creationDate: self.serviceCurrent["services"][i]["createDate"].stringValue, _createdBy: self.serviceCurrent["services"][i]["addedByName"].stringValue, _completionDate: self.serviceCurrent["services"][i]["completionDate"].stringValue, _completionMileage: self.serviceCurrent["services"][i]["completionMileage"].stringValue, _completedBy: self.serviceCurrent["services"][i]["completedByName"].stringValue, _notes: self.serviceCurrent["services"][i]["notes"].stringValue, _status: self.serviceCurrent["services"][i]["status"].stringValue, _currentValue: self.serviceCurrent["services"][i]["currentValue"].stringValue, _nextValue: self.serviceCurrent["services"][i]["nextValue"].stringValue, _equipmentID: self.serviceCurrent["services"][i]["equipmentID"].stringValue)
                        
                        self.serviceCurrentArray.append(equipmentService)
                    }
                    
                    
                    self.serviceHistory = JSON(json)
                    
                    let historyJsonCount = self.serviceHistory["serviceHistory"].count
                    print("historyJsonCount: \(historyJsonCount)")
                    for i in 0 ..< historyJsonCount {
                        
                        let equipmentService = EquipmentService(_ID: self.serviceHistory["serviceHistory"][i]["ID"].stringValue, _name: self.serviceHistory["serviceHistory"][i]["name"].stringValue, _type: self.serviceHistory["serviceHistory"][i]["type"].stringValue, _typeName: self.serviceCurrent["services"][i]["typeName"].stringValue, _frequency: self.serviceHistory["serviceHistory"][i]["frequency"].stringValue, _instruction: self.serviceHistory["serviceHistory"][i]["instructions"].stringValue, _creationDate: self.serviceHistory["serviceHistory"][i]["createDate"].stringValue, _createdBy: self.serviceHistory["serviceHistory"][i]["addedByName"].stringValue, _completionDate: self.serviceHistory["serviceHistory"][i]["completionDate"].stringValue, _completionMileage: self.serviceHistory["serviceHistory"][i]["completionMileage"].stringValue, _completedBy: self.serviceHistory["serviceHistory"][i]["completedByName"].stringValue, _notes: self.serviceHistory["serviceHistory"][i]["notes"].stringValue, _status: self.serviceHistory["serviceHistory"][i]["status"].stringValue, _currentValue: self.serviceCurrent["serviceHistory"][i]["currentValue"].stringValue, _nextValue: self.serviceCurrent["serviceHistory"][i]["nextValue"].stringValue, _equipmentID: self.serviceCurrent["services"][i]["equipmentID"].stringValue)
                        
                        self.serviceHistoryArray.append(equipmentService)
                    }
                    
                
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                }
        }
        
    }
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        
        
        
        //image
        self.equipmentImage = UIImageView()
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = CGPoint(x: self.equipmentImage.frame.size.width / 2, y: self.equipmentImage.frame.size.height / 2)
        equipmentImage.addSubview(activityView)
        activityView.startAnimating()
        
        let imgURL:URL = URL(string: self.equipment.image.thumbPath!)!
        
        print("imgURL = \(imgURL)")
        
        Nuke.loadImage(with: imgURL, into: self.equipmentImage!){
            print("nuke loadImage")
            self.equipmentImage?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
            self.imageFullViewController = ImageFullViewController(_image: self.equipment.image)
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
            self.tapBtn.addTarget(self, action: #selector(EquipmentServiceListViewController.showFullScreenImage), for: UIControlEvents.touchUpInside)
        }
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControlState.normal)
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
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let setMileageButton = UIBarButtonItem(title: "Set Mileage", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EquipmentServiceListViewController.handleSetMileage))
        mileageToolBar.setItems([spaceButton, setMileageButton], animated: false)
        mileageToolBar.isUserInteractionEnabled = true
        mileageTxtField.inputAccessoryView = mileageToolBar
        
        
        
        
        self.mileageButton.addTarget(self, action: #selector(EquipmentServiceListViewController.checkForServices), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.mileageButton)
        
        
        
        //service
        serviceSC = SegmentedControl(items: items)
        serviceSC.selectedSegmentIndex = 0
        
        serviceSC.addTarget(self, action: #selector(self.changeServiceView(sender:)), for: .valueChanged)
        self.view.addSubview(serviceSC)
        
        self.serviceTableView.delegate  =  self
        self.serviceTableView.dataSource = self
        self.serviceTableView.rowHeight = 60.0
        self.serviceTableView.register(EquipmentServiceTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(serviceTableView)
        if shouldUpdateTable {
            self.serviceTableView.reloadData()
            shouldUpdateTable = false
        }
        
        
        self.addServiceButton.addTarget(self, action: #selector(EquipmentServiceListViewController.addService), for: UIControlEvents.touchUpInside)
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
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(40)]-[mileageLbl]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mileageTxt]-[mileageBtn(80)]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceSegmentedControl]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
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
            //simpleAlert(_vc: self, _title: "No Services Due Now", _message: "")
            
            
            if self.equipment.status == "1" || self.equipment.status == "2"{
                print("update equipment status")
                
                let alertController = UIAlertController(title: "No Services Due Now", message: "\(self.equipment.name!) looks good, would you like to update its status to \"Online\"?", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.equipment.status = "0"
                    self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                simpleAlert(_vc: self, _title: "No Services Due Now", _message: "")
            }
            
            
            
            
            
            break
        case let x where x == 1:
            
            if self.equipment.status == "0"{
                print("update equipment status")
                
                let alertController = UIAlertController(title: "1 Service Due Now", message: "\(self.equipment.name!) needs service now, would you like to update its status to \"Needs Service\"?", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.equipment.status = "1"
                    self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                simpleAlert(_vc: self, _title: "Service Due Now", _message: "There is 1 service due now.")
            }
            
            
            
            self.serviceSC.selectedSegmentIndex = 0
            self.tableViewMode = "CURRENT"
            
            //need to set equipment status to Needs Repair/Service
            break
        case let x where x > 1:
            
            if self.equipment.status == "0"{
                print("update equipment status")
                
                let alertController = UIAlertController(title: "\(n) Services Due Now", message: "\(self.equipment.name!) needs service now, would you like to update its status to \"Needs Service\"?", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.equipment.status = "1"
                    self.editEquipmentDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                simpleAlert(_vc: self, _title: "Services Due Now", _message: "There are \(n) services due now.")
            }
            self.serviceSC.selectedSegmentIndex = 0
            self.tableViewMode = "CURRENT"
            self.serviceTableView.reloadData()
            
            //need to set equipment status to Needs Repair/Service
            break
        default:
            simpleAlert(_vc: self, _title: "No Services Due Now", _message: "")
            break
        }
        
        
        
        serviceTableView.reloadData()
        
        print("self.equipment.status = \(self.equipment.status) n = \(n)")
        //update equipment status if services are needed
        
    }
    
   
    
   
    
    
    
    
    
    @objc func addService(){
        print("add service")
        /*
        if(currentValue == ""){
            simpleAlert(_vc: self, _title: "Enter Mileage/Hours", _message: "")
            return
        }
 */
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
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
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
        
        /*
        if(currentValue == ""){
            simpleAlert(_vc: self, _title: "Enter Mileage/Hours", _message: "")
            return
        }
 */
        
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentServiceTableViewCell
        
        if self.mileageTxtField.text == ""{
            currentCell.equipmentService.currentValue = "0"
        }else{
            currentCell.equipmentService.currentValue = self.mileageTxtField.text
        }
        
        
        if(currentCell.equipmentService.frequency != "0" && currentCell.equipmentService.currentValue != "0" && Int(currentCell.equipmentService.type)! > 1){
            currentCell.equipmentService.nextValue = "\(Int(currentCell.equipmentService.frequency)! + Int(currentCell.equipmentService.currentValue)!)"
            print("next value = \(currentCell.equipmentService.nextValue)")
        }
 
        
        let equipmentServiceViewController = EquipmentServiceViewController(_equipmentService: currentCell.equipmentService)
        navigationController?.pushViewController(equipmentServiceViewController, animated: false )
        //equipmentViewController.equipmentDelegate = self
        equipmentServiceViewController.serviceListDelegate = self
        
        
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
        shouldUpdateTable = true
        getEquipmentServiceInfo()
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


