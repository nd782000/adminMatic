//
//  NewEditCustomerViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/31/19.
//  Copyright © 2019 Nick. All rights reserved.
//

//  Edited for safeView



import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class NewEditCustomerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate,  UIScrollViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    
    
    
    
    var customerJSON: JSON!
    var customerID:String!
    
    let dateFormatter = DateFormatter()
    
    
    var submitButton:UIBarButtonItem!
    
    //var delegate:CustomerListDelegate?
    var editDelegate:EditCustomerDelegate!
    
    var scrollView:UIScrollView = UIScrollView()
    //Name
    var nameLbl:GreyLabel!
   
   //company switch
    var companyLbl:Label!
    var companySwitch:UISwitch = UISwitch()
    var company:String = "0"
    
    //company
    var companyNameLbl:Label!
    var companyTxtField:PaddedTextField!
    var companyValue:String = ""
    
    //salutation
    var salutationLbl:Label!
    var salutationTxtField:PaddedTextField!
    var salutationPicker:Picker!
    var salutationValue:String = ""
    //fName
    var fNameLbl:Label!
    var fNameTxtField:PaddedTextField!
    var fNameValue:String = ""
    //mi
    var miLbl:Label!
    var miTxtField:PaddedTextField!
    var miValue:String = ""
    //lName
    var lNameLbl:Label!
    var lNameTxtField:PaddedTextField!
    var lNameValue:String = ""
    
    
    //sysName
    var sysNameLbl:Label!
    var sysNameTxtField:PaddedTextField!
    var sysNameValue:String = ""
    
    var originalSysName:String = ""
    var nameChange:String = "0"
    
    //jobsite
    var jobSiteLbl:GreyLabel!
    
    
    //jobAddr
    var jobAddr1Lbl:Label!
    var jobAddr1TxtField:PaddedTextField!
    var jobAddr1Value:String = ""
    
    var jobAddr2Lbl:Label!
    var jobAddr2TxtField:PaddedTextField!
    var jobAddr2Value:String = ""
    
    var jobAddr3Lbl:Label!
    var jobAddr3TxtField:PaddedTextField!
    var jobAddr3Value:String = ""
   
    
    
    var jobAddr4Lbl:Label!
    var jobAddr4TxtField:PaddedTextField!
    var jobAddr4Value:String = ""
    
    var jobTownLbl:Label!
    var jobTownTxtField:PaddedTextField!
    var jobTownValue:String = ""
    
    var jobZipLbl:Label!
    var jobZipTxtField:PaddedTextField!
    var jobZipValue:String = ""
    
    var jobStateLbl:Label!
    var jobStateTxtField:PaddedTextField!
    var jobStatePicker:Picker!
    var jobStateValue:String = ""
    
    var copyBtn:Button!
    
    //billAddr
    var billLbl:GreyLabel!
    
    /*
    var billNameLbl:Label!
    var billNameTxtField:PaddedTextField!
    var billNameValue:String = ""
    */
    
    
    var billAddr1Lbl:Label!
    var billAddr1TxtField:PaddedTextField!
    var billAddr1Value:String = ""
    
    var billAddr2Lbl:Label!
    var billAddr2TxtField:PaddedTextField!
    var billAddr2Value:String = ""
    
    var billAddr3Lbl:Label!
    var billAddr3TxtField:PaddedTextField!
    var billAddr3Value:String = ""
    
    
    var billAddr4Lbl:Label!
    var billAddr4TxtField:PaddedTextField!
    var billAddr4Value:String = ""
    
    
    var billTownLbl:Label!
    var billTownTxtField:PaddedTextField!
    var billTownValue:String = ""
    
    var billZipLbl:Label!
    var billZipTxtField:PaddedTextField!
    var  billZipValue:String = ""
    
    var billStateLbl:Label!
    var billStateTxtField:PaddedTextField!
    var billStatePicker:Picker!
    var billStateValue:String = ""
    
    var referredByDescriptionLbl:GreyLabel!
    var referredByLbl:Label!
    var referredByTxtField:PaddedTextField!
    var referredByPicker:Picker!
    var referredByValue:String = ""
    
    //active switch
    var activeLbl:Label!
    var activeSwitch:UISwitch = UISwitch()
    var active:String = "1"
    
    var submitBtn:Button!
    
   
   
    
    
    var keyBoardShown:Bool = false
    
    var editsMade:Bool = false
    
   
    
    
    //init for new
    init(){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        //for an empty lead to start things off
       // self.customer = Customer(_name: "", _id: "0", _address: "", _contactID: "")
        self.customerID = "0"
    }
    
    //init for edit
    init(_customerID:String){
        super.init(nibName:nil,bundle:nil)
        print("customer init \(_customerID)")
        //for an empty lead to start things off
        //self.customer = _customer
        self.customerID = _customerID
        
        
    }
    

    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(NewEditCustomerViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        if customerID == "0"{
            layoutViews()
            
        }else{
            getCustomerInfo()
        }
        
    }
    
    
    
    
    func getCustomerInfo(){
        title = "Loading..."
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        
        
        
        Alamofire.request(API.Router.customer(["ID":self.customerID as AnyObject])).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            ////print(response.result)   // result of response serialization
            
            
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.customerJSON = JSON(json)
                self.parseCustomerJSON()
                
                
                
                
            }
        }
        
    }
    
    
    
    
    
    func parseCustomerJSON(){
        print("parse customer JSON")
        self.companyValue = self.customerJSON["customer"]["companyName"].stringValue
        
        self.salutationValue = self.customerJSON["customer"]["salutation"].stringValue
        self.fNameValue = self.customerJSON["customer"]["fname"].stringValue
        self.miValue = self.customerJSON["customer"]["mname"].stringValue
        self.lNameValue = self.customerJSON["customer"]["lname"].stringValue
        self.sysNameValue = self.customerJSON["customer"]["name"].stringValue
        self.originalSysName = self.sysNameValue
        self.referredByValue = self.customerJSON["customer"]["hear"].stringValue
        self.active = self.customerJSON["customer"]["active"].stringValue
        
        for i in 0 ..< self.customerJSON["customer"]["contacts"].count{
            if self.customerJSON["customer"]["contacts"][i]["type"].stringValue == "3"{
                //bill address
                //self.billNameValue = self.customerJSON["customer"]["contacts"][i]["name"].stringValue
                self.billAddr1Value = self.customerJSON["customer"]["contacts"][i]["street1"].stringValue
                self.billAddr2Value = self.customerJSON["customer"]["contacts"][i]["street2"].stringValue
                self.billAddr3Value = self.customerJSON["customer"]["contacts"][i]["street3"].stringValue
                self.billAddr4Value = self.customerJSON["customer"]["contacts"][i]["street4"].stringValue
                self.billTownValue = self.customerJSON["customer"]["contacts"][i]["city"].stringValue
                self.billZipValue = self.customerJSON["customer"]["contacts"][i]["zip"].stringValue
                self.billStateValue = self.customerJSON["customer"]["contacts"][i]["state"].stringValue
            }else if self.customerJSON["customer"]["contacts"][i]["type"].stringValue == "4"{
                
                //jobsite address
                self.jobAddr1Value = self.customerJSON["customer"]["contacts"][i]["street1"].stringValue
                self.jobAddr2Value = self.customerJSON["customer"]["contacts"][i]["street2"].stringValue
                self.jobAddr3Value = self.customerJSON["customer"]["contacts"][i]["street3"].stringValue
                self.jobAddr4Value = self.customerJSON["customer"]["contacts"][i]["street4"].stringValue
                self.jobTownValue = self.customerJSON["customer"]["contacts"][i]["city"].stringValue
                self.jobZipValue = self.customerJSON["customer"]["contacts"][i]["zip"].stringValue
                self.jobStateValue = self.customerJSON["customer"]["contacts"][i]["state"].stringValue
            }
            
            
            
        }
        
        
        
        


        // print("parse customerJSON: \(self.customerJSON)")
        
        
        self.layoutViews()
    }
    
    
    func layoutViews(){
        //print("layout views")
        if(self.customerID == "0"){
            title =  "New Customer"
            
           
        }else{
           
            title =  "Edit Customer #" + self.customerID
            
            
            
        }
        
        //print("layout views 1")
        
        submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditCustomerViewController.submit))
        navigationItem.rightBarButtonItem = submitButton
        
      
        
        
        //print("layout views 2")
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        //scrollView.contentSize.height = 1380
        scrollView.contentSize.width = self.layoutVars.fullWidth
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = layoutVars.backgroundColor
        scrollView.isUserInteractionEnabled = true
        
        //print("layout views 3")
        
        view.addSubview(scrollView)
        
       
        
        let textInputToolBar = UIToolbar()
        textInputToolBar.barStyle = UIBarStyle.default
        textInputToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        textInputToolBar.sizeToFit()
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelInput))
        
        textInputToolBar.setItems([closeButton], animated: false)
        textInputToolBar.isUserInteractionEnabled = true
        
        
       
        //name
        
        self.nameLbl = GreyLabel()
        self.nameLbl.text = "Customer Name"
        scrollView.addSubview(nameLbl)
       
        self.companyLbl = Label()
        self.companyLbl.text = "Is this customer a business?"
        
        scrollView.addSubview(companyLbl)
        
        self.companySwitch = UISwitch()
        self.companySwitch.translatesAutoresizingMaskIntoConstraints = false
        
        if self.companyValue != ""{
            companySwitch.isOn = true
        }
        
        self.companySwitch.addTarget(self, action: #selector(self.companySwitchValueDidChange(sender:)), for: .valueChanged)
        scrollView.addSubview(companySwitch)
        
        
        
        //print("layout views 6")
        self.companyNameLbl = Label()
        self.companyNameLbl.text = "Business Name:"
        self.companyNameLbl.textAlignment = .right
        scrollView.addSubview(companyNameLbl)
        
        self.companyTxtField = PaddedTextField()
        self.companyTxtField.text = self.companyValue
        self.companyTxtField.delegate = self
        self.companyTxtField.returnKeyType = .next
        self.companyTxtField.autocapitalizationType = .words
        self.companyTxtField.tag = 0
        self.companyTxtField.inputAccessoryView = textInputToolBar
        self.companyTxtField.autocorrectionType = .no
        scrollView.addSubview(companyTxtField)
        
        
        
        
        
        self.salutationLbl = Label()
        self.salutationLbl.text = "Prefix:"
        self.salutationLbl.textAlignment = .right
        scrollView.addSubview(salutationLbl)
        
        self.salutationPicker = Picker()
        self.salutationPicker.delegate = self
        self.salutationPicker.dataSource = self
        self.salutationPicker.tag = 0
        
        self.salutationTxtField = PaddedTextField()
        self.salutationTxtField.text = self.salutationValue
        self.salutationTxtField.delegate = self
        self.salutationTxtField.returnKeyType = .next
        //self.salutationTxtField.tag = 1
        self.salutationTxtField.inputView = self.salutationPicker
        
        self.salutationTxtField.autocorrectionType = .no
        scrollView.addSubview(salutationTxtField)
        
        let salutationToolBar = UIToolbar()
        salutationToolBar.barStyle = UIBarStyle.default
        salutationToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        salutationToolBar.sizeToFit()
        let closeSalutationButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setSalutationButton = UIBarButtonItem(title: "Set Prefix", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleSalutationChange))
        salutationToolBar.setItems([closeSalutationButton, spaceButton, setSalutationButton], animated: false)
        salutationToolBar.isUserInteractionEnabled = true
        
        self.salutationTxtField.inputAccessoryView = salutationToolBar
        
        
        self.fNameLbl = Label()
        self.fNameLbl.text = "First:"
        self.fNameLbl.textAlignment = .right
        scrollView.addSubview(fNameLbl)
        
        self.fNameTxtField = PaddedTextField()
        self.fNameTxtField.text = self.fNameValue
        self.fNameTxtField.delegate = self
        self.fNameTxtField.returnKeyType = .next
        //self.fNameTxtField.tag = 2
        self.fNameTxtField.inputAccessoryView = textInputToolBar
        self.fNameTxtField.autocorrectionType = .no
        scrollView.addSubview(fNameTxtField)
        
        
        
        self.miLbl = Label()
        self.miLbl.text = "Middle:"
        self.miLbl.textAlignment = .right
        scrollView.addSubview(miLbl)
        
        self.miTxtField = PaddedTextField()
        self.miTxtField.text = self.miValue
        self.miTxtField.delegate = self
        self.miTxtField.returnKeyType = .next
        //self.miTxtField.tag = 3
        self.miTxtField.inputAccessoryView = textInputToolBar
        self.miTxtField.autocorrectionType = .no
        scrollView.addSubview(miTxtField)
        
        self.lNameLbl = Label()
        self.lNameLbl.text = "Last:"
        self.lNameLbl.textAlignment = .right
        scrollView.addSubview(lNameLbl)
        
        self.lNameTxtField = PaddedTextField()
        self.lNameTxtField.text = self.lNameValue
        self.lNameTxtField.delegate = self
        self.lNameTxtField.returnKeyType = .next
        //self.lNameTxtField.tag = 4
        self.lNameTxtField.inputAccessoryView = textInputToolBar
        self.lNameTxtField.autocorrectionType = .no
        scrollView.addSubview(lNameTxtField)
        
        self.sysNameLbl = Label()
        self.sysNameLbl.text = "System Name:"
        self.sysNameLbl.textColor = UIColor.red
        self.sysNameLbl.textAlignment = .right
        scrollView.addSubview(sysNameLbl)
        
        self.sysNameTxtField = PaddedTextField()
        self.sysNameTxtField.text = self.sysNameValue
        self.sysNameTxtField.delegate = self
        self.sysNameTxtField.returnKeyType = .next
        //self.sysNameTxtField.tag = 5
        self.sysNameTxtField.inputAccessoryView = textInputToolBar
        self.sysNameTxtField.autocorrectionType = .no
        scrollView.addSubview(sysNameTxtField)
        
       
        
        //print("layout views 7")
        
    //Job Site
        
        self.jobSiteLbl = GreyLabel()
        self.jobSiteLbl.text = "Job Site Address"
        scrollView.addSubview(jobSiteLbl)
        
        
        self.jobAddr1Lbl = Label()
        self.jobAddr1Lbl.text = "Street 1:"
        self.jobAddr1Lbl.textAlignment = .right
        scrollView.addSubview(jobAddr1Lbl)
        
        self.jobAddr1TxtField = PaddedTextField()
        self.jobAddr1TxtField.text = self.jobAddr1Value
        self.jobAddr1TxtField.delegate = self
        self.jobAddr1TxtField.returnKeyType = .next
        //self.jobAddr1TxtField.tag = 6
        self.jobAddr1TxtField.inputAccessoryView = textInputToolBar
        self.jobAddr1TxtField.autocorrectionType = .no
        scrollView.addSubview(jobAddr1TxtField)
        
        self.jobAddr2Lbl = Label()
        self.jobAddr2Lbl.text = "Street 2:"
        self.jobAddr2Lbl.textAlignment = .right
        scrollView.addSubview(jobAddr2Lbl)
        
        self.jobAddr2TxtField = PaddedTextField()
        self.jobAddr2TxtField.text = self.jobAddr2Value
        self.jobAddr2TxtField.delegate = self
        self.jobAddr2TxtField.returnKeyType = .next
        //self.jobAddr2TxtField.tag = 7
        self.jobAddr2TxtField.inputAccessoryView = textInputToolBar
        self.jobAddr2TxtField.autocorrectionType = .no
        scrollView.addSubview(jobAddr2TxtField)
        
        self.jobAddr3Lbl = Label()
        self.jobAddr3Lbl.text = "Street 3:"
        self.jobAddr3Lbl.textAlignment = .right
        scrollView.addSubview(jobAddr3Lbl)
        
        self.jobAddr3TxtField = PaddedTextField()
        self.jobAddr3TxtField.text = self.jobAddr3Value
        self.jobAddr3TxtField.delegate = self
        self.jobAddr3TxtField.returnKeyType = .next
        //self.jobAddr3TxtField.tag = 8
        self.jobAddr3TxtField.inputAccessoryView = textInputToolBar
        self.jobAddr3TxtField.autocorrectionType = .no
        scrollView.addSubview(jobAddr3TxtField)
        
        self.jobAddr4Lbl = Label()
        self.jobAddr4Lbl.text = "Street 4:"
        self.jobAddr4Lbl.textAlignment = .right
        scrollView.addSubview(jobAddr4Lbl)
        
        self.jobAddr4TxtField = PaddedTextField()
        self.jobAddr4TxtField.text = self.jobAddr4Value
        self.jobAddr4TxtField.delegate = self
        self.jobAddr4TxtField.returnKeyType = .next
        //self.jobAddr4TxtField.tag = 9
        self.jobAddr4TxtField.inputAccessoryView = textInputToolBar
        self.jobAddr4TxtField.autocorrectionType = .no
        scrollView.addSubview(jobAddr4TxtField)
        
        self.jobTownLbl = Label()
        self.jobTownLbl.text = "City:"
        self.jobTownLbl.textAlignment = .right
        scrollView.addSubview(jobTownLbl)
        
        self.jobTownTxtField = PaddedTextField()
        self.jobTownTxtField.text = self.jobTownValue
        self.jobTownTxtField.delegate = self
        self.jobTownTxtField.returnKeyType = .next
       // self.jobTownTxtField.tag = 10
        self.jobTownTxtField.inputAccessoryView = textInputToolBar
        self.jobTownTxtField.autocorrectionType = .no
        scrollView.addSubview(jobTownTxtField)
        
        self.jobStateLbl = Label()
        self.jobStateLbl.text = "State:"
        self.jobStateLbl.textAlignment = .right
        scrollView.addSubview(jobStateLbl)
        
        
        self.jobStatePicker = Picker()
        self.jobStatePicker.delegate = self
        self.jobStatePicker.dataSource = self
        self.jobStatePicker.tag = 1
        
        
        self.jobStateTxtField = PaddedTextField()
        self.jobStateTxtField.text = self.jobStateValue
        self.jobStateTxtField.inputView = self.jobStatePicker
        self.jobStateTxtField.delegate = self
        //self.jobStateTxtField.tag = 11
        scrollView.addSubview(jobStateTxtField)
        
        let jobStateToolBar = UIToolbar()
        jobStateToolBar.barStyle = UIBarStyle.default
        jobStateToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        jobStateToolBar.sizeToFit()
        let closeJobStateButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        let setJobStateButton = UIBarButtonItem(title: "Set State", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleJobStateChange))
        jobStateToolBar.setItems([closeJobStateButton, spaceButton, setJobStateButton], animated: false)
        jobStateToolBar.isUserInteractionEnabled = true
        jobStateTxtField.inputAccessoryView = jobStateToolBar
        
        
        
        self.jobZipLbl = Label()
        self.jobZipLbl.text = "Zip:"
        self.jobZipLbl.textAlignment = .right
        scrollView.addSubview(jobZipLbl)
        
        
        self.jobZipTxtField = PaddedTextField()
        self.jobZipTxtField.text = self.jobZipValue
        self.jobZipTxtField.delegate = self
        self.jobZipTxtField.returnKeyType = .next
        //self.jobZipTxtField.tag = 12
        self.jobZipTxtField.inputAccessoryView = textInputToolBar
        self.jobZipTxtField.autocorrectionType = .no
        scrollView.addSubview(jobZipTxtField)
        
        
        
        
        
         
         
         
        //print("layout views 8")
        self.copyBtn = Button(titleText: "Copy from Job Site")
        self.copyBtn.addTarget(self, action: #selector(self.copyToBilling), for: .touchUpInside)
        scrollView.addSubview(copyBtn)
        
        
        //Billing
        
        self.billLbl = GreyLabel()
        self.billLbl.text = "Billing Address"
        scrollView.addSubview(billLbl)
        
        
        /*
        self.billNameLbl = Label()
        self.billNameLbl.text = "Billing Name:"
        scrollView.addSubview(billNameLbl)
        
       
        
        self.billNameTxtField = PaddedTextField()
        self.billNameTxtField.text = self.billNameValue
        self.billNameTxtField.delegate = self
        self.billNameTxtField.returnKeyType = .next
        //self.billNameTxtField.tag = 13
        self.billNameTxtField.autocapitalizationType = .words
        self.billNameTxtField.inputAccessoryView = textInputToolBar
        self.billNameTxtField.autocorrectionType = .no
        scrollView.addSubview(billNameTxtField)
        */
        
        
        self.billAddr1Lbl = Label()
        self.billAddr1Lbl.text = "Street 1:"
        scrollView.addSubview(billAddr1Lbl)
        
        self.billAddr1TxtField = PaddedTextField()
        self.billAddr1TxtField.text = self.billAddr1Value
        self.billAddr1TxtField.delegate = self
        self.billAddr1TxtField.returnKeyType = .next
        //self.billAddr1TxtField.tag = 14
        self.billAddr1TxtField.inputAccessoryView = textInputToolBar
        self.billAddr1TxtField.autocorrectionType = .no
        scrollView.addSubview(billAddr1TxtField)
        
        self.billAddr2Lbl = Label()
        self.billAddr2Lbl.text = "Street 2:"
        scrollView.addSubview(billAddr2Lbl)
        
        self.billAddr2TxtField = PaddedTextField()
        self.billAddr2TxtField.text = self.billAddr2Value
        self.billAddr2TxtField.delegate = self
        self.billAddr2TxtField.returnKeyType = .next
        //self.billAddr2TxtField.tag = 15
        self.billAddr2TxtField.inputAccessoryView = textInputToolBar
        self.billAddr2TxtField.autocorrectionType = .no
        scrollView.addSubview(billAddr2TxtField)
        
        self.billAddr3Lbl = Label()
        self.billAddr3Lbl.text = "Street 3:"
        scrollView.addSubview(billAddr3Lbl)
        
        self.billAddr3TxtField = PaddedTextField()
        self.billAddr3TxtField.text = self.billAddr3Value
        self.billAddr3TxtField.delegate = self
        self.billAddr3TxtField.returnKeyType = .next
        //self.billAddr3TxtField.tag = 16
        self.billAddr3TxtField.inputAccessoryView = textInputToolBar
        self.billAddr3TxtField.autocorrectionType = .no
        scrollView.addSubview(billAddr3TxtField)
        
        self.billAddr4Lbl = Label()
        self.billAddr4Lbl.text = "Street 4:"
        scrollView.addSubview(billAddr4Lbl)
        
        self.billAddr4TxtField = PaddedTextField()
        self.billAddr4TxtField.text = self.billAddr4Value
        self.billAddr4TxtField.delegate = self
        self.billAddr4TxtField.returnKeyType = .next
        //self.billAddr4TxtField.tag = 17
        self.billAddr4TxtField.inputAccessoryView = textInputToolBar
        self.billAddr4TxtField.autocorrectionType = .no
        scrollView.addSubview(billAddr4TxtField)
        
        self.billTownLbl = Label()
        self.billTownLbl.text = "City:"
        scrollView.addSubview(billTownLbl)
        
        self.billTownTxtField = PaddedTextField()
        self.billTownTxtField.text = self.billTownValue
        self.billTownTxtField.delegate = self
        self.billTownTxtField.returnKeyType = .next
        //self.billTownTxtField.tag = 18
        self.billTownTxtField.inputAccessoryView = textInputToolBar
        self.billTownTxtField.autocorrectionType = .no
        scrollView.addSubview(billTownTxtField)
        
        self.billStateLbl = Label()
        self.billStateLbl.text = "State:"
        scrollView.addSubview(billStateLbl)
        
        
        self.billStatePicker = Picker()
        self.billStatePicker.delegate = self
        self.billStatePicker.dataSource = self
        self.billStatePicker.tag = 2
        
        
        self.billStateTxtField = PaddedTextField()
        self.billStateTxtField.text = self.billStateValue
        self.billStateTxtField.inputView = self.billStatePicker
        self.billStateTxtField.delegate = self
        //self.billStateTxtField.tag = 19
        scrollView.addSubview(billStateTxtField)
        
        let billStateToolBar = UIToolbar()
        billStateToolBar.barStyle = UIBarStyle.default
        billStateToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        billStateToolBar.sizeToFit()
        let closeBillStateButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        let setBillStateButton = UIBarButtonItem(title: "Set State", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleBillStateChange))
        billStateToolBar.setItems([closeBillStateButton, spaceButton, setBillStateButton], animated: false)
        billStateToolBar.isUserInteractionEnabled = true
        billStateTxtField.inputAccessoryView = billStateToolBar
        
        
        
        self.billZipLbl = Label()
        self.billZipLbl.text = "Zip:"
        scrollView.addSubview(billZipLbl)
        
        
        self.billZipTxtField = PaddedTextField()
        self.billZipTxtField.text = self.billZipValue
        self.billZipTxtField.delegate = self
        self.billZipTxtField.returnKeyType = .next
        //self.billZipTxtField.tag = 20
        self.billZipTxtField.inputAccessoryView = textInputToolBar
        self.billZipTxtField.autocorrectionType = .no
        scrollView.addSubview(billZipTxtField)
        
        
        self.referredByDescriptionLbl = GreyLabel()
        self.referredByDescriptionLbl.text = "How did this cutomer hear about us?"
        scrollView.addSubview(referredByDescriptionLbl)
        
        
        self.referredByLbl = Label()
        self.referredByLbl.text = "Referred By:"
        scrollView.addSubview(referredByLbl)
        
        self.referredByPicker = Picker()
        self.referredByPicker.delegate = self
        self.referredByPicker.dataSource = self
        self.referredByPicker.tag = 3
        
        self.referredByTxtField = PaddedTextField()
        if self.referredByValue != ""{
            self.referredByTxtField.text = self.appDelegate.customerHearTypes[Int(self.referredByValue)!]
        }
        
        self.referredByTxtField.delegate = self
        self.referredByTxtField.inputView = self.referredByPicker
       // self.referredByTxtField.tag = 21
        scrollView.addSubview(referredByTxtField)
 
        let referredByToolBar = UIToolbar()
        referredByToolBar.barStyle = UIBarStyle.default
        referredByToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        referredByToolBar.sizeToFit()
        let closeReferredByButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        let setReferredByButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleReferredByChange))
        referredByToolBar.setItems([closeReferredByButton, spaceButton, setReferredByButton], animated: false)
        referredByToolBar.isUserInteractionEnabled = true
        referredByTxtField.inputAccessoryView = referredByToolBar
        
        
        
        self.activeLbl = Label()
        self.activeLbl.text = "Is this customer active?"
        
        scrollView.addSubview(activeLbl)
        
        self.activeSwitch = UISwitch()
        self.activeSwitch.translatesAutoresizingMaskIntoConstraints = false
        if self.active == "1"{
            activeSwitch.isOn = true
        }
        self.activeSwitch.addTarget(self, action: #selector(self.activeSwitchValueDidChange(sender:)), for: .valueChanged)
        scrollView.addSubview(activeSwitch)
        
        
        
        self.submitBtn = Button(titleText: "Submit")
        self.submitBtn.addTarget(self, action: #selector(self.submit), for: .touchUpInside)
        scrollView.addSubview(submitBtn)
        
        //print("layout views 9")
 
  
        
        
        
        
        
        if self.companySwitch.isOn {
            self.constraintsForBusiness()
        }else{
            self.constraintsForResidnce()
        }
       
        
        
       
         
       
       
        
    }
    
    
    func constraintsForBusiness(){
        
        removeAllConstraintsFromView(view: scrollView)
        
        scrollView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        scrollView.contentSize.height = 1230
        
        nameLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        nameLbl.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        nameLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        companySwitch.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        companySwitch.topAnchor.constraint(equalTo: nameLbl.bottomAnchor).isActive = true
        companySwitch.widthAnchor.constraint(equalToConstant: 60).isActive = true
        companySwitch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        companyLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 80).isActive = true
        companyLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor).isActive = true
        companyLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        companyLbl.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60)
        
        
        
        
        self.companyNameLbl.isHidden = false
        self.companyTxtField.isHidden = false
        self.salutationLbl.isHidden = true
        self.salutationTxtField.isHidden = true
        self.fNameLbl.isHidden = true
        self.fNameTxtField.isHidden = true
        self.miLbl.isHidden = true
        self.miTxtField.isHidden = true
        self.lNameLbl.isHidden = true
        self.lNameTxtField.isHidden = true
        
        salutationTxtField.tag = 0
        fNameTxtField.tag = 0
        miTxtField.tag = 0
        lNameTxtField.tag = 0
        
        
        companyTxtField.tag = 1
        sysNameTxtField.tag = 2
            
        jobAddr1TxtField.tag = 3
        jobAddr2TxtField.tag = 4
        jobAddr3TxtField.tag = 5
        jobAddr4TxtField.tag = 6
        jobTownTxtField.tag = 7
        jobStateTxtField.tag = 8
        jobZipTxtField.tag = 9
        //billNameTxtField.tag = 10
        billAddr1TxtField.tag = 10
        billAddr2TxtField.tag = 11
        billAddr3TxtField.tag = 12
        billAddr4TxtField.tag = 13
        billTownTxtField.tag = 14
        billStateTxtField.tag = 15
        billZipTxtField.tag = 16
        referredByTxtField.tag = 17
        
        
        
        companyNameLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        companyNameLbl.topAnchor.constraint(equalTo: companyLbl.bottomAnchor, constant: 10).isActive = true
        companyNameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.companyNameLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.companyTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.companyTxtField.topAnchor.constraint(equalTo: companyLbl.bottomAnchor, constant: 10).isActive = true
        self.companyTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.companyTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        sysNameLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        sysNameLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        sysNameLbl.topAnchor.constraint(equalTo: companyNameLbl.bottomAnchor, constant: 10).isActive = true
        sysNameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.sysNameLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.sysNameTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.sysNameTxtField.topAnchor.constraint(equalTo: companyNameLbl.bottomAnchor, constant: 10).isActive = true
        self.sysNameTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.sysNameTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        self.constraintsForAddresses()
    }
    
    func constraintsForResidnce(){
        
        removeAllConstraintsFromView(view: scrollView)
        
        
        scrollView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        scrollView.contentSize.height = 1380
        
        nameLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        nameLbl.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        nameLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        companySwitch.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        companySwitch.topAnchor.constraint(equalTo: nameLbl.bottomAnchor).isActive = true
        companySwitch.widthAnchor.constraint(equalToConstant: 60).isActive = true
        companySwitch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        companyLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 80).isActive = true
        companyLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor).isActive = true
        companyLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        companyLbl.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60)
        
        
        
        self.companyNameLbl.isHidden = true
        self.companyTxtField.isHidden = true
        self.salutationLbl.isHidden = false
        self.salutationTxtField.isHidden = false
        self.fNameLbl.isHidden = false
        self.fNameTxtField.isHidden = false
        self.miLbl.isHidden = false
        self.miTxtField.isHidden = false
        self.lNameLbl.isHidden = false
        self.lNameTxtField.isHidden = false
        
        salutationTxtField.tag = 1
        fNameTxtField.tag = 2
        miTxtField.tag = 3
        lNameTxtField.tag = 4
        sysNameTxtField.tag = 5
        
        companyTxtField.tag = 0
        jobAddr1TxtField.tag = 6
        jobAddr2TxtField.tag = 7
        jobAddr3TxtField.tag = 8
        jobAddr4TxtField.tag = 9
        jobTownTxtField.tag = 10
        jobStateTxtField.tag = 11
        jobZipTxtField.tag = 12
        //billNameTxtField.tag = 13
        billAddr1TxtField.tag = 13
        billAddr2TxtField.tag = 14
        billAddr3TxtField.tag = 15
        billAddr4TxtField.tag = 16
        billTownTxtField.tag = 17
        billStateTxtField.tag = 18
        billZipTxtField.tag = 29
        referredByTxtField.tag = 20
        
        
        salutationLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        salutationLbl.topAnchor.constraint(equalTo: companyLbl.bottomAnchor, constant: 10).isActive = true
        salutationLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.salutationLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.salutationTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.salutationTxtField.topAnchor.constraint(equalTo: companyLbl.bottomAnchor, constant: 10).isActive = true
        self.salutationTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.salutationTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        
        fNameLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        fNameLbl.topAnchor.constraint(equalTo: salutationLbl.bottomAnchor, constant: 10).isActive = true
        fNameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.fNameLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.fNameTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.fNameTxtField.topAnchor.constraint(equalTo: salutationLbl.bottomAnchor, constant: 10).isActive = true
        self.fNameTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.fNameTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        miLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        miLbl.topAnchor.constraint(equalTo: fNameLbl.bottomAnchor, constant: 10).isActive = true
        miLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.miLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.miTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.miTxtField.topAnchor.constraint(equalTo: fNameLbl.bottomAnchor, constant: 10).isActive = true
        self.miTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.miTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        lNameLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        lNameLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        lNameLbl.topAnchor.constraint(equalTo: miLbl.bottomAnchor, constant: 10).isActive = true
        lNameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lNameLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.lNameTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.lNameTxtField.topAnchor.constraint(equalTo: miLbl.bottomAnchor, constant: 10).isActive = true
        self.lNameTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lNameTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        sysNameLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        sysNameLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        sysNameLbl.topAnchor.constraint(equalTo: lNameLbl.bottomAnchor, constant: 10).isActive = true
        sysNameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.sysNameLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.sysNameTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.sysNameTxtField.topAnchor.constraint(equalTo: lNameLbl.bottomAnchor, constant: 10).isActive = true
        self.sysNameTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.sysNameTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        self.constraintsForAddresses()
    }
    
    func constraintsForAddresses(){
        
        //jobsite
        
        jobSiteLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        jobSiteLbl.topAnchor.constraint(equalTo: sysNameLbl.bottomAnchor, constant: 10).isActive = true
        jobSiteLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        jobSiteLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        jobAddr1Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobAddr1Lbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobAddr1Lbl.topAnchor.constraint(equalTo: jobSiteLbl.bottomAnchor, constant: 10).isActive = true
        jobAddr1Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr1Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobAddr1TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobAddr1TxtField.topAnchor.constraint(equalTo: jobSiteLbl.bottomAnchor, constant: 10).isActive = true
        self.jobAddr1TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr1TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        jobAddr2Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobAddr2Lbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobAddr2Lbl.topAnchor.constraint(equalTo: jobAddr1Lbl.bottomAnchor, constant: 10).isActive = true
        jobAddr2Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr2Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobAddr2TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobAddr2TxtField.topAnchor.constraint(equalTo: jobAddr1Lbl.bottomAnchor, constant: 10).isActive = true
        self.jobAddr2TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr2TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        jobAddr3Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobAddr3Lbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobAddr3Lbl.topAnchor.constraint(equalTo: jobAddr2Lbl.bottomAnchor, constant: 10).isActive = true
        jobAddr3Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr3Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobAddr3TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobAddr3TxtField.topAnchor.constraint(equalTo: jobAddr2Lbl.bottomAnchor, constant: 10).isActive = true
        self.jobAddr3TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr3TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        jobAddr4Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobAddr4Lbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobAddr4Lbl.topAnchor.constraint(equalTo: jobAddr3Lbl.bottomAnchor, constant: 10).isActive = true
        jobAddr4Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr4Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobAddr4TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobAddr4TxtField.topAnchor.constraint(equalTo: jobAddr3Lbl.bottomAnchor, constant: 10).isActive = true
        self.jobAddr4TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobAddr4TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        jobTownLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobTownLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobTownLbl.topAnchor.constraint(equalTo: jobAddr4Lbl.bottomAnchor, constant: 10).isActive = true
        jobTownLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobTownLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobTownTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobTownTxtField.topAnchor.constraint(equalTo: jobAddr4Lbl.bottomAnchor, constant: 10).isActive = true
        self.jobTownTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobTownTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        jobStateLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobStateLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobStateLbl.topAnchor.constraint(equalTo: jobTownLbl.bottomAnchor, constant: 10).isActive = true
        jobStateLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobStateLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobStateTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobStateTxtField.topAnchor.constraint(equalTo: jobTownLbl.bottomAnchor, constant: 10).isActive = true
        self.jobStateTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobStateTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        jobZipLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        jobZipLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        jobZipLbl.topAnchor.constraint(equalTo: jobStateLbl.bottomAnchor, constant: 10).isActive = true
        jobZipLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobZipLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.jobZipTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.jobZipTxtField.topAnchor.constraint(equalTo: jobStateLbl.bottomAnchor, constant: 10).isActive = true
        self.jobZipTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.jobZipTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        //billing address
        
        billLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        self.billLbl.topAnchor.constraint(equalTo: jobZipLbl.bottomAnchor, constant: 10).isActive = true
        billLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        billLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        copyBtn.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        copyBtn.topAnchor.constraint(equalTo: billLbl.bottomAnchor).isActive = true
        copyBtn.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        copyBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        /*
        billNameLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billNameLbl.topAnchor.constraint(equalTo: copyBtn.bottomAnchor, constant: 10).isActive = true
        billNameLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billNameLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billNameTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billNameTxtField.topAnchor.constraint(equalTo: copyBtn.bottomAnchor, constant: 10).isActive = true
        self.billNameTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billNameTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
 
 */
        
        billAddr1Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billAddr1Lbl.topAnchor.constraint(equalTo: copyBtn.bottomAnchor, constant: 10).isActive = true
        billAddr1Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr1Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billAddr1TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billAddr1TxtField.topAnchor.constraint(equalTo: copyBtn.bottomAnchor, constant: 10).isActive = true
        self.billAddr1TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr1TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        billAddr2Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billAddr2Lbl.topAnchor.constraint(equalTo: billAddr1Lbl.bottomAnchor, constant: 10).isActive = true
        billAddr2Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr2Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billAddr2TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billAddr2TxtField.topAnchor.constraint(equalTo: billAddr1Lbl.bottomAnchor, constant: 10).isActive = true
        self.billAddr2TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr2TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        billAddr3Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billAddr3Lbl.topAnchor.constraint(equalTo: billAddr2Lbl.bottomAnchor, constant: 10).isActive = true
        billAddr3Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr3Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billAddr3TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billAddr3TxtField.topAnchor.constraint(equalTo: billAddr2Lbl.bottomAnchor, constant: 10).isActive = true
        self.billAddr3TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr3TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        billAddr4Lbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billAddr4Lbl.topAnchor.constraint(equalTo: billAddr3Lbl.bottomAnchor, constant: 10).isActive = true
        billAddr4Lbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr4Lbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billAddr4TxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billAddr4TxtField.topAnchor.constraint(equalTo: billAddr3Lbl.bottomAnchor, constant: 10).isActive = true
        self.billAddr4TxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billAddr4TxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        billTownLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billTownLbl.topAnchor.constraint(equalTo: billAddr4Lbl.bottomAnchor, constant: 10).isActive = true
        billTownLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billTownLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billTownTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billTownTxtField.topAnchor.constraint(equalTo: billAddr4Lbl.bottomAnchor, constant: 10).isActive = true
        self.billTownTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billTownTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        billStateLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billStateLbl.topAnchor.constraint(equalTo: billTownLbl.bottomAnchor, constant: 10).isActive = true
        billStateLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billStateLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billStateTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billStateTxtField.topAnchor.constraint(equalTo: billTownLbl.bottomAnchor, constant: 10).isActive = true
        self.billStateTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billStateTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        billZipLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        billZipLbl.topAnchor.constraint(equalTo: billStateLbl.bottomAnchor, constant: 10).isActive = true
        billZipLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billZipLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.billZipTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.billZipTxtField.topAnchor.constraint(equalTo: billStateLbl.bottomAnchor, constant: 10).isActive = true
        self.billZipTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.billZipTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        
        //Referred By
        
        referredByDescriptionLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        self.referredByDescriptionLbl.topAnchor.constraint(equalTo: billZipLbl.bottomAnchor, constant: 10).isActive = true
        referredByDescriptionLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        referredByDescriptionLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        
        referredByLbl.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 135).isActive = true
        referredByLbl.topAnchor.constraint(equalTo: referredByDescriptionLbl.bottomAnchor, constant: 10).isActive = true
        referredByLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.referredByLbl.widthAnchor.constraint(equalToConstant: 125)
        
        
        self.referredByTxtField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 140).isActive = true
        self.referredByTxtField.topAnchor.constraint(equalTo: referredByDescriptionLbl.bottomAnchor, constant: 10).isActive = true
        self.referredByTxtField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.referredByTxtField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 160).isActive = true
        
        activeSwitch.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        activeSwitch.topAnchor.constraint(equalTo: referredByLbl.bottomAnchor, constant: 10).isActive = true
        activeSwitch.widthAnchor.constraint(equalToConstant: 60).isActive = true
        activeSwitch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        activeLbl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 80).isActive = true
        activeLbl.topAnchor.constraint(equalTo: referredByLbl.bottomAnchor, constant: 10).isActive = true
        activeLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        activeLbl.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60)
        
        submitBtn.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        submitBtn.topAnchor.constraint(equalTo: activeLbl.bottomAnchor, constant: 10).isActive = true
        submitBtn.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        submitBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
    }
    
    func removeAllConstraintsFromView(view: UIScrollView) { for c in view.constraints { view.removeConstraint(c)
        
        }
        
    }
    
    @objc func copyToBilling(){
        //print("copyToBilling")
        /*
        billAddr1TxtField.text = jobAddr1TxtField.text
        billAddr2TxtField.text = jobAddr2TxtField.text
        billAddr3TxtField.text = jobAddr3TxtField.text
        billAddr4TxtField.text = jobAddr4TxtField.text
        billTownTxtField.text = jobTownTxtField.text
        billStateTxtField.text = jobStateTxtField.text
        billZipTxtField.text = jobZipTxtField.text
 */
        //billAddr1TxtField.text = jobAddr1TxtField.text
        billAddr2TxtField.text = jobAddr1TxtField.text
        billAddr3TxtField.text = jobAddr2TxtField.text
        billAddr4TxtField.text = jobAddr3TxtField.text! + " " + jobAddr4TxtField.text!
        billTownTxtField.text = jobTownTxtField.text
        billStateTxtField.text = jobStateTxtField.text
        billZipTxtField.text = jobZipTxtField.text
    }
    
    
    
    @objc func companySwitchValueDidChange(sender:UISwitch!)
    {
        //print("switchValueDidChange groupImages = \(groupImages)")
        
        if sender.isOn {
            self.constraintsForBusiness()
        }else{
            self.constraintsForResidnce()
        }
    }
    
    @objc func activeSwitchValueDidChange(sender:UISwitch!)
    {
        //print("switchValueDidChange groupImages = \(groupImages)")
        
        if sender.isOn {
            self.active = "1"
        }else{
            self.active = "0"
        }
    }
    
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        //print("pickerview tag: \(pickerView.tag)")
        var count:Int = 0
        if pickerView.tag == 0{
            count = self.layoutVars.salutations.count
        }else if pickerView.tag == 1 || pickerView.tag == 2{
            count = self.layoutVars.states.count
        }else{
            count = self.appDelegate.customerHearIDs.count
        }
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return self.layoutVars.salutations[row]
        }else if pickerView.tag == 1 || pickerView.tag == 2{
            return self.layoutVars.states[row]
        }else{
            return self.appDelegate.customerHearTypes[row]
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        editsMade = true
        //print("pickerview tag: \(pickerView.tag)")
        if pickerView.tag == 0 {
            self.salutationValue = self.layoutVars.salutations[row]
            self.salutationTxtField.text = self.salutationValue
            return
        }
        
        if pickerView.tag == 1 {
            self.jobStateValue = self.layoutVars.states[row]
            self.jobStateTxtField.text = self.jobStateValue
            return
        }
        if pickerView.tag == 2 {
            self.billStateValue = self.layoutVars.states[row]
            self.billStateTxtField.text = self.billStateValue
            return
        }
        
        if pickerView.tag == 3 {
            self.referredByValue = self.appDelegate.customerHearIDs[row]
            self.referredByTxtField.text = self.appDelegate.customerHearTypes[row]
            return
        }
        
    }
    
    @objc func cancelPicker(){
        //self.statusValueToUpdate = self.statusValue
        self.salutationTxtField.resignFirstResponder()
        self.jobStateTxtField.resignFirstResponder()
        self.billStateTxtField.resignFirstResponder()
        self.referredByTxtField.resignFirstResponder()
        
        
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.editsMade = true
        if companySwitch.isOn{
            if textField.tag == 1 && sysNameTxtField.text == ""{
                sysNameTxtField.text = companyTxtField.text
                if billAddr1TxtField.text == ""{
                    billAddr1TxtField.text = companyTxtField.text
                }
            }
        }else{
            if  textField.tag == 2 || textField.tag == 4 && sysNameTxtField.text == ""{
                if fNameTxtField.text != "" && lNameTxtField.text != ""{
                    sysNameTxtField.text = "\(lNameTxtField.text!), \(fNameTxtField.text!)"
                }
                
                
                
                
                
            }
            
            if textField.tag == 1 || textField.tag == 2 || textField.tag == 3 || textField.tag == 4{
                var billName:String = ""
                
                if salutationTxtField.text != ""{
                    billName += salutationTxtField.text!
                }
                
                if fNameTxtField.text != ""{
                    billName += " \(fNameTxtField.text!)"
                }
                
                if miTxtField.text != ""{
                    billName += " \(miTxtField.text!)"
                }
                
                if lNameTxtField.text != ""{
                    billName += " \(lNameTxtField.text!)"
                }
                
                billAddr1TxtField.text = billName
            }
        }
        
    }
    
    
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    @objc func cancelInput(){
        print("Cancel Input")
        self.view.endEditing(true)
        //self.purchasedTxtField.resignFirstResponder()
    }
    
    @objc func handleSalutationChange(){
        self.salutationTxtField.resignFirstResponder()
        self.salutationValue = layoutVars.salutations[self.salutationPicker.selectedRow(inComponent: 0)]
        self.salutationTxtField.text = self.salutationValue
        print("salutationValue = \(salutationValue)")
        editsMade = true
    }
    
    /*
    @objc func cancelJobStateInput(){
        print("Cancel JobState Input")
        self.jobStateTxtField.resignFirstResponder()
    }
    */
    @objc func handleJobStateChange(){
        self.jobStateTxtField.resignFirstResponder()
        self.jobStateValue = layoutVars.states[self.jobStatePicker.selectedRow(inComponent: 0)]
        self.jobStateTxtField.text = self.jobStateValue
        print("jobState = \(jobStateValue)")
        editsMade = true
        
        jobZipTxtField.becomeFirstResponder()
    }
    
    /*
    @objc func cancelBillStateInput(){
        print("Cancel BillState Input")
        self.billStateTxtField.resignFirstResponder()
    }
 */
    
    
    @objc func handleBillStateChange(){
        self.billStateTxtField.resignFirstResponder()
        self.billStateValue = layoutVars.states[self.billStatePicker.selectedRow(inComponent: 0)]
        self.billStateTxtField.text = self.billStateValue
        print("billState = \(billStateValue)")
        editsMade = true
        billZipTxtField.becomeFirstResponder()
    }
    
    /*
    @objc func cancelReferredByInput(){
        print("Cancel Reffered By Input")
        self.referredByTxtField.resignFirstResponder()
    }
 */
    
    
    @objc func handleReferredByChange(){
        self.referredByTxtField.resignFirstResponder()
        //self.referredByValue = layoutVars.customerReferences[self.referredByPicker.selectedRow(inComponent: 0)]
        
        self.referredByValue = self.appDelegate.customerHearIDs[self.referredByPicker.selectedRow(inComponent: 0)]
        self.referredByTxtField.text = self.appDelegate.customerHearTypes[self.referredByPicker.selectedRow(inComponent: 0)]
        //self.referredByTxtField.text = self.referredByValue
        print("referredBy = \(referredByValue)")
        editsMade = true
        
    }
    
    
    
    
    
    
    func validateFields()->Bool{
        print("validate fields")
        sysNameTxtField.reset()
        if sysNameTxtField.text!.count > 41{
            sysNameTxtField.error()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "System Name Too Long", _message: "The system name can have a maximum of 41 characters.")
            return false
        }
        
        if sysNameTxtField.text == ""{
            sysNameTxtField.error()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Customer", _message: "Provide a system name.")
            return false
        }
        
        if billAddr1TxtField.text!.count > 31{
            billAddr1TxtField.error()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Billing Name Too Long", _message: "The billing name can have a maximum of 31 characters.")
            return false
        }
        
        
        return true
        
        
    }
    
    
    
    
    @objc func submit(){
        
        cancelInput()
        indicator = SDevIndicator.generate(self.view)!
        
        if(!validateFields()){
            print("didn't pass validation")
            indicator.dismissIndicator()
            return
        }
 
        
    
        print("originalSysName = \(originalSysName)")
        print("sysNameTextField.text = \(String(describing: sysNameTxtField.text!))")
        
        if  sysNameTxtField.text! == originalSysName{
            self.nameChange = "0"
        }else{
            self.nameChange = "1"
        }
       
        var parameters:[String:String] = [:]
        
        parameters["companyName"] = self.companyTxtField.text
        parameters["salutation"] = self.salutationTxtField.text
        parameters["firstName"] = self.fNameTxtField.text
        parameters["middleName"] = self.miTxtField.text
        parameters["lastName"] = self.lNameTxtField.text
        parameters["sysName"] = self.sysNameTxtField.text
        
        parameters["nameChange"] = self.nameChange
        
        parameters["jobStreet1"] = self.jobAddr1TxtField.text
        parameters["jobStreet2"] = self.jobAddr2TxtField.text
        parameters["jobStreet3"] = self.jobAddr3TxtField.text
        parameters["jobStreet4"] = self.jobAddr4TxtField.text
        parameters["jobCity"] = self.jobTownTxtField.text
        parameters["jobState"] = self.jobStateTxtField.text
        parameters["jobZip"] = self.jobZipTxtField.text
        
       // parameters["billName"] = self.billNameTxtField.text
        parameters["billStreet1"] = self.billAddr1TxtField.text
        parameters["billStreet2"] = self.billAddr2TxtField.text
        parameters["billStreet3"] = self.billAddr3TxtField.text
        parameters["billStreet4"] = self.billAddr4TxtField.text
        parameters["billCity"] = self.billTownTxtField.text
        parameters["billState"] = self.billStateTxtField.text
        parameters["billZip"] = self.billZipTxtField.text
        
        parameters["referredBy"] = self.referredByValue
        parameters["active"] = self.active
        parameters["customerID"] = self.customerID
        parameters["createdBy"] = self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)
        
        
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/customer.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("update customer response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    
                    let nameTaken:String? = self.json["nameTaken"].stringValue
                    if nameTaken == "1"{
                        
                        self.indicator.dismissIndicator()
                        self.sysNameTxtField.error()
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Name Taken", _message: "The system name provided is already used.  Please create a unique name.")
                        return
                    }
                    
                    
                    self.originalSysName = self.sysNameTxtField.text!
                    
                    
                    self.customerID = self.json["custID"].stringValue
                    
                    self.layoutVars.playSaveSound()
                    
                    self.editsMade = false // avoids the back without saving check
                    
                    
                    if self.editDelegate != nil{
                        
                        print("call editDelegate")
                        self.editDelegate.updateCustomer(_customerID: self.customerID)
                        //self.goBack()
                    }
                    /*
                    if self.delegate != nil{
                        print("call delegate")
                        self.delegate?.updateList()
                    }
                    */
                    self.goBack()
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
 
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scroll view did scroll")
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    
    @objc func goBack(){
        if(self.editsMade == true){
            //print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                //print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                _ = self.navigationController?.popViewController(animated: false)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
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
    
    
    
}
