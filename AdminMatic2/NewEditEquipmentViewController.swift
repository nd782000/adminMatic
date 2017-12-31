//
//  NewEditEquipmentViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/19/17.
//  Copyright © 2017 Nick. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Nuke


protocol UpdateEquipmentImageDelegate{
    func updateImage(_image:Image)
}


class NewEditEquipmentViewController: UIViewController, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UpdateEquipmentImageDelegate {
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
    var descriptionView:UITextView!
    
    
    
    
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
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(LeadViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        showLoadingScreen()
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
            if let json = response.result.value {
               
                let typesCount = JSON(json)["types"].count
                print("typescount: \(typesCount)")
                for i in 0 ..< typesCount {
                    self.typeIDArray.append(JSON(json)["types"][i]["ID"].stringValue)
                    self.typeNameArray.append(JSON(json)["types"][i]["name"].stringValue)
                }
                
                let fuelTypesCount = JSON(json)["fuelTypes"].count
                print("fuelTypesCount: \(fuelTypesCount)")
                for i in 0 ..< fuelTypesCount {
                    self.fuelIDArray.append(JSON(json)["fuelTypes"][i]["ID"].stringValue)
                    self.fuelNameArray.append(JSON(json)["fuelTypes"][i]["name"].stringValue)
                }
                
                let engineTypesCount = JSON(json)["engineTypes"].count
                print("engineTypesCount: \(engineTypesCount)")
                for i in 0 ..< engineTypesCount {
                    self.engineIDArray.append(JSON(json)["engineTypes"][i]["ID"].stringValue)
                    self.engineNameArray.append(JSON(json)["engineTypes"][i]["name"].stringValue)
                }
                
                let crewCount = JSON(json)["crews"].count
                print("crewCount: \(crewCount)")
                for i in 0 ..< crewCount {
                    self.crewIDArray.append(JSON(json)["crews"][i]["ID"].stringValue)
                    self.crewNameArray.append(JSON(json)["crews"][i]["name"].stringValue)
                }
                
                let vendorCount = JSON(json)["vendors"].count
                print("vendorCount: \(vendorCount)")
                for i in 0 ..< vendorCount {
                    self.vendorIDArray.append(JSON(json)["vendors"][i]["ID"].stringValue)
                    self.vendorNameArray.append(JSON(json)["vendors"][i]["name"].stringValue)
                }
                
                 self.noPic = JSON(json)["noPic"].stringValue
                
                self.layoutViews()
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
            let image:Image = Image(_ID: "0", _noPicPath: noPic)
            self.equipment.image = image
        }else{
           
            title =  "Edit Equipment #" + self.equipment.ID
            submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditEquipmentViewController.submit))
        }
        navigationItem.rightBarButtonItem = submitButton
        
        
        //image
        self.equipmentImage = UIImageView()
        
        
            activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityView.center = CGPoint(x: self.equipmentImage.frame.size.width / 2, y: self.equipmentImage.frame.size.height / 2)
            equipmentImage.addSubview(activityView)
            activityView.startAnimating()
            
            //let imgURL:URL = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.equipment.pic!)!
        
            let imgURL = URL(string: equipment.image.thumbPath!)!
        
            print("imgURL = \(imgURL)")
            
            
            Nuke.loadImage(with: imgURL, into: self.equipmentImage!){
                print("nuke loadImage")
                self.equipmentImage?.handle(response: $0, isFromMemoryCache: $1)
                self.activityView.stopAnimating()
                //self.image = Image(_path: self.equipment.pic!)
                //self.image = equipment.image
            }
            
        
        
        
        self.equipmentImage.layer.cornerRadius = 5.0
        self.equipmentImage.layer.borderWidth = 2
        self.equipmentImage.layer.borderColor = layoutVars.borderColor
        self.equipmentImage.clipsToBounds = true
        self.equipmentImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.equipmentImage)
        
        self.tapBtn = Button()
        self.tapBtn.translatesAutoresizingMaskIntoConstraints = false
        self.tapBtn.addTarget(self, action: #selector(NewEditEquipmentViewController.editImage), for: UIControlEvents.touchUpInside)
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControlState.normal)
        self.view.addSubview(self.tapBtn)
        
        
        
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = "Name:"
        self.nameLbl.textAlignment = .left
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(nameLbl)
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
        self.view.addSubview(self.nameTxtField)
        
        
        //crew
        
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew:"
        self.crewLbl.textAlignment = .left
        self.crewLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(crewLbl)
        
        self.crewPicker = Picker()
        self.crewPicker.delegate = self
        self.crewTxtField = PaddedTextField(placeholder: "Crew")
        self.crewTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.crewTxtField.delegate = self
        self.crewTxtField.tag = 2
        self.crewTxtField.inputView = crewPicker
        self.crewTxtField.returnKeyType = .done
        self.view.addSubview(self.crewTxtField)
        
        
        let crewToolBar = UIToolbar()
        crewToolBar.barStyle = UIBarStyle.default
        crewToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        crewToolBar.sizeToFit()
        let closeCrewButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelCrewInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let setCrewButton = UIBarButtonItem(title: "Set Crew", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.handleCrewChange))
        crewToolBar.setItems([closeCrewButton, spaceButton, setCrewButton], animated: false)
        crewToolBar.isUserInteractionEnabled = true
        crewTxtField.inputAccessoryView = crewToolBar
        
        
       
        
        crewTxtField.text = equipment.crewName
        
        
        //make
        self.makeLbl = GreyLabel()
        self.makeLbl.text = "Make:"
        self.makeLbl.textAlignment = .left
        self.makeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(makeLbl)
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
        self.view.addSubview(self.makeTxtField)
        
        
        //model
        self.modelLbl = GreyLabel()
        self.modelLbl.text = "Model:"
        self.modelLbl.textAlignment = .left
        self.modelLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(modelLbl)
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
        self.view.addSubview(self.modelTxtField)
        
        //type
        self.typeLbl = GreyLabel()
        self.typeLbl.text = "Type:"
        self.typeLbl.textAlignment = .left
        self.typeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(typeLbl)
        
        self.typePicker = Picker()
        self.typePicker.delegate = self
        self.typePicker.tag = 5
        self.typeTxtField = PaddedTextField(placeholder: "Type")
        self.typeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.typeTxtField.delegate = self
        self.typeTxtField.inputView = typePicker
        self.typeTxtField.returnKeyType = .done
        self.view.addSubview(self.typeTxtField)
        
        
        let typeToolBar = UIToolbar()
        typeToolBar.barStyle = UIBarStyle.default
        typeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        typeToolBar.sizeToFit()
        let closeTypeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelTypeInput))
        let setTypeButton = UIBarButtonItem(title: "Set Type", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.handleTypeChange))
        typeToolBar.setItems([closeTypeButton, spaceButton, setTypeButton], animated: false)
        typeToolBar.isUserInteractionEnabled = true
        typeTxtField.inputAccessoryView = typeToolBar
        
        
        
        
        typeTxtField.text = equipment.typeName
        
        
        
        //serial
        self.serialLbl = GreyLabel()
        self.serialLbl.text = "Serial #:"
        self.serialLbl.textAlignment = .left
        self.serialLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(serialLbl)
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
        self.view.addSubview(self.serialTxtField)
        
        //fuel
        self.fuelLbl = GreyLabel()
        self.fuelLbl.text = "Fuel:"
        self.fuelLbl.textAlignment = .left
        self.fuelLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(fuelLbl)
        
        self.fuelPicker = Picker()
        self.fuelPicker.delegate = self
        self.fuelPicker.tag = 7
        
        self.fuelTxtField = PaddedTextField(placeholder: "Fuel")
        self.fuelTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.fuelTxtField.delegate = self
        self.fuelTxtField.tag = 7
        
        self.fuelTxtField.returnKeyType = .done
        self.fuelTxtField.inputView = fuelPicker
        self.view.addSubview(self.fuelTxtField)
        
        
        let fuelToolBar = UIToolbar()
        fuelToolBar.barStyle = UIBarStyle.default
        fuelToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        fuelToolBar.sizeToFit()
        let closeFuelButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelFuelInput))
        let setFuelButton = UIBarButtonItem(title: "Set Fuel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.handleFuelChange))
        fuelToolBar.setItems([closeFuelButton, spaceButton, setFuelButton], animated: false)
        fuelToolBar.isUserInteractionEnabled = true
        fuelTxtField.inputAccessoryView = fuelToolBar
        
       
        
        
        fuelTxtField.text = equipment.fuelTypeName
        
        
        
        //engine
        
        self.engineLbl = GreyLabel()
        self.engineLbl.text = "Engine:"
        self.engineLbl.textAlignment = .left
        self.engineLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(engineLbl)
        
        self.enginePicker = Picker()
        self.enginePicker.delegate = self
        self.enginePicker.tag = 8
        
        self.engineTxtField = PaddedTextField(placeholder: "Engine")
        self.engineTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.engineTxtField.delegate = self
        self.engineTxtField.tag = 8
        
        self.engineTxtField.inputView = enginePicker
        self.engineTxtField.returnKeyType = .done
        self.view.addSubview(self.engineTxtField)
        
        
        let engineToolBar = UIToolbar()
        engineToolBar.barStyle = UIBarStyle.default
        engineToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        engineToolBar.sizeToFit()
        let closeEngineButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelEngineInput))
        let setEngineButton = UIBarButtonItem(title: "Set Engine", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.handleEngineChange))
        engineToolBar.setItems([closeEngineButton, spaceButton, setEngineButton], animated: false)
        engineToolBar.isUserInteractionEnabled = true
        engineTxtField.inputAccessoryView = engineToolBar
        
        
        
        engineTxtField.text = equipment.fuelTypeName
        
        
        //dealer
        self.vendorLbl = GreyLabel()
        self.vendorLbl.text = "Dealer:"
        self.vendorLbl.textAlignment = .left
        self.vendorLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(vendorLbl)
        
        
      
        self.vendorTxtField = PaddedTextField(placeholder: "Dealer")
        self.vendorTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.vendorTxtField.delegate = self
        self.vendorTxtField.tag = 9
        //self.engineTxtField.inputView = enginePicker
        self.vendorTxtField.returnKeyType = .search
        //self.scheduleengineTxtField.layer.borderWidth = 0
        self.view.addSubview(self.vendorTxtField)
        self.vendorTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        let vendorToolBar = UIToolbar()
        vendorToolBar.barStyle = UIBarStyle.default
        vendorToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        vendorToolBar.sizeToFit()
        let closeVendorButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelVendorInput))
        
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
        self.view.addSubview(purchasedLbl)
        
        
        purchasedPicker = DatePicker()
        purchasedPicker.datePickerMode = UIDatePickerMode.date
        
        
        self.purchasedTxtField = PaddedTextField(placeholder: "Purchase Date")
        self.purchasedTxtField.returnKeyType = UIReturnKeyType.next
        self.purchasedTxtField.delegate = self
        self.purchasedTxtField.tag = 10
        self.purchasedTxtField.inputView = self.purchasedPicker
        self.view.addSubview(self.purchasedTxtField)
        
        let purchasedToolBar = UIToolbar()
        purchasedToolBar.barStyle = UIBarStyle.default
        purchasedToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        purchasedToolBar.sizeToFit()
        let closePurchasedButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelPurchasedInput))
        let setPurchasedButton = UIBarButtonItem(title: "Set Purchased", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.handlePurchasedPicker))
        purchasedToolBar.setItems([closePurchasedButton, spaceButton, setPurchasedButton], animated: false)
        purchasedToolBar.isUserInteractionEnabled = true
        purchasedTxtField.inputAccessoryView = purchasedToolBar
        
        
        print("purchased = \(equipment.purchaseDate)")
        if(equipment.purchaseDate != "" && equipment.purchaseDate != "null"){
            self.purchasedTxtField.text = equipment.purchaseDate
        }
        
        
        //description
        self.descriptionLbl = GreyLabel()
        self.descriptionLbl.text = "Description:"
        self.descriptionLbl.textAlignment = .left
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.descriptionLbl)
        
        self.descriptionView = UITextView()
        self.descriptionView.returnKeyType = .done
        self.descriptionView.text = self.equipment.description
        self.descriptionView.font = layoutVars.smallFont
        self.descriptionView.isEditable = true
        self.descriptionView.delegate = self
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.descriptionView)
        
        let descriptionToolBar = UIToolbar()
        descriptionToolBar.barStyle = UIBarStyle.default
        descriptionToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        descriptionToolBar.sizeToFit()
        let closeDescriptionButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEditEquipmentViewController.cancelDescriptionInput))
        
        descriptionToolBar.setItems([closeDescriptionButton], animated: false)
        descriptionToolBar.isUserInteractionEnabled = true
        self.descriptionView.inputAccessoryView = descriptionToolBar
        
        
        
        self.submitButtonBottom.addTarget(self, action: #selector(NewEditEquipmentViewController.submit), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.submitButtonBottom)
        
        
        self.vendorResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.vendorResultsTableView.delegate  =  self
        self.vendorResultsTableView.dataSource = self
        self.vendorResultsTableView.register(VendorTableViewCell.self, forCellReuseIdentifier: "vendorCell")
        self.vendorResultsTableView.alpha = 0.0
        self.view.addSubview(vendorResultsTableView)
        
        
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
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[typeLbl]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tapBtn(120)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[typeTxt]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[crewLbl]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(120)]-5-[crewTxt]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[makeLbl(halfWidth)]-5-[modelLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[makeTxt(halfWidth)]-5-[modelTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameLbl(halfWidth)]-5-[serialLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nameTxt(halfWidth)]-5-[serialTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fuelLbl(halfWidth)]-5-[engineLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fuelTxt(halfWidth)]-5-[engineTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[vendorLbl(halfWidth)]-5-[purchasedLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[vendorTxt(halfWidth)]-5-[purchasedTxt(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descriptionLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descriptionView]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[vendorTable]-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        
        

        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[typeLbl(30)][typeTxt(30)]-[crewLbl(30)][crewTxt(30)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(120)][modelLbl(30)][modelTxt(30)][serialLbl(30)][serialTxt(30)][engineLbl(30)][engineTxt(30)][purchasedLbl(30)][purchasedTxt(30)][descriptionLbl(30)][descriptionView(75)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[tapBtn(120)][makeLbl(30)][makeTxt(30)][nameLbl(30)][nameTxt(30)][fuelLbl(30)][fuelTxt(30)][vendorLbl(30)][vendorTxt(30)][vendorTable]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submitBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
    }
    
    @objc func editImage(){
        print("Edit Image")
        
        if equipment.ID == "0"{
            simpleAlert(_vc: self, _title: "Save Equipment First", _message: "You must save the new equipment before adding an image.")
        }else{
            
            //if equipment.pic == ""{
            if equipment.image.ID == "0"{
                print("no pic")
                imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Equipment", _equipmentID: equipment.ID)
                imageUploadPrepViewController.layoutViews()
                imageUploadPrepViewController.equipmentImageDelegate = self
                self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
            }else{
                print("already has a pic")
                
                
                
                let actionSheet = UIAlertController(title: "Replace existing equipment image? ", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                actionSheet.view.backgroundColor = UIColor.white
                actionSheet.view.layer.cornerRadius = 5;
                
                actionSheet.addAction(UIAlertAction(title: "Add New Image", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                    self.imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Equipment", _equipmentID: self.equipment.ID)
                    self.imageUploadPrepViewController.layoutViews()
                    self.imageUploadPrepViewController.equipmentImageDelegate = self
                    self.navigationController?.pushViewController(self.imageUploadPrepViewController, animated: false )
                    
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
                }))
                
                
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    self.present(actionSheet, animated: true, completion: nil)
                    
                    break
                // It's an iPhone
                case .pad:
                    let nav = UINavigationController(rootViewController: actionSheet)
                    nav.modalPresentationStyle = UIModalPresentationStyle.popover
                    let popover = nav.popoverPresentationController as UIPopoverPresentationController!
                    actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                    popover?.sourceView = self.view
                    popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                    
                    self.present(nav, animated: true, completion: nil)
                    break
                // It's an iPad
                case .unspecified:
                    break
                default:
                    self.present(actionSheet, animated: true, completion: nil)
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
        
        print("crew = \(equipment.crew)")
        print("crewName = \(equipment.crewName)")
        
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
        print("type = \(equipment.type)")
        print("typeName = \(equipment.typeName)")
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
        
        print("fuel = \(equipment.fuelType)")
        print("fuelName = \(equipment.fuelTypeName)")
        
        
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
        
        print("engine = \(equipment.engineType)")
        print("engineName = \(equipment.engineTypeName)")
        
        
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
        print("equipment.purchaseDate = \(equipment.purchaseDate)")
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
        
        if textField.tag > 6{
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 200
                
                
            }, completion: { finished in
                // //print("Napkins opened!")
            })
        }
        
    }
    
     func textFieldDidChange(_ textField: UITextField) {
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
        if textField.tag == 9{
            
            
            self.vendorResultsTableView.reloadData()
        }
        
        if textField.tag > 4{
            if(self.view.frame.origin.y < 0){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.view.frame.origin.y += 200
                    
                    
                }, completion: { finished in
                })
            }
        }
        
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
    }
    
    
    
    
    
    
    
    
  
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        print("pickerview tag: \(pickerView.tag)")
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
                highlightedText.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: match.range)
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
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Select a Type")
            return false
        }
        
        //crew check
        if(equipment.crew == ""){
            print("select a crew")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Select a Crew")
            return false
        }
        //make check
        if(equipment.make == ""){
            print("select a make")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Provide a Make (Brand)")
            return false
        }
        //model check
        if(equipment.model == ""){
            print("select a model")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Provide a Model")
            return false
        }
        //name check
        if(equipment.name == ""){
            print("select a name")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Provide a Name")
            return false
        }
        //serial check
        if(equipment.serial == ""){
            print("select a serial")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Provide a Serial #")
            return false
        }
        //fuel check
        if(equipment.fuelType == ""){
            print("select a fuel type")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Select a Fuel Type")
            return false
        }
        //engine check
        if(equipment.engineType == ""){
            print("select an engine type")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Select an Engine Type")
            return false
        }
        //dealer check
        if(equipment.dealer == ""){
            print("select a dealer")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Select a Dealer")
            return false
        }
        //date check
        if(equipment.purchaseDate == ""){
            print("select a purchased date")
            simpleAlert(_vc: self, _title: "Incomplete Equipment", _message: "Select a Purchase Date")
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
        
        let parameters = ["equipmentID": self.equipment.ID as AnyObject, "addedBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "name": self.equipment.name as AnyObject, "make": self.equipment.make as AnyObject,"model": self.equipment.model  as AnyObject, "crew": self.equipment.crew as AnyObject, "vendorID": equipment.dealer  as AnyObject, "fuelType": self.equipment.fuelType as AnyObject, "engineType": self.equipment.engineType as AnyObject, "mileage": self.equipment.mileage as AnyObject, "serial": self.equipment.serial as AnyObject, "status": self.equipment.status as AnyObject, "type": self.equipment.type as AnyObject, "active": "1" as AnyObject, "description": equipment.description as AnyObject, "purchaseDate": equipment.purchaseDate as AnyObject] as [String : Any]
        
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
                        simpleAlert(_vc: self, _title: "Error with Save", _message: self.json["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                        
                    let newEquipmentID = self.json["equipmentID"].stringValue
                    
                    
                    self.equipment.ID = newEquipmentID
                    
                    
                    
                    if self.equipment.image.ID == "0"{
                        let alertController = UIAlertController(title: "Add Image?", message: "Please add an image of the equipment.", preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: "Don't Add", style: UIAlertActionStyle.destructive) {
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
                        
                        let okAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            print("OK")
                            
                            self.imageAddedAfterSubmit = true
                            
                            self.editImage()
                            
                            
                        }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
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
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //if self.delegate != nil{
                    //self.delegate.reDrawEquipmentList()
                //}
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
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
    
    
    func updateImage(_image:Image){
        print("update image")
        
        
        activityView.startAnimating()
        self.equipment.image = _image
        //self.equipment.pic = _image.thumbPath
        let imgURL:URL = URL(string: self.equipment.image.thumbPath)!
        
       // print("imgURL = \(imgURL)")
        
        
        Nuke.loadImage(with: imgURL, into: self.equipmentImage!){
            print("nuke loadImage")
            self.equipmentImage?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
            //self.image = Image(_path: self.equipment.pic!)
            
            
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
    
    
    /*
    func updateTable(_points:Int){
        print("updateTable")
        //getLead()
    }
 */
}

