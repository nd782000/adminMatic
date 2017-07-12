//
//  WorkOrderViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation

import UIKit
import Alamofire
import SwiftyJSON

protocol WoDelegate{
    func refreshWo()
    func refreshWo(_refeshWoID:String, _newWoStatus:String)
}


class WorkOrderViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, WoDelegate {
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var editMode:Bool = false
    
    var scrollView: UIScrollView!
    var tapBtn:UIButton!
    
    var scheduleDelegate:ScheduleDelegate!
    var scheduleIndex:Int!
    
    var json:JSON!
    var workOrderID:String!
    var customerID:String!
    var customerName:String!
    
    var statusIcon:UIImageView = UIImageView()
    
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Un-Done","In Progress","Done","Cancel","Waiting"]
    
    
    var statusValue: String!
    var statusValueToUpdate: String!
    var customerBtn: Button!
    var locationValue:String?
    var infoMode:Int! = 0
    var infoView: UIView! = UIView()

    var scheduleLbl:GreyLabel!
    var schedule:GreyLabel!
    
    var scheduleDateFormatter:DateFormatter!
    
   
    
    var scheduleKeyWordValue:String?
    
    
    var deadLineValue:String = ""
    
    var chargeLbl:GreyLabel!
    var charge:GreyLabel!
    var chargeValue:String!
    
    var crewLbl:GreyLabel!
    var crew:GreyLabel!
    var crewsValue:String?
    
    var salesRepLbl:GreyLabel!
    var salesRep:GreyLabel!
    var salesRepValue:String!

    var fieldNotesView: UIView! = UIView()
    var fieldNotesLbl:GreyLabel!
    var fieldNotesTxt:GreyLabel!
    
    var woItems: JSON!
    var woItemsArray:[WoItem] = []
    var empsOnWo:[Employee] = []
    var fieldNotes:[FieldNote] = []
    
    var woItemViewController:WoItemViewController?
    var refreshWoID:String?
    var currentWoItem:WoItem?
    
    var numberFieldNotePics: Int = 0
    
    var itemsTableView: TableView!
    
    var profitView: UIView! = UIView()
    
    var priceLbl:GreyLabel!
    var price:GreyLabel!
    var priceValue:String?
    var priceRawValue:String?
    
    var costLbl:GreyLabel!
    var cost:GreyLabel!
    var costValue:String?
    var costRawValue:String?
    
    var profitLbl:GreyLabel!
    var profit:GreyLabel!
    var profitValue:String?
    
    var percentLbl:GreyLabel!
    var percent:GreyLabel!
    var percentValue:String?
    
    var profitBarView:UIView!
    var incomeView:UIView!
    var costView:UIView!
    
   
    
    
    
    
    init(_workOrderID:String,_customerName:String){
        
        super.init(nibName:nil,bundle:nil)
        print("workorder init")
        self.workOrderID = _workOrderID
        self.customerName = _customerName
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshWo(){
        numberFieldNotePics = 0
        json = []
        self.woItems = []
        self.woItemsArray = []
        self.empsOnWo = []
        self.crewsValue = ""
        self.deadLineValue = ""
        self.fieldNotes = []
         self.getWorkOrder()
    }
    
    func refreshWo(_refeshWoID _refreshWoID:String, _newWoStatus:String){
        //print("refreshWo")
        //print("current status = \(self.statusValue)")
        
        
        self.refreshWoID = _refreshWoID
        numberFieldNotePics = 0
        json = []
        self.woItems = []
        self.woItemsArray = []
        self.empsOnWo = []
        self.crewsValue = ""
        self.deadLineValue = ""
        self.fieldNotes = []
        
        
       

        
        
        if(self.statusValue != _newWoStatus && _newWoStatus != "na"){
            
            var statusName = ""
            switch (_newWoStatus) {
            case "1":
                statusName = "Un-Done"
                break;
            case "2":
                statusName = "In Progress"
                break;
            case "3":
                statusName = "Done"
                break;
            case "3":
                statusName = "Cancel"
                break;
                
            default:
                statusName = ""
                break;
            }

            
            
            
            let alertController = UIAlertController(title: "Set Work Order to \(statusName)", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                
                self.getWorkOrder()
                
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                /*
                //cache buster
                let now = Date()
                let timeInterval = now.timeIntervalSince1970
                let timeStamp = Int(timeInterval)
                */
                var parameters:[String:String]
                parameters = [
                    "woID":self.workOrderID,
                    "status":_newWoStatus,
                    "empID":(self.appDelegate.loggedInEmployee?.ID)!
                ]
                
                print("parameters = \(parameters)")
                
                
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/workOrderStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    print(response.request ?? "")  // original URL request
                    //print(response.response ?? "") // URL response
                    //print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    
                    
                     self.getWorkOrder()
                    
                    
                    }
 
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)

        }else{
            getWorkOrder()

        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        // Do any additional setup after loading the view.
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(WorkOrderViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading..."
        getWorkOrder()
    }
    

    
    //sends request for wo Data
    func getWorkOrder() {
        print(" GetWo  Work Order Id \(self.workOrderID)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
      
        
        Alamofire.request(API.Router.workOrder(["woID":self.workOrderID as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            
            response in
            // ////print(response.request)  // original URL request
            //////print(response.response) // URL response
            //////print(response.data)     // server data
            //////print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                // Close Indicator
                self.indicator.dismissIndicator()
                
                print("----------------")
                
                
                print("Work Order  JSON: \(json)")
                
                print("----------------")
                
                
                self.json = JSON(json)["woInfo"]
                self.parseJSON()
            }
        }
 
    }
    
    
    func parseJSON(){
        
        
        //print(" parseJSON()")
        
        self.customerID = self.json["customerID"].stringValue
        let mainAddr:String = self.json["customer"]["mainAddr"].stringValue
         self.locationValue =  mainAddr.components(separatedBy: ",").first
        
        
        if(self.json["deadline"].stringValue != "0000-00-00 00:00:00"){
            self.deadLineValue = "Deadline: \(self.json["deadline"].stringValue)"
        }
        
    
        print("date raw = \(self.json["dateRaw"].stringValue)")
        scheduleKeyWordValue = self.json["date"].stringValue
        
        chargeValue = ""
        
        
        switch (self.json["charge"].stringValue) {
        case "1":
            chargeValue = "NC $0.00"
            break;
        case "2":
            chargeValue = "FL \(self.json["totalPrice"].string!)"
            break;
        case "3":
            chargeValue = "T & M"
            break;
            
        default:
            chargeValue = "Null"//online
            break;
        }
 

         //print("400")
        let crewsOnWoCount = self.json["crews"].count
        empsOnWo = []
        if(crewsOnWoCount == 0){
            self.crewsValue = "No Crew"
        }else{
            self.crewsValue = ""
        }
        
        for p in 0 ..< crewsOnWoCount {
            
            if self.crewsValue!.isEmpty {
                self.crewsValue = self.json["crews"][p]["name"].stringValue
            } else {
                self.crewsValue! += " | \(self.json["crews"][p]["name"].stringValue)"
            }
            
            let empsInCrewCount = self.json["crews"][p]["emps"].count
            for m in 0 ..< empsInCrewCount {
                let empID = self.json["crews"][p]["emps"][m]["ID"].stringValue
                let empName = self.json["crews"][p]["emps"][m]["name"].stringValue
                let empLName = self.json["crews"][p]["emps"][m]["lname"].stringValue
                let empFName = self.json["crews"][p]["emps"][m]["fname"].stringValue
                let empUserName = self.json["crews"][p]["emps"][m]["username"].stringValue
                let empPic = self.json["crews"][p]["emps"][m]["pic"].stringValue
                
                let empPhone = self.json["crews"][p]["emps"][m]["phone"].stringValue
                let empDepID = self.json["crews"][p]["emps"][m]["dep"].stringValue
                let empPayRate = self.json["crews"][p]["emps"][m]["payRate"].stringValue
                let empAppScore = self.json["crews"][p]["emps"][m]["appScore"].stringValue
                let empObject = Employee(_ID: empID, _name: empName, _lname: empLName, _fname: empFName, _username: empUserName, _pic: empPic, _phone: empPhone, _depID: empDepID, _payRate: empPayRate, _appScore: empAppScore )
                
                empsOnWo.append(empObject)
            }
            
        }
        
        self.salesRepValue = self.json["salesRep"].string
        
        self.priceValue = self.json["totalPrice"].string
        self.costValue = self.json["totalCost"].string
        self.priceRawValue = self.json["totalPriceRaw"].string
        self.costRawValue = self.json["totalCostRaw"].string
        
        print("self.priceValue = \(self.priceValue)")
        
        
        self.profitValue = self.json["profitAmount"].string
        self.percentValue = self.json["profit"].string
        
       
        
        
        var json: JSON = ["columns" : ["created_at" : "DESC", "id" : "DESC"]]
        
        let jsonDic = json["columns"].dictionary
        
        var result: [String : String] = [:]
        if let jsonDic = jsonDic {
            for (key, value) in jsonDic {
                result[key] = value.stringValue
            }
        }
        
        print("result = \(result)")
        
        self.statusValue = self.json["status"].stringValue
        
        self.statusValueToUpdate = self.statusValue
        
        
        if(self.scheduleDelegate != nil){
            self.scheduleDelegate.reDrawSchedule(_index: self.scheduleIndex, _status: self.statusValue , _price: priceValue!, _cost: costValue!, _priceRaw: priceRawValue!, _costRaw: costRawValue!)
        }
    
    
    
        let jsonCount = self.json["items"].count
        
        for i in 0 ..< jsonCount {
            let woItem = WoItem( _ID: self.json["items"][i]["ID"].stringValue,_type: self.json["items"][i]["type"].stringValue, _sort: self.json["items"][i]["sort"].stringValue, _input: self.json["items"][i]["input"].stringValue, _est: self.json["items"][i]["est"].stringValue, _empDesc: self.json["items"][i]["empDesc"].stringValue, _itemStatus: self.json["items"][i]["itemStatus"].stringValue, _chargeID: self.json["items"][i]["chargeID"].stringValue, _act: self.json["items"][i]["act"].stringValue, _price: self.json["items"][i]["price"].stringValue, _total: self.json["items"][i]["total"].stringValue, _totalCost: self.json["items"][i]["totalCost"].stringValue, _usageQty:self.json["items"][i]["usageQty"].stringValue, _extraUsage:self.json["items"][i]["extraUsage"].stringValue, _unit:self.json["items"][i]["unitName"].stringValue)
            
            if(woItem.ID == refreshWoID){
                //print("refreshWoID = \(woItem)")
                currentWoItem = woItem
                if(self.woItemViewController != nil){
                    //print("update woItemVC \(self.currentWoItem?.usageQty)")
                    self.woItemViewController!.woItem = self.currentWoItem
                    self.woItemViewController?.customerID = self.customerID
                    self.woItemViewController?.saleRepName = self.salesRepValue
                    self.woItemViewController?.layoutViews()
                }
                
            }
            print("usageQty = \(woItem.usageQty)")
            
            //tasks
            
            let taskCount = self.json["items"][i]["tasks"].count
            for n in 0 ..< taskCount {
                //var taskPicUrl = "0"
                //var taskThumbUrl = "0"
                var taskImages:[Image] = []
                //if(self.json["items"][i]["tasks"][n]["pic"].stringValue != "0" && self.json["items"][i]["tasks"][n]["image"] != JSON.null){
                    
                    
                    
                    let imageCount = Int((self.json["items"][i]["tasks"][n]["images"].count))
                    print("imageCount: \(imageCount)")
                    
                    
                    
                    
                    for p in 0 ..< imageCount {
                        
                        let fileName:String = (self.json["items"][i]["tasks"][n]["images"][p]["fileName"].stringValue)
                        
                        let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                        let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                        let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                        
                        //create a item object
                        print("create an image object \(i)")
                        
                        print("rawPath = \(rawPath)")
                        
                        let image = Image(_id: self.json["items"][i]["tasks"][n]["images"][p]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["items"][i]["tasks"][n]["images"][p]["name"].stringValue,_width: self.json["items"][i]["tasks"][n]["images"][p]["width"].stringValue,_height: self.json["items"][i]["tasks"][n]["images"][p]["height"].stringValue,_description: self.json["items"][i]["tasks"][n]["images"][p]["description"].stringValue,_dateAdded: self.json["items"][i]["tasks"][n]["images"][p]["dateAdded"].stringValue,_createdBy: self.json["items"][i]["tasks"][n]["images"][p]["createdByName"].stringValue,_type: self.json["items"][i]["tasks"][n]["images"][p]["type"].stringValue)
                        
                        image.customer = (self.json["items"][i]["tasks"][n]["images"][p]["customer"].stringValue)
                        image.tags = (self.json["items"][i]["tasks"][n]["images"][p]["tags"].stringValue)
                        
                        print("appending image")
                        taskImages.append(image)
                        
                    }

                
                
                
           // print("task = ")
                ////print("thumb url = \(taskThumbUrl)")
                
                let task = Task(_ID: self.json["items"][i]["tasks"][n]["ID"].stringValue, _sort: self.json["items"][i]["tasks"][n]["sort"].stringValue, _status: self.json["items"][i]["tasks"][n]["status"].stringValue, _task: self.json["items"][i]["tasks"][n]["task"].stringValue, _images:taskImages)
                woItem.tasks.append(task)
            }
            
            let vendorCount = self.json["items"][i]["vendors"].count
            for n in 0 ..< vendorCount {
                let vendor = Vendor(_name: self.json["items"][i]["vendors"][n]["companyName"].stringValue, _id: self.json["items"][i]["vendors"][n]["vendorID"].stringValue, _address: self.json["items"][i]["vendors"][n]["address"].stringValue, _phone: self.json["items"][i]["vendors"][n]["phone"].stringValue, _website: self.json["items"][i]["vendors"][n]["website"].stringValue, _balance: self.json["items"][i]["vendors"][n]["balance"].stringValue, _lng: self.json["items"][i]["vendors"][n]["lng"].stringValue, _lat: self.json["items"][i]["vendors"][n]["lat"].stringValue)
                vendor.itemCost = self.json["items"][i]["vendors"][n]["cost"].stringValue
                woItem.vendors.append(vendor)
            }
            let vendor = Vendor(_name: "Other", _id: "0", _address: "", _phone: "", _website: "", _balance: "", _lng: "", _lat: "")
            woItem.vendors.append(vendor)
            
            let usageCount = self.json["items"][i]["usage"].count
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for n in 0 ..< usageCount {
                let startDate = dateFormatter.date(from: self.json["items"][i]["usage"][n]["start"].string!)!
                let stopDate:Date?
            
                var locked:Bool
                let usageQty = Double(self.json["items"][i]["usage"][n]["qty"].stringValue)
                if(usageQty! > 0.0 && self.json["items"][i]["usage"][n]["addedBy"].string != appDelegate.loggedInEmployee?.ID){
                    locked = true
                }else{
                    locked = false
                }
                
                
                let usage:Usage
                
                if(self.json["items"][i]["usage"][n]["stop"].string != "0000-00-00 00:00:00"){
                    stopDate = dateFormatter.date(from: self.json["items"][i]["usage"][n]["stop"].string!)!
                    
                   usage = Usage(_ID: self.json["items"][i]["usage"][n]["ID"].stringValue,
                                      _empID: self.json["items"][i]["usage"][n]["empID"].stringValue,
                                      _depID: self.json["items"][i]["usage"][n]["depID"].stringValue,
                                      _woID: self.json["items"][i]["usage"][n]["woID"].stringValue,
                                      _start: startDate,
                                      _stop: stopDate,
                                      _lunch: self.json["items"][i]["usage"][n]["lunch"].stringValue,
                                      _qty: self.json["items"][i]["usage"][n]["qty"].stringValue,
                                      _empName: self.json["items"][i]["usage"][n]["empName"].stringValue,
                                      _type: self.json["items"][i]["usage"][n]["type"].stringValue,
                                      _itemID: self.json["items"][i]["usage"][n]["woItemID"].stringValue,
                                      _unitPrice: self.json["items"][i]["usage"][n]["unitPrice"].stringValue,
                                      _totalPrice: self.json["items"][i]["usage"][n]["totalPrice"].stringValue,
                                      _vendor: self.json["items"][i]["usage"][n]["vendor"].stringValue,
                                      _unitCost: self.json["items"][i]["usage"][n]["unitCost"].stringValue,
                                      _totalCost: self.json["items"][i]["usage"][n]["totalCost"].stringValue,
                                      _chargeType: self.json["items"][i]["chargeID"].stringValue,
                                      _override: self.json["items"][i]["usage"][n]["override"].stringValue,
                                      _empPic: self.json["items"][i]["usage"][n]["empPic"].stringValue,
                                      _locked: locked,
                                      _addedBy: appDelegate.loggedInEmployee?.ID,
                                      _del: ""
                    )
                }else{
                    
                    usage = Usage(_ID: self.json["items"][i]["usage"][n]["ID"].stringValue,
                                      _empID: self.json["items"][i]["usage"][n]["empID"].stringValue,
                                      _depID: self.json["items"][i]["usage"][n]["depID"].stringValue,
                                      _woID: self.json["items"][i]["usage"][n]["woID"].stringValue,
                                      _start: startDate,
                                      _lunch: self.json["items"][i]["usage"][n]["lunch"].stringValue,
                                      _qty: self.json["items"][i]["usage"][n]["qty"].stringValue,
                                      _empName: self.json["items"][i]["usage"][n]["empName"].stringValue,
                                      _type: self.json["items"][i]["usage"][n]["type"].stringValue,
                                      _itemID: self.json["items"][i]["usage"][n]["woItemID"].stringValue,
                                      _unitPrice: self.json["items"][i]["usage"][n]["unitPrice"].stringValue,
                                      _totalPrice: self.json["items"][i]["usage"][n]["totalPrice"].stringValue,
                                      _vendor: self.json["items"][i]["usage"][n]["vendor"].stringValue,
                                      _unitCost: self.json["items"][i]["usage"][n]["unitCost"].stringValue,
                                      _totalCost: self.json["items"][i]["usage"][n]["totalCost"].stringValue,
                                      _chargeType: self.json["items"][i]["chargeID"].stringValue,
                                      _override: self.json["items"][i]["usage"][n]["override"].stringValue,
                                      _empPic: self.json["items"][i]["usage"][n]["empPic"].stringValue,
                                      _locked: locked,
                                      _addedBy: appDelegate.loggedInEmployee?.ID,
                                      _del: ""
                    )
                }
                woItem.usages.append(usage)
            }
            
            self.woItemsArray.append(woItem)
            
        }
        
        
        //FieldNotes
        let fieldNoteCount = self.json["fieldNotes"].count
        
        print("fieldNoteCount: \(fieldNoteCount)")
        print("JSON fieldnotes: \(self.json["fieldNotes"])")
        for n in 0 ..< fieldNoteCount {
            
           // var picUrl = "0"
           // var thumbUrl = "0"
            
            var fieldNoteImages:[Image]  = []
            
            
            let imageCount = self.json["fieldNotes"][n]["images"].count
            print("imageCount: \(imageCount)")
            
           // let thumbBase:String = self.images["thumbBase"].stringValue
           // let rawBase:String = self.images["rawBase"].stringValue
            
            for i in 0 ..< imageCount {
                
                let thumbPath:String = "\(self.layoutVars.thumbBase)\(self.json["fieldNotes"][n]["images"][i]["fileName"].stringValue)"
                let mediumPath:String = "\(self.layoutVars.mediumBase)\(self.json["fieldNotes"][n]["images"][i]["fileName"].stringValue)"
                let rawPath:String = "\(self.layoutVars.rawBase)\(self.json["fieldNotes"][n]["images"][i]["fileName"].stringValue)"
                
                //create a item object
                print("create an image object \(i)")
                
                let image = Image(_id: self.json["fieldNotes"][n]["images"][i]["ID"].stringValue,_thumbPath: thumbPath, _mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["fieldNotes"][n]["images"][i]["name"].stringValue,_width: self.json["fieldNotes"][n]["images"][i]["width"].stringValue,_height: self.json["fieldNotes"][n]["images"][i]["height"].stringValue,_description: self.json["fieldNotes"][n]["images"][i]["description"].stringValue,_dateAdded: self.json["fieldNotes"][n]["images"][i]["dateAdded"].stringValue,_createdBy: self.json["fieldNotes"][n]["images"][i]["createdBy"].stringValue,_type: self.json["fieldNotes"][n]["images"][i]["type"].stringValue)
                
                image.customer = self.json["fieldNotes"][n]["images"][i]["customer"].stringValue
                image.tags = self.json["fieldNotes"][n]["images"][i]["tags"].stringValue
                
                fieldNoteImages.append(image)
                
            }
            
             
            
            
            let fieldNote = FieldNote(_ID: self.json["fieldNotes"][n]["ID"].stringValue, _note: self.json["fieldNotes"][n]["note"].stringValue, _customerID: self.json["fieldNotes"][n]["customerID"].stringValue, _workOrderID: self.json["fieldNotes"][n]["workOrderID"].stringValue, _createdBy: self.json["fieldNotes"][n]["createdBy"].stringValue, _status: self.json["fieldNotes"][n]["status"].stringValue, _images:fieldNoteImages)
            
            //print("thumb url = \(thumbUrl)")
            
            
            if(Int(self.json["fieldNotes"][n]["images"].count) > 0){
                self.numberFieldNotePics += Int(self.json["fieldNotes"][n]["images"].count)
            }
            
            
            self.fieldNotes.append(fieldNote)
            
        }
        self.layoutViews()
 
    }
    
    
    func layoutViews(){
        //print("layout views")
        
        for fieldNote in fieldNotes{
            ////print("thumb = \(fieldNote.thumb)")
        }
        
        title =  "Work Order #" + self.workOrderID
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        if(self.scrollView != nil){
            self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
        }
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        if(self.fieldNotesView != nil){
            self.fieldNotesView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        if(self.profitView != nil){
            self.profitView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        
        if(self.woItemViewController != nil){
            self.woItemViewController?.woItem = currentWoItem
            self.woItemViewController?.layoutViews()
        }
        
        
        
        //statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        self.view.addSubview(statusIcon)
        setStatus(status: self.json["status"].stringValue)
        
        
        //employee picker
        self.statusPicker = Picker()
        print("statusValue : \(statusValue)")
        print("set picker position : \(Int(self.statusValue)! - 1)")
        
        self.statusPicker.delegate = self
        
        self.statusPicker.selectRow(Int(self.statusValue)! - 1, inComponent: 0, animated: false)
        
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

        
        self.customerBtn = Button(titleText: "\(self.customerName!) \(self.locationValue!)")
        self.customerBtn.contentHorizontalAlignment = .left
        let custIcon:UIImageView = UIImageView()
        custIcon.backgroundColor = UIColor.clear
        custIcon.contentMode = .scaleAspectFill
        custIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        let custImg = UIImage(named:"custIcon.png")
        custIcon.image = custImg
        self.customerBtn.addSubview(custIcon)
        self.customerBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.customerBtn.addTarget(self, action: #selector(WorkOrderViewController.showCustInfo), for: UIControlEvents.touchUpInside)
        
        
        self.view.addSubview(customerBtn)
        
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.infoView.layer.cornerRadius = 4
        self.view.addSubview(infoView)
        
        
        //schedule
        self.scheduleLbl = GreyLabel()
        self.scheduleLbl.text = "Schedule:"
        self.scheduleLbl.textAlignment = .left
        self.scheduleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(scheduleLbl)
        
        self.schedule = GreyLabel()
        self.schedule.text = self.scheduleKeyWordValue
        self.schedule.font = layoutVars.labelBoldFont
        self.schedule.textAlignment = .left
        self.schedule.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(schedule)

        
        //charge
        self.chargeLbl = GreyLabel()
        self.chargeLbl.text = "Charge:"
        self.chargeLbl.textAlignment = .left
        self.chargeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeLbl)
        
        self.charge = GreyLabel()
        self.charge.text = self.chargeValue
        self.charge.font = layoutVars.labelBoldFont
        self.charge.textAlignment = .left
        self.charge.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(charge)
        
        //crew
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew:"
        self.crewLbl.textAlignment = .left
        self.crewLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(crewLbl)
        
        self.crew = GreyLabel()
        self.crew.text = self.crewsValue
        self.crew.font = layoutVars.labelBoldFont
        self.crew.textAlignment = .left
        self.crew.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(crew)
        
        
        //sales rep
        self.salesRepLbl = GreyLabel()
        self.salesRepLbl.text = "Rep:"
        self.salesRepLbl.textAlignment = .left
        self.salesRepLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRepLbl)
        
        self.salesRep = GreyLabel()
        self.salesRep.text = self.salesRepValue
        self.salesRep.font = layoutVars.labelBoldFont
        self.salesRep.textAlignment = .left
        self.salesRep.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRep)
        
        
        // Field Notes Window
        
        self.fieldNotesView.translatesAutoresizingMaskIntoConstraints = false
        self.fieldNotesView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.fieldNotesView.layer.cornerRadius = 4
        self.view.addSubview(fieldNotesView)
        
        
        let smallCameraIcon:UIImageView = UIImageView()
        smallCameraIcon.backgroundColor = UIColor.clear
        smallCameraIcon.contentMode = .scaleAspectFill
        smallCameraIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let smallCameraImg = UIImage(named:"smallCameraIcon.png")
        smallCameraIcon.image = smallCameraImg
        
        
        self.fieldNotesLbl = GreyLabel(icon: true)
        self.fieldNotesLbl.text = "Field Notes:"
        self.fieldNotesLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.fieldNotesLbl.addSubview(smallCameraIcon)
        
        self.fieldNotesView.addSubview(fieldNotesLbl)
        
        self.fieldNotesTxt = GreyLabel()
        var picString:String = ""
        if(self.numberFieldNotePics > 0){
            picString = "(\(self.numberFieldNotePics) Images)"
        }
        if(self.fieldNotes.count == 0){
            self.fieldNotesTxt.text = "No Saved Notes"
        }else if(self.fieldNotes.count > 1){
            self.fieldNotesTxt.text = "\(self.fieldNotes.count) notes \(picString)"
        }else{
            self.fieldNotesTxt.text = "\(self.fieldNotes.count) note \(picString)"
        }
        
        self.fieldNotesTxt.translatesAutoresizingMaskIntoConstraints = false
        
        self.fieldNotesView.addSubview(fieldNotesTxt)
        
        

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WorkOrderViewController.showFieldNotesList))
        fieldNotesView.addGestureRecognizer(tapGesture)
        
        
        let tableHead:UIView! = UIView()
        let statusTH: THead = THead(text: "Sts.")
        let nameTH: THead = THead(text: "Name")
        let estTH: THead = THead(text: "Est.")
        let actTH: THead = THead(text: "Act.")
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        tableHead.addSubview(statusTH)
        tableHead.addSubview(nameTH)
        tableHead.addSubview(estTH)
        tableHead.addSubview(actTH)
        
        self.view.addSubview(tableHead)
        
        self.itemsTableView  =   TableView()
        self.itemsTableView.autoresizesSubviews = true
        self.itemsTableView.delegate  =  self
        self.itemsTableView.dataSource  =  self
        self.itemsTableView.layer.cornerRadius = 0
        self.itemsTableView.register(WoItemTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.itemsTableView)
        
    
        
    // Profit View
        
        self.profitView.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.profitView.layer.cornerRadius = 4
        
        self.view.addSubview(self.profitView)
        
        
        self.priceLbl = GreyLabel(icon: false)
        self.priceLbl.text = "Price:"
        self.priceLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(priceLbl)
        
        
        self.price = GreyLabel()
        self.price.text = self.priceValue
        self.price.font = layoutVars.labelBoldFont
        self.price.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(price)

        self.costLbl = GreyLabel(icon: false)
        self.costLbl.text = "Cost:"
        self.costLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(costLbl)
        
        self.cost = GreyLabel()
        self.cost.text = self.costValue
        self.cost.font = layoutVars.labelBoldFont
        self.cost.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(cost)
        
        self.profitLbl = GreyLabel(icon: false)
        self.profitLbl.text = "Profit:"
        self.profitLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(profitLbl)
        
        self.profit = GreyLabel()
        self.profit.text = self.profitValue
        self.profit.font = layoutVars.labelBoldFont
        self.profit.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(profit)
        
        self.percentLbl = GreyLabel(icon: false)
        self.percentLbl.text = "Profit %:"
        self.percentLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(percentLbl)
        
        self.percent = GreyLabel()
        self.percent.text = self.percentValue
        self.percent.font = layoutVars.labelBoldFont
        self.percent.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(percent)
        
        
        self.profitBarView = UIView()
        self.profitBarView.backgroundColor = UIColor.gray
        self.profitBarView.layer.borderColor = layoutVars.borderColor
        self.profitBarView.layer.borderWidth = 1.0
        self.profitBarView.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(self.profitBarView)
        
        
        //Profit Info
        let profitBarWidth = Float(layoutVars.fullWidth - 20)
        
        
        let totalRaw = Float(self.priceRawValue!)
        let totalCostRaw = Float(self.costRawValue!)
        
        
        var scaleFactor = Float(0.00)
        var costWidth = Float(0.00)
        
        if(totalRaw! > 0.0){
            ////print("greater")
            scaleFactor = Float(profitBarWidth / totalRaw!)
            costWidth = totalCostRaw! * scaleFactor
            if(costWidth > profitBarWidth){
                costWidth = profitBarWidth
            }
        }else{
            costWidth = profitBarWidth
        }
        
        
        let costBarOffset = profitBarWidth - costWidth
        
        //////print("income = \(income)")
        //////print("cost = \(cost)")
        ////print("scaleFactor = \(scaleFactor)")
        ////print("costWidth = \(costWidth)")
        ////print("profitBarWidth = \(profitBarWidth)")
        ////print("costBarOffset = \(costBarOffset)")
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        

        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "fieldNotes":self.fieldNotesView,
            "th":tableHead,
            "table":self.itemsTableView,
            "profitView":self.profitView,
        ] as [String:AnyObject]
        
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusIcon(40)]-15-[customerBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[info]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[fieldNotes]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[table]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[th]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[profitView]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[customerBtn(40)]-[info(90)]-[fieldNotes(40)]-[th][table]-[profitView(85)]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-79-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        //auto layout group
        let infoDictionary = [
            "scheduleLbl":self.scheduleLbl,
            "schedule":self.schedule,
            "chargeLbl":self.chargeLbl,
            "charge":self.charge,
            "crewLbl":self.crewLbl,
            "crew":self.crew,
            "salesRepLbl":self.salesRepLbl,
            "salesRep":self.salesRep
        ] as [String:AnyObject]
        
        
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[scheduleLbl]-[schedule]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[chargeLbl]-[charge]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[crewLbl]-[crew]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[salesRepLbl]-[salesRep]-10-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scheduleLbl(22)]-[chargeLbl(22)]-[crewLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[schedule(22)]-[charge(22)]-[crew(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scheduleLbl(22)]-[chargeLbl(22)]-[salesRepLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scheduleLbl(22)]-[charge(22)]-[salesRep(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        
        //auto layout group
        let fieldNotesDictionary = [
            "fieldNotesLbl":self.fieldNotesLbl,
            "fieldNotesTxt":self.fieldNotesTxt
        ] as [String:AnyObject]
        
        
        self.fieldNotesView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fieldNotesLbl(130)]-[fieldNotesTxt]-10-|", options: [], metrics: metricsDictionary, views: fieldNotesDictionary))
        self.fieldNotesView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[fieldNotesLbl]", options: [], metrics: metricsDictionary, views: fieldNotesDictionary))
        self.fieldNotesView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[fieldNotesTxt]", options: [], metrics: metricsDictionary, views: fieldNotesDictionary))
        
        
        // Tablehead
        let thDictionary = [
            "sts":statusTH,
            "name":nameTH,
            "est":estTH,
            "act":actTH
        ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[sts(40)]-10-[name]-5-[est(50)]-10-[act(50)]-5-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[sts(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[name(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[est(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[act(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        //print("6")

        //auto layout group
        let profitDictionary = [
            "priceLbl":self.priceLbl,
            "costLbl":self.costLbl,
            "profitLbl":self.profitLbl,
            "percentLbl":self.percentLbl,
            "price":self.price,
            "cost":self.cost,
            "profit":self.profit,
            "percent":self.percent,
            "profitBar":self.profitBarView
            ] as [String:AnyObject]
        
        
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[priceLbl]-[price]", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[profitLbl]-[profit]-10-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[costLbl]-[cost]", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[percentLbl]-[percent]-10-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[profitBar]-10-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[priceLbl]-[costLbl]", options: [], metrics: metricsDictionary, views: profitDictionary))
         self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[price]-[cost]", options: [], metrics: metricsDictionary, views: profitDictionary))
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[profitLbl]-[percentLbl]", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[profit]-[percent]", options: [], metrics: metricsDictionary, views: profitDictionary))
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[profitBar(10)]-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        
        incomeView = UIView()
        incomeView.layer.cornerRadius = 5
        incomeView.layer.masksToBounds = true
        incomeView.backgroundColor = layoutVars.buttonColor1
        incomeView.translatesAutoresizingMaskIntoConstraints = false
        self.profitBarView.addSubview(self.incomeView)
        
        costView = UIView()
        costView.layer.cornerRadius = 5
        costView.layer.masksToBounds = true
        costView.backgroundColor = UIColor.red
        costView.translatesAutoresizingMaskIntoConstraints = false
        self.profitBarView.addSubview(self.costView)
        
        
        //print("7")

        
        let profitBarViewsDictionary = [
            
            "incomeView":self.incomeView,
            "costView":self.costView
            ]  as [String:AnyObject]
        
        let profitBarSizeVals = ["profitBarWidth":profitBarWidth as AnyObject,"costWidth":costWidth as AnyObject,"costBarOffset":costBarOffset as AnyObject]  as [String:AnyObject]
        
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[incomeView(profitBarWidth)]|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[costView(costWidth)]-costBarOffset-|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[incomeView(10)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[costView(10)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        //print("8")
    }
    
    func showFieldNotesList(){
        let fieldNotesListViewControler:FieldNoteListViewController = FieldNoteListViewController(_workOrderID: self.workOrderID,_customerID: self.customerID, _fieldNotes: self.fieldNotes)
        fieldNotesListViewControler.woDelegate = self
        navigationController?.pushViewController(fieldNotesListViewControler, animated: false )
    }
    
    func enterEditMode(){
        editMode = true
        removeViews()
        
    }
    
    func exitEditMode(){
        editMode = false
        removeViews()
        layoutViews()
        
    }
    
    func showCustInfo() {
        ////print("SHOW CUST INFO")
        let customerViewController = CustomerViewController(_customerID: self.customerID,_customerName: self.customerName)
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
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
       // shows first 3 status options, not cancel or waiting
        return self.statusArray.count - 2
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
        case 4:
            myImageView.image = UIImage(named:"waitingStatus.png")
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
        
        self.statusValueToUpdate = "\(row + 1)"
    }
    
    func cancelPicker(){
         //self.statusValueToUpdate = self.statusValue
        self.statusTxtField.resignFirstResponder()
    }
    
    func handleStatusChange(){
        
        self.statusTxtField.resignFirstResponder()
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //print("status = \(self.statusValueToUpdate)")
        
        
        
        
        var parameters:[String:String]
        parameters = [
            "woID":self.workOrderID,
            "status":self.statusValueToUpdate,
            "empID":(self.appDelegate.loggedInEmployee?.ID)!
        ]
        
        /*
        parameters = [
            "woID":self.workOrderID,
            "status":"\(self.statusPicker.selectedRow(inComponent: 0))",
            "empID":(self.appDelegate.loggedInEmployee?.ID)!
        ]
 */
        
        print("parameters = \(parameters)")
        
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/workOrderStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            
             self.statusValue = self.statusValueToUpdate
            
            self.setStatus(status: self.statusValue)
          
            
        if(self.scheduleDelegate != nil){
                self.scheduleDelegate.reDrawSchedule(_index: self.scheduleIndex, _status: self.statusValue, _price: self.priceValue!, _cost: self.costValue!, _priceRaw: self.priceRawValue!, _costRaw: self.costRawValue!)
                }
            }.responseString() {
                response in
                print(response)  // original URL request
            }
        
        
        
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //return self.woItemsArray.count
        var count:Int!
        count = self.woItemsArray.count + 1
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:WoItemTableViewCell = itemsTableView.dequeueReusableCell(withIdentifier: "cell") as! WoItemTableViewCell
        
        if(indexPath.row == self.woItemsArray.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            cell.woItem = self.woItemsArray[indexPath.row]
            
            cell.layoutViews()
            
            
            cell.setStatus(status: cell.woItem.itemStatus)
            cell.nameLbl.text = cell.woItem.input
            cell.estLbl.text = cell.woItem.est
            cell.actLbl.text = cell.woItem.usageQty
        }
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == self.woItemsArray.count){
            self.addItem()
        }else{
            let indexPath = tableView.indexPathForSelectedRow;
            let currentCell = tableView.cellForRow(at: indexPath!) as! WoItemTableViewCell;
            if(currentCell.woItem != nil && currentCell.woItem.ID != ""){
                self.woItemViewController = WoItemViewController(_woID: self.workOrderID, _woItem: currentCell.woItem, _empsOnWo: self.empsOnWo, _woStatus: self.statusValue)
                self.woItemViewController!.woDelegate = self
                print("task count = \(currentCell.woItem.tasks.count)")
                // print("task image  count = \(currentCell.woItem.tasks)")
                self.woItemViewController?.tasks = currentCell.woItem.tasks
                self.woItemViewController?.layoutViews()
                
                navigationController?.pushViewController(self.woItemViewController!, animated: false )
                tableView.deselectRow(at: indexPath!, animated: true)
            }
        }
        
        
    }
    
    
    
    func addItem(){
        print("add item rep: \(self.salesRepValue!)")
        
        
        if(self.json["charge"].stringValue == "2"){
            var message:String = ""
            if(self.salesRepValue! != "No Rep"){
                message = "Contact sales rep: \(self.salesRepValue!) or the office to add items to this work order."
            }else{
                message = "Contact the office to add items to this work order."
            }
            let alertController = UIAlertController(title: "Flat Price Work Order", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //self.popView()
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        
        
        
        
        
        let newWoItemViewController:NewWoItemViewController = NewWoItemViewController(_woID: self.workOrderID, _charge: self.json["charge"].stringValue)
        
        newWoItemViewController.delegate = self
        
        
        //print("url = https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
        
       // print("self.selectedImages.count = \(selectedImages.count)")
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        newWoItemViewController.loadLinkList(_linkType: "items", _loadScript: API.Router.itemList(["cb":timeStamp as AnyObject]))
        
        
        //imageUploadPrepViewController.delegate = self
        
        self.navigationController?.pushViewController(newWoItemViewController, animated: false )
        

        
        
        
        
        
        /*
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _ID: "0")
        imageUploadPrepViewController.selectedID = self.woItem.ID
        imageUploadPrepViewController.customerID = self.customerID
        // imageUploadPrepViewController.itemID = self.woItem.
        imageUploadPrepViewController.layoutViews()
        
        imageUploadPrepViewController.woID = self.woID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.fieldNoteDelegate = self
        
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        
        */
        
        
    }
    
    
    
    
    
    
    
    
    func handleDatePicker()
    {
        ////print("DATE: \(dateFormatter.stringFromDate(datePickerView.date))")
       // self.dateTxtField.text =  dateFormatter.string(from: datePickerView.date)
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //let offset = (textField.frame.origin.y - 150)
        //let scrollPoint : CGPoint = CGPoint(x: 0, y: offset)
        //self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       // self.scrollView.setContentOffset(CGPoint.zero, animated: true)
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
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
        
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
        
        
        switch (status) {
        case "1":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
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
            
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }

        
    }
    
    
}









