//
//  EquipmentViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/15/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Nuke

protocol EditEquipmentDelegate{
    func updateEquipment(_equipment:Equipment)
}


class EquipmentViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, EditEquipmentDelegate {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var equipmentDelegate:EquipmentListDelegate!
    var equipmentIndex:Int!
    
    var equipmentJSON: JSON!
    var equipment:Equipment!
    

    
    var editButton:UIBarButtonItem!
    var editsMade:Bool = false
    
    
    var equipmentImage:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var tapBtn:Button!
    
    var nameLbl:GreyLabel!
    
    var statusIcon:UIImageView = UIImageView()
    
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Online","Needs Service","Broken","Winterized"]
    
    
    var statusValue: String!
    var statusValueToUpdate: String!
    
    var typeLbl:GreyLabel!
    var makeModelLbl:GreyLabel!
    var serialLbl:GreyLabel!
    var crewLbl:GreyLabel!
    var fuelLbl:GreyLabel!
    var engineLbl:GreyLabel!
    var dealerLbl:GreyLabel!
    var dealerValueBtn:Button!
    var purchaseDateLbl:GreyLabel!
    
    var descriptionView:UITextView!
    
    
    var serviceLbl:GreyLabel!
    
    let items = ["History","Up-Coming"]
    var serviceSC:SegmentedControl!
    
    var serviceTableView:TableView = TableView()
    var tableViewMode:String = "HISTORY"
    
   
    
    var keyBoardShown:Bool = false
    
    var serviceHistoryArray:[EquipmentService] = []
    var serviceHistory:JSON!
    
    var serviceUpcomingArray:[EquipmentService] = []
    var serviceUpcoming:JSON!
    
    
    var imageFullViewController:ImageFullViewController!
    
    
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        print("init _equipmentID = \(_equipment.ID)")
        self.equipment = _equipment
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        print("view will appear")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Equipment"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        getEquipmentServiceHistory()
        
    }
    
    func getEquipmentServiceHistory(){
        
        
         indicator = SDevIndicator.generate(self.view)!
        
        
        self.serviceHistoryArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
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
                    self.serviceHistory = JSON(json)
                    
                    let jsonCount = self.serviceHistory["serviceHistory"].count
                    print("JSONcount: \(jsonCount)")
                    for i in 0 ..< jsonCount {
                        
                        let equipmentService = EquipmentService(_ID: self.serviceHistory["serviceHistory"][i]["ID"].stringValue, _name: self.serviceHistory["serviceHistory"][i]["name"].stringValue, _type: self.serviceHistory["serviceHistory"][i]["type"].stringValue, _frequency: self.serviceHistory["serviceHistory"][i]["frequency"].stringValue, _instruction: self.serviceHistory["serviceHistory"][i]["instruction"].stringValue, _completionDate: self.serviceHistory["serviceHistory"][i]["completionDate"].stringValue, _completionMileage: self.serviceHistory["serviceHistory"][i]["completionMileage"].stringValue, _completedBy: self.serviceHistory["serviceHistory"][i]["completedBy"].stringValue, _notes: self.serviceHistory["serviceHistory"][i]["notes"].stringValue, _status: self.serviceHistory["serviceHistory"][i]["status"].stringValue)
                        
                        self.serviceHistoryArray.append(equipmentService)
                    }
                    
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                }
        }
 
    }
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        // indicator.dismissIndicator()
        
        
        
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EquipmentViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        ///////////   employee section   /////////////
        //image
        self.equipmentImage = UIImageView()
        
        
        
            activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityView.center = CGPoint(x: self.equipmentImage.frame.size.width / 2, y: self.equipmentImage.frame.size.height / 2)
            equipmentImage.addSubview(activityView)
            activityView.startAnimating()
            
            //let imgURL:URL = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.equipment.pic!)!
        
            let imgURL:URL = URL(string: self.equipment.image.thumbPath!)!
        
            print("imgURL = \(imgURL)")
            
            
            Nuke.loadImage(with: imgURL, into: self.equipmentImage!){
                print("nuke loadImage")
                self.equipmentImage?.handle(response: $0, isFromMemoryCache: $1)
                self.activityView.stopAnimating()
                
                //let image = Image(_path: self.equipment.pic!)
                
                
                
                //self.imageFullViewController = ImageFullViewController(_image: image)
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
        //if equipment.pic != "" {
        if equipment.image.ID != "0" {
            self.tapBtn.addTarget(self, action: #selector(EquipmentViewController.showFullScreenImage), for: UIControlEvents.touchUpInside)
        }
            self.tapBtn.backgroundColor = UIColor.clear
            self.tapBtn.setTitle("", for: UIControlState.normal)
            self.view.addSubview(self.tapBtn)
        
        
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = self.equipment.name!
        self.nameLbl.font = layoutVars.largeFont
        self.view.addSubview(self.nameLbl)
        
    
        //status
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        self.view.addSubview(statusIcon)
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
        
        //crew
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew: \(self.equipment.crewName!)"
        self.crewLbl.font = layoutVars.smallFont
        self.view.addSubview(self.crewLbl)
        
        //make model
        self.makeModelLbl = GreyLabel()
        self.makeModelLbl.text = "\(self.equipment.make!) - \(self.equipment.model!)"
        self.makeModelLbl.font = layoutVars.smallFont
        self.view.addSubview(self.makeModelLbl)
        
        //serial
        self.serialLbl = GreyLabel()
        self.serialLbl.text = "Serial#: \(self.equipment.serial!)"
        self.serialLbl.font = layoutVars.smallFont
        self.view.addSubview(self.serialLbl)
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = "Type: \(self.equipment.typeName!)"
        self.typeLbl.font = layoutVars.smallFont
        self.view.addSubview(self.typeLbl)
        
        //fuelType
        self.fuelLbl = GreyLabel()
        self.fuelLbl.text = "Fuel Type: \(self.equipment.fuelTypeName!)"
        self.fuelLbl.font = layoutVars.smallFont
        self.view.addSubview(self.fuelLbl)
        
        //engineType
        self.engineLbl = GreyLabel()
        self.engineLbl.text = "Engine Type: \(self.equipment.engineTypeName!)"
        self.engineLbl.font = layoutVars.smallFont
        self.view.addSubview(self.engineLbl)
        
        //dealer
        self.dealerLbl = GreyLabel()
        self.dealerLbl.text = "Dealer:"
        self.dealerLbl.font = layoutVars.smallFont
        self.view.addSubview(self.dealerLbl)
        
        //dealer value (vendor btn)
        self.dealerValueBtn = Button()
        self.dealerValueBtn.translatesAutoresizingMaskIntoConstraints = false
        self.dealerValueBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        self.dealerValueBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.dealerValueBtn.backgroundColor = UIColor.clear
        //self.dealerValueBtn.titleLabel?.textColor = layoutVars.buttonBackground
        
        if equipment.dealer != "0"{
            self.dealerValueBtn.addTarget(self, action: #selector(EquipmentViewController.showVendorView), for: UIControlEvents.touchUpInside)
            self.dealerValueBtn.setTitle(equipment.dealerName!, for: UIControlState.normal)
        }else{
            self.dealerValueBtn.setTitle("No Dealer on File", for: UIControlState.normal)
        }
        
       
        
        self.dealerValueBtn.setTitleColor(layoutVars.buttonColor1, for: .normal)
        
        
        self.view.addSubview(self.dealerValueBtn)
        
        //purchase date
        
        
        
        
        self.purchaseDateLbl = GreyLabel()
        print("purchaseDate = \(self.equipment.purchaseDate!)")
        if self.equipment.purchaseDate! != "" && self.equipment.purchaseDate! != "0000-00-00"{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: self.equipment.purchaseDate!)!
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "MM-dd-yyyy"
            let convertedDate = dateFormatter2.string(from: date)
            self.purchaseDateLbl.text = "Purchased: \(convertedDate)"
        }else{
             self.purchaseDateLbl.text = "No Date"
        }
        
        self.purchaseDateLbl.font = layoutVars.smallFont
        self.view.addSubview(self.purchaseDateLbl)
        
        
        //description
        
        self.descriptionView = UITextView()
        if self.equipment.description == ""{
            self.descriptionView.text = "No Description Provided"
        }else{
            self.descriptionView.text = self.equipment.description
        }
        
        self.descriptionView.font = layoutVars.textFieldFont
        self.descriptionView.backgroundColor = UIColor.clear
        self.descriptionView.isEditable = false
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(descriptionView)
        
        
        
        //service lbl
        self.serviceLbl = GreyLabel()
        self.serviceLbl.text = "Service:"
        self.serviceLbl.font = layoutVars.smallFont
        self.view.addSubview(self.serviceLbl)
        
        
        //service
        serviceSC = SegmentedControl(items: items)
        serviceSC.selectedSegmentIndex = 0
        
        serviceSC.addTarget(self, action: #selector(self.changeServiceView(sender:)), for: .valueChanged)
        self.view.addSubview(serviceSC)
        
        self.serviceTableView.delegate  =  self
        self.serviceTableView.dataSource = self
        self.serviceTableView.rowHeight = 50.0
        self.serviceTableView.register(EquipmentServiceTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(serviceTableView)
        
        
        
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "image":self.equipmentImage,
            "tapBtn":self.tapBtn,
            "name":self.nameLbl,
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "crew":self.crewLbl,
            "makeModel":self.makeModelLbl,
            "description":self.descriptionView,
            "serial":self.serialLbl,
            "type":self.typeLbl,
            "fuel":self.fuelLbl,
            "engine":self.engineLbl,
            "dealer":self.dealerLbl,
            "dealerValue":self.dealerValueBtn,
            "purchaseDate":self.purchaseDateLbl,
            "service":self.serviceLbl,
            "serviceSegmentedControl":self.serviceSC,
            "serviceTable":self.serviceTableView
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusIcon(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusTxtField(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[makeModel]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[description]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[type]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serial]-[crew(140)]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[fuel]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[engine]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dealer(80)][dealerValue]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[purchaseDate]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[service(80)][serviceSegmentedControl]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceTable]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(80)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tapBtn(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[statusIcon(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[statusTxtField(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[name(40)][makeModel(30)][description(20)][type(30)][serial(30)][fuel(30)][engine(30)][dealer(30)][purchaseDate(30)][service(30)]-[serviceTable]-10-|", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        
        
        
        
        
    }
    
    @objc func displayEditView(){
        print("display Edit View")
        self.equipmentDelegate.disableSearch()
        let editEquipmentViewController = NewEditEquipmentViewController(_equipment: self.equipment)
        editEquipmentViewController.editDelegate = self
        navigationController?.pushViewController(editEquipmentViewController, animated: false )
    }
    
    
    
    
    @objc func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        print("show full screen")
        
        navigationController?.pushViewController(imageFullViewController, animated: false )
    }
    
    
    
    
    @objc func showVendorView(){
        print("vendor = \(equipment.dealer)")
        let vendorViewController = VendorViewController(_vendorID: equipment.dealer)
        navigationController?.pushViewController(vendorViewController, animated: false )
    }
    
    
    
    
    @objc func changeServiceView(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
        case 0://history
            self.tableViewMode = "HISTORY"
            
            break
        case 1://up-coming
            
            break
        
        default:
            
            break
        }
        
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
    }
    
    @objc func cancelPicker(){
        self.statusTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        
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
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        switch self.tableViewMode{
        case "HISTORY":
            count = self.serviceHistoryArray.count
            break
        case "HISTORY":
            count = self.serviceUpcomingArray.count
            break
       
        default:
            count = self.serviceHistoryArray.count
            break
        }
        
        return count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serviceTableView.dequeueReusableCell(withIdentifier: "cell") as! EquipmentServiceTableViewCell
        switch self.tableViewMode{
        case "SCHEDULE":
            
            cell.equipmentService = self.serviceHistoryArray[indexPath.row]
            cell.layoutViews()
            break
        case "HISTORY":
            
            cell.equipmentService = self.serviceUpcomingArray[indexPath.row]
            cell.layoutViews()
        default:
            
            break
        }
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
    
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentServiceTableViewCell;
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
    }
    

    func updateEquipment(_equipment: Equipment){
        print("update Equipment")
        editsMade = true
        self.equipment = _equipment
        self.layoutViews()
        self.equipmentDelegate.reDrawEquipmentList()
        
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

