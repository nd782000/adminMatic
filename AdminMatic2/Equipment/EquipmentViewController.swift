//
//  EquipmentViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/15/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol EditEquipmentDelegate{
    func updateEquipment(_equipment:Equipment)
    func updateServiceList()
}


class EquipmentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, EditEquipmentDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var equipmentDelegate:EquipmentListDelegate!
    var equipmentIndex:Int!
    
    var equipmentJSON: JSON!
    var equipment:Equipment!
    var equipmentServiceJSON: JSON!
    var serviceCurrentArray:[EquipmentService] = []
    var equipmentHistoryJSON: JSON!
    var serviceHistoryArray:[EquipmentService] = []
    
    
    var keyBoardShown:Bool = false
    var tableViewMode:String = "CURRENT"
    let items = ["Current","History"]
    
    //set container to safe bounds of view
    let safeContainer:UIView = UIView()
    
    var editButton:UIBarButtonItem!
    var editsMade:Bool = false
    
    
    var equipmentImage:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var tapBtn:Button!
    
    
    var nameLbl:GreyLabel!
    var typeLbl:GreyLabel!
    var crewLbl:GreyLabel!
    
    
    var statusIcon:UIImageView = UIImageView()
    
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Online","Needs Service","Broken","Winterized"]
    
    
    var statusValue: String!
    var statusValueToUpdate: String!
    
    
    var detailsBtn:Button!
    
    
    var mileageLbl:GreyLabel!
    var mileageTxtField:PaddedTextField!
    var mileageButton:Button = Button(titleText: "Check")
    var currentValue:String = "0"
 
    
    let dateFormatter = DateFormatter()
    
    var serviceSC:SegmentedControl!
    var serviceTableView:TableView! // = TableView()
    var addServiceButton:Button = Button(titleText: "Add Service")
    

   // var imageFullViewController:ImageFullViewController!
    var imageDetailViewController:ImageDetailViewController!
    
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        //print("init _equipmentID = \(_equipment.ID)")
        self.equipment = _equipment
         self.getEquipmentServiceInfo()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Equipment"
        
       
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
        dateFormatter.dateFormat = "MM/dd/yy"
    }
    
   
    

    func getEquipmentServiceInfo(){
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
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
        
        
    
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EquipmentViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        
       
        
        safeContainer.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //image
        self.equipmentImage = UIImageView()
    
        activityView = UIActivityIndicatorView(style: .whiteLarge)
       
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        equipmentImage.addSubview(activityView)
        activityView.startAnimating()
        
        
        Alamofire.request(self.equipment.image.thumbPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
               // self.imageFullViewController = ImageFullViewController(_image: self.equipment.image)
                self.imageDetailViewController = ImageDetailViewController(_image: self.equipment.image)
                self.equipmentImage.image = image
                self.activityView.stopAnimating()
            }
        }
        
        
        self.equipmentImage.layer.cornerRadius = 5.0
        self.equipmentImage.layer.borderWidth = 2
        self.equipmentImage.layer.borderColor = layoutVars.borderColor
        self.equipmentImage.clipsToBounds = true
        self.equipmentImage.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.equipmentImage)
        
        
        self.tapBtn = Button()
        self.tapBtn.translatesAutoresizingMaskIntoConstraints = false
        if equipment.image.ID != "0" {
            self.tapBtn.addTarget(self, action: #selector(EquipmentViewController.showFullScreenImage), for: UIControl.Event.touchUpInside)
        }
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControl.State.normal)
        safeContainer.addSubview(self.tapBtn)
        
       
        
        //status
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        setStatus(status: equipment.status)
        
        self.statusPicker = Picker()
        self.statusPicker.delegate = self
        self.statusPicker.selectRow(Int(self.equipment.status)!, inComponent: 0, animated: false)
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
        
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(WorkOrderViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = BarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(WorkOrderViewController.handleStatusChange))
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        statusTxtField.inputAccessoryView = toolBar
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = self.equipment.name!
        self.nameLbl.font = layoutVars.largeFont
        safeContainer.addSubview(self.nameLbl)
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = self.equipment.typeName!
        self.typeLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.typeLbl)
        
        //crew
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew: \(self.equipment.crewName!)"
        self.crewLbl.textAlignment = .right
        self.crewLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.crewLbl)
        
        //details btn
        self.detailsBtn = Button(titleText: "View Equipment Details")
        self.detailsBtn.translatesAutoresizingMaskIntoConstraints = false
        self.detailsBtn.addTarget(self, action: #selector(EquipmentViewController.showDetailsView), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.detailsBtn)
        
        
        
        //mileageLbl
        self.mileageLbl = GreyLabel()
        self.mileageLbl.text = "Current Service Check:"
        self.mileageLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.mileageLbl)
        
        self.mileageTxtField = PaddedTextField(placeholder: "Mileage/Hours...")
        self.mileageTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.mileageTxtField.delegate = self
        self.mileageTxtField.keyboardType = UIKeyboardType.numberPad
        self.mileageTxtField.returnKeyType = .done
        safeContainer.addSubview(self.mileageTxtField)
        
        let mileageToolBar = UIToolbar()
        mileageToolBar.barStyle = UIBarStyle.default
        mileageToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        mileageToolBar.sizeToFit()
        
        let setMileageButton = BarButtonItem(title: "Set Mileage", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleSetMileage))
        mileageToolBar.setItems([spaceButton, setMileageButton], animated: false)
        mileageToolBar.isUserInteractionEnabled = true
        mileageTxtField.inputAccessoryView = mileageToolBar
        
    
        self.mileageButton.addTarget(self, action: #selector(self.checkForServices), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.mileageButton)
        
        
        
        //service
        serviceSC = SegmentedControl(items: items)
        serviceSC.selectedSegmentIndex = 0
        
        serviceSC.addTarget(self, action: #selector(self.changeServiceView(sender:)), for: .valueChanged)
        safeContainer.addSubview(serviceSC)
        
    
        self.serviceTableView = TableView()
        self.serviceTableView.delegate  =  self
        self.serviceTableView.dataSource = self
        self.serviceTableView.rowHeight = 60.0
        self.serviceTableView.layer.cornerRadius = 4
        self.serviceTableView.layer.borderWidth = 1
        self.serviceTableView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        
        
        self.serviceTableView.register(EquipmentServiceTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(serviceTableView)
        
        self.addServiceButton.addTarget(self, action: #selector(self.addService), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.addServiceButton)
        
    
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "image":self.equipmentImage,
            "activity":self.activityView,
            "tapBtn":self.tapBtn,
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "name":self.nameLbl,
            "type":self.typeLbl,
            "crew":self.crewLbl,
            "detailsBtn":self.detailsBtn,
            "mileageLbl":self.mileageLbl,
            "mileageTxt":self.mileageTxtField,
            "mileageBtn":self.mileageButton,
            "serviceSegmentedControl":self.serviceSC,
            "serviceTable":self.serviceTableView,
            "addServiceBtn":self.addServiceButton
            ] as [String:Any]
        
        print("auto layout 1")
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusIcon(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activity(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusTxtField(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[type]-[crew]-|", options: [], metrics: nil,views: equipmentViewsDictionary))
       
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[detailsBtn]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[mileageLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mileageTxt]-[mileageBtn(80)]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceSegmentedControl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceTable]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addServiceBtn]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
    
        print("auto layout 4")
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(80)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tapBtn(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activity(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        print("auto layout 5")
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusTxtField(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(40)]-[type(30)]-[detailsBtn(40)]-[mileageLbl(30)]-[mileageTxt(40)]-[serviceSegmentedControl(40)][serviceTable]-[addServiceBtn(40)]-10-|", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(40)]-[crew(30)]-[detailsBtn(40)]-[mileageLbl(30)]-[mileageBtn(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        
        
    }
    
    @objc func displayEditView(){
        print("display Edit View")
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        //self.equipmentDelegate.disableSearch()
        let editEquipmentViewController = NewEditEquipmentViewController(_equipment: self.equipment)
        editEquipmentViewController.editDelegate = self
        navigationController?.pushViewController(editEquipmentViewController, animated: false )
    }
    
    
    
    
    @objc func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        print("show full screen")
        
        navigationController?.pushViewController(imageDetailViewController, animated: false )
    }
    
    
    
    @objc func showDetailsView(){
        print("show details view")
        let detailsViewController = EquipmentDetailsViewController(_equipment: self.equipment)
        //detailsViewController.editEquipmentDelegate = self
        navigationController?.pushViewController(detailsViewController, animated: false )
    }
    
/*
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
 */
    
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
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
    
    
    
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    
    // returns the # of rows in each component..
    
    
    
    @objc func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
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
            myImageView.image = UIImage(named:"onlineIcon.png")
            break
        case 1:
            myImageView.image = UIImage(named:"needsRepairIcon.png")
            break
        case 2:
            myImageView.image = UIImage(named:"brokenIcon.png")
            break
        case 3:
            myImageView.image = UIImage(named:"winterizedIcon.png")
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
        
        self.statusValueToUpdate = "\(row)"
        self.equipment.status = "\(row)"
    }
    
    @objc func cancelPicker(){
        self.statusTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        
        print("handle status change")
        
        self.statusTxtField.resignFirstResponder()
        
        if self.statusValueToUpdate != nil{
            
            indicator = SDevIndicator.generate(self.view)!
            
            var parameters:[String:String]
            parameters = [
                "equipmentID":self.equipment.ID,
                "status":self.statusValueToUpdate
            ]
            
            print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/equipmentStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                self.statusValue = self.statusValueToUpdate
                self.setStatus(status: self.statusValue)
                
                if(self.equipmentDelegate != nil){
                    self.equipmentDelegate.reDrawEquipmentList()
                }
                
                self.indicator.dismissIndicator()
                
                }.responseString() {
                    response in
                    print(response)  // original URL request
            }
        }
    }
    
    
    
    func setStatus(status: String) {
        print("set status status = \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"onlineIcon.png")
            statusIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"needsRepairIcon.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"brokenIcon.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"winterizedIcon.png")
            statusIcon.image = statusImg
            break;
        default:
            statusIcon.image = nil
            break;
        }
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
                    self.updateEquipment(_equipment: self.equipment)
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
                    self.updateEquipment(_equipment: self.equipment)
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
                    self.updateEquipment(_equipment: self.equipment)
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
    
    
    
    

    func updateEquipment(_equipment: Equipment){
        print("update Equipment")
        editsMade = true
        self.equipment = _equipment
        
        statusValueToUpdate = equipment.status
        handleStatusChange()
        self.layoutViews()
        
    }
    
    
    // equipment service list delegates
    func updateServiceList() {
        print("updateServiceList")
        getEquipmentServiceInfo()
    }
    
    

    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
}
