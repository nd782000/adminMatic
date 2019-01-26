//
//  NewEditEquipmentServiceViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/4/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


 
class NewEditEquipmentServiceViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    
    var equipmentID:String!
    var currentValue:String = "0"
    var equipmentService:EquipmentService!
    var submitButton:UIBarButtonItem!
    
    var serviceListDelegate:ServiceListDelegate!
    var editDelegate:EditEquipmentServiceDelegate!
    var editsMade:Bool = false
    

    //name
    var nameLbl:GreyLabel!
    var nameTxtField:PaddedTextField!
    
    //type
    var typeLbl:GreyLabel!
    var typeTxtField:PaddedTextField!
    var typePicker: Picker!
    var typeArray:[String] = ["One Time","Date Based","Mile/Km. Based","Engine Hour Based","Inspection"]
    
    //frequency
    var frequencyLbl:GreyLabel!
    var frequencyTxtField:PaddedTextField!
    
    //current
    var currentLbl:GreyLabel!
    var currentTxtField:PaddedTextField!
    
    //next
    var nextLbl:GreyLabel!
    var nextTxtField:PaddedTextField!
    
    var nextDatePicker: DatePicker!
    
    
    
    //instructions
    var instructionsLbl:GreyLabel!
    var instructionsView:UITextView = UITextView()
    let instructionsToolBar:UIToolbar = UIToolbar()

    var submitButtonBottom:Button = Button(titleText: "Submit")
    
    let dateFormatter = DateFormatter()
    let dateFormatterDB = DateFormatter()
    

    //init for new
    init(_equipmentID:String,_currentValue:String){
        super.init(nibName:nil,bundle:nil)
        self.equipmentID = _equipmentID
        if _currentValue == ""{
            print("setting current value to 0")
            self.currentValue = "0"
        }else{
            self.currentValue = _currentValue
        }
        
        print("init self.currentValue = \(self.currentValue)")
        //for an empty lead to start things off
    }
    
    
    //init for edit
    init(_equipmentService:EquipmentService){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        self.equipmentService = _equipmentService
        print("init self.currentValue = \(self.currentValue)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(LeadViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        layoutViews()
    }
    
    
    
    
     override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.instructionsView.contentOffset = CGPoint.zero
            self.instructionsView.scrollRangeToVisible(NSRange(location:0, length:0))
        }
    }
    
    
    
    func layoutViews(){
        
        
        submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditEquipmentServiceViewController.submit))

        //print("layout views")
        
        
        if(self.equipmentService == nil){
            title =  "New Service"
            self.equipmentService = EquipmentService(_ID:"0", _name: "",_type:"0",_typeName:"One Time",  _frequency:"0",  _instruction:"", _creationDate:"", _createdBy:"", _completionDate:"", _completionMileage:"0", _completedBy:"", _notes:"", _status:"0", _currentValue:self.currentValue, _nextValue:"0", _equipmentID:self.equipmentID)
        }else{
            title =  "Edit Service"
        }
        navigationItem.rightBarButtonItem = submitButton
        
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatterDB.dateFormat = "yyyy-MM-dd HH:mm:ss"
       
        
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = "Name:"
        self.nameLbl.textAlignment = .left
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(nameLbl)
        if self.equipmentService.name == ""{
            self.nameTxtField = PaddedTextField(placeholder: "Name")
        }else{
            self.nameTxtField = PaddedTextField()
            self.nameTxtField.text = equipmentService.name!
        }
        
        self.nameTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTxtField.autocapitalizationType = .words
        self.nameTxtField.delegate = self
        self.nameTxtField.tag = 1
        self.nameTxtField.returnKeyType = .done
        self.view.addSubview(self.nameTxtField)
        
        
       
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = "Type:"
        self.typeLbl.textAlignment = .left
        self.typeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(typeLbl)
        
        self.typePicker = Picker()
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        self.typePicker.tag = 5
        
        
        if self.equipmentService.type == ""{
            self.typeTxtField = PaddedTextField(placeholder: "Type")
        }else{
            self.typeTxtField = PaddedTextField()
            self.typeTxtField.text = equipmentService.typeName!
        }
        
        self.typeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.typeTxtField.delegate = self
        self.typeTxtField.inputView = typePicker
        self.typeTxtField.returnKeyType = .done
        self.view.addSubview(self.typeTxtField)
        
        
        let typeToolBar = UIToolbar()
        typeToolBar.barStyle = UIBarStyle.default
        typeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        typeToolBar.sizeToFit()
        let closeTypeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.cancelTypeInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setTypeButton = UIBarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.handleTypeChange))
        typeToolBar.setItems([closeTypeButton, spaceButton, setTypeButton], animated: false)
        typeToolBar.isUserInteractionEnabled = true
        typeTxtField.inputAccessoryView = typeToolBar
        
        
        
        
        //frequency
        self.frequencyLbl = GreyLabel()
        
        self.frequencyLbl.textAlignment = .left
        self.frequencyLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(frequencyLbl)
        if self.equipmentService.frequency == "0"{
            self.frequencyTxtField = PaddedTextField(placeholder: "Frequency")
        }else{
            self.frequencyTxtField = PaddedTextField()
            self.frequencyTxtField.text = equipmentService.frequency!
        }
        
        self.frequencyTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.frequencyTxtField.delegate = self
        self.frequencyTxtField.tag = 10
        self.frequencyTxtField.keyboardType = UIKeyboardType.numberPad
        self.view.addSubview(self.frequencyTxtField)
        
        let frequencyToolBar = UIToolbar()
        frequencyToolBar.barStyle = UIBarStyle.default
        frequencyToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        frequencyToolBar.sizeToFit()
        let closeFrequencyButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.cancelFrequencyInput))
        let setFrequencyButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.handleFrequencyChange))
        
        frequencyToolBar.setItems([closeFrequencyButton,spaceButton,setFrequencyButton], animated: false)
        frequencyToolBar.isUserInteractionEnabled = true
        self.frequencyTxtField.inputAccessoryView = frequencyToolBar
        
        
        
        //current
        self.currentLbl = GreyLabel()
        self.currentLbl.textAlignment = .left
        self.currentLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(currentLbl)
        
        
        
       
       // setCurrentText()
        
        
        if self.equipmentService.type == "1"{
            //treat current as a date
            
            
            self.currentTxtField = PaddedTextField()
            self.currentTxtField.text = dateFormatter.string(from: Date())
            self.currentTxtField.isEnabled = false
            
        }else{
            if self.equipmentService.currentValue == "0"{
                self.currentTxtField = PaddedTextField(placeholder: "Current")
            }else{
                self.currentTxtField = PaddedTextField()
                self.currentTxtField.text = equipmentService.currentValue!
            }
            self.currentTxtField.keyboardType = UIKeyboardType.numberPad
            self.currentTxtField.delegate = self
            self.currentTxtField.tag = 11
        }
 
        
        
        self.currentTxtField.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.currentTxtField)
        
        let currentToolBar = UIToolbar()
        currentToolBar.barStyle = UIBarStyle.default
        currentToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        currentToolBar.sizeToFit()
        let closeCurrentButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.cancelCurrentInput))
        let setCurrentButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.handleCurrentChange))
        
        currentToolBar.setItems([closeCurrentButton,spaceButton,setCurrentButton], animated: false)
        
        currentToolBar.isUserInteractionEnabled = true
        self.currentTxtField.inputAccessoryView = currentToolBar
        
        
        
        //next
        self.nextLbl = GreyLabel()
        self.nextLbl.textAlignment = .left
        self.nextLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(nextLbl)
        
        //setNextText()
       
        if self.equipmentService.type == "1"{
            //treat current as a date
            nextDatePicker = DatePicker()
            nextDatePicker.datePickerMode = UIDatePicker.Mode.date
            self.nextTxtField = PaddedTextField()
            self.nextTxtField.inputView = self.nextDatePicker
            self.nextTxtField.text = layoutVars.determineUpcomingDate(_equipmentService: equipmentService)
            let date = dateFormatter.date(from: self.nextTxtField.text!)
            nextDatePicker.date = date!
            nextDatePicker.minimumDate = Date()
            
        }else{
            if self.equipmentService.nextValue == "0"{
                self.nextTxtField = PaddedTextField(placeholder: "Next")
            }else{
                self.nextTxtField = PaddedTextField()
                self.nextTxtField.text = equipmentService.nextValue!
            }
            self.nextTxtField.keyboardType = UIKeyboardType.numberPad
            self.nextTxtField.delegate = self
            self.nextTxtField.tag = 11
        }
 
        
        self.nextTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.nextTxtField)
        
        let nextToolBar = UIToolbar()
        nextToolBar.barStyle = UIBarStyle.default
        nextToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        nextToolBar.sizeToFit()
        let closeNextButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.cancelNextInput))
        let setNextButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.handleNextChange))
        nextToolBar.setItems([closeNextButton,spaceButton,setNextButton], animated: false)
        
        nextToolBar.isUserInteractionEnabled = true
        self.nextTxtField.inputAccessoryView = nextToolBar
        
        
        
        
        self.typePicker.selectRow(Int(self.equipmentService.type)!, inComponent: 0, animated: false)
        editInputLabels()
        
       
        
        
        
        //instructions
        self.instructionsLbl = GreyLabel()
        self.instructionsLbl.text = "Instructions:"
        self.instructionsLbl.textAlignment = .left
        self.instructionsLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.instructionsLbl)
        
       // self.instructionsView = UITextView()
        self.instructionsView.layer.borderWidth = 1
        self.instructionsView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.instructionsView.layer.cornerRadius = 4.0
        //self.instructionsView.returnKeyType = .done
        self.instructionsView.text = self.equipmentService.instruction
        self.instructionsView.font = layoutVars.smallFont
        self.instructionsView.isEditable = true
        self.instructionsView.delegate = self
        self.instructionsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.instructionsView)
        
        //let instructionsToolBar = UIToolbar()
        self.instructionsToolBar.barStyle = UIBarStyle.default
        self.instructionsToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        self.instructionsToolBar.sizeToFit()
        let closeInstructionsButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.cancelInstructionsInput))
        let setInstructionsButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentServiceViewController.handleInstructionsChange))
        
        self.instructionsToolBar.setItems([closeInstructionsButton,spaceButton,setInstructionsButton], animated: false)
        self.instructionsToolBar.isUserInteractionEnabled = true
        self.instructionsView.inputAccessoryView = self.instructionsToolBar
        
        
        
        self.submitButtonBottom.addTarget(self, action: #selector(NewEditEquipmentServiceViewController.submit), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.submitButtonBottom)
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            "nameLbl":self.nameLbl,
            "nameTxt":self.nameTxtField,
            "typeLbl":self.typeLbl,
            "typeTxt":self.typeTxtField,
            "frequencyLbl":self.frequencyLbl,
            "frequencyTxt":self.frequencyTxtField,
            "currentLbl":self.currentLbl,
            "currentTxt":self.currentTxtField,
            "nextLbl":self.nextLbl,
            "nextTxt":self.nextTxtField,
            "instructionsLbl":self.instructionsLbl,
            "instructionsView":self.instructionsView,
            "submitBtn":self.submitButtonBottom
            ] as [String:AnyObject]
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameLbl]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameTxt]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[typeLbl]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[typeTxt]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[frequencyLbl]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[frequencyTxt]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[currentLbl(halfWidth)]-[nextLbl(halfWidth)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[currentTxt(halfWidth)]-[nextTxt(halfWidth)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[instructionsLbl]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[instructionsView]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[submitBtn]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][nameTxt(30)]-[typeLbl(30)][typeTxt(30)]-[frequencyLbl(30)][frequencyTxt(30)]-[currentLbl(30)][currentTxt(30)]-[instructionsLbl(30)][instructionsView]-[submitBtn(40)]-20-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][nameTxt(30)]-[typeLbl(30)][typeTxt(30)]-[frequencyLbl(30)][frequencyTxt(30)]-[nextLbl(30)][nextTxt(30)]-[instructionsLbl(30)][instructionsView]-[submitBtn(40)]-20-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
    }
    
    
    
    
    func setCurrentText(){
        
        print("set current text")
        if self.equipmentService.type == "1"{
            //treat current as a date
            
            
            //self.currentTxtField = PaddedTextField()
            self.currentTxtField.text = dateFormatter.string(from: Date())
            self.currentTxtField.isEnabled = false
            self.currentValue = "0"
            self.equipmentService.currentValue = "0"
            
        }else{
            
            self.currentValue = "0"
            self.equipmentService.currentValue = "0"
            self.currentTxtField.text = equipmentService.currentValue!
            
            self.currentTxtField.isEnabled = true
            self.currentTxtField.keyboardType = UIKeyboardType.numberPad
            self.currentTxtField.delegate = self
            self.currentTxtField.tag = 11
        }
    }
    
    func setNextText(){
        print("setNextText")
        if self.equipmentService.type == "1"{
            //treat current as a date
            nextDatePicker = DatePicker()
            nextDatePicker.datePickerMode = UIDatePicker.Mode.date
            //self.nextTxtField = PaddedTextField()
            self.nextTxtField.inputView = self.nextDatePicker
            self.nextTxtField.text = layoutVars.determineUpcomingDate(_equipmentService: equipmentService)
            nextDatePicker.minimumDate = Date()
            let date = dateFormatter.date(from: self.nextTxtField.text!)
            nextDatePicker.date = date!
            
            
        }else{
            
            self.nextTxtField.text = equipmentService.nextValue!
            self.nextTxtField.inputView = nil
            self.nextTxtField.keyboardType = UIKeyboardType.numberPad
            self.nextTxtField.delegate = self
            self.nextTxtField.tag = 11
        }
    }
    
    
    
    @objc func cancelTypeInput(){
        print("Cancel Type Input")
        self.typeTxtField.resignFirstResponder()
        
       
            equipmentService.type = "\(self.typePicker.selectedRow(inComponent: 0))"
            equipmentService.typeName = typeArray[self.typePicker.selectedRow(inComponent: 0)]
            
            self.typeTxtField.text = equipmentService.typeName
            
            //print("type = \(equipmentService.type)")
            //print("typeName = \(equipmentService.typeName)")
            
            editsMade = true
            
            editInputLabels()
    }
    
    @objc func handleTypeChange(){
        self.typeTxtField.resignFirstResponder()
        
        equipmentService.type = "\(self.typePicker.selectedRow(inComponent: 0))"
        equipmentService.typeName = typeArray[self.typePicker.selectedRow(inComponent: 0)]
        
        
       
        equipmentService.creationDate = dateFormatterDB.string(from: Date())

        
        self.typeTxtField.text = equipmentService.typeName
        //print("type = \(equipmentService.type)")
       // print("typeName = \(equipmentService.typeName)")
        
       
            editsMade = true
            editInputLabels()
            setCurrentText()
            setNextText()
       
        
        
        
    }
    
    
    @objc func cancelCurrentInput(){
        print("Cancel Current Input")
        self.currentTxtField.resignFirstResponder()
        if self.currentTxtField.text != self.equipmentService.currentValue{
            editsMade = true
        }
    }
    @objc func handleCurrentChange(){
        print("Set Current Input")
        self.currentTxtField.resignFirstResponder()
        
        if frequencyTxtField.text == ""{
            frequencyTxtField.text = "0"
            equipmentService.frequency = "0"
        }
        if currentTxtField.text == ""{
            currentTxtField.text = "0"
            equipmentService.currentValue = "0"
        }
        
        
        self.equipmentService.currentValue = self.currentTxtField.text
        
        if(self.equipmentService.frequency != "0" && self.equipmentService.currentValue != "0" && self.equipmentService.nextValue == "0"){
            self.nextTxtField.text = "\(Int(self.equipmentService.frequency)! + Int(self.equipmentService.currentValue)!)"
            self.equipmentService.nextValue = self.nextTxtField.text
        }
        
        
        editsMade = true
    }
    
    @objc func cancelNextInput(){
        print("Cancel Next Input")
        self.nextTxtField.resignFirstResponder()
        if self.nextTxtField.text != self.equipmentService.nextValue{
            editsMade = true
        }
    }
    @objc func handleNextChange(){
        print("Set Next Input")
        self.nextTxtField.resignFirstResponder()
        if self.equipmentService.type == "1"{
            
            
           
            let date = dateFormatterDB.date(from: equipmentService.creationDate)
            
            self.nextTxtField.text = dateFormatter.string(from: nextDatePicker.date)
            
            let calendar = Calendar.current
            
            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: date!)
            let date2 = calendar.startOfDay(for: nextDatePicker.date)
            
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            
            print("number of days from creation date = \(components.day!)")
            
            equipmentService.nextValue = "\(components.day!)"
            
        }else{
            self.equipmentService.nextValue = self.nextTxtField.text
            
        }
        editsMade = true
    }
    
    
    
    
    
    
    @objc func cancelFrequencyInput(){
        print("Cancel Frequency Input")
        self.frequencyTxtField.resignFirstResponder()
        if self.frequencyTxtField.text != self.equipmentService.frequency{
            editsMade = true
        }
    }
    
    @objc func handleFrequencyChange(){
        print("Set Frequency Input")
        self.frequencyTxtField.resignFirstResponder()
        self.equipmentService.frequency = self.frequencyTxtField.text
        
        
        
        
        if equipmentService.type == "1"{
            if(self.equipmentService.frequency != "0"){
                self.equipmentService.nextValue = "\(Int(self.equipmentService.frequency)!)"
                self.nextTxtField.text = layoutVars.determineUpcomingDate(_equipmentService: equipmentService)
                let date = dateFormatter.date(from: self.nextTxtField.text!)
                nextDatePicker.date = date!
                
                
                
                handleNextChange()
                
                
                
            }
        }else{
            
            if frequencyTxtField.text == ""{
                frequencyTxtField.text = "0"
                equipmentService.frequency = "0"
            }
            if currentTxtField.text == ""{
                currentTxtField.text = "0"
                equipmentService.currentValue = "0"
            }
            
            
            if(self.equipmentService.frequency != "0" && self.equipmentService.currentValue != "0"){
                self.nextTxtField.text = "\(Int(self.equipmentService.frequency)! + Int(self.equipmentService.currentValue)!)"
                self.equipmentService.nextValue = self.nextTxtField.text
            }
        }
        
        
        
        
        
        editsMade = true
    }
    
   
    
   
    
    @objc func cancelInstructionsInput(){
        print("Cancel Instructions Input")
        self.instructionsView.resignFirstResponder()
        if self.instructionsView.text != self.equipmentService.instruction{
            editsMade = true
        }
    }
    
    @objc func handleInstructionsChange(){
        print("Set Instructions Input")
        self.instructionsView.resignFirstResponder()
        self.equipmentService.instruction = self.instructionsView.text
        editsMade = true
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        print("tag = \(textField.tag)")
        
        
    }
    
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        print("textField.tag = \(textField.tag)")
        textField.text = textField.text?.capitalized
        if(textField.tag == 10){
            if(frequencyTxtField.text != ""){
                self.equipmentService.frequency = frequencyTxtField.text
            }
        }
        if(textField.tag == 11){
            if(currentTxtField.text != ""){
                self.equipmentService.currentValue = currentTxtField.text
            }
        }
        
        
        
        
        
        editsMade = true
        
       
        
        
    }
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textFieldDidBeginEditing")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y -= 250
            
            
        }, completion: { finished in
            // //print("Napkins opened!")
        })
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y += 250
                
                
            }, completion: { finished in
            })
        }
        editsMade = true
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        let count:Int = self.typeArray.count
       
        return count
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title:String = self.typeArray[row]
        return title
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        equipmentService.type = "\(row)"
        equipmentService.typeName = self.typeArray[row]
        typeTxtField.text = self.typeArray[row]
    }
    
    func editInputLabels(){
        print("editInputLabels")
        switch self.typePicker.selectedRow(inComponent: 0) {
        case 0:
            //One Time
            self.frequencyLbl.text = "Frequency:"
            self.frequencyTxtField.isEnabled = false
            self.frequencyLbl.alpha = 0.5
            self.frequencyTxtField.alpha = 0.5
            self.currentLbl.text = "Current:"
            self.currentTxtField.isEnabled = false
            self.currentLbl.alpha = 0.5
            self.currentTxtField.alpha = 0.5
            self.nextLbl.text = "Next:"
            self.nextTxtField.isEnabled = false
            self.nextLbl.alpha = 0.5
            self.nextTxtField.alpha = 0.5
            self.instructionsView.inputAccessoryView = self.instructionsToolBar
            break
        case 1:
            //Date Based
            print("date based")
            self.frequencyLbl.text = "Frequency(Days):"
            self.frequencyTxtField.isEnabled = true
            self.frequencyLbl.alpha = 1.0
            self.frequencyTxtField.alpha = 1.0
            print("date based 1")
            self.currentLbl.text = "Current:"
            self.currentTxtField.isEnabled = false
            self.currentLbl.alpha = 1.0
            self.currentTxtField.alpha = 1.0
            print("date based 2")
            self.nextLbl.text = "Next:"
            self.nextTxtField.isEnabled = true
            self.nextLbl.alpha = 1.0
            self.nextTxtField.alpha = 1.0
            self.instructionsView.inputAccessoryView = self.instructionsToolBar
            break
            
        case 2:
            //Mileage Based
            self.frequencyLbl.text = "Frequency(Miles/Km.):"
            self.frequencyTxtField.isEnabled = true
            self.frequencyLbl.alpha = 1.0
            self.frequencyTxtField.alpha = 1.0
            self.currentLbl.text = "Current(Miles/Km.):"
            self.currentTxtField.isEnabled = true
            self.currentLbl.alpha = 1.0
            self.currentTxtField.alpha = 1.0
            self.nextLbl.text = "Next(Miles/Km.):"
            self.nextTxtField.isEnabled = true
            self.nextLbl.alpha = 1.0
            self.nextTxtField.alpha = 1.0
            self.instructionsView.inputAccessoryView = self.instructionsToolBar
            break
        case 3:
            //Engine Hour Based
            self.frequencyLbl.text = "Frequency(Engine Hours):"
            self.frequencyTxtField.isEnabled = true
            self.frequencyLbl.alpha = 1.0
            self.frequencyTxtField.alpha = 1.0
            self.currentLbl.text = "Current(Engine Hours):"
            self.currentTxtField.isEnabled = true
            self.currentLbl.alpha = 1.0
            self.currentTxtField.alpha = 1.0
            self.nextLbl.text = "Next(Engine Hours):"
            self.nextTxtField.isEnabled = true
            self.nextLbl.alpha = 1.0
            self.nextTxtField.alpha = 1.0
            self.instructionsView.inputAccessoryView = self.instructionsToolBar
            break
        case 4:
            //Inspection
            self.frequencyLbl.text = "Frequency:"
            self.frequencyTxtField.isEnabled = false
            self.frequencyLbl.alpha = 0.5
            self.frequencyTxtField.alpha = 0.5
            self.currentLbl.text = "Current:"
            self.currentTxtField.isEnabled = false
            self.currentLbl.alpha = 0.5
            self.currentTxtField.alpha = 0.5
            self.nextLbl.text = "Next:"
            self.nextTxtField.isEnabled = false
            self.nextLbl.alpha = 0.5
            self.nextTxtField.alpha = 0.5
            self.instructionsLbl.alpha = 0.5
            self.instructionsView.alpha = 0.5
            self.instructionsView.isEditable = false
            self.instructionsView.inputAccessoryView = nil
            break
        default:
            //One Time
            self.frequencyLbl.text = "Frequency:"
            self.frequencyTxtField.isEnabled = false
            self.frequencyLbl.alpha = 0.5
            self.frequencyTxtField.alpha = 0.5
            self.currentLbl.text = "Current:"
            self.currentTxtField.isEnabled = false
            self.currentLbl.alpha = 0.5
            self.currentTxtField.alpha = 0.5
            self.nextLbl.text = "Next:"
            self.nextTxtField.isEnabled = false
            self.nextLbl.alpha = 0.5
            self.nextTxtField.alpha = 0.5
        }
    }
    
    
    func validateFields()->Bool{
        
        
        print("validate fields")
        
        
        if nameTxtField.text != nameTxtField.placeHolder{
            equipmentService.name = nameTxtField.text!
        }
        
        print("type text = \(typeTxtField.text!)")
        //print("type place holder = \(typeTxtField.placeHolder)")
        
        if typeTxtField.text != typeTxtField.placeHolder{
            print("set type")
            equipmentService.type = "\(typePicker.selectedRow(inComponent: 0))"
            equipmentService.typeName = typeTxtField.text!
        }
        if frequencyTxtField.isEnabled == true && frequencyTxtField.text != frequencyTxtField.placeHolder{
            equipmentService.frequency = frequencyTxtField.text!
        }
        
        if currentTxtField.isEnabled == true && currentTxtField.text != currentTxtField.placeHolder{
            print("setting current value to textField")
            equipmentService.currentValue = currentTxtField.text!
        }
        
        
        
       // print("frequency = \(equipmentService.frequency)")
       // print("current = \(equipmentService.currentValue)")
        //print("next = \(equipmentService.nextValue)")
        
        
        if equipmentService.currentValue == "" {
            equipmentService.currentValue = "0"
        }
        
        equipmentService.instruction = instructionsView.text!
        if(equipmentService.type != "1"){
            if(equipmentService.frequency != "0" && equipmentService.currentValue != "0"){
                if equipmentService.nextValue == "0"{
                    equipmentService.nextValue = "\(Int(equipmentService.frequency)! + Int(equipmentService.currentValue)!)"
                }
            }
        }
        
        
       // print("nextValue = \(equipmentService.nextValue)")
        
        //name check
        if(equipmentService.name == ""){
            print("give a name")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Give a Name")
            return false
        }
        
        //type check
        if(equipmentService.typeName == ""){
            print("select a type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Select a Type")
            return false
        }
        
        //frequency check
        if(equipmentService.type != "0" && equipmentService.type != "4" && equipmentService.frequency == "0"){
            print("give a frequency")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Give a Frequency")
            return false
        }
        
        //current check
        if(equipmentService.type != "0" && equipmentService.type != "4" && equipmentService.currentValue == "0" && equipmentService.type != "1"){
            print("give a current value")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Give a Current Value")
            return false
        }
        
        //next check
        if(equipmentService.type != "0" && equipmentService.type != "4" && equipmentService.nextValue == "0"){
            print("give a next value")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Give a Next Value")
            return false
        }
        
        //instructions check
        if(equipmentService.instruction == "" && equipmentService.type != "4"){
            print("give some instructions")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Give some Instructions")
            return false
        }
        
        return true
    }
    
    
    
    @objc func submit(){
        print("submit equipment")
        
        
        
            if(!validateFields()){
                print("didn't pass validation")
                return
            }
       
        
        //validate all fields
        
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        let parameters:[String:String]
        parameters = ["ID": self.equipmentService.ID, "addedBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), "name": self.equipmentService.name, "type": self.equipmentService.type,"frequency": self.equipmentService.frequency, "instructions": self.equipmentService.instruction, "equipmentID": self.equipmentService.equipmentID, "status": self.equipmentService.status, "nextValue": self.equipmentService.nextValue] as! [String : String]
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/equipmentService.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("equipment response = \(response)")
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
                    let newEquipmentServiceID = self.json["serviceID"].stringValue
                    //let creationDate = self.json["creationDate"].stringValue
                    
                    print("new service id = \(newEquipmentServiceID)")
                    //print("creationDate = \(creationDate)")
                    //self.equipmentService.creationDate = creationDate
                    
                    self.editsMade = false
                    
                    if(self.serviceListDelegate != nil){
                        self.serviceListDelegate.updateServiceList()
                    }
                    if(self.editDelegate != nil){
                        self.editDelegate.updateEquipmentService(_equipmentService: self.equipmentService)
                    }
                    
                   
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
                //self.submit()
                if self.editDelegate != nil{
                self.editDelegate.updateEquipmentService(_equipmentService: self.equipmentService)
                }
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            
            _ = navigationController?.popViewController(animated: true)
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



