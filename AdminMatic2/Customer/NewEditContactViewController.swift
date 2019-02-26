//
//  NewEditContactViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/19.
//  Copyright © 2019 Nick. All rights reserved.
//



//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class NewEditContactViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    var delegate:ContactListDelegate!
    
    var submitButton:UIBarButtonItem!
    
    var editsMade:Bool = false
    
    
    var contactID:String = "0"
    
    
    
    var custId:String!
    
    var type:String = ""
    var typeName:String = ""
    var typeLbl:GreyLabel!
    var typePicker:Picker!
    var typeTxtField:PaddedTextField!
    
    var name:String = ""
    var nameLbl:GreyLabel!
    var nameTxtField:PaddedTextField!
    
    var val:String = ""
    var valueLbl:GreyLabel!
    var valueTxtField:PaddedTextField!
    
    var preferredLbl:Label!
    var preferredSwitch:UISwitch = UISwitch()
    var preferredValue:String = "0"
    
    var submitButtonBottom:Button = Button(titleText: "Submit")
    
    
    
    //init for new
    init(_custID:String){
        super.init(nibName:nil,bundle:nil)
        self.custId = _custID
        
    }
    
    
    //init for edit
    init(_custID:String,_contactID:String,_type:String,_typeName:String,_name:String,_value:String,_preferred:String){
        super.init(nibName:nil,bundle:nil)
        
        self.custId = _custID
        self.contactID = _contactID
        self.type = _type
        self.typeName = _typeName
        self.name = _name
        self.val = _value
        self.preferredValue = _preferred
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(NewEditEquipmentFieldViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        self.layoutViews()
    }
    
    
    
    
    func layoutViews(){
        
        
        //print("layout views")
        if(self.contactID == "0"){
            title =  "New Contact"
            
            
        }else{
            title =  "Edit Contact"
        }
        
        submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditContactViewController.submit))
        navigationItem.rightBarButtonItem = submitButton
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = "Type:"
        self.typeLbl.textAlignment = .left
        self.typeLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(typeLbl)
        if self.type == ""{
            self.typeTxtField = PaddedTextField(placeholder: "Type")
        }else{
            self.typeTxtField = PaddedTextField()
            self.typeTxtField.text = typeName
        }
        
        
        self.typePicker = Picker()
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        
        self.typeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.typeTxtField.autocapitalizationType = .words
        self.typeTxtField.returnKeyType = .done
        self.typeTxtField.delegate = self
        self.typeTxtField.inputView = self.typePicker
        safeContainer.addSubview(self.typeTxtField)
        
        let typeToolBar = UIToolbar()
        typeToolBar.barStyle = UIBarStyle.default
        typeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        typeToolBar.sizeToFit()
        let closeTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContactViewController.cancelTypeInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContactViewController.handleTypeChange))
        typeToolBar.setItems([closeTypeButton, spaceButton, setTypeButton], animated: false)
        typeToolBar.isUserInteractionEnabled = true
        typeTxtField.inputAccessoryView = typeToolBar
        
        
        
        
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = "Name (ex: John's Email):"
        self.nameLbl.textAlignment = .left
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(nameLbl)
        if self.name == ""{
            self.nameTxtField = PaddedTextField(placeholder: "Name")
        }else{
            self.nameTxtField = PaddedTextField()
            self.nameTxtField.text = name
        }
        
        
        let textInputToolBar = UIToolbar()
        textInputToolBar.barStyle = UIBarStyle.default
        textInputToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        textInputToolBar.sizeToFit()
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelInput))
        
        textInputToolBar.setItems([closeButton], animated: false)
        textInputToolBar.isUserInteractionEnabled = true
        
        
        
        self.nameTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTxtField.autocapitalizationType = .words
        self.nameTxtField.returnKeyType = .done
        self.nameTxtField.delegate = self
        self.nameTxtField.inputAccessoryView = textInputToolBar
        safeContainer.addSubview(self.nameTxtField)
        
        
        //value
        self.valueLbl = GreyLabel()
        self.valueLbl.text = "Value (ex: john@gmail.com):"
        self.valueLbl.textAlignment = .left
        self.valueLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(valueLbl)
        if self.val == ""{
            self.valueTxtField = PaddedTextField(placeholder: "Value")
        }else{
            self.valueTxtField = PaddedTextField()
            self.valueTxtField.text = val
        }
        
        self.valueTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.valueTxtField.autocapitalizationType = .none
        self.valueTxtField.returnKeyType = .done
        self.valueTxtField.delegate = self
        self.valueTxtField.inputAccessoryView = textInputToolBar
        safeContainer.addSubview(self.valueTxtField)
        
        
        
        self.preferredLbl = Label()
        self.preferredLbl.text = "Preferred Contact?"
        
        safeContainer.addSubview(preferredLbl)
        
        self.preferredSwitch = UISwitch()
        self.preferredSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        if self.preferredValue == "1"{
            preferredSwitch.isOn = true
        }
        
        self.preferredSwitch.addTarget(self, action: #selector(self.preferredSwitchValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(preferredSwitch)
        
        
        
        
        
        
        self.submitButtonBottom.addTarget(self, action: #selector(NewEditEquipmentFieldViewController.submit), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.submitButtonBottom)
        
        
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "typeLbl":self.typeLbl,
            "typeTxt":self.typeTxtField,
            "nameLbl":self.nameLbl,
            "nameTxt":self.nameTxtField,
            "valueLbl":self.valueLbl,
            "valueTxt":self.valueTxtField,
            "preferredLbl":self.preferredLbl,
            "preferredSwitch":self.preferredSwitch,
            
            "submitBtn":self.submitButtonBottom
            ] as [String:AnyObject]
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[typeLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[typeTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[nameLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[nameTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[valueLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[valueTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[preferredSwitch(60)][preferredLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[submitBtn]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[typeLbl(40)][typeTxt(40)]-[nameLbl(40)][nameTxt(40)]-[valueLbl(40)][valueTxt(40)]-20-[preferredLbl(40)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[typeLbl(40)][typeTxt(40)]-[nameLbl(40)][nameTxt(40)]-[valueLbl(40)][valueTxt(40)]-20-[preferredSwitch(40)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submitBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        
        
        
        
    }
    
    
    @objc func preferredSwitchValueDidChange(sender:UISwitch!)
    {
        //print("switchValueDidChange groupImages = \(groupImages)")
        
        if sender.isOn {
            self.preferredValue = "1"
        }else{
            self.preferredValue = "0"
        }
    }
    
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        var count:Int = 0
       
        count = self.appDelegate.contactTypeNames.count
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title:String = ""
        
        title = self.appDelegate.contactTypeNames[row]
        
        return title
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("pickerview tag: \(pickerView.tag)")
        
        
        
            type = self.appDelegate.contactTypeIDs[row]
            typeTxtField.text = self.appDelegate.contactTypeNames[row]
            
        
    }
    
    
    
    
    
    @objc func cancelTypeInput(){
        print("Cancel Type Input")
        self.typeTxtField.resignFirstResponder()
    }
    
    @objc func handleTypeChange(){
        self.typeTxtField.resignFirstResponder()
        
        //equipment.crew = crewIDArray[self.crewPicker.selectedRow(inComponent: 0)]
        //equipment.crewName = crewNameArray[self.crewPicker.selectedRow(inComponent: 0)]
        self.type = self.appDelegate.contactTypeIDs[self.typePicker.selectedRow(inComponent: 0)]
        self.typeTxtField.text = self.appDelegate.contactTypeNames[self.typePicker.selectedRow(inComponent: 0)]
        
       
        
        editsMade = true
    }
    
    @objc func cancelInput(){
        print("Cancel Input")
        self.view.endEditing(true)
        //self.purchasedTxtField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder()
        editsMade = true
        return true
    }
    
    
    
    
    
    func validateFields()->Bool{
        
        
        print("validate fields")
        
        
        
        if nameTxtField.text != nameTxtField.placeHolder{
            name = nameTxtField.text!
        }
        
        if valueTxtField.text != valueTxtField.placeHolder{
            val = valueTxtField.text!
        }
        
        //type check
        if(typeTxtField.text == "" || typeTxtField.text == typeTxtField.placeHolder){
            print("provide a type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Contact", _message: "Provide a Type")
            return false
        }
        
        
        
        //value check
        if(val == ""){
            print("provide a value")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Contact", _message: "Provide a Value")
            return false
        }
        
        
        
        
        return true
        
        
    }
    
    
    
    @objc func submit(){
        print("submit field")
        
        
        
        if(!validateFields()){
            print("didn't pass validation")
            return
        }
        
        
        //validate all fields
        
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        
        
        /*
 $type = $_POST['type'];
 $name = $db->real_escape_string($_POST['name']);
 //$sort = $_POST['sort'];
 $contactID = intval($_POST['contactID']);
 $del = intval($_POST['del']);
 $custID = intval($_POST['custID']);
 */
        
        
        
        let parameters:[String:String]
        parameters = ["type": self.type, "name": self.name, "value": self.val, "contactID": self.contactID, "custID": self.custId, "preferred": self.preferredValue] as! [String : String]
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contact.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("contact response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    
                    if self.json["errorArray"][0]["error"].stringValue.count > 0{
                        self.layoutVars.playErrorSound()
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Error with Save", _message: self.json["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                    
                    self.layoutVars.playSaveSound()
                    //let newContactID = self.json["equipmentFieldID"].stringValue
                    
                    
                    //self.ID = newEquipmentFieldID
                    
                    self.editsMade = false // avoids the back without saving check
                    
                    
                    
                    self.delegate.updateList()
                    
                    self.goBack()
                    
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
        
        
    }
    
    
    
    
    @objc func goBack(){
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                _ = self.navigationController?.popViewController(animated: false)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: false)
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
    
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    
    
    
    
    
}


