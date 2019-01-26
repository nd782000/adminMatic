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
//import Nuke

protocol EditEquipmentDelegate{
    func updateEquipment(_equipment:Equipment)
}

 
class EquipmentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, EditEquipmentDelegate {
    
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
    var descriptionView:UITextView = UITextView()
    var serialLbl:GreyLabel!
    var crewLbl:GreyLabel!
    var fuelLbl:GreyLabel!
    var engineLbl:GreyLabel!
    var dealerLbl:GreyLabel!
    var dealerValueBtn:Button!
    var purchaseDateLbl:GreyLabel!
    var serviceBtn:Button!
    
    
    
   
    
    var keyBoardShown:Bool = false
    
    
    
    
    
    var imageFullViewController:ImageFullViewController!
    
    
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        //print("init _equipmentID = \(_equipment.ID)")
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
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        layoutViews()
        
        DispatchQueue.main.async {
            self.descriptionView.contentOffset = CGPoint.zero
            self.descriptionView.scrollRangeToVisible(NSRange(location:0, length:0))
        }
        
        
    }
    
   
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        
        
        
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EquipmentViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        //image
        self.equipmentImage = UIImageView()
    
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        //activityView.center = CGPoint(x: self.equipmentImage.frame.size.width / 2, y: self.equipmentImage.frame.size.height / 2)
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        equipmentImage.addSubview(activityView)
        activityView.startAnimating()
        
        /*
        let imgURL:URL = URL(string: self.equipment.image.thumbPath!)!
    
        print("imgURL = \(imgURL)")
        
        Nuke.loadImage(with: imgURL, into: self.equipmentImage!){
            print("nuke loadImage")
            self.equipmentImage?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
            self.imageFullViewController = ImageFullViewController(_image: self.equipment.image)
        }
        */
        
        
        Alamofire.request(self.equipment.image.thumbPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                self.imageFullViewController = ImageFullViewController(_image: self.equipment.image)
                self.equipmentImage.image = image
                //cell.imageView.image = image
                self.activityView.stopAnimating()
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
            self.tapBtn.addTarget(self, action: #selector(EquipmentViewController.showFullScreenImage), for: UIControl.Event.touchUpInside)
        }
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControl.State.normal)
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
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(WorkOrderViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(WorkOrderViewController.handleStatusChange))
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
        self.dealerValueBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        self.dealerValueBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.dealerValueBtn.backgroundColor = UIColor.clear
        //self.dealerValueBtn.titleLabel?.textColor = layoutVars.buttonBackground
        
        if equipment.dealer != "0"{
            self.dealerValueBtn.addTarget(self, action: #selector(EquipmentViewController.showVendorView), for: UIControl.Event.touchUpInside)
            self.dealerValueBtn.setTitle(equipment.dealerName!, for: UIControl.State.normal)
        }else{
            self.dealerValueBtn.setTitle("No Dealer on File", for: UIControl.State.normal)
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
        
        //self.descriptionView = UITextView()
        if self.equipment.description == ""{
            self.descriptionView.text = "No Description Provided"
        }else{
            self.descriptionView.text = self.equipment.description
        }
        
        self.descriptionView.font = layoutVars.smallFont
        self.descriptionView.backgroundColor = UIColor.clear
        self.descriptionView.isEditable = false
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(descriptionView)
        
        
        
        //service btn
        
        //dealer value (vendor btn)
        self.serviceBtn = Button(titleText: "View Service Lists")
        self.serviceBtn.translatesAutoresizingMaskIntoConstraints = false
        self.serviceBtn.addTarget(self, action: #selector(EquipmentViewController.showServiceListView), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.serviceBtn)
        
        
        
        
        
        
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "image":self.equipmentImage,
            "activity":self.activityView,
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
            "serviceBtn":self.serviceBtn
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusIcon(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activity(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusTxtField(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[makeModel]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[description]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[type]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serial]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[crew]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[fuel]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[engine]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dealer(80)][dealerValue]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[purchaseDate]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[serviceBtn]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: equipmentViewsDictionary))
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(80)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tapBtn(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activity(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[statusIcon(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[statusTxtField(40)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[name(40)][makeModel(40)]-[description(40)][type(30)][serial(30)][crew(30)][fuel(30)][engine(30)][dealer(30)][purchaseDate(30)]", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[serviceBtn(40)]-16-|", options: [], metrics: sizeVals, views: equipmentViewsDictionary))
        
        
        
        
        
    }
    
    @objc func displayEditView(){
        print("display Edit View")
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        
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
        //print("vendor = \(equipment.dealer)")
        let vendorViewController = VendorViewController(_vendorID: equipment.dealer)
        navigationController?.pushViewController(vendorViewController, animated: false )
    }
    
    @objc func showServiceListView(){
        print("show service list view")
        let serviceListViewController = EquipmentServiceListViewController(_equipment: self.equipment)
        serviceListViewController.editEquipmentDelegate = self
        navigationController?.pushViewController(serviceListViewController, animated: false )
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
    
    
    
    

    func updateEquipment(_equipment: Equipment){
        print("update Equipment")
        editsMade = true
        self.equipment = _equipment
        
        statusValueToUpdate = equipment.status
        handleStatusChange()
        self.layoutViews()
        //self.equipmentDelegate.reDrawEquipmentList()
        
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

