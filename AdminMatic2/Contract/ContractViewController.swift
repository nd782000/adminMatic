//
//  ContractViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON




protocol EditContractDelegate{
    func updateContract(_contract:Contract)
    func updateContract(_contractItem:ContractItem)
    func updateContract(_contract:Contract, _status:String)
    //func updateContractLead(_lead:Lead)
    func suggestStatusChange(_emailCount:Int)
}





class ContractViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, EditContractDelegate, EditTermsDelegate, StackDelegate, EditLeadDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    var contract:Contract!
    var delegate:ContractListDelegate!
    
    var editLeadDelegate:EditLeadDelegate!
    var sortEditsMade:Bool = false
    
    var stackController:StackController!
    
    var optionsButton:UIBarButtonItem!
    var editsMade:Bool = false
    var statusIcon:UIImageView = UIImageView()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["New","Sent","Awarded","Scheduled","Declined","Waiting","Canceled"]
    var statusValue: String!
    var statusValueToUpdate: String!
    var customerBtn: Button!
    var infoView: UIView! = UIView()
    
    var titleLbl:GreyLabel!
    var titleValue:GreyLabel!
    
    var chargeTypeLbl:GreyLabel!
    var chargeType:GreyLabel!
    
    var chargeTypeArray = ["NC - No Charge", "FL - Flat Priced", "T & M - Time & Material"]
    
    
    var salesRepLbl:GreyLabel!
    var salesRep:GreyLabel!
    
    var notesLbl:GreyLabel!
    var notesView:UITextView!
    var itemsLbl:GreyLabel!
    var items: JSON!
    var itemsArray:[ContractItem] = []
    var itemIDArray:[String] = []
    //var signatureArray:[Signature] = []
    var itemRowToEdit:Int?
    
    var customerSignature:Signature!
    var itemsTableView: TableView!
    
    var signBtn:Button = Button(titleText: "Sign")
    var signatureImageContainerView:UIView!
    var signatureImage:UIImage!
    var signatureImageView:UIImageView!
    
    var tapBtn:UIButton!
    
    var totalLbl:GreyLabel!
    var taxLbl:GreyLabel!
    
    
    var leadTasksWaiting:String?
    
    //var employeeSignature:Bool = false
    
    
    var contractItemViewController:ContractItemViewController?

    //var lead:Lead?
    
    init(_contract:Contract){
        super.init(nibName:nil,bundle:nil)
        
        self.contract = _contract
        //print("contract init - total = \(contract.total)")
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
        backButton.addTarget(self, action: #selector(ContractViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading..."
        getContract()
    }
    
    
    //sends request for lead tasks
    func getContract() {
        //print(" GetContract  Contract Id \(self.contract.ID)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.itemsArray = []
        let parameters:[String:String]
        parameters = ["contractID": self.contract.ID,"customerID": self.contract.customer,"repID": self.contract.salesRep]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("contract response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    self.parseJSON()
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    
    func parseJSON(){
        
        //primary info
        
        self.contract.subTotal =  self.json["contract"]["subTotal"].stringValue
        self.contract.taxTotal =  self.json["contract"]["taxTotal"].stringValue
        self.contract.total =  self.json["contract"]["total"].stringValue
        self.contract.terms = self.json["contract"]["termsDescription"].stringValue
        
        
        
        
        //items
        let itemCount = self.json["items"].count
        for i in 0 ..< itemCount {
            
            
            
            let taskCount = self.json["items"][i]["tasks"].count
            var contractTasks:[ContractTask] = []
            
            
            for n in 0 ..< taskCount {
                
                
                
                var taskImages:[Image] = []
                
                let imageCount = Int((self.json["items"][i]["tasks"][n]["images"].count))
                print("imageCount: \(imageCount)")
                
                for p in 0 ..< imageCount {
                    
                    let fileName:String = (self.json["items"][i]["tasks"][n]["images"][p]["fileName"].stringValue)
                    
                    let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                    let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                    let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                    
                    //create a item object
                    print("create an image object \(i)")
                    
                    print("thumbPath = \(thumbPath)")
                    print("rawPath = \(rawPath)")
                    
                    let image = Image(_id: self.json["items"][i]["tasks"][n]["images"][p]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["items"][i]["tasks"][n]["images"][p]["name"].stringValue,_width: self.json["items"][i]["tasks"][n]["images"][p]["width"].stringValue,_height: self.json["items"][i]["tasks"][n]["images"][p]["height"].stringValue,_description: self.json["items"][i]["tasks"][n]["images"][p]["description"].stringValue,_dateAdded: self.json["items"][i]["tasks"][n]["images"][p]["dateAdded"].stringValue,_createdBy: self.json["items"][i]["tasks"][n]["images"][p]["createdByName"].stringValue,_type: self.json["items"][i]["tasks"][n]["images"][p]["type"].stringValue)
                    
                    image.customer = (self.json["items"][i]["tasks"][n]["images"][p]["customer"].stringValue)
                    image.tags = (self.json["items"][i]["tasks"][n]["images"][p]["tags"].stringValue)
                    
                    print("appending image")
                    taskImages.append(image)
                    
                }
                
                
                
                
                
                let task  = ContractTask(_ID: self.json["items"][i]["tasks"][n]["ID"].stringValue, _contractItemID: self.json["items"][i]["tasks"][n]["contractItemID"].stringValue, _createDate: self.json["items"][i]["tasks"][n]["createDate"].stringValue, _createdBy: self.json["items"][i]["tasks"][n]["createdBy"].stringValue, _sort: self.json["items"][i]["tasks"][n]["sort"].stringValue, _taskDescription: self.json["items"][i]["tasks"][n]["taskDescription"].stringValue, _images: taskImages)
                
                contractTasks.append(task)
                
            }
            
            
            
            
            
            
            let item = ContractItem(_ID: self.json["items"][i]["ID"].stringValue, _chargeType: self.json["items"][i]["chargeType"].stringValue, _contractID: self.contract.ID, _createDate: self.json["items"][i]["createDate"].stringValue, _itemID:self.json["items"][i]["itemID"].stringValue, _name:self.json["items"][i]["name"].stringValue, _price:self.json["items"][i]["price"].stringValue, _qty:self.json["items"][i]["qty"].stringValue, _totalImages:self.json["items"][i]["totalImages"].stringValue, _total:self.json["items"][i]["total"].stringValue, _type: self.json["items"][i]["type"].stringValue, _taxCode: self.json["items"][i]["taxType"].stringValue, _subcontractor: self.json["items"][i]["subcontractor"].stringValue, _hideUnits: self.json["items"][i]["hideUnits"].stringValue)
            
            
                item.tasks = contractTasks
            
             self.itemsArray.append(item)
            
            
        }
        
        self.itemIDArray = []
        for item in itemsArray{
            let ID = item.ID!
            self.itemIDArray.append(ID)
        }
        
        
        //signatures
        
        
        if self.contract.customerSignature == "1"{
            customerSignature = Signature(_contractID: self.contract.ID, _type: "1", _path: self.json["contract"]["customerSignaturePath"].stringValue)
            print("customer signature = \(self.json["contract"]["customerSignaturePath"].stringValue)")
            //self.signatureArray.append(signature)
        }
        
        
        self.layoutViews()
    }
    
    
    func layoutViews(){
        print("layout views")
        title =  "Contract #" + self.contract.ID
        
        optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(ContractViewController.displayContractOptions))
        navigationItem.rightBarButtonItem = optionsButton
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        stackController = StackController()
        stackController.delegate = self
        stackController.getStack(_type:1,_ID:self.contract.ID)
        safeContainer.addSubview(stackController)
        
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        setStatus(status: contract.status)
        
        //picker
        self.statusPicker = Picker()
        //print("statusValue : \(contract.status)")
        print("set picker position : \(Int(contract.status)!)")
        
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
        
        
        self.statusPicker.selectRow(Int(contract.status)!, inComponent: 0, animated: false)
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
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ContractViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ContractViewController.handleStatusChange))
        
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        statusTxtField.inputAccessoryView = toolBar
        
        self.customerBtn = Button(titleText: "\(self.contract.customerName!)")
        self.customerBtn.contentHorizontalAlignment = .left
        let custIcon:UIImageView = UIImageView()
        custIcon.backgroundColor = UIColor.clear
        custIcon.contentMode = .scaleAspectFill
        custIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        let custImg = UIImage(named:"custIcon.png")
        custIcon.image = custImg
        self.customerBtn.addSubview(custIcon)
        self.customerBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.customerBtn.addTarget(self, action: #selector(self.showCustInfo), for: UIControl.Event.touchUpInside)
        
        safeContainer.addSubview(customerBtn)
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.infoView.layer.borderWidth = 1
        self.infoView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.infoView.layer.cornerRadius = 4.0
        safeContainer.addSubview(infoView)
        
        //title
        self.titleLbl = GreyLabel()
        self.titleLbl.text = "Title:"
        self.titleLbl.textAlignment = .left
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleLbl)
        
        self.titleValue = GreyLabel()
        self.titleValue.text = self.contract.title
        self.titleValue.font = layoutVars.labelBoldFont
        self.titleValue.textAlignment = .left
        self.titleValue.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleValue)
        
        //charge type
        self.chargeTypeLbl = GreyLabel()
        self.chargeTypeLbl.text = "Charge Type:"
        self.chargeTypeLbl.textAlignment = .left
        self.chargeTypeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeTypeLbl)
        
        self.chargeType = GreyLabel()
        self.chargeType.text = self.chargeTypeArray[Int(self.contract.chargeType)! - 1]
        self.chargeType.font = layoutVars.labelBoldFont
        self.chargeType.textAlignment = .left
        self.chargeType.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeType)
        
        //sales rep
        self.salesRepLbl = GreyLabel()
        self.salesRepLbl.text = "Sales Rep:"
        self.salesRepLbl.textAlignment = .left
        self.salesRepLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRepLbl)
        
        self.salesRep = GreyLabel()
        self.salesRep.text = self.contract.repName
        self.salesRep.font = layoutVars.labelBoldFont
        self.salesRep.textAlignment = .left
        self.salesRep.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRep)
        
        //notes
        self.notesLbl = GreyLabel()
        self.notesLbl.text = "Notes:"
        self.notesLbl.textAlignment = .left
        self.notesLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(notesLbl)
        
        self.notesView = UITextView()
        self.notesView.text = self.contract.notes
        self.notesView.font = layoutVars.textFieldFont
        self.notesView.isEditable = false
        self.notesView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(notesView)
        
        //items
        self.itemsLbl = GreyLabel()
        self.itemsLbl.text = "Items:"
        self.itemsLbl.textAlignment = .left
        self.itemsLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(itemsLbl)
        
        self.itemsTableView  =   TableView()
        self.itemsTableView.autoresizesSubviews = true
        self.itemsTableView.delegate  =  self
        self.itemsTableView.dataSource  =  self
        self.itemsTableView.layer.cornerRadius = 4
        self.itemsTableView.rowHeight = 90
        self.itemsTableView.register(ContractItemTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.itemsTableView.rowHeight = UITableView.automaticDimension
        self.itemsTableView.estimatedRowHeight = 60
        
        
        safeContainer.addSubview(self.itemsTableView)
        
        
        
        self.signBtn.addTarget(self, action: #selector(ContractViewController.sign), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.signBtn)
        
        
        
        self.signatureImageContainerView = UIView()
        self.signatureImageContainerView.layer.borderWidth = 1
        self.signatureImageContainerView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.signatureImageContainerView.backgroundColor = UIColor.white
        self.signatureImageContainerView.layer.cornerRadius = 4.0
        self.signatureImageContainerView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.signatureImageContainerView)
        
        
        
        
        self.signatureImageView = UIImageView()
        self.signatureImageView.contentMode = .scaleAspectFit
        self.signatureImageView.translatesAutoresizingMaskIntoConstraints = false
        self.signatureImageContainerView.addSubview(self.signatureImageView)
        
        
        //main views
        let imageContainerDictionary = [
            "signature":self.signatureImageView
            ] as [String:AnyObject]
        
        self.signatureImageContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[signature]-2-|", options: [], metrics: nil, views: imageContainerDictionary))
        self.signatureImageContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[signature]-4-|", options: [], metrics: nil, views: imageContainerDictionary))
        
        
        
        self.tapBtn = Button()
        self.tapBtn.translatesAutoresizingMaskIntoConstraints = false
        self.tapBtn.addTarget(self, action: #selector(ContractViewController.showSignatureOptions), for: UIControl.Event.touchUpInside)
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControl.State.normal)
        safeContainer.addSubview(self.tapBtn)
        
        
        //total
        self.totalLbl = GreyLabel()
        self.totalLbl.text =  self.layoutVars.numberAsCurrency(_number: self.contract.total!) 
        self.totalLbl.textAlignment = .right
        self.totalLbl.font = layoutVars.largeFont
        self.totalLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(totalLbl)
        
        //tax
        self.taxLbl = GreyLabel()
        self.taxLbl.text = "Includes any Tax"
        self.taxLbl.textAlignment = .right
        self.taxLbl.font = layoutVars.microFont
        self.taxLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(taxLbl)
        
        
        if self.contract.customerSignature == "1"{
        //if(self.signatureArray.count > 0){
            print("trying to load path \(self.customerSignature.path!)")
            let imgURL:URL = URL(string: self.customerSignature.path!)!
            
            
            let data = try? Data(contentsOf: imgURL) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            self.signatureImageView!.image = UIImage(data: data!)
            
        }
        
    
        if itemsArray.count == 0{
            newContractMessage()
        }
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150, "halfWidth": layoutVars.halfWidth] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "stackController":self.stackController,
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "itemsLbl":self.itemsLbl,
            "table":self.itemsTableView,
            "signBtn":self.signBtn,
            "signature":self.signatureImageContainerView,
            "tapBtn":self.tapBtn,
            "totalLbl":self.totalLbl,
            "taxLbl":self.taxLbl
            ] as [String:AnyObject]
        
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackController]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(40)]-[customerBtn]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[info]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[itemsLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[table]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        if(self.contract.customerSignature == "1"){
           
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[signature(halfWidth)]-[totalLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(halfWidth)]-[totalLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tapBtn(halfWidth)]-[taxLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
            
            signBtn.isHidden = true
        }else{
            
             safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[signBtn(halfWidth)]-[totalLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[signBtn(halfWidth)]-[taxLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            signBtn.isHidden = false
            tapBtn.isHidden = true
            
        }
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(160)]-[itemsLbl(22)][table]-[signBtn(40)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        if(self.contract.customerSignature == "1"){
            
            //print("v constraint for signature")
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(160)]-[itemsLbl(22)][table]-[signature(40)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(160)]-[itemsLbl(22)][table]-[tapBtn(40)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(160)]-[itemsLbl(22)][table][totalLbl(35)][taxLbl(10)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        
        //auto layout group
        let infoDictionary = [
            "titleLbl":self.titleLbl,
            "title":self.titleValue,
            "chargeTypeLbl":self.chargeTypeLbl,
            "chargeType":self.chargeType,
            "salesRepLbl":self.salesRepLbl,
            "salesRep":self.salesRep,
            "notesLbl":self.notesLbl,
            "notes":self.notesView
            ] as [String:AnyObject]
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl(85)][title]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeLbl(80)][chargeType]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[salesRepLbl(80)]-[salesRep]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
       
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllTop, metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notes]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)][chargeTypeLbl(22)][salesRepLbl(22)][notesLbl(22)][notes]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title(22)][chargeType(22)][salesRep(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
       
    }
    
    func newContractMessage(){
        //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Add Items", _message: "You should add items to this contract.")
        
        
        let alertController = UIAlertController(title: "Add Items?", message: "This contract has no items.  Add items now?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Not Now", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
            return
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
        
            self.addItem()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func showCustInfo() {
        ////print("SHOW CUST INFO")
        let customerViewController = CustomerViewController(_customerID: self.contract.customer,_customerName: self.contract.customerName)
        navigationController?.pushViewController(customerViewController, animated: false )
    }
    
    func removeViews(){
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
            myImageView.image = UIImage(named:"unDoneStatus.png")
            break
        case 1:
            myImageView.image = UIImage(named:"inProgressStatus.png")
            break
        case 2:
            myImageView.image = UIImage(named:"acceptedStatus.png")
            break
        case 3:
            myImageView.image = UIImage(named:"doneStatus.png")
            break
        case 4:
            myImageView.image = UIImage(named:"cancelStatus.png")
            break
        case 5:
            myImageView.image = UIImage(named:"waitingStatus.png")
            break
        case 6:
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
        editsMade = true
    }
    
    @objc func cancelPicker(){
        self.statusTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        self.statusTxtField.resignFirstResponder()
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            self.contract.status = "\(self.statusPicker.selectedRow(inComponent: 0))"
            self.updateContract(_contract: self.contract)
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        if tableView.isEditing{
            count = self.itemsArray.count
        }else{
            count = self.itemsArray.count + 1
        }
        
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:ContractItemTableViewCell = itemsTableView.dequeueReusableCell(withIdentifier: "cell") as! ContractItemTableViewCell
        
            if(indexPath.row == self.itemsArray.count){
                //cell add btn mode
                cell.layoutAddBtn()
            }else{
                cell.contractItem = self.itemsArray[indexPath.row]
                cell.layoutViews()
                cell.contractItem.tasks = self.itemsArray[indexPath.row].tasks
            }
        
       
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == self.itemsArray.count){
            tableView.deselectRow(at: indexPath, animated: false)
            self.addItem()
        }else{
            
            // load item view
            //tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            
            
            let indexPath = tableView.indexPathForSelectedRow;
            let currentCell = tableView.cellForRow(at: indexPath!) as! ContractItemTableViewCell;
            if(currentCell.contractItem != nil && currentCell.contractItem.ID != ""){
                self.contractItemViewController = ContractItemViewController(_contract: self.contract, _contractItem: currentCell.contractItem)
                if self.contract.lead != nil{
                    self.contractItemViewController?.lead = self.contract.lead

                }
                self.contractItemViewController?.leadDelegate = self
                self.contractItemViewController?.leadTasksWaiting = self.leadTasksWaiting
                
                self.contractItemViewController!.contractDelegate = self
               
                self.contractItemViewController?.layoutViews()
                
               self.itemRowToEdit = indexPath!.row
                
                navigationController?.pushViewController(self.contractItemViewController!, animated: false )
                tableView.deselectRow(at: indexPath!, animated: true)
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.row != itemsArray.count){
            return true
        }else{
            return false
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit tapped")
            self.editItem(_row:indexPath.row)
            
        }
        edit.backgroundColor = UIColor.gray
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete tapped")
            self.deleteItem(_row: indexPath.row)
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, edit]
    }
    
    //reorder cells
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //let indexPath = tableView.indexPathForSelectedRow;
       // let currentCell = tableView.cellForRow(at: indexPath!) as! ContractItemTableViewCell;
        
        let ID = self.itemsArray[sourceIndexPath.row].ID!
        self.itemIDArray.remove(at: sourceIndexPath.row)
        self.itemIDArray.insert(ID, at: destinationIndexPath.row)
        
        let item:ContractItem = self.itemsArray[sourceIndexPath.row]
        self.itemsArray.remove(at: sourceIndexPath.row)
        self.itemsArray.insert(item, at: destinationIndexPath.row)
        
        
        sortEditsMade = true
    }
    
    
    
    
    
    
    func deleteItem(_row:Int){
        print("delete item")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            let alertController = UIAlertController(title: "Delete Item?", message: "Are you sure you want to delete this contract item?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                
                var shouldRefreshTerms:Bool = false
            
            
                var parameters:[String:String]
                parameters = [
                    "contractItemID":self.itemsArray[_row].ID,
                    "contractID":self.contract.ID
                ]
                print("parameters = \(parameters)")
                
                
                
                
                
                
                
                
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/contractItem.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("delete response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        if let json = response.result.value {
                            print("JSON: \(json)")
                            self.json = JSON(json)
                            //self.parseJSON()
                            
                            
                            let subTotal = self.json["subTotal"]
                            print("subTotal: \(subTotal)")
                            
                            let taxTotal = self.json["taxTotal"]
                            print("taxTotal: \(taxTotal)")
                            
                            let total = self.json["total"]
                            print("total: \(total)")
                            
                            
                            
                            self.contract.subTotal = subTotal.stringValue
                            self.contract.taxTotal = taxTotal.stringValue
                            self.contract.total = total.stringValue
                            
                            if self.json["shouldRefreshTerms"].stringValue == "1"{
                                shouldRefreshTerms = true
                            }
                            
                            
                            
                            if shouldRefreshTerms == true{
                                print("refresh terms")
                                let alertController2 = UIAlertController(title: "Regenerate Contract Terms", message: "This item had contract terms, would you like to regenerate the contract terms now based on current items?  All custom edits to terms will be overwritten.", preferredStyle: UIAlertController.Style.alert)
                                let cancelAction2 = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                                    (result : UIAlertAction) -> Void in
                                    print("No")
                                    
                                    self.itemsArray.remove(at: _row)
                                    
                                    
                                    self.updateContract(_contract: self.contract)
                                    
                                    
                                    return
                                }
                                
                                let okAction2 = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                                    (result : UIAlertAction) -> Void in
                                    print("Yes")
                                    
                                    print("re generate contract terms")
                                    
                                    
                                    
                                    var parameters:[String:String]
                                    parameters = [
                                        "contractID":self.contract.ID,
                                        "refresh":"1"
                                        
                                        
                                    ]
                                    
                                    print("parameters = \(parameters)")
                                    
                                    
                                    
                                    self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contractTerms.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                                        response in
                                        print(response.request ?? "")  // original URL request
                                        //print(response.response ?? "") // URL response
                                        //print(response.data ?? "")     // server data
                                        print(response.result)   // result of response serialization
                                        
                                        
                                        
                                       
                                        }.responseJSON(){
                                            response in
                                            if let json = response.result.value {
                                                print("JSON: \(json)")
                                                self.json = JSON(json)
                                                let newTerms = self.json["newTerms"].stringValue
                                                self.contract.terms = newTerms
                                                
                                                
                                                
                                                
                                                self.itemsArray.remove(at: _row)
                                                
                                                
                                                self.updateContract(_contract: self.contract)
                                                
                                                
                                            }
                                            print(" dismissIndicator")
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                
                                
                                alertController2.addAction(cancelAction2)
                                alertController2.addAction(okAction2)
                                self.layoutVars.getTopController().present(alertController2, animated: true, completion: nil)
                                
                                
                                
                            }else{
                                self.itemsArray.remove(at: _row)
                                self.updateContract(_contract: self.contract)
                            }
                            
                            
                            
                            
                        }
     
                
                       
                }
                
                
                
                
                
                }
            
            
            
            
            
            
            
            
            
            
            
            
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
     
        }
        
        
    }
    
    
    
    func editItem(_row:Int){
        print("edit item")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            if self.contract.status == "1" || self.contract.status == "2" || self.contract.status == "3" || self.contract.status == "4"{
                let alertController = UIAlertController(title: "Edit Item?", message: "The customer may have already seen this contract. Are you sure you want to edit this item?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("Cancel")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                    self.displayEditItemView(_row:_row)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }else{
               displayEditItemView(_row:_row)
            }
            
        }
    }
    
    func displayEditItemView(_row:Int){
        
        self.itemRowToEdit = _row
        
        //let newEditContractItemViewController:NewEditContractItemViewController = NewEditContractItemViewController(_contract:self.contract,_itemID:self.itemsArray[_row].ID,_itemName:self.itemsArray[_row].name,_itemType:self.itemsArray[_row].type,_est:self.itemsArray[_row].qty,_price:self.itemsArray[_row].price,_originalID:self.itemsArray[_row].itemID,_hideUnits:self.itemsArray[_row].hideUnits)
        let contractItem:ContractItem = ContractItem(_ID: self.itemsArray[_row].ID, _chargeType: self.itemsArray[_row].chargeType, _contractID: self.contract.ID, _itemID: self.itemsArray[_row].itemID, _name: self.itemsArray[_row].name, _price: self.itemsArray[_row].price, _qty: self.itemsArray[_row].qty, _total: self.itemsArray[_row].total, _type: self.itemsArray[_row].type, _taxCode: self.itemsArray[_row].taxCode, _subcontractor: self.itemsArray[_row].subcontractor, _hideUnits: self.itemsArray[_row].hideUnits)
        
        let newEditContractItemViewController:NewEditContractItemViewController = NewEditContractItemViewController(_contract: self.contract, _contractItem: contractItem)
        newEditContractItemViewController.delegate = self
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        newEditContractItemViewController.loadLinkList(_linkType: "items", _loadScript: API.Router.itemList(["cb":timeStamp as AnyObject]))
        self.navigationController?.pushViewController(newEditContractItemViewController, animated: false )
    }
    
    
    func addItem(){
        print("add item")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            if self.contract.status == "1" || self.contract.status == "2" || self.contract.status == "3" || self.contract.status == "4"{
                let alertController = UIAlertController(title: "Add Item?", message: "The customer may have already seen this contract. Are you sure you want to add an item?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("Cancel")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                    self.displayAddItemView()
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }else{
                displayAddItemView()
            }
            
            
            
            
            
            
            
        }
        
    }
    
    func displayAddItemView(){
        let newEditContractItemViewController:NewEditContractItemViewController = NewEditContractItemViewController(_contract: self.contract,_itemCount:self.itemsArray.count)
        
        newEditContractItemViewController.delegate = self
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        newEditContractItemViewController.loadLinkList(_linkType: "items", _loadScript: API.Router.itemList(["cb":timeStamp as AnyObject]))
        self.navigationController?.pushViewController(newEditContractItemViewController, animated: false )
        
    }
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @objc func displayContractOptions(){
        print("display Options")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
        
            let actionSheet = UIAlertController(title: "Contract Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Edit Contract", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("display Edit View")
                self.displayEditView()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Edit Terms", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("display Edit View")
                self.displayTermsView()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Sort Items", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("Sort Items")
                self.sortItems()
            }))
            
            
            actionSheet.addAction(UIAlertAction(title: "Send Contract", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("Send Contract")
                
                self.sendContract()


            
            }))
            
            
            
            
            actionSheet.addAction(UIAlertAction(title: "Schedule Contract", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("schedule contract")
                
                //turn contract into workorder
                    //link contract to work order
                
                //open workorder in edit view
                    //confirm title
                    //add schedule parameters
                    //select dept and crew
                
                self.scheduleContract()
                
                
            }))
            
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                //self.present(actionSheet, animated: true, completion: nil)
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController as UIPopoverPresentationController?
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                //self.present(nav, animated: true, completion: nil)
                layoutVars.getTopController().present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                //self.present(actionSheet, animated: true, completion: nil)
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
        }
        
        
    }
    
    func displayEditView(){
        let editContractViewController = NewEditContractViewController(_contract:self.contract)
        editContractViewController.editDelegate = self
        self.navigationController?.pushViewController(editContractViewController, animated: false )
    }
    
    
    @objc func displayTermsView(){
        print("terms")
        let termsViewController:TermsViewController = TermsViewController(_terms: self.contract.terms, _contractID: self.contract.ID)
        termsViewController.delegate = self
        navigationController?.pushViewController(termsViewController, animated: false )
    }
    
    func sortItems(){
        print("sort items")
        
        itemsTableView.isEditing = !itemsTableView.isEditing
        
        optionsButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ContractViewController.saveSort))
        navigationItem.rightBarButtonItem = optionsButton
        self.itemsTableView.reloadData()
        
    }
    
    @objc func saveSort(_leave:Bool = false){
        print("save sort")
        
        
        itemsTableView.isEditing = !itemsTableView.isEditing
        optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(ContractViewController.displayContractOptions))
        navigationItem.rightBarButtonItem = optionsButton
        
        if sortEditsMade{
            
        
            indicator = SDevIndicator.generate(self.view)!
            
            
            
            
            
            let parameters = [
                "dataBase":"projects",
                "table": "contractItems",
                "IDs": NSArray(array: self.itemIDArray)
                ] as [String : Any]
            
            
            
            
            print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/itemSort.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("response = \(response)")
                }
                .responseJSON(){
                    response in
                    self.sortEditsMade = false
                    
                    if _leave{
                        self.indicator.dismissIndicator()
                        _ = self.navigationController?.popViewController(animated: false)
                    }else{
                        self.getContract()
                    }
                    
                    
         
                    
            }
        }
        
        //self.itemsTableView.reloadData()
        
    }
    
    func updateTerms(_terms:String){
        print("update terms with: \(_terms)")
        self.contract.terms = _terms
        //self.updateContract(_contract: self.contract)
        
    }
    
    
    
    @objc func sendContract(){
        
        let emailViewController:EmailViewController = EmailViewController(_customerID: self.contract.customer, _customerName: self.contract.customerName, _type: "2", _docID: self.contract.ID)
        emailViewController.contractDelegate = self
        navigationController?.pushViewController(emailViewController, animated: false )
    
    }
    
    
    
    
    
    
    //sends request for lead tasks
    func scheduleContract() {
        print(" scheduleContract \(self.contract.ID!)")
        
        
        if self.contract.status == "3"{
            
            
            let alertController = UIAlertController(title: "Contract Already Scheduled", message: "This contract has already been scheduled.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                
               return
                    
                    
                }
            
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true)
            }
        
            
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        //self.itemsArray = []
        let parameters:[String:String]
        parameters = ["contractID": self.contract.ID,"createdBy":self.appDelegate.loggedInEmployee?.ID, "notes":self.contract.notes] as! [String : String]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/new/workOrder.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("contract response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    let newWoID = JSON(json)["newWoID"].stringValue
                    
                    
                    
                    if self.contract.status == "0" || self.contract.status == "1" || self.contract.status == "2" || self.contract.status == "4" || self.contract.status == "5" || self.contract.status == "6"{
                        self.indicator.dismissIndicator()
                        
                        let alertController = UIAlertController(title: "Update Contract Status?", message: "Do you want to set the contract to SCHEDULED?", preferredStyle: UIAlertController.Style.alert)
                        let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                            (result : UIAlertAction) -> Void in
                            
                            
                            self.goToNewWorkOrder(_newWoID:newWoID)
                        
                        }
                        let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            
                            self.indicator = SDevIndicator.generate(self.view)!
                            
                            var parameters:[String:String]
                            parameters = [
                                "contractID":self.contract.ID,
                                "statusID":"3"
                            ]
                            
                            self.contract.status = "3"
                            self.setStatus(status: "3")
                            print("parameters = \(parameters)")
                            
                            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/changeContractStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                                response in
                                print(response.request ?? "")  // original URL request
                                print(response.result)   // result of response serialization
                                
                                
                                
                                self.indicator.dismissIndicator()
                                
                                self.goToNewWorkOrder(_newWoID:newWoID)
                                
                                
                            }
                            
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.layoutVars.getTopController().present(alertController, animated: true)
                    }else{
                        self.goToNewWorkOrder(_newWoID:newWoID)
                    }
                    
                    
                    
                
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    
    
    
    
    func goToNewWorkOrder(_newWoID:String){
        print("goToNewWorkOrder ID = \(_newWoID)")
        
        
        
        
        
        let alertController = UIAlertController(title: "Finish Setting Up New Work Order?", message: "Do you want to go to the new work order to add and edit its fields?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
            self.getContract()
            
            return
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
            
            
            
            let wo:WorkOrder = WorkOrder(_ID: _newWoID, _statusID: "1", _date: "", _firstItem: "", _statusName: "", _customer: self.contract.customer, _type: "", _progress: "", _totalPrice: "", _totalCost: "", _totalPriceRaw: "", _totalCostRaw: "", _charge: self.contract.chargeType, _title: self.contract.title, _customerName: self.contract.customerName)
            
            wo.rep = self.contract.salesRep
            wo.repName = self.contract.repName
            wo.notes = self.contract.notes
            
            
            let newEditWorkOrderViewController = NewEditWoViewController(_contract: self.contract, _wo: wo)
            
            newEditWorkOrderViewController.editContractDelegate = self
            //newEditWorkOrderViewController.editDelegate = self
            self.navigationController?.pushViewController(newEditWorkOrderViewController, animated: false )
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    // This triggers the textFieldDidEndEditing method that has the textField within it.
    //  This then triggers the resign() method to remove the keyboard.
    //  We use this in the "done" button action.
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    
    func setStatus(status: String) {
        print("set status \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"acceptedStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "4":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        case "5":
            let statusImg = UIImage(named:"waitingStatus.png")
            statusIcon.image = statusImg
            break;
        case "6":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        default:
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    
   
    
    
    
    
    
    @objc func showSignatureOptions(){
        
        print("showSignatureOptions")
        
        let actionSheet = UIAlertController(title: "Signature Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.view.backgroundColor = UIColor.white
        actionSheet.view.layer.cornerRadius = 5;
        
        actionSheet.addAction(UIAlertAction(title: "Delete Signature", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.deleteSignature()
        }))
        
        
        
        actionSheet.addAction(UIAlertAction(title: "Change Signature", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.sign()
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
            let popover = nav.popoverPresentationController as UIPopoverPresentationController?
            actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
            
            self.present(nav, animated: true, completion: nil)
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
    
    @objc func deleteSignature(){
        
        print("delete signature")
       // print("contract status = \(self.contract.status)")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
        
            let alertController = UIAlertController(title: "Delete Signature?", message: "Are you sure you want to delete this signature?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                
               
            
            
                var parameters:[String:String]
                parameters = [
                    "contractID":self.contract.ID,
                    "customerID":self.contract.customer
                ]
                print("parameters = \(parameters)")
                
                print("remove signature from array")
            
                
                self.contract.customerSignature = "0"
                
                
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/signature.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    print(response.request ?? "")  // original URL request
                    print(response.result)   // result of response serialization
                    
                    
                    if self.contract.status == "0"  || self.contract.status == "1" || self.contract.status == "2"{
                        //status already set to NEW or SENT
                        
                        self.getContract()
                    }else{
                        let alertController = UIAlertController(title: "Update Contract Status?", message: "Do you want to set the contract back to NEW?", preferredStyle: UIAlertController.Style.alert)
                        let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                            (result : UIAlertAction) -> Void in
                            
                            self.getContract()
                        }
                        let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            
                            
                            var parameters:[String:String]
                            parameters = [
                                "contractID":self.contract.ID,
                                "statusID":"0"
                            ]
                            
                            self.contract.status = "0"
                            self.setStatus(status: "0")
                            print("parameters = \(parameters)")
                            
                            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/changeContractStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                                response in
                                print(response.request ?? "")  // original URL request
                                print(response.result)   // result of response serialization
                                
                                
                            
                                self.editsMade = true
                                self.getContract()
                                
                            }
                            
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.layoutVars.getTopController().present(alertController, animated: true)
                    }
                    
                    
                    
                    
                    }.responseString() {
                        response in
                        print(response)  // original URL request
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    @objc func sign(){
        
        print("sign")
        
        if self.contract.salesRep == "" || self.contract.salesRep == "0"{
            handleNoSalesRep()
        }else{
            let signatureViewController:SignatureViewController = SignatureViewController(_contract: self.contract)
            signatureViewController.delegate = self
            navigationController?.pushViewController(signatureViewController, animated: false )
            
        }
        
        
        
    }
    
    
    func handleNoSalesRep(){
        print("check for sales rep")
        //if self.contract.salesRep == "" || self.contract.salesRep == "0"{
            
            
            let alertController = UIAlertController(title: "No Sales Rep Assigned", message: "Please link a sales rep to this contract", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //YES  go to signature page
                
               self.displayEditView()
                //return and get contract
                
            }
            
            
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true)
            
            
       
    }
    
   
    
    
    
    
    func suggestStatusChange(_emailCount:Int) {
        print("suggestStatusChange")
        
        var messageString:String = "Email Sent"
        if _emailCount > 1{
            messageString = "Emails Sent"
        }
        if self.contract.status == "0" {
            
            
            
            let alertController = UIAlertController(title: messageString, message:  "Set contract status to SENT?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                
                //self.getContract()
                
                
                
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                
                var parameters:[String:String]
                parameters = [
                    "contractID":self.contract.ID,
                    "statusID":"1"
                ]
                
                self.contract.status = "1"
                self.setStatus(status: "1")
                print("parameters = \(parameters)")
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/changeContractStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    print(response.request ?? "")  // original URL request
                    print(response.result)   // result of response serialization
                    
                    
                    
                    self.layoutVars.playSaveSound()
                    
                }
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true)
            
            
            
            //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Email Sent", _message: "")
            
        }else{
            
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: messageString, _message: "")
            
        }
        
    }
    
    
    func updateContract(_contract: Contract){
        print("update Contract")
        editsMade = true
        self.contract = _contract
        
        
        
        var parameters:[String:String]
        parameters = [
            "contractID":self.contract.ID,
            "createdBy":self.contract.createdBy,
            "customer":self.contract.customer,
            "salesRep":self.contract.salesRep,
        
            "chargeType":self.contract.chargeType,
            "status":self.contract.status,
            "total":self.contract.total,
            "notes":self.contract.notes,
            "repName":self.contract.repName,
            "customerName":self.contract.customerName,
            "title":self.contract.title,
            "companySigned":self.contract.repSignature,
            "customerSigned":self.contract.customerSignature
            
        ]
        
        print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            
            
            //self.checkForSalesRep()
            self.getContract()
            
            
        }
    
    }
    
    func updateContract(_contractItem: ContractItem){
        print("updateContract Item")
        //self.itemsArray[itemRowToEdit!] = _contractItem
        self.getContract()
    }
    
    
    
    
    func updateContract(_contract: Contract, _status:String){
        print("update Contract")
        editsMade = true
        self.contract = _contract
        
        
        
        var parameters:[String:String]
        parameters = [
            "contractID":self.contract.ID,
            "createdBy":self.contract.createdBy,
            "customer":self.contract.customer,
            "salesRep":self.contract.salesRep,
            
            "chargeType":self.contract.chargeType,
            "status":self.contract.status,
            "total":self.contract.total,
            "notes":self.contract.notes,
            "repName":self.contract.repName,
            "customerName":self.contract.customerName,
            "title":self.contract.title,
            "companySigned":self.contract.repSignature,
            "customerSigned":self.contract.customerSignature,
            
            
        ]
        
        print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            
            //self.checkForEmployeeSignature()
            self.getContract()
            
            
        }
        
        setStatus(status: _status)
    
    }
    
  
    
    //lead Delegate
    func updateLead(_lead:Lead,_newStatusValue:String){
        self.contract.lead = _lead
        
        if self.editLeadDelegate != nil{
            self.editLeadDelegate.updateLead(_lead: self.contract.lead!, _newStatusValue: (self.contract.lead?.statusId)!)
        }
        
        
        
    }
    
    
    
    //Stack Delegates
    func displayAlert(_title: String) {
        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: _title, _message: "")
    }
    
    
    
    func newLeadView(_lead:Lead){
        
        let leadViewController:LeadViewController = LeadViewController(_lead: _lead)
        //leadViewController
        self.navigationController?.pushViewController(leadViewController, animated: false )
        
    }
    
    
    func newContractView(_contract:Contract){
        
        
    }
    
    func newWorkOrderView(_workOrder:WorkOrder){
        
        let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrderID: _workOrder.ID)
        workOrderViewController.editLeadDelegate = self
        self.navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
    }
    
    func newInvoiceView(_invoice:Invoice){
        
        let invoiceViewController:InvoiceViewController = InvoiceViewController(_invoice: _invoice)
        self.navigationController?.pushViewController(invoiceViewController, animated: false )
        
        //self.navigationController?.pushViewController(_view, animated: false )
        
    }
    
    
    
    
    func setLeadTasksWaiting(_leadTasksWaiting:String){
        self.leadTasksWaiting = _leadTasksWaiting
    }
    
    
    
    
    func suggestNewWorkOrderFromContract(){
        print("suggestNewWorkOrderFromContract")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            let alertController = UIAlertController(title: "No Work Order Exists", message: "Would you like to link a new WorkOrder now?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                //_ = self.navigationController?.popViewController(animated: true)
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                self.scheduleContract()
                
                
                
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
        }
        
        
    }
    
    //following 2 mwethods not used in this vc
    func suggestNewContractFromLead(){
        print("suggestNewContractFromLead")
    }
    
    func suggestNewWorkOrderFromLead(){
        print("suggestNewWorkOrderFromLead")
    }
    
    
    
   
    
    @objc func goBack(){
        
        if sortEditsMade == true{
            print("sortEditsMade = true")
            let alertController = UIAlertController(title: "Sort Change", message: "Leave without saving?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Don't Save", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
                //_ = self.navigationController?.popViewController(animated: true)
                //return
            }
            
            let okAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                self.saveSort(_leave:true)
                // _ = self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
        
        
        
        if(editsMade == true){
            if delegate != nil{
                delegate.getContracts(_openNewContract: false)
            }
            if editLeadDelegate != nil{
                editLeadDelegate.updateLead(_lead: self.contract.lead!, _newStatusValue: (self.contract.lead?.statusId!)!)
            }
        }
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    
    
   
}
