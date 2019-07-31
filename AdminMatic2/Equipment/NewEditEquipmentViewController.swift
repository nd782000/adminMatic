//
//  NewEditEquipmentViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/19/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import Nuke


protocol UpdateEquipmentImageDelegate{
    func updateImage(_image:Image2)
}

 

class NewEditEquipmentViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UpdateEquipmentImageDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    
    var equipment:Equipment!
    var submitButton:UIBarButtonItem!
    var delegate:EquipmentListDelegate!
    var editDelegate:EditEquipmentDelegate!
    var editsMade:Bool = false
    
    //image
    var equipmentImage:UIImageView!
    var activityView:UIActivityIndicatorView!
    var tapBtn:Button!
    var noPic:String!
    
    //name
    var nameLbl:GreyLabel!
    var nameTxtField:PaddedTextField!
    
    //crew
    var crewLbl:GreyLabel!
    var crewTxtField:PaddedTextField!
    var crewPicker: Picker! 
    var crewNameArray:[String] = []
    var crewIDArray:[String] = []
    var crewSelectedID:String = ""
    
    //make
    var makeLbl:GreyLabel!
    var makeTxtField:PaddedTextField!
    
    //model
    var modelLbl:GreyLabel!
    var modelTxtField:PaddedTextField!
    
    //type
    var typeLbl:GreyLabel!
    var typeTxtField:PaddedTextField!
    var typePicker: Picker!
    var typeNameArray:[String] = []
    var typeIDArray:[String] = []
    var typeSelectedID:String = ""
    
    //serial
    var serialLbl:GreyLabel!
    var serialTxtField:PaddedTextField!
    
    //fuel
    var fuelLbl:GreyLabel!
    var fuelTxtField:PaddedTextField!
    var fuelPicker: Picker!
    var fuelNameArray:[String] = []
    var fuelIDArray:[String] = []
    var fuelSelectedID:String = ""
    
    //engine
    var engineLbl:GreyLabel!
    var engineTxtField:PaddedTextField!
    var enginePicker: Picker!
    var engineNameArray:[String] = []
    var engineIDArray:[String] = []
    var engineSelectedID:String = ""
    
    //vendor search
    var vendorLbl:GreyLabel!
    
    var vendorTxtField:PaddedTextField!
    
    var vendorResultsTableView:TableView = TableView()
    var vendorSearchResults:[String] = []
    var vendorIDArray = [String]()
    var vendorNameArray = [String]()
    var vendorSelectedID:String = ""
    
    //purchased date
    var purchasedLbl:GreyLabel!
    var purchasedTxtField:PaddedTextField!
    var purchasedPicker: DatePicker!
    var purchaseDate:String = ""
    
    //description textview
    var descriptionLbl:GreyLabel!
    var descriptionView:UITextView = UITextView()
    
    
    
    
    var submitButtonBottom:Button = Button(titleText: "Submit")
    
    
    let dateFormatter = DateFormatter()
    let dateFormatterDB = DateFormatter()
    
    
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    //var image:Image!
    
    var imageAddedAfterSubmit:Bool = false
    

    
    //init for new
    init(){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        //for an empty lead to start things off
    }
    
   
    //init for edit
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        self.equipment = _equipment
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
        backButton.addTarget(self, action: #selector(LeadViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
        showLoadingScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.descriptionView.contentOffset = CGPoint.zero
            self.descriptionView.scrollRangeToVisible(NSRange(location:0, length:0))
        }
    }
    
    
    func showLoadingScreen(){
        title = "Loading..."
        getPickerInfo()
    }
    
    func getPickerInfo(){
        print("get picker info")
        indicator = SDevIndicator.generate(self.view)!
        
        
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        
        var parameters:[String:String]
        parameters = [
            "cb":"\(timeStamp)"
        ]
        
        print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/equipmentFields.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            
            
            
            
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let types = json["types"] as? [[String: Any]],
                    let fuelTypes = json["fuelTypes"] as? [[String: Any]],
                    let engineTypes = json["engineTypes"] as? [[String: Any]],
                    let crews = json["crews"] as? [[String: Any]],
                    let vendors = json["vendors"] as? [[String: Any]]{
                    for type in types {
                        if let typeID = type["ID"] as? String {
                            self.self.typeIDArray.append(typeID)
                        }
                        if let name = type["name"] as? String {
                            self.typeNameArray.append(name)
                        }
                    }
                    
                    for fuelType in fuelTypes {
                        if let typeID = fuelType["ID"] as? String {
                            self.fuelIDArray.append(typeID)
                        }
                        if let name = fuelType["name"] as? String {
                            self.fuelNameArray.append(name)
                        }
                    }
                    
                    for engineType in engineTypes {
                        if let typeID = engineType["ID"] as? String {
                            self.engineIDArray.append(typeID)
                        }
                        if let name = engineType["name"] as? String {
                            self.engineNameArray.append(name)
                        }
                    }
                    
                    for crew in crews {
                        if let crewID = crew["ID"] as? String {
                            self.crewIDArray.append(crewID)
                        }
                        if let name = crew["name"] as? String {
                            self.crewNameArray.append(name)
                        }
                    }
                    
                    for vendor in vendors {
                        if let vendorID = vendor["ID"] as? String {
                            self.vendorIDArray.append(vendorID)
                        }
                        if let name = vendor["name"] as? String {
                            self.vendorNameArray.append(name)
                        }
                    }
                    
                    self.noPic = json["noPic"] as? String
                    self.layoutViews()
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            
            
           
            
        }
        
    }
    
    
    func layoutViews(){
        
        self.indicator.dismissIndicator()
        
        //print("layout views")
        if(self.equipment == nil){
            title =  "New Equipment"
            submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditEquipmentViewController.submit))
            self.equipment = Equipment(_ID: "0", _name: "", _make: "", _model: "", _serial: "", _crew: "", _crewName: "", _status: "0", _type: "", _typeName: "", _fuelType: "", _fuelTypeName: "", _engineType: "", _engineTypeName: "", _mileage: "", _dealer: "", _dealerName: "", _purchaseDate: "", _description: "")
            //let image:Image = Image(_ID: "0", _noPicPath: noPic)
            let image = Image2(_id: "0", _fileName: "", _name: "", _width: "", _height: "", _description: "", _dateAdded: "", _createdBy: "", _type: "")
            image.setDefaultPath()
            
            self.equipment.image = image
            
            
        }else{
           
            title =  "Edit Equipment"
            submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditEquipmentViewController.submit))
        }
        navigationItem.rightBarButtonItem = submitButton
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //image
        self.equipmentImage = UIImageView()
        
        
            activityView = UIActivityIndicatorView(style: .whiteLarge)
            activityView.center = CGPoint(x: self.equipmentImage.frame.size.width / 2, y: self.equipmentImage.frame.size.height / 2)
            equipmentImage.addSubview(activityView)
            //activityView.startAnimating()
            
            //let imgURL:URL = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.equipment.pic!)!
       
        
        Alamofire.request(equipment.image.thumbPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
               // self.imageFullViewController = ImageFullViewController(_image: self.equipment.image)
                // cell.imageView.image = image
                
                //self.image = equipment.image
                self.equipmentImage.image = image
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
        self.tapBtn.addTarget(self, action: #selector(NewEditEquipmentViewController.editImage), for: UIControl.Event.touchUpInside)
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControl.State.normal)
        safeContainer.addSubview(self.tapBtn)
        
        
        
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = "Name:"
        self.nameLbl.textAlignment = .left
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(nameLbl)
        if self.equipment.name == ""{
            self.nameTxtField = PaddedTextField(placeholder: "Name")
        }else{
            self.nameTxtField = PaddedTextField()
            self.nameTxtField.text = equipment.name!
        }
        
        self.nameTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTxtField.delegate = self
        self.nameTxtField.tag = 1
        self.nameTxtField.returnKeyType = .done
        self.nameTxtField.autocorrectionType = .no
        safeContainer.addSubview(self.nameTxtField)
        
        
        //crew
        
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew:"
        self.crewLbl.textAlignment = .left
        self.crewLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(crewLbl)
        
        self.crewPicker = Picker()
        self.crewPicker.delegate = self
        self.crewPicker.dataSource = self
        self.crewTxtField = PaddedTextField(placeholder: "Crew")
        self.crewTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.crewTxtField.delegate = self
        self.crewTxtField.tag = 2
        self.crewTxtField.inputView = crewPicker
        self.crewTxtField.returnKeyType = .done
        safeContainer.addSubview(self.crewTxtField)
        
        
        let crewToolBar = UIToolbar()
        crewToolBar.barStyle = UIBarStyle.default
        crewToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        crewToolBar.sizeToFit()
        let closeCrewButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelCrewInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setCrewButton = BarButtonItem(title: "Set Crew", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.handleCrewChange))
        crewToolBar.setItems([closeCrewButton, spaceButton, setCrewButton], animated: false)
        crewToolBar.isUserInteractionEnabled = true
        crewTxtField.inputAccessoryView = crewToolBar
        
        
       
        
        crewTxtField.text = equipment.crewName
        
        
        //make
        self.makeLbl = GreyLabel()
        self.makeLbl.text = "Make:"
        self.makeLbl.textAlignment = .left
        self.makeLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(makeLbl)
        if self.equipment.make == ""{
            self.makeTxtField = PaddedTextField(placeholder: "Make")
        }else{
            self.makeTxtField = PaddedTextField()
            self.makeTxtField.text = equipment.make!
        }
        self.makeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.makeTxtField.delegate = self
        self.makeTxtField.tag = 3
        self.makeTxtField.returnKeyType = .done
        self.makeTxtField.autocorrectionType = .no
        safeContainer.addSubview(self.makeTxtField)
        
        
        //model
        self.modelLbl = GreyLabel()
        self.modelLbl.text = "Model:"
        self.modelLbl.textAlignment = .left
        self.modelLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(modelLbl)
        if self.equipment.model == ""{
            self.modelTxtField = PaddedTextField(placeholder: "Model")
        }else{
            self.modelTxtField = PaddedTextField()
            self.modelTxtField.text = equipment.model!
        }
        self.modelTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.modelTxtField.delegate = self
        self.modelTxtField.tag = 4
        self.modelTxtField.returnKeyType = .done
        self.modelTxtField.autocorrectionType = .no
        safeContainer.addSubview(self.modelTxtField)
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = "Type:"
        self.typeLbl.textAlignment = .left
        self.typeLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(typeLbl)
        
        self.typePicker = Picker()
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        self.typePicker.tag = 5
        self.typeTxtField = PaddedTextField(placeholder: "Type")
        self.typeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.typeTxtField.delegate = self
        self.typeTxtField.inputView = typePicker
        self.typeTxtField.returnKeyType = .done
        safeContainer.addSubview(self.typeTxtField)
        
        
        let typeToolBar = UIToolbar()
        typeToolBar.barStyle = UIBarStyle.default
        typeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        typeToolBar.sizeToFit()
        let closeTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelTypeInput))
        let setTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.handleTypeChange))
        typeToolBar.setItems([closeTypeButton, spaceButton, setTypeButton], animated: false)
        typeToolBar.isUserInteractionEnabled = true
        typeTxtField.inputAccessoryView = typeToolBar
        
        
        
        
        typeTxtField.text = equipment.typeName
        
        
        
        //serial
        self.serialLbl = GreyLabel()
        self.serialLbl.text = "Serial #:"
        self.serialLbl.textAlignment = .left
        self.serialLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(serialLbl)
        if self.equipment.serial == ""{
            self.serialTxtField = PaddedTextField(placeholder: "Serial #")
        }else{
            self.serialTxtField = PaddedTextField()
            self.serialTxtField.text = equipment.serial!
        }
        self.serialTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.serialTxtField.delegate = self
        self.serialTxtField.tag = 6
        self.serialTxtField.returnKeyType = .done
        self.serialTxtField.autocorrectionType = .no
        safeContainer.addSubview(self.serialTxtField)
        
        //fuel
        self.fuelLbl = GreyLabel()
        self.fuelLbl.text = "Fuel:"
        self.fuelLbl.textAlignment = .left
        self.fuelLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(fuelLbl)
        
        self.fuelPicker = Picker()
        self.fuelPicker.delegate = self
        self.fuelPicker.dataSource = self
        self.fuelPicker.tag = 7
        
        self.fuelTxtField = PaddedTextField(placeholder: "Fuel")
        self.fuelTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.fuelTxtField.delegate = self
        self.fuelTxtField.tag = 7
        
        self.fuelTxtField.returnKeyType = .done
        self.fuelTxtField.inputView = fuelPicker
        safeContainer.addSubview(self.fuelTxtField)
        
        
        let fuelToolBar = UIToolbar()
        fuelToolBar.barStyle = UIBarStyle.default
        fuelToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        fuelToolBar.sizeToFit()
        let closeFuelButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelFuelInput))
        let setFuelButton = BarButtonItem(title: "Set Fuel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.handleFuelChange))
        fuelToolBar.setItems([closeFuelButton, spaceButton, setFuelButton], animated: false)
        fuelToolBar.isUserInteractionEnabled = true
        fuelTxtField.inputAccessoryView = fuelToolBar
        
       
        
        
        fuelTxtField.text = equipment.fuelTypeName
        
        
        
        //engine
        
        self.engineLbl = GreyLabel()
        self.engineLbl.text = "Engine:"
        self.engineLbl.textAlignment = .left
        self.engineLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(engineLbl)
        
        self.enginePicker = Picker()
        self.enginePicker.delegate = self
        self.enginePicker.dataSource = self
        self.enginePicker.tag = 8
        
        self.engineTxtField = PaddedTextField(placeholder: "Engine")
        self.engineTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.engineTxtField.delegate = self
        self.engineTxtField.tag = 8
        
        self.engineTxtField.inputView = enginePicker
        self.engineTxtField.returnKeyType = .done
        safeContainer.addSubview(self.engineTxtField)
        
        
        let engineToolBar = UIToolbar()
        engineToolBar.barStyle = UIBarStyle.default
        engineToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        engineToolBar.sizeToFit()
        let closeEngineButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelEngineInput))
        let setEngineButton = BarButtonItem(title: "Set Engine", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.handleEngineChange))
        engineToolBar.setItems([closeEngineButton, spaceButton, setEngineButton], animated: false)
        engineToolBar.isUserInteractionEnabled = true
        engineTxtField.inputAccessoryView = engineToolBar
        
        
        
        engineTxtField.text = equipment.engineTypeName
        
        
        //dealer
        self.vendorLbl = GreyLabel()
        self.vendorLbl.text = "Dealer:"
        self.vendorLbl.textAlignment = .left
        self.vendorLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(vendorLbl)
        
        
      
        self.vendorTxtField = PaddedTextField(placeholder: "Dealer")
        self.vendorTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.vendorTxtField.delegate = self
        self.vendorTxtField.tag = 9
        //self.engineTxtField.inputView = enginePicker
        self.vendorTxtField.returnKeyType = .search
        //self.scheduleengineTxtField.layer.borderWidth = 0
        safeContainer.addSubview(self.vendorTxtField)
        self.vendorTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        let vendorToolBar = UIToolbar()
        vendorToolBar.barStyle = UIBarStyle.default
        vendorToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        vendorToolBar.sizeToFit()
        let closeVendorButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelVendorInput))
        
        vendorToolBar.setItems([closeVendorButton], animated: false)
        vendorToolBar.isUserInteractionEnabled = true
        vendorTxtField.inputAccessoryView = vendorToolBar
        
        
        if(self.vendorIDArray.count == 0){
            vendorTxtField.isUserInteractionEnabled = false
        }
        if(equipment.dealerName != ""){
            vendorTxtField.text = equipment.dealerName
        }
        
        
        
        //purchased
        
        self.purchasedLbl = GreyLabel()
        self.purchasedLbl.text = "Purchase Date:"
        self.purchasedLbl.textAlignment = .left
        self.purchasedLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(purchasedLbl)
        
        
        purchasedPicker = DatePicker()
        purchasedPicker.datePickerMode = UIDatePicker.Mode.date
        
        
        self.purchasedTxtField = PaddedTextField(placeholder: "Purchase Date")
        self.purchasedTxtField.returnKeyType = UIReturnKeyType.next
        self.purchasedTxtField.delegate = self
        self.purchasedTxtField.tag = 10
        self.purchasedTxtField.inputView = self.purchasedPicker
        safeContainer.addSubview(self.purchasedTxtField)
        
        let purchasedToolBar = UIToolbar()
        purchasedToolBar.barStyle = UIBarStyle.default
        purchasedToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        purchasedToolBar.sizeToFit()
        let closePurchasedButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelPurchasedInput))
        let setPurchasedButton = BarButtonItem(title: "Set Purchased", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.handlePurchasedPicker))
        purchasedToolBar.setItems([closePurchasedButton, spaceButton, setPurchasedButton], animated: false)
        purchasedToolBar.isUserInteractionEnabled = true
        purchasedTxtField.inputAccessoryView = purchasedToolBar
        
        
        //print("purchased = \(equipment.purchaseDate)")
        if(equipment.purchaseDate != "" && equipment.purchaseDate != "null"){
            self.purchasedTxtField.text = dateFormatter.string(from: dateFormatterDB.date(from: equipment.purchaseDate)!)
            self.purchasedPicker.date = dateFormatterDB.date(from: equipment.purchaseDate)!
        }
        
        
        //description
        self.descriptionLbl = GreyLabel()
        self.descriptionLbl.text = "Description:"
        self.descriptionLbl.textAlignment = .left
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.descriptionLbl)
        
        //self.descriptionView = UITextView()
        //self.descriptionView.returnKeyType = .done
        self.descriptionView.text = self.equipment.description
        self.descriptionView.font = layoutVars.smallFont
        self.descriptionView.isEditable = true
        self.descriptionView.delegate = self
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.descriptionView)
        
        let descriptionToolBar = UIToolbar()
        descriptionToolBar.barStyle = UIBarStyle.default
        descriptionToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        descriptionToolBar.sizeToFit()
        let closeDescriptionButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelDescriptionInput))
        let setDescriptionButton = BarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelDescriptionInput))
        
        descriptionToolBar.setItems([closeDescriptionButton,spaceButton,setDescriptionButton], animated: false)
        descriptionToolBar.isUserInteractionEnabled = true
        self.descriptionView.inputAccessoryView = descriptionToolBar
        
        
        
        self.submitButtonBottom.addTarget(self, action: #selector(NewEditEquipmentViewController.submit), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.submitButtonBottom)
        
        
        self.vendorResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.vendorResultsTableView.delegate  =  self
        self.vendorResultsTableView.dataSource = self
        self.vendorResultsTableView.register(VendorTableViewCell.self, forCellReuseIdentifier: "vendorCell")
        self.vendorResultsTableView.alpha = 0.0
        safeContainer.addSubview(vendorResultsTableView)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "image":self.equipmentImage,
            "tapBtn":self.tapBtn,
            "nameLbl":self.nameLbl,
            "nameTxt":self.nameTxtField,
            "crewLbl":self.crewLbl,
            "crewTxt":self.crewTxtField,
            "makeLbl":self.makeLbl,
            "makeTxt":self.makeTxtField,
            "modelLbl":self.modelLbl,
            "modelTxt":self.modelTxtField,
            "typeLbl":self.typeLbl,
            "typeTxt":typeTxtField,
            "serialLbl":self.serialLbl,
            "serialTxt":self.serialTxtField,
            "fuelLbl":self.fuelLbl,
            "fuelTxt":self.fuelTxtField,
            "engineLbl":self.engineLbl,
            "engineTxt":self.engineTxtField,
            "vendorLbl":self.vendorLbl,
            "vendorTxt":self.vendorTxtField,
            "vendorTable":self.vendorResultsTableView,
            "purchasedLbl":self.purchasedLbl,
            "purchasedTxt":self.purchasedTxtField,
            "descriptionLbl":self.descriptionLbl,
            "descriptionView":self.descriptionView,
            "submitBtn":self.submitButtonBottom
            ] as [String:AnyObject]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[typeLbl]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tapBtn(120)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[typeTxt]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[crewLbl]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[crewTxt]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[makeLbl(halfWidth)]-5-[modelLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[makeTxt(halfWidth)]-5-[modelTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameLbl(halfWidth)]-5-[serialLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameTxt(halfWidth)]-5-[serialTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fuelLbl(halfWidth)]-5-[engineLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fuelTxt(halfWidth)]-5-[engineTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[vendorLbl(halfWidth)]-5-[purchasedLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[vendorTxt(halfWidth)]-5-[purchasedTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descriptionLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descriptionView]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[vendorTable]-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        
        

        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[typeLbl(30)][typeTxt(30)][crewLbl(30)][crewTxt(30)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(120)][modelLbl(30)][modelTxt(30)][serialLbl(30)][serialTxt(30)][engineLbl(30)][engineTxt(30)][purchasedLbl(30)][purchasedTxt(30)][descriptionLbl(30)][descriptionView(75)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tapBtn(120)][makeLbl(30)][makeTxt(30)][nameLbl(30)][nameTxt(30)][fuelLbl(30)][fuelTxt(30)][vendorLbl(30)][vendorTxt(30)][vendorTable]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submitBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
    }
    
    @objc func editImage(){
        print("Edit Image")
        
        if equipment.ID == "0"{
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Save Equipment First", _message: "You must save the new equipment before adding an image.")
        }else{
            
            //New Image
            if equipment.image.ID == "0"{
                print("no pic")
                imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Equipment", _equipmentID: equipment.ID)
                imageUploadPrepViewController.layoutViews()
                imageUploadPrepViewController.equipmentImageDelegate = self
                self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
                imageUploadPrepViewController.addImages()
            }else{
            //Change Image
                print("already has a pic")
                let actionSheet = UIAlertController(title: "Replace existing equipment image? ", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                actionSheet.view.backgroundColor = UIColor.white
                actionSheet.view.layer.cornerRadius = 5;
                
                actionSheet.addAction(UIAlertAction(title: "Change Image", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                    self.imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Equipment", _equipmentID: self.equipment.ID)
                    self.imageUploadPrepViewController.layoutViews()
                    self.imageUploadPrepViewController.equipmentImageDelegate = self
                    self.navigationController?.pushViewController(self.imageUploadPrepViewController, animated: false )
                    self.imageUploadPrepViewController.changeImage()
                    
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
                }))
                
                
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                    
                    break
                // It's an iPhone
                case .pad:
                    let nav = UINavigationController(rootViewController: actionSheet)
                    nav.modalPresentationStyle = UIModalPresentationStyle.popover
                    let popover = nav.popoverPresentationController! 
                    actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                    
                    self.layoutVars.getTopController().present(nav, animated: true, completion: nil)
                    break
                // It's an iPad
                case .unspecified:
                    break
                default:
                    self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                    break
                    
                    // Uh, oh! What could it be?
                }
            
            }
            
        }
    }
    
    
    @objc func cancelCrewInput(){
        print("Cancel Crew Input")
        self.crewTxtField.resignFirstResponder()
    }
    
    @objc func handleCrewChange(){
         self.crewTxtField.resignFirstResponder()
        
        equipment.crew = crewIDArray[self.crewPicker.selectedRow(inComponent: 0)]
        equipment.crewName = crewNameArray[self.crewPicker.selectedRow(inComponent: 0)]
        
        self.crewTxtField.text = equipment.crewName
        
        print("crew = \(String(describing: equipment.crew))")
        print("crewName = \(String(describing: equipment.crewName))")
        
        editsMade = true
    }
    
    
    
    @objc func cancelTypeInput(){
        print("Cancel Type Input")
        self.typeTxtField.resignFirstResponder()
    }
    
    @objc func handleTypeChange(){
        print("handleTypeChange")
        self.typeTxtField.resignFirstResponder()
        
        equipment.type = typeIDArray[self.typePicker.selectedRow(inComponent: 0)]
        equipment.typeName = typeNameArray[self.typePicker.selectedRow(inComponent: 0)]
        
        self.typeTxtField.text = equipment.typeName
       // print("type = \(equipment.type)")
       // print("typeName = \(equipment.typeName)")
        editsMade = true
    }
    
    @objc func cancelFuelInput(){
        print("Cancel Fuel Input")
        self.fuelTxtField.resignFirstResponder()
    }
    
    @objc func handleFuelChange(){
        self.fuelTxtField.resignFirstResponder()
        
        equipment.fuelType = fuelIDArray[self.fuelPicker.selectedRow(inComponent: 0)]
        equipment.fuelTypeName = fuelNameArray[self.fuelPicker.selectedRow(inComponent: 0)]
        
        
        self.fuelTxtField.text = equipment.fuelTypeName
        
        //print("fuel = \(equipment.fuelType)")
        //print("fuelName = \(equipment.fuelTypeName)")
        
        
        editsMade = true
    }
    
    @objc func cancelEngineInput(){
        print("Cancel Engine Input")
        self.engineTxtField.resignFirstResponder()
    }
    
    @objc func handleEngineChange(){
        self.engineTxtField.resignFirstResponder()
        
        equipment.engineType = engineIDArray[self.enginePicker.selectedRow(inComponent: 0)]
        equipment.engineTypeName = engineNameArray[self.enginePicker.selectedRow(inComponent: 0)]
        
        
        self.engineTxtField.text = equipment.engineTypeName
        
        //print("engine = \(equipment.engineType)")
        //print("engineName = \(equipment.engineTypeName)")
        
        
        editsMade = true
    }
    
    @objc func cancelPurchasedInput(){
        print("Cancel Purchased Input")
        self.purchasedTxtField.resignFirstResponder()
    }
    
    
    
    @objc func handlePurchasedPicker(){
        print("handlePurchasedPicker")
        
        equipment.purchaseDate = dateFormatterDB.string(from: purchasedPicker.date)
        self.purchasedTxtField.text = dateFormatter.string(from: purchasedPicker.date)
       // print("equipment.purchaseDate = \(equipment.purchaseDate)")
        self.purchasedTxtField.resignFirstResponder()
        editsMade = true
        
    }
    
    
    @objc func cancelVendorInput(){
        print("Cancel Vendor Input")
        self.vendorTxtField.resignFirstResponder()
        self.vendorResultsTableView.alpha = 0.0
    }
    
    
    @objc func cancelDescriptionInput(){
        print("Cancel Description Input")
        self.descriptionView.resignFirstResponder()
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder()
        return true
    }
 
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        print("tag = \(textField.tag)")
        if textField.tag == 9{
            
            print("textField.count = \(textField.text!.count)")
            if (textField.text!.count == 0) {
                self.vendorResultsTableView.alpha = 0.0
                equipment.dealer = ""
                equipment.dealerName = ""
            }else{
                self.vendorResultsTableView.alpha = 1.0
            }
            
            filterSearchResults()
            
            self.vendorResultsTableView.reloadData()
        }
        
        
        
         }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        print("textFieldDidChange")
       
            
            print("textField.count = \(textField.text!.count)")
            if (textField.text!.count == 0) {
                self.vendorResultsTableView.alpha = 0.0
                equipment.dealer = ""
                equipment.dealerName = ""
            }else{
                self.vendorResultsTableView.alpha = 1.0
            }
            
            filterSearchResults()
            
            self.vendorResultsTableView.reloadData()
        
    }
    
    
   
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        print("textField.tag = \(textField.tag)")
        if textField.tag == 1 || textField.tag == 3 || textField.tag == 4{
            textField.text = textField.text?.capitalized
        }
        
        if textField.tag == 9{
            
            
            self.vendorResultsTableView.reloadData()
        }
        
        
        editsMade = true
        
    }
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textFieldDidBeginEditing")
       
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
       
        
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
        var count:Int = 0
        switch pickerView.tag {
        case 2:
            count = self.crewIDArray.count
            break
        case 5:
            count = self.typeIDArray.count
            break
        case 7:
            count = self.fuelIDArray.count
            break
        case 8:
            count = self.engineIDArray.count
            break
        default:
            //1
            count = self.crewIDArray.count
        }
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title:String = ""
        switch pickerView.tag {
        case 2:
            title = self.crewNameArray[row]
            break
        case 5:
            title = self.typeNameArray[row]
            break
        case 7:
            title = self.fuelNameArray[row]
            break
        case 8:
            title = self.engineNameArray[row]
            break
        default:
            //1
            title = self.crewNameArray[row]
        }
        return title
    }
    
 
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("pickerview tag: \(pickerView.tag)")
        
        
        switch pickerView.tag {
        case 2:
            equipment.crew = self.crewIDArray[row]
            equipment.crewName = self.crewNameArray[row]
            crewTxtField.text = self.crewNameArray[row]
            break
        case 5:
            equipment.type = self.typeIDArray[row]
            equipment.typeName = self.typeNameArray[row]
            typeTxtField.text = self.typeNameArray[row]
            break
        case 7:
            equipment.fuelType = self.fuelIDArray[row]
            equipment.fuelTypeName = self.fuelNameArray[row]
            fuelTxtField.text = self.fuelNameArray[row]
            break
        case 8:
            equipment.engineType = self.engineIDArray[row]
            equipment.engineTypeName = self.engineNameArray[row]
            engineTxtField.text = self.engineNameArray[row]
            break
        default:
            //1
            equipment.crew = self.crewIDArray[row]
            equipment.crewName = self.crewNameArray[row]
            crewTxtField.text = self.crewNameArray[row]
        }
    }
    
    
   
    
    func filterSearchResults(){
        print("filterSearch")
            vendorSearchResults = []
            self.vendorSearchResults = self.vendorNameArray.filter({( aVendor: String ) -> Bool in
                return (aVendor.lowercased().range(of: vendorTxtField.text!.lowercased(), options:.regularExpression) != nil)})
            self.vendorResultsTableView.reloadData()
    }
    
    
    
    
    
    /////////////// Table Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    
        let count = self.vendorSearchResults.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        let searchString = self.vendorTxtField.text!.lowercased()
        let cell:VendorTableViewCell = tableView.dequeueReusableCell(withIdentifier: "vendorCell") as! VendorTableViewCell
        
        
        cell.nameLbl.text = self.vendorSearchResults[indexPath.row]
        cell.name = self.vendorSearchResults[indexPath.row]
        if let i = self.vendorNameArray.index(of: cell.nameLbl.text!) {
            cell.id = self.vendorIDArray[i]
        } else {
            cell.id = ""
        }
        
        //text highlighting
        let baseString:NSString = cell.name as NSString
        let highlightedText = NSMutableAttributedString(string: cell.name)
        var error: NSError?
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        if let regexError = error {
            print("Oh no! \(regexError)")
        } else {
            for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
            }
        }
        cell.nameLbl.attributedText = highlightedText
        
        
        return cell
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! VendorTableViewCell
        equipment.dealer = currentCell.id
        equipment.dealerName = currentCell.name
        
        vendorTxtField.text = currentCell.name
        vendorResultsTableView.alpha = 0.0
        vendorTxtField.resignFirstResponder()
        
        editsMade = true
 
            
    }
    
    
    
    
   
    
    func validateFields()->Bool{
        
        
        print("validate fields")
        
        if nameTxtField.text != nameTxtField.placeHolder{
            equipment.name = nameTxtField.text!
        }
        if makeTxtField.text != makeTxtField.placeHolder{
            equipment.make = makeTxtField.text!
        }
        if modelTxtField.text != modelTxtField.placeHolder{
            equipment.model = modelTxtField.text!
        }
        if serialTxtField.text != serialTxtField.placeHolder{
            equipment.serial = serialTxtField.text!
        }
        
        
        equipment.description = descriptionView.text!
        
        
       
        
        
        //type check
        if(equipment.type == ""){
            print("select a type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Select a Type")
            return false
        }
        
        //crew check
        if(equipment.crew == ""){
            print("select a crew")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Select a Crew")
            return false
        }
        //make check
        if(equipment.make == ""){
            print("select a make")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Provide a Make (Brand)")
            return false
        }
        //model check
        if(equipment.model == ""){
            print("select a model")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Provide a Model")
            return false
        }
        //name check
        if(equipment.name == ""){
            print("select a name")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Provide a Name")
            return false
        }
        //serial check
        if(equipment.serial == ""){
            print("select a serial")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Provide a Serial #")
            return false
        }
        //fuel check
        if(equipment.fuelType == ""){
            print("select a fuel type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Select a Fuel Type")
            return false
        }
        //engine check
        if(equipment.engineType == ""){
            print("select an engine type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Select an Engine Type")
            return false
        }
        //dealer check
        if(equipment.dealer == ""){
            print("select a dealer")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Select a Dealer")
            return false
        }
        //date check
        if(equipment.purchaseDate == ""){
            print("select a purchased date")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Equipment", _message: "Select a Purchase Date")
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
        parameters = ["equipmentID": self.equipment.ID, "addedBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), "name": self.equipment.name, "make": self.equipment.make,"model": self.equipment.model, "crew": self.equipment.crew, "vendorID": equipment.dealer, "fuelType": self.equipment.fuelType, "engineType": self.equipment.engineType, "mileage": self.equipment.mileage, "serial": self.equipment.serial, "status": self.equipment.status, "type": self.equipment.type, "active": "1", "description": equipment.description, "purchaseDate": equipment.purchaseDate] as! [String : String]
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/equipment.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
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
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Error with Save", _message: self.json["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                        
                    let newEquipmentID = self.json["equipmentID"].stringValue
                    
                    
                    self.equipment.ID = newEquipmentID
                    
                    
                    
                    if self.equipment.image.ID == "0"{
                        let alertController = UIAlertController(title: "Add Image?", message: "Please add an image of the equipment.", preferredStyle: UIAlertController.Style.alert)
                        let cancelAction = UIAlertAction(title: "Don't Add", style: UIAlertAction.Style.destructive) {
                            (result : UIAlertAction) -> Void in
                            print("Cancel")
                            if(self.title == "New Equipment"){
                                self.delegate.reDrawEquipmentList()
                            }else{
                                self.editDelegate.updateEquipment(_equipment: self.equipment)
                            }
                            self.editsMade = false // avoids the back without saving check
                            self.goBack()
                        }
                        
                        let okAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            print("OK")
                            
                            self.imageAddedAfterSubmit = true
                            
                            self.editImage()
                            
                            
                        }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                    }else{
                        
                        
                        
                        if(self.title == "New Equipment"){
                            self.delegate.reDrawEquipmentList()
                        }else{
                            self.editDelegate.updateEquipment(_equipment: self.equipment)
                        }
                        self.editsMade = false // avoids the back without saving check
                        self.goBack()
                    }
                    
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
                //if self.delegate != nil{
                    //self.delegate.reDrawEquipmentList()
                //}
                
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
    
    
    func updateImage(_image:Image2){
        print("update image")
        
        
        activityView.startAnimating()
        self.equipment.image = _image
        //self.equipment.pic = _image.thumbPath
        let imgURL:URL = URL(string: self.equipment.image.thumbPath!)!
        
        
        Alamofire.request(imgURL).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                self.equipmentImage.image = image
                
                
                
                self.activityView.stopAnimating()
                
                if(self.title == "New Equipment"){
                    self.delegate.reDrawEquipmentList()
                }else{
                    self.editDelegate.updateEquipment(_equipment: self.equipment)
                }
                
                
                if self.imageAddedAfterSubmit {
                    
                    self.editsMade = false
                    self.goBack()
                }
                
                
            }
        }
        
        
      
        
    }
    
    
    
}

