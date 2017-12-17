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




class EquipmentViewController: ViewControllerWithMenu, UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDelegate {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var equipmentDelegate:EquipmentDelegate!
    var equipmentIndex:Int!
    
    var equipmentJSON: JSON!
    var equipment:Equipment!
    

    //employee info
    var equipmentView:UIView!
    var serviceView:UIView!
    
    
    var equipmentImage:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var nameLbl:GreyLabel!
    
    var statusIcon:UIImageView = UIImageView()
    
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Online","Needs Service","Broken","Winterized"]
    
    
    var statusValue: String!
    var statusValueToUpdate: String!

    var makeModelLbl:GreyLabel!
    var serialLbl:GreyLabel!
    
    var keyBoardShown:Bool = false
    
    var equipmentServiceArray:[EquipmentService] = []
    var equipmentService:JSON!
    
    
    
    
    
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
        
        /*
         indicator = SDevIndicator.generate(self.view)!
        
        
        self.equipmentServiceArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)"]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/equipmentServiceHistory.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("equipment service response = \(response)")
            }
            .responseJSON() {
                response in
                if let json = response.result.value {
                    self.equipmentService = JSON(json)
                    
                    let jsonCount = self.equipmentService["serviceHistory"].count
                    print("JSONcount: \(jsonCount)")
                    for i in 0 ..< jsonCount {
                        
                        let equipmentService = EquipmentService(_ID: self.equipmentService["equipmentService"][i]["ID"].stringValue, _name: self.equipmentService["equipmentService"][i]["name"].stringValue, _type: self.equipmentService["equipmentService"][i]["type"].stringValue, _frequency: self.equipmentService["equipmentService"][i]["frequency"].stringValue, _instruction: self.equipmentService["equipmentService"][i]["instruction"].stringValue, _completionDate: self.equipmentService["equipmentService"][i]["completionDate"].stringValue, _completionMileage: self.equipmentService["equipmentService"][i]["completionMileage"].stringValue, _completedBy: self.equipmentService["equipmentService"][i]["completedBy"].stringValue, _notes: self.equipmentService["equipmentService"][i]["notes"].stringValue, _status: self.equipmentService["equipmentService"][i]["status"].stringValue)
                        
                        self.equipmentServiceArray.append(equipmentService)
                    }
                    
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                }
                self.layoutViews()
        }
 */
        
        
        
        self.layoutViews()
    }
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        // indicator.dismissIndicator()
        
        //////////   containers for different sections
        self.equipmentView = UIView()
        self.equipmentView.backgroundColor = layoutVars.backgroundColor
        self.equipmentView.layer.borderColor = layoutVars.borderColor
        self.equipmentView.layer.borderWidth = 1.0
        self.equipmentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.equipmentView)
        
        self.serviceView = UIView()
        self.serviceView.backgroundColor = layoutVars.backgroundColor
        self.serviceView.layer.borderColor = layoutVars.borderColor
        self.serviceView.layer.borderWidth = 1.0
        self.serviceView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.serviceView)
        
        
        //auto layout group
        let viewsDictionary = [
            "equipmentView":self.equipmentView,
            "serviceView":self.serviceView
            ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[equipmentView(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[serviceView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[equipmentView(200)][serviceView]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        ///////////   employee section   /////////////
        //image
        self.equipmentImage = UIImageView()
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = CGPoint(x: self.equipmentImage.frame.size.width / 2, y: self.equipmentImage.frame.size.height / 2)
        equipmentImage.addSubview(activityView)
        activityView.startAnimating()
        
        let imgURL:URL = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.equipment.pic!)!
        
        print("imgURL = \(imgURL)")
        
        
        Nuke.loadImage(with: imgURL, into: self.equipmentImage!){
            print("nuke loadImage")
            self.equipmentImage?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
        }
        
        
        self.equipmentImage.layer.cornerRadius = 5.0
        self.equipmentImage.layer.borderWidth = 2
        self.equipmentImage.layer.borderColor = layoutVars.borderColor
        self.equipmentImage.clipsToBounds = true
        self.equipmentImage.translatesAutoresizingMaskIntoConstraints = false
        self.equipmentView.addSubview(self.equipmentImage)
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = self.equipment.name!
        self.nameLbl.font = layoutVars.largeFont
        self.equipmentView.addSubview(self.nameLbl)
        
    
        //statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        self.equipmentView.addSubview(statusIcon)
        
        
        setStatus(status: equipment.status)
        
        
        //employee picker
        self.statusPicker = Picker()
        print("statusValue : \(equipment.status)")
        print("set picker position : \(Int(self.equipment.status)! - 1)")
        
        self.statusPicker.delegate = self
        
        self.statusPicker.selectRow(Int(self.equipment.status)! - 1, inComponent: 0, animated: false)
        
        self.statusTxtField = PaddedTextField(placeholder: "")
        self.statusTxtField.textAlignment = NSTextAlignment.center
        self.statusTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.statusTxtField.tag = 1
        self.statusTxtField.delegate = self
        self.statusTxtField.tintColor = UIColor.clear
        self.statusTxtField.backgroundColor = UIColor.clear
        self.statusTxtField.inputView = statusPicker
        self.statusTxtField.layer.borderWidth = 0
        self.equipmentView.addSubview(self.statusTxtField)
        
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
        
        //make model
        self.makeModelLbl = GreyLabel()
        self.makeModelLbl.text = "\(self.equipment.make!) - \(self.equipment.model!)"
        self.makeModelLbl.font = layoutVars.labelFont
        self.equipmentView.addSubview(self.makeModelLbl)
        
        //serial
        self.serialLbl = GreyLabel()
        self.serialLbl.text = "Serial#: \(self.equipment.serial!)"
        self.serialLbl.font = layoutVars.labelFont
        self.equipmentView.addSubview(self.serialLbl)
        
        
        //auto layout group
        let equipmentViewsDictionary = [
            "image":self.equipmentImage,
            "name":self.nameLbl,
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "makeModel":self.makeModelLbl,
            "serial":self.serialLbl
            ] as [String:Any]
        
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusIcon(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[name]-[statusTxtField(40)]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[makeModel]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(80)]-[serial]-|", options: [], metrics: nil, views: equipmentViewsDictionary))
        
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(80)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(40)]-[makeModel(30)]-[serial(30)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(40)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        self.equipmentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusTxtField(40)]", options: [], metrics: nil, views: equipmentViewsDictionary))
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            // tableView.contentInset.bottom = keyboardFrame.height
            if(!keyBoardShown){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    // var fabricTopFrame = self.fabricTop.frame
                    self.view.frame.origin.y -= keyboardFrame.height
                    
                }, completion: { finished in
                    // //print("Napkins opened!")
                })
            }
        }
        keyBoardShown = true
    }
    
    
    @objc func keyboardDidHide(notification: NSNotification) {
        keyBoardShown = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            // var fabricTopFrame = self.fabricTop.frame
            self.view.frame.origin.y = 0
            
        }, completion: { finished in
            ////print("Napkins opened!")
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
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
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
            myImageView.image = UIImage(named:"doneStatus.png")
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
        //self.statusValueToUpdate = self.statusValue
        self.statusTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        
        self.statusTxtField.resignFirstResponder()
        
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
                self.equipmentDelegate.reDrawEquipmentList(_index: self.equipmentIndex, _status: self.statusValue)
                
            }
            }.responseString() {
                response in
                print(response)  // original URL request
        }
        
    }
    
    
    
    
    
    
    func setStatus(status: String) {
        print("set status status = \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"doneStatus.png")
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
            //let statusImg = UIImage(named:"onlineIcon.png")
            statusIcon.image = nil
            break;
        }
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

