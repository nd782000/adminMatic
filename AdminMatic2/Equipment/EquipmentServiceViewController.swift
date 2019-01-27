//
//  EquipmentServiceViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol EditEquipmentServiceDelegate{
    func updateEquipmentService(_equipmentService:EquipmentService)
}

 
class EquipmentServiceViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, EditEquipmentServiceDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var serviceListDelegate:ServiceListDelegate!
    
    var equipmentJSON: JSON!
    var equipmentService:EquipmentService!
    
    var editButton:UIBarButtonItem!
    var editsMade:Bool = false
    
    var nameLbl:GreyLabel!
    
    var statusIcon:UIImageView = UIImageView()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Not Started","In Progress","Done","Cancel"]
    
    var statusValue: String!
    var statusValueToUpdate: String!
    
    var typeLbl:GreyLabel!
    var dueLbl:GreyLabel!
    var frequencyLbl:GreyLabel!
    
    var creationOnByLbl:GreyLabel!
    
    var instructionsLbl:GreyLabel!
    var instructionsView:UITextView = UITextView()
    
    var currentLbl:GreyLabel!
    var currentTxtField:PaddedTextField!
    
    var nextLbl:GreyLabel!
    var nextTxtField:PaddedTextField!
    
    var nextDatePicker: DatePicker!

    var completionNotesLbl:GreyLabel!
    var completionNotesView:UITextView = UITextView()
    
    var statusLbl:GreyLabel!
    var statusIcon2:UIImageView = UIImageView()
    var statusTxtField2:PaddedTextField!
    var statusPicker2: Picker!
    
    var keyBoardShown:Bool = false
    
    let dateFormatter = DateFormatter()
    let dateFormatterDB = DateFormatter()
    
    
    
    init(_equipmentService:EquipmentService){
        super.init(nibName:nil,bundle:nil)
        //print("init _equipmentService.ID = \(_equipmentService.ID)")
        //print("init current = \(_equipmentService.currentValue)")
        self.equipmentService = _equipmentService
        
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
        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Service"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        layoutViews()
        
        
        DispatchQueue.main.async {
            self.instructionsView.contentOffset = CGPoint.zero
            self.instructionsView.scrollRangeToVisible(NSRange(location:0, length:0))
            
            self.completionNotesView.contentOffset = CGPoint.zero
            self.completionNotesView.scrollRangeToVisible(NSRange(location:0, length:0))
        }
        
        
        
        
    }
    
    
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        
        //print("self.equipmentService.frequency = \(self.equipmentService.frequency)")
        //print("self.equipmentService.currentValue = \(self.equipmentService.currentValue)")
        //print("self.equipmentService.nextValue = \(self.equipmentService.nextValue)")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EquipmentViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatterDB.dateFormat = "yyyy-MM-dd HH:mm:ss"
       
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = self.equipmentService.name!
        self.nameLbl.font = layoutVars.largeFont
        safeContainer.addSubview(self.nameLbl)
        
        //status
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        
        
        self.statusPicker = Picker()
        self.statusPicker.delegate = self
        self.statusPicker.selectRow(Int(self.equipmentService.status)!, inComponent: 0, animated: false)
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
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.handleStatusChange))
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        statusTxtField.inputAccessoryView = toolBar
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = "Type: \(self.equipmentService.typeName!)"
        self.typeLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.typeLbl)
        
        //due
        self.dueLbl = GreyLabel()
        self.dueLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.dueLbl)
        
        
        self.frequencyLbl = GreyLabel()
        self.frequencyLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.frequencyLbl)
        
        let creationDateFormatter:DateFormatter = DateFormatter()
        creationDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let creationDate = creationDateFormatter.date(from: self.equipmentService.creationDate!)
        //print("creation date = \(creationDate)")
        //created on/by
        self.creationOnByLbl = GreyLabel()
        self.creationOnByLbl.text = "By: \(self.equipmentService.createdBy!) on \(self.dateFormatter.string(from: creationDate!))"
        self.creationOnByLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.creationOnByLbl)
        
        
        //instructions
        self.instructionsLbl = GreyLabel()
        self.instructionsLbl.text = "Instructions:"
        self.instructionsLbl.textAlignment = .left
        self.instructionsLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.instructionsLbl)
        
        //self.instructionsView = UITextView()
        self.instructionsView.layer.borderWidth = 1
        self.instructionsView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.instructionsView.layer.cornerRadius = 4.0
        
        self.instructionsView.backgroundColor = UIColor.clear
        self.instructionsView.text = self.equipmentService.instruction
        self.instructionsView.font = layoutVars.smallFont
        self.instructionsView.isEditable = false
        self.instructionsView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.instructionsView)
        
        //current
        self.currentLbl = GreyLabel()
        self.currentLbl.textAlignment = .left
        self.currentLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(currentLbl)
        
        
        
        let currentToolBar = UIToolbar()
        currentToolBar.barStyle = UIBarStyle.default
        currentToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        currentToolBar.sizeToFit()
        let closeCurrentButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.cancelCurrentInput))
        let setCurrentButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.handleCurrentChange))
        
        currentToolBar.setItems([closeCurrentButton,spaceButton,setCurrentButton], animated: false)
        currentToolBar.isUserInteractionEnabled = true
        
        
        
        
        
        //next
        
    
        self.nextLbl = GreyLabel()
        self.nextLbl.text = "Next:"
        self.nextLbl.textAlignment = .left
        self.nextLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(nextLbl)
        
        
       
        
        let nextToolBar = UIToolbar()
        nextToolBar.barStyle = UIBarStyle.default
        nextToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        nextToolBar.sizeToFit()
        let closeNextButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.cancelNextInput))
        let setNextButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.handleNextChange))
        nextToolBar.setItems([closeNextButton,spaceButton,setNextButton], animated: false)
        nextToolBar.isUserInteractionEnabled = true
        
       
        
        //completion notes
        self.completionNotesLbl = GreyLabel()
        self.completionNotesLbl.text = "Completion Notes:"
        self.completionNotesLbl.textAlignment = .left
        self.completionNotesLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.completionNotesLbl)
        
        //self.completionNotesView = UITextView()
        self.completionNotesView.layer.borderWidth = 1
        self.completionNotesView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.completionNotesView.layer.cornerRadius = 4.0
        self.completionNotesView.returnKeyType = .done
        self.completionNotesView.text = self.equipmentService.notes
        self.completionNotesView.font = layoutVars.smallFont
        self.completionNotesView.isEditable = true
        self.completionNotesView.delegate = self
        self.completionNotesView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.completionNotesView)
        
        
        let completionNotesToolBar = UIToolbar()
        completionNotesToolBar.barStyle = UIBarStyle.default
        completionNotesToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        completionNotesToolBar.sizeToFit()
        let closeCompletionNotesButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.cancelCompletionNotesInput))
        let setCompletionNotesButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EquipmentServiceViewController.handleCompletionNotesChange))
        completionNotesToolBar.setItems([closeCompletionNotesButton,spaceButton,setCompletionNotesButton], animated: false)
        completionNotesToolBar.isUserInteractionEnabled = true
        self.completionNotesView.inputAccessoryView = completionNotesToolBar
        
        
        //status2
        self.statusLbl = GreyLabel()
        self.statusLbl.text = "Status:"
        safeContainer.addSubview(self.statusLbl)
        
        
        
        self.statusPicker2 = Picker()
        self.statusPicker2.delegate = self
        self.statusPicker2.selectRow(Int(self.equipmentService.status)!, inComponent: 0, animated: false)
        self.statusTxtField2 = PaddedTextField(placeholder: "")
        self.statusTxtField2.textAlignment = NSTextAlignment.left
        self.statusTxtField2.translatesAutoresizingMaskIntoConstraints = false
        self.statusTxtField2.tag = 2
        self.statusTxtField2.delegate = self
        self.statusTxtField2.tintColor = UIColor.clear
        self.statusTxtField2.backgroundColor = UIColor.white
        self.statusTxtField2.layer.borderWidth = 1
        self.statusTxtField2.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.statusTxtField2.layer.cornerRadius = 4.0
        self.statusTxtField2.inputView = statusPicker2
        self.statusTxtField2.leftMargin = 50
        safeContainer.addSubview(self.statusTxtField2)
        
        statusTxtField2.inputAccessoryView = toolBar
        
        statusIcon2.translatesAutoresizingMaskIntoConstraints = false
        statusIcon2.backgroundColor = UIColor.clear
        statusIcon2.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon2)
        
        setStatus(status: equipmentService.status)
        
        
        
        switch equipmentService.type {
        case "0":
            dueLbl.text = "Due: Now"
            dueLbl.textColor = UIColor.red
            
            self.frequencyLbl.text = "Frequency: N/A"
            
            self.currentLbl.text = "Current  Mi, Km, or Hrs:"
            
            if self.equipmentService.currentValue == "0"{
                self.currentTxtField = PaddedTextField(placeholder: "Current")
            }else{
                self.currentTxtField = PaddedTextField()
                self.currentTxtField.text = equipmentService.currentValue!
            }
            self.currentTxtField.keyboardType = UIKeyboardType.numberPad
            self.currentTxtField.delegate = self
            self.currentTxtField.tag = 10
            
            safeContainer.addSubview(self.currentTxtField)
            self.currentTxtField.inputAccessoryView = currentToolBar
            
            if self.equipmentService.nextValue == "0"{
                self.nextTxtField = PaddedTextField(placeholder: "Next")
            }else{
                self.nextTxtField = PaddedTextField()
                self.nextTxtField.text = equipmentService.nextValue!
            }
           
            self.nextTxtField.keyboardType = UIKeyboardType.numberPad
            self.nextTxtField.delegate = self
            self.nextTxtField.tag = 11
            safeContainer.addSubview(self.nextTxtField)
            
            nextLbl.isHidden = true
            nextTxtField.isHidden = true
            
            
            break
        case "1":
            let date = dateFormatter.date(from: layoutVars.determineUpcomingDate(_equipmentService: equipmentService))
            
            let date2 = dateFormatter.string(from: date!)
            
            print("date = \(date2)")
            dueLbl.text = "Due: \(date2)"
            if date! < Date()  {
                print("date1 is earlier than Now")
                
                dueLbl.textColor = UIColor.red
            }else{
                dueLbl.textColor = UIColor.black
            }
            
            self.frequencyLbl.text = "Frequency: \(self.equipmentService.frequency!) Days"
            
            self.currentLbl.text = "Current Date:"
            self.currentTxtField = PaddedTextField()
            safeContainer.addSubview(self.currentTxtField)
            
            self.currentTxtField.text = dateFormatter.string(from: Date())
            self.currentTxtField.isEnabled = false
            
            nextDatePicker = DatePicker()
            nextDatePicker.datePickerMode = UIDatePicker.Mode.date
            
            self.nextTxtField = PaddedTextField()
            safeContainer.addSubview(self.nextTxtField)
            
            self.nextTxtField.inputView = self.nextDatePicker
            self.nextTxtField.text = layoutVars.determineUpcomingDate(_equipmentService: equipmentService)
            
            nextDatePicker.date = date!
            nextDatePicker.minimumDate = Date()
            
            break
        case "2":
            dueLbl.text = "Due: \(equipmentService.nextValue!) Mi./Km."
            if self.equipmentService.serviceDue {
                dueLbl.textColor = UIColor.red
            }else{
                dueLbl.textColor = UIColor.black
            }
            
            self.frequencyLbl.text = "Frequency: \(self.equipmentService.frequency!) Miles/Km."
            
            self.currentLbl.text = "Current Mi./Km.:"
            
            if self.equipmentService.currentValue == "0"{
                self.currentTxtField = PaddedTextField(placeholder: "Current")
            }else{
                self.currentTxtField = PaddedTextField()
                self.currentTxtField.text = equipmentService.currentValue!
            }
            
            self.currentTxtField.keyboardType = UIKeyboardType.numberPad
            self.currentTxtField.delegate = self
            self.currentTxtField.tag = 10
            
            safeContainer.addSubview(self.currentTxtField)
            
            if self.equipmentService.nextValue == "0"{
                self.nextTxtField = PaddedTextField(placeholder: "Next")
            }else{
                self.nextTxtField = PaddedTextField()
                self.nextTxtField.text = equipmentService.nextValue!
            }
            self.nextTxtField.keyboardType = UIKeyboardType.numberPad
            self.nextTxtField.delegate = self
            self.nextTxtField.tag = 11
            
            safeContainer.addSubview(self.nextTxtField)
            
            break
        case "3":
            dueLbl.text = "Due: \(equipmentService.nextValue!) Hours"
            if self.equipmentService.serviceDue {
                dueLbl.textColor = UIColor.red
            }else{
                dueLbl.textColor = UIColor.black
            }
            
            self.frequencyLbl.text = "Frequency: \(self.equipmentService.frequency!) Engine Hours"
            
            self.currentLbl.text = "Current Hours.:"
            
            if self.equipmentService.currentValue == "0"{
                self.currentTxtField = PaddedTextField(placeholder: "Current")
            }else{
                self.currentTxtField = PaddedTextField()
                self.currentTxtField.text = equipmentService.currentValue!
            }
            
            self.currentTxtField.keyboardType = UIKeyboardType.numberPad
            self.currentTxtField.delegate = self
            self.currentTxtField.tag = 10
            safeContainer.addSubview(self.currentTxtField)
            
            if self.equipmentService.nextValue == "0"{
                self.nextTxtField = PaddedTextField(placeholder: "Next")
            }else{
                self.nextTxtField = PaddedTextField()
                self.nextTxtField.text = equipmentService.nextValue!
            }
            self.nextTxtField.keyboardType = UIKeyboardType.numberPad
            self.nextTxtField.delegate = self
            self.nextTxtField.tag = 11
            
            safeContainer.addSubview(self.nextTxtField)
            
            break
        default:
            dueLbl.text = "Due: Now"
            dueLbl.textColor = UIColor.red
            
            self.frequencyLbl.text = "Frequency: N/A"
            
            if self.equipmentService.currentValue == "0"{
                self.currentTxtField = PaddedTextField(placeholder: "Current")
            }else{
                self.currentTxtField = PaddedTextField()
                self.currentTxtField.text = equipmentService.currentValue!
            }
            
            self.currentTxtField.keyboardType = UIKeyboardType.numberPad
            self.currentTxtField.delegate = self
            self.currentTxtField.tag = 10
            
            safeContainer.addSubview(self.currentTxtField)
            
            if self.equipmentService.nextValue == "0"{
                self.nextTxtField = PaddedTextField(placeholder: "Next")
            }else{
                self.nextTxtField = PaddedTextField()
                self.nextTxtField.text = equipmentService.nextValue!
            }
            self.nextTxtField.keyboardType = UIKeyboardType.numberPad
            self.nextTxtField.delegate = self
            self.nextTxtField.tag = 11
            
            safeContainer.addSubview(self.nextTxtField)
        }
        
        
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            
            "name":self.nameLbl,
            "statusIcon":self.statusIcon,
            "statusTxt":self.statusTxtField,
            "typeLbl":self.typeLbl,
            "dueLbl":self.dueLbl,
            "frequencyLbl":self.frequencyLbl,
            "creationOnByLbl":self.creationOnByLbl,
            "instructionLbl":self.instructionsLbl,
            "instructionView":self.instructionsView,
            "currentLbl":self.currentLbl,
            "currentTxt":self.currentTxtField,
            "nextLbl":self.nextLbl,
            "nextTxt":self.nextTxtField,
            "completionNotesLbl":self.completionNotesLbl,
            "completionNotesView":self.completionNotesView,
            "statusLbl":self.statusLbl,
            "statusIcon2":self.statusIcon2,
            "statusTxt2":self.statusTxtField2
            
            ] as [String:Any]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-[statusIcon(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-[statusTxt(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[typeLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dueLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[frequencyLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[creationOnByLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[instructionLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[instructionView]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[currentLbl(halfWidth)]-[nextLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[currentTxt(halfWidth)]-[nextTxt]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[completionNotesLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[completionNotesView]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[statusIcon2(32)]", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusTxt2]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusTxt(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(40)][typeLbl(30)][dueLbl(30)][frequencyLbl(30)][creationOnByLbl(30)][instructionLbl(30)][instructionView(60)]-[currentLbl(30)][currentTxt(30)]-[completionNotesLbl(30)][completionNotesView]-[statusLbl(30)][statusIcon2(40)]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(40)][typeLbl(30)][dueLbl(30)][frequencyLbl(30)][creationOnByLbl(30)][instructionLbl(30)][instructionView(60)]-[nextLbl(30)][nextTxt(30)]-[completionNotesLbl(30)][completionNotesView]-[statusLbl(30)][statusTxt2(40)]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
    }
    
    @objc func displayEditView(){
        print("display Edit View")
        
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        //self.equipmentDelegate.disableSearch()
        let editEquipmentServiceViewController = NewEditEquipmentServiceViewController(_equipmentService: self.equipmentService)
        editEquipmentServiceViewController.editDelegate = self
        navigationController?.pushViewController(editEquipmentServiceViewController, animated: false )
 
        
    }
    
    @objc func cancelCurrentInput(){
        print("Cancel Current Input")
        self.currentTxtField.resignFirstResponder()
    }
    @objc func handleCurrentChange(){
        print("Set Current Input")
        self.currentTxtField.resignFirstResponder()
        //if self.equipmentService.type == "1"{
            //self.currentTxtField.text = dateFormatter.string(from: currentDatePicker.date)
        //}else{
        if self.currentTxtField.text == ""{
            self.equipmentService.currentValue = "0"
        }else{
            self.equipmentService.currentValue = self.currentTxtField.text
        }
        
        
            editsMade = true
        //}
    }
    
    @objc func cancelNextInput(){
        print("Cancel Next Input")
        self.nextTxtField.resignFirstResponder()
    }
    @objc func handleNextChange(){
        print("Set Next Input")
        self.nextTxtField.resignFirstResponder()
        //self.equipmentService.nextValue = self.nextTxtField.text
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
            
            
            //submit
            self.statusValueToUpdate = equipmentService.status
            handleStatusChange()
            
            
        }else{
            self.equipmentService.nextValue = self.nextTxtField.text
            
        }
        editsMade = true
    }
    
    
    @objc func cancelCompletionNotesInput(){
        print("Cancel Completion Notes Input")
        self.completionNotesView.resignFirstResponder()
    }
    @objc func handleCompletionNotesChange(){
        print("Set Completion Notes Input")
        self.completionNotesView.resignFirstResponder()
        self.equipmentService.notes = self.completionNotesView.text
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
    
    
    /*
     func textFieldDidChange(_ textField: UITextField) {
     print("textFieldDidChange")
     
     
     
     }
     */
    
    
    
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        print("textField.tag = \(textField.tag)")
        
        //print("frequency = \(equipmentService.frequency)")
        //print("currentValue = \(equipmentService.currentValue)")
        
        
        if(equipmentService.type != "1"){
            if(textField.tag == 10){
                if(currentTxtField.text != ""){
                    self.equipmentService.currentValue = currentTxtField.text
                }
            }
            
            
            if(self.equipmentService.frequency != "0" && self.equipmentService.currentValue != "0"){
                self.nextTxtField.text = "\(Int(self.equipmentService.frequency)! + Int(self.equipmentService.currentValue)!)"
                self.equipmentService.nextValue = self.nextTxtField.text
            }
        }
        
        
        
        editsMade = true
        
        
    }
    
    
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange")
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
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
        self.statusTxtField2.resignFirstResponder()
    }
    
    
    
    
    
    
    func validateFields()->Bool{
        
        
        print("validate fields")
        
        
        if currentTxtField.text != currentTxtField.placeHolder{
            equipmentService.currentValue = currentTxtField.text!
            
            if self.statusValueToUpdate == "2"{
                equipmentService.completionMileage = equipmentService.currentValue
            }
        }
        
        
        if nextTxtField.text != nextTxtField.placeHolder && nextTxtField.text != "" && equipmentService.type != "1"{
            equipmentService.nextValue = nextTxtField.text!
        }
        
       
        equipmentService.notes = completionNotesView.text!
        
        
        
        if(equipmentService.type == "2" || equipmentService.type == "3"){
            if(equipmentService.currentValue == "0"){
                print("give a current Value")
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Service", _message: "Give a Current Value")
                return false
            }
        }
        
       
        
        return true
    }
    
    
    
    
    
    
    
    
    
    
    
    @objc func handleStatusChange(){
        
        //print("statusValueToUpdate = \(self.statusValueToUpdate)")
        
        self.statusTxtField.resignFirstResponder()
        self.statusTxtField2.resignFirstResponder()
        
        if self.statusValueToUpdate != nil{
            
            
            
            if(self.statusValueToUpdate == "1" || self.statusValueToUpdate == "2"){
                if(!self.validateFields()){
                    return
                }
            }
           
            indicator = SDevIndicator.generate(self.view)!
            
            
            var parameters:[String:String]
            parameters = [
                "ID":self.equipmentService.ID,
                "completedBy":(self.appDelegate.loggedInEmployee?.ID)!,
                "completeValue":self.equipmentService.completionMileage,
                "completionNotes":self.equipmentService.notes,
                "nextValue":self.equipmentService.nextValue,
                "status":self.statusValueToUpdate
            ]
            
            print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/equipmentServiceComplete.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                self.statusValue = self.statusValueToUpdate
                self.setStatus(status: self.statusValue)
                
                
               
                self.serviceListDelegate.updateServiceList()
                
                self.editsMade = false
                
                self.indicator.dismissIndicator()
                
                //if status is DONE alert user that a new service is being made, (not for One Time services)
                if self.statusValueToUpdate == "2"{
                    switch (self.equipmentService.type) {
                    case "0":
                        print("no alert necessary")
                        break
                    case "1":
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "New Service Added", _message: "A new \(self.equipmentService.typeName!) service has been added to be done on \(self.layoutVars.determineUpcomingDate(_equipmentService: self.equipmentService)).")
                        break
                    case "2":
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "New Service Added", _message: "A new \(self.equipmentService.typeName!) service has been added to be done at \(self.equipmentService.nextValue!) Miles/Km..")
                        break
                    case "3":
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "New Service Added", _message: "A new \(self.equipmentService.typeName!) service has been added to be done at \(self.equipmentService.nextValue!) Engine Hours.")
                        break
                    default:
                        print("no alert necessary")
                        break
                    }
                }
                    
                
                self.layoutVars.playSaveSound()
                
                
                }.responseString() {
                    response in
                    print(response)  // original URL request
            }
        }
    }
    
    func setStatus(status: String) {
        
        print("Set Status \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            statusIcon2.image = statusImg
            statusTxtField2.text = "Not Started"
            break;
        case "1":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            statusIcon2.image = statusImg
            statusTxtField2.text = "In Progress"
            break;
        case "2":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            statusIcon2.image = statusImg
            statusTxtField2.text = "Done"
            break;
        case "3":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            statusIcon2.image = statusImg
            statusTxtField2.text = "Cancel"
            break;
       
            
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            statusIcon2.image = statusImg
            statusTxtField2.text = "Not Started"
            break;
        }
        
        
    }
    
    /*
    func determineUpcomingDate()->String{
        print("determineUpcomingDate")
        print("creationDate = \(equipmentService.creationDate)")
        print("nextValue = \(equipmentService.nextValue)")
        
        let date = dateFormatter.date(from: equipmentService.creationDate)
        
        let daysToAdd = Int(equipmentService.nextValue)!
        let futureDate = Calendar.current.date(byAdding:
            .day, // updated this params to add hours
            value: daysToAdd,
            to: date!)
        
        print(dateFormatter.string(from: futureDate!))
        return dateFormatter.string(from: futureDate!)
    }
 */
    /*
    func determineUpcomingDate()->String{
        print("determineUpcomingDate")
        
        
        //var dateString = "2014-07-15" // change to your date format
        
        let dbDateFormatter = DateFormatter()
        dbDateFormatter.dateFormat = "MM/dd/yy"
        
        let dbDate = dbDateFormatter.date(from: equipmentService.creationDate)
        print("equipmentService.nextValue = \(equipmentService.nextValue)")
        print("equipmentService.creationDate = \(equipmentService.creationDate)")
        print("dbDate = \(dbDate)")
        
        
        
        let daysToAdd = Int(equipmentService.nextValue)!
        let futureDate = Calendar.current.date(byAdding:
            .day, // updated this params to add hours
            value: daysToAdd,
            to: dbDate!)
        
        print(dateFormatter.string(from: futureDate!))
        return dateFormatter.string(from: futureDate!)
        
    }
 */
    
    
    
   
    func updateEquipmentService(_equipmentService:EquipmentService){
        print("updateEquipmentService")
        self.equipmentService = _equipmentService
        self.layoutViews()
        self.serviceListDelegate.updateServiceList()
    }
    
    
    
    
    @objc func goBack(){
        
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?  Change Status to save any changes.", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //self.submit()
                
                
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
        //print("Test")
    }
    
    
}


