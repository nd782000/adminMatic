//
//  CustomerViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import DKImagePickerController

protocol EditCustomerDelegate{
    func updateCustomer(_customerID:String)
}


class CustomerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ScheduleDelegate, ImageViewDelegate, ImageLikeDelegate, LeadListDelegate, ContractListDelegate, InvoiceListDelegate, EditCustomerDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var customerListDelegate:CustomerListDelegate!
    
    
    
    //var delegate:CustomerListDelegate?
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var customerID:String
    var customerName:String
    
    var customerJSON: JSON!
    var customer:Customer!
    //extra customer properties, customer object doesn't have'
    var phone: String = "No Phone Found"
    var phoneName: String = ""
    var email: String = "No Email Found"
    var emailName: String = ""
    var jobSiteAddress: String = "No Job Site Found"
    var lat: NSString?
    var lng: NSString?
    
    var editButton:UIBarButtonItem!
    
    //customer info
    var customerView:UIView!
    var customerLbl:GreyLabel!
    var customerPhoneBtn:Button!
    var phoneNumberClean:String!
    var customerEmailBtn:Button!
    var customerAddressBtn:Button!
    var allContactsBtn:Button!
    
    
    
    
    //details view
    var detailsView:UIView!
    let items = ["Leads","Contracts","W.O.s","Invoices","Images"]
    var customSC:SegmentedControl!
    
    
    var customerDetailsTableView:TableView = TableView()
    var tableViewMode:String = "SCHEDULE"
    
    
    var customerLeadArray:[Lead] = []
    
    var leadViewController:LeadViewController!
    
    var addLeadBtn:Button!
    
    var customerContractArray:[Contract] = []
    
    var contractViewController:LeadViewController!
    
    var addContractBtn:Button!
    
    var customerScheduleArray:[WorkOrder] = []
    
    
    var addWorkOrderBtn:Button!
    
    
    var customerInvoiceArray:[Invoice] = []
    var addInvoiceBtn:Button!
    
    var noLeadsLabel:Label = Label()
    var noContractsLabel:Label = Label()
    var noScheduleLabel:Label = Label()
    var noInvoicesLabel:Label = Label()
    var noImagesLbl:Label = Label()
    
    var totalImages:Int!
    var imageArray:[Image] = []
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    var addImageBtn:Button = Button(titleText: "Add Images")
    
    var imagesLoadedInitial:Bool = false
    var imagesLoaded:Bool = false
    var currentImageIndex:Int = 0
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var displayImages:Bool = false
    var viewsLoaded:Bool = false
    
    
    
    
    var order:String = "ID DESC"
    
    
    var lazyLoad = 0
    var limit = 100
    var offset = 0
    var batch = 0
    
    
    
    init(_customerID:String,_customerName:String){
        self.customerID = _customerID
        self.customerName = _customerName

        super.init(nibName:nil,bundle:nil)
    }
    
    init(_customerID:String,_customerName:String,_imageView:Bool){
        self.customerID = _customerID
        self.customerName = _customerName
        
        super.init(nibName:nil,bundle:nil)
        
        self.displayImages = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //print(currentReachabilityStatus) //true connected
        //print(currentReachabilityStatus != .notReachable) //true connected
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Customer"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        
        getCustomerData(_id: self.customerID)
    }
    
    
    func getCustomerData(_id:String){
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        
        
        
        Alamofire.request(API.Router.customer(["ID":self.customerID as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
           // //print(response.request ?? "")  // original URL request
            ////print(response.response ?? "") // URL response
            ////print(response.data ?? "")     // server data
            ////print(response.result)   // result of response serialization
            
           
           
            if let json = response.result.value {
               // print("JSON: \(json)")
                self.customerJSON = JSON(json)
                self.parseCustomerJSON()
                
                
                
                
            }
        }
        
    }
    
   
    
    
    
    func parseCustomerJSON(){
        
        
       // print("parse customerJSON: \(self.customerJSON)")
        self.customerName = self.customerJSON["customer"]["name"].string!
        //loop through contacts and put them in appropriate places
        let contactCount:Int = self.customerJSON["customer"]["contacts"].count
        //print("contactCount: \(contactCount)")
        for i in 0 ..< contactCount {
            //print("contactID: " + self.customerJSON["customer"]["contacts"][i]["ID"].string!)
            switch  self.customerJSON["customer"]["contacts"][i]["type"].string! {
            //phone
            case "1":
                //print("case = phone")
                 //print("phone = \(self.customerJSON["customer"]["contacts"][i]["value"].string!)")
                //print("phone = \(self.customerJSON["customer"]["contacts"][i]["value"].string!)")
                    self.phone = self.customerJSON["customer"]["contacts"][i]["value"].string!
                    if self.customerJSON["customer"]["contacts"][i]["name"] != JSON.null
                    {
                        self.phoneName = " (" + self.customerJSON["customer"]["contacts"][i]["name"].string! + ")"
                        //print("self.phoneName = \(self.phoneName)")
                    }
                break
            //email
            case "2":
                //print("case = email")
                    self.email = self.customerJSON["customer"]["contacts"][i]["value"].string!
                    if self.customerJSON["customer"]["contacts"][i]["name"] != JSON.null
                    {
                        self.emailName =  " (" + self.customerJSON["customer"]["contacts"][i]["name"].string! + ")"
                    }
                break
                
            //job site address
            case "4":
                
                self.jobSiteAddress = self.customerJSON["customer"]["contacts"][i]["fullAddress"].stringValue
                self.lat = self.customerJSON["customer"]["contacts"][i]["lat"].stringValue as NSString
                self.lng = self.customerJSON["customer"]["contacts"][i]["lng"].stringValue as NSString
                //print(" lat \(self.lat)")
                
                
            break
                
            default :
                break
                
            }
            
        }
        
        
        self.getLeads(_openNewLead:false)
    }
    
    
    func getLeads(_openNewLead:Bool){
       // print("getLeads")
        
        self.customerLeadArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)", "custID":self.customerID]
        //print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leads.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
               // print("lead response = \(response)")
            }
            .responseJSON() {
                response in
                
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let leads = json["leads"] as? [[String: Any]] {
                        
                        let leadCount = leads.count
                       // print("lead count = \(leadCount)")
                        
                        
                        for i in 0 ..< leadCount {
                            
                            
                            //create an object
                           // print("create a lead object \(i)")
                            
                            
                            //as! String
                            let lead =  Lead(_ID: leads[i]["ID"] as? String, _statusID: leads[i]["status"] as? String, _scheduleType: leads[i]["timeType"] as? String, _date: leads[i]["date"] as? String, _time: leads[i]["time"] as? String, _statusName: leads[i]["statusName"] as? String, _customer: leads[i]["customer"] as? String, _customerName: leads[i]["custName"] as? String, _urgent: leads[i]["urgent"] as? String, _description: leads[i]["description"] as? String, _rep: leads[i]["salesRep"] as? String, _repName: leads[i]["repName"] as? String, _deadline: leads[i]["deadline"] as? String, _requestedByCust: leads[i]["requestedByCust"] as? String, _createdBy: leads[i]["createdBy"] as? String, _daysAged: leads[i]["daysAged"] as? String)
                            
                            lead.dateNice = leads[i]["dateNice"] as? String
                            
                            lead.custNameAndID = "\(lead.customerName!) #\(lead.ID!)"
                            
                           // print("json zone = \(leads[i]["zone"] as! String)")
                            
                           
                            
                            
                            self.customerLeadArray.append(lead)
                            
                            
                            
                            
                            
                        }
                    }
                    
                    
                   
                  
                    if _openNewLead {
                       // print("open new lead")
                        
                        
                        
                        
                        self.leadViewController = LeadViewController(_lead: self.customerLeadArray[0])
                        self.leadViewController.delegate = self
                        self.navigationController?.pushViewController(self.leadViewController, animated: false )
                        
                        
                        
                    }else{
                            //for initial view, continue on to load cust schedule
                            self.getContracts(_openNewContract: false)
                            
                       
                        
                    }
                    
                    
                    
                } catch {
                   // print("Error deserializing JSON: \(error)")
                }
                
                
                
        }
        
    }
    
    
    
    
    
    
    
    func getContracts(_openNewContract :Bool){
        //print("getContracts")
        
        self.customerContractArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)", "custID":self.customerID]
       // print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/contracts.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
               // print("contract response = \(response)")
            }
            .responseJSON() {
                response in
                
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let contracts = json["contracts"] as? [[String: Any]] {
                        
                        let contractCount = contracts.count
                       // print("contract count = \(contractCount)")
                        
                        
                        for i in 0 ..< contractCount {
                            
                            
                            //create an object
                           // print("create a contract object \(i)")
                            
                            
                            
                            
                            //as! String
                            let contract = Contract(_ID: contracts[i]["ID"] as? String, _title: contracts[i]["title"] as? String, _status: contracts[i]["status"] as? String, _statusName: contracts[i]["statusName"] as? String, _chargeType: contracts[i]["chargeType"] as? String, _customer: contracts[i]["customer"] as? String, _customerName: contracts[i]["custName"] as? String, _notes: contracts[i]["notes"] as? String, _salesRep: contracts[i]["salesRep"] as? String, _repName: contracts[i]["repName"] as? String, _createdBy: contracts[i]["createdBy"] as? String, _createDate: contracts[i]["createDate"] as? String, _subTotal: contracts[i]["subTotal"] as? String, _taxTotal: contracts[i]["taxTotal"] as? String, _total: contracts[i]["total"] as? String, _terms: contracts[i]["termsDescription"] as? String, _daysAged: contracts[i]["daysAged"] as? String)
                            
                            
                            
                            
                            contract.custNameAndID = "\(contract.customerName!) #\(contract.ID!)"
                            
                            contract.customerSignature  = contracts[i]["customerSigned"]as! String
                            
                            
                            
                            self.customerContractArray.append(contract)
                            
                            
                            
                            
                            
                            
                        }
                    }
                    
                    
                    
                   
                self.getCustomerSchedule(_id: self.customerID)
                        
                  
                    
                } catch {
                    //print("Error deserializing JSON: \(error)")
                }
                
                
        }
        
    }
    
    
    
    func getCustomerSchedule(_id:String){
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        

        
        Alamofire.request(API.Router.workOrderList(["empID":"" as AnyObject,"custID":_id as AnyObject,"active":"1" as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            
            
            
            //native way
            
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let workOrders = json["workOrder"] as? [[String: Any]] {
                    
                    let workOrderCount = workOrders.count
                  //  print("work order count = \(workOrderCount)")
                    
                    
                    for i in 0 ..< workOrderCount {
                        
                        
                        //create an object
                        //print("create a work order object \(i)")
                        
                        
                        
                        let workOrder = WorkOrder(_ID: workOrders[i]["ID"] as? String, _statusID: workOrders[i]["statusID"] as? String, _date: workOrders[i]["date"] as? String, _firstItem: workOrders[i]["firstItem"] as? String, _statusName: workOrders[i]["statusName"] as? String, _customer: workOrders[i]["customer"] as? String, _type: workOrders[i]["type"] as? String, _progress: workOrders[i]["progress"] as? String, _totalPrice: workOrders[i]["totalPrice"] as? String, _totalCost: workOrders[i]["totalCost"] as? String, _totalPriceRaw: workOrders[i]["totalPriceRaw"] as? String, _totalCostRaw: workOrders[i]["totalCostRaw"] as? String, _charge: workOrders[i]["charge"] as? String, _title: workOrders[i]["title"] as? String, _customerName: workOrders[i]["customerName"] as? String)
                        
                        
                        
                        self.customerScheduleArray.append(workOrder)
                        
                        
                        
                    }
                }
                
                    self.getInvoices()
                
            } catch {
                //print("Error deserializing JSON: \(error)")
            }
           
        }
        
    }
    
    
    func getInvoices(){
      //  print("getInvoices")
        
        self.customerInvoiceArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)", "custID":self.customerID]
        //print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/invoices.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
               // print("invoice response = \(response)")
            }
            .responseJSON() {
                response in
                
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let invoices = json["invoices"] as? [[String: Any]] {
                        
                        let invoiceCount = invoices.count
                       // print("invoice count = \(invoiceCount)")
                        
                        
                        for i in 0 ..< invoiceCount {
                            
                            
                            //create an object
                           // print("create a invoice object \(i)")
                            
                            let invoice = Invoice(_ID: (invoices[i]["ID"] as? String)!, _date: (invoices[i]["invoiceDate"] as? String)!,_customer: (invoices[i]["customer"] as? String)!, _customerName: (invoices[i]["custName"] as? String)!, _totalPrice: self.layoutVars.numberAsCurrency(_number:(invoices[i]["total"] as? String)!), _status: (invoices[i]["invoiceStatus"] as? String)!)
                            
                            
                            invoice.title = (invoices[i]["title"] as? String)!
                            
                            
                            self.customerInvoiceArray.append(invoice)
                            
                            
                            
                        }
                    }
                    
                    
                    self.indicator.dismissIndicator()
                  
                    if self.displayImages{
                        self.getImages()
                    }else{
                        
                        self.layoutViews()
                    }
                    
                    
                    
                } catch {
                  //  print("Error deserializing JSON: \(error)")
                }
                
        }
        
    }
    
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        //print("get images")
       
        if imagesLoadedInitial{
            switchTableView(_displayMode: "IMAGES")
            return
        }
        indicator = SDevIndicator.generate(self.view)!
        
        let parameters:[String:String]
        parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID!,"limit": "\(self.limit)","offset": "\(self.offset)", "order":self.order, "customer": self.customerID] as! [String : String] 
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("images response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let images = json["images"] as? [[String: Any]] {
                        
                        let imageCount = images.count
                        //print("image count = \(imageCount)")
                        
                        let thumbBase:String = json["thumbBase"] as! String
                        let mediumBase:String = json["mediumBase"] as! String
                        let rawBase:String = json["rawBase"] as! String
                        
                        
                        self.imagesLoadedInitial = true
                        self.imagesLoaded = true
                        
                        
                        //for image in images {
                        for i in 0 ..< imageCount {
                            
                            let thumbPath:String = "\(thumbBase)\(images[i]["fileName"] as! String)"
                            let mediumPath:String = "\(mediumBase)\(images[i]["fileName"] as! String)"
                            let rawPath:String = "\(rawBase)\(images[i]["fileName"] as! String)"
                            
                            //create a item object
                            //print("create an image object \(i)")
                           
                            let image = Image(_id: images[i]["ID"] as? String,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: images[i]["name"] as? String,_width: images[i]["width"] as? String,_height: images[i]["height"] as? String,_description: images[i]["description"] as? String,_dateAdded: images[i]["dateAdded"] as? String,_createdBy: images[i]["createdByName"] as? String,_type: images[i]["type"] as? String)
                            
                            image.customer = images[i]["customer"] as! String
                            image.customerName = images[i]["customerName"] as! String
                            image.tags = images[i]["tags"] as! String
                            image.liked =  images[i]["liked"] as! String //images[i]["liked"] as! String
                            image.likes = images[i]["likes"] as! String
                            image.index = i
                           
                            self.imageArray.append(image)
                            
                           
                            
                        }
                    }
                    
                    
                    self.imagesLoadedInitial = true
                    
                    if self.viewsLoaded == false{
                        self.layoutViews()
                    }else{
                        self.switchTableView(_displayMode: "IMAGES")
                        
                        
                        if(self.lazyLoad != 0){
                            self.lazyLoad = 0
                            self.imageCollectionView?.reloadData()
                        }
                    }
                    
                    
                   
                } catch {
                    //print("Error deserializing JSON: \(error)")
                }
                
                self.indicator.dismissIndicator()
        }
    }
    
    func layoutViews(){
        ////print("customer view layoutViews")
        //////////   containers for different sections
        
        self.viewsLoaded = true
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.customerView = UIView()
        self.customerView.layer.borderColor = layoutVars.borderColor
        self.customerView.layer.borderWidth = 1.0
        self.customerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.customerView)
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.detailsView)
        
      
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth,"width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight - 235,"collectionViewOffset":(layoutVars.navAndStatusBarHeight - 35) * -1] as [String:Any]
        
        self.customerView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.customerView.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        self.customerView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.customerView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        
        self.detailsView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        
        self.detailsView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 250.0).isActive = true
        self.detailsView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        self.detailsView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 1.0, constant: -250.0).isActive = true
        
        
        ///////////   customer contact section   /////////////
        
        ////print("customer view layoutViews 2")
        //name
        self.customerLbl = GreyLabel()
        self.customerLbl.text = self.customerName
        self.customerLbl.font = layoutVars.largeFont
        self.customerView.addSubview(self.customerLbl)
        
        //phone
        self.phoneNumberClean = cleanPhoneNumber(self.phone)
        
        self.customerPhoneBtn = Button()
        self.customerPhoneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerPhoneBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.customerPhoneBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        ////print("phone = \(self.phone)")
        ////print("phoneName = \(self.phoneName)")
        ////print("phone clean = \(self.phoneNumberClean)")
        self.customerPhoneBtn.setTitle(self.phone + self.phoneName, for: UIControl.State.normal)
        if self.phone != "No Phone Found" {
            self.customerPhoneBtn.addTarget(self, action: #selector(CustomerViewController.phoneHandler), for: UIControl.Event.touchUpInside)
        }
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.contentMode = .scaleAspectFill
        phoneIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.customerPhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        
        self.customerView.addSubview(self.customerPhoneBtn)
        ////print("customer view layoutViews 3")
        
        self.customerEmailBtn = Button()
        self.customerEmailBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerEmailBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.customerEmailBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        
        self.customerEmailBtn.setTitle(self.email + self.emailName, for: UIControl.State.normal)
        if self.email != "No Email Found" {
            self.customerEmailBtn.addTarget(self, action: #selector(CustomerViewController.emailHandler), for: UIControl.Event.touchUpInside)
        }
        
        let emailIcon:UIImageView = UIImageView()
        emailIcon.backgroundColor = UIColor.clear
        emailIcon.contentMode = .scaleAspectFill
        emailIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let emailImg = UIImage(named:"emailIcon.png")
        emailIcon.image = emailImg
        self.customerEmailBtn.titleLabel?.addSubview(emailIcon)
        
        
        self.customerView.addSubview(self.customerEmailBtn)
        
        self.customerAddressBtn = Button()
        self.customerAddressBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerAddressBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.customerAddressBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        
        self.customerAddressBtn.setTitle(self.jobSiteAddress, for: UIControl.State.normal)
        if self.jobSiteAddress != "No Job Site Found" {
            self.customerAddressBtn.addTarget(self, action: #selector(CustomerViewController.mapHandler), for: UIControl.Event.touchUpInside)
        }
        
        ////print("customer view layoutViews 4")
        
        let addressIcon:UIImageView = UIImageView()
        addressIcon.backgroundColor = UIColor.clear
        addressIcon.contentMode = .scaleAspectFill
        addressIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let addressImg = UIImage(named:"mapIcon.png")
        addressIcon.image = addressImg
        self.customerAddressBtn.titleLabel?.addSubview(addressIcon)
        
        
        self.customerView.addSubview(self.customerAddressBtn)
        
        
        self.allContactsBtn = Button()
        self.allContactsBtn.translatesAutoresizingMaskIntoConstraints = false
        self.allContactsBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.allContactsBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.allContactsBtn.setTitle("More Info", for: UIControl.State.normal)
        self.allContactsBtn.addTarget(self, action: #selector(CustomerViewController.showAllContacts), for: UIControl.Event.touchUpInside)
        
        
        self.customerView.addSubview(self.allContactsBtn)
        
        //auto layout group
        let customersViewsDictionary = [
            
            "view2":self.customerLbl,
            "view3":self.customerPhoneBtn,
            "view4":self.customerEmailBtn,
            "view5":self.customerAddressBtn,
            "view6":self.allContactsBtn
            //"view7":self.addLeadBtn
        ] as [String : Any]
         self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view6]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view2(35)]-[view3(40)]-[view4(40)]-[view5(40)]-[view6(40)]", options: [], metrics: sizeVals, views: customersViewsDictionary))
        
        ///////////   Customer Details Section   /////////////
        
       
        customSC = SegmentedControl(items: items)
        customSC.layer.cornerRadius = 0.0
        self.detailsView.addSubview(customSC)
        
        self.customerDetailsTableView.delegate  =  self
        self.customerDetailsTableView.dataSource = self
        self.customerDetailsTableView.rowHeight = 50.0
        self.customerDetailsTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        self.detailsView.addSubview(customerDetailsTableView)
        
       
        
        noLeadsLabel.text = "No Leads"
        noLeadsLabel.textAlignment = NSTextAlignment.center
        noLeadsLabel.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noLeadsLabel)
        
        self.addLeadBtn = Button()
        self.addLeadBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addLeadBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addLeadBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.addLeadBtn.setTitle("Add Lead", for: UIControl.State.normal)
        self.addLeadBtn.addTarget(self, action: #selector(CustomerViewController.addLead), for: UIControl.Event.touchUpInside)
        self.detailsView.addSubview(self.addLeadBtn)
        
        
        noContractsLabel.text = "No Contracts"
        noContractsLabel.textAlignment = NSTextAlignment.center
        noContractsLabel.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noContractsLabel)
        
        self.addContractBtn = Button()
        self.addContractBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addContractBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addContractBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.addContractBtn.setTitle("Add Contract", for: UIControl.State.normal)
        self.addContractBtn.addTarget(self, action: #selector(CustomerViewController.addContract), for: UIControl.Event.touchUpInside)
        self.detailsView.addSubview(self.addContractBtn)
        
        
        
        noScheduleLabel.text = "No Work on Schedule"
        noScheduleLabel.textAlignment = NSTextAlignment.center
        noScheduleLabel.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noScheduleLabel)
        
        self.addWorkOrderBtn = Button()
        self.addWorkOrderBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addWorkOrderBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addWorkOrderBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.addWorkOrderBtn.setTitle("Add Work Order", for: UIControl.State.normal)
        self.addWorkOrderBtn.addTarget(self, action: #selector(CustomerViewController.addWorkOrder), for: UIControl.Event.touchUpInside)
        self.detailsView.addSubview(self.addWorkOrderBtn)
        
        noInvoicesLabel.text = "No Invoices"
        noInvoicesLabel.textAlignment = NSTextAlignment.center
        noInvoicesLabel.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noInvoicesLabel);
        
        self.addInvoiceBtn = Button()
        self.addInvoiceBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addInvoiceBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addInvoiceBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.addInvoiceBtn.setTitle("Add Invoice", for: UIControl.State.normal)
        self.addInvoiceBtn.addTarget(self, action: #selector(CustomerViewController.addInvoice), for: UIControl.Event.touchUpInside)
        self.detailsView.addSubview(self.addInvoiceBtn)
        

        //Images
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50), collectionViewLayout: layout)
        
        self.imageCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        self.detailsView.addSubview(imageCollectionView!)
        imageCollectionView?.isHidden = true
        
       
        self.edgesForExtendedLayout = UIRectEdge.top
        
        self.imageCollectionView?.alwaysBounceVertical = true
        
        
        self.noImagesLbl.text = "No Images Uploaded"
        self.noImagesLbl.textColor = UIColor.white
        self.noImagesLbl.textAlignment = .center
        self.noImagesLbl.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noImagesLbl)
        
        
        self.addImageBtn.addTarget(self, action: #selector(CustomerViewController.addImage), for: UIControl.Event.touchUpInside)
        
        self.addImageBtn.layer.cornerRadius = 0.0
        self.detailsView.addSubview(self.addImageBtn)
        

        
        if self.displayImages == true{
            customSC.selectedSegmentIndex = 4
            
            self.switchTableView(_displayMode: "IMAGES")
        }else{
            customSC.selectedSegmentIndex = 2
            self.switchTableView(_displayMode: "WORKORDERS")
        }
        
        customSC.addTarget(self, action: #selector(self.changeSearchOptions(sender:)), for: .valueChanged)
        
        //auto layout group
        let customerDetailsViewsDictionary = [
            "view1":customSC,
            "view2":customerDetailsTableView,
            "view3":imageCollectionView!,
            "view4":addImageBtn,
            "view5":self.noLeadsLabel,
            "view6":self.noContractsLabel,
            "view7":self.noScheduleLabel,
            "view8":self.noInvoicesLabel,
            "view9":self.noImagesLbl,
            "view10":self.addLeadBtn,
            "view11":self.addContractBtn,
            "view12":self.addWorkOrderBtn,
            "view13":addInvoiceBtn,
        ] as [String : Any]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view4(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view5(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view6(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view7(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view8(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view9(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view10(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view11(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view12(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view13(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)][view2]-40-|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[view3]-40-|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view4(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view5(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view6(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view7(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view8(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view9(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view10(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view11(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view12(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view13(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        
    }
    
    
    @objc func displayEditView(){
        print("display Edit View")
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 2,_view: self) {
            return
        }
        
        //self.equipmentDelegate.disableSearch()
        let editCustomerViewController = NewEditCustomerViewController(_customerID: customerID)
        editCustomerViewController.editDelegate = self
        navigationController?.pushViewController(editCustomerViewController, animated: false )
    }
    
    
    
    
    
    
    @objc func phoneHandler(){
        ////print("phone handler")
        callPhoneNumber(self.phoneNumberClean)
    }
    
    
    @objc func emailHandler(){
        sendEmail(self.email)
    }
    
    @objc func mapHandler() {
        ////print("map handler")
        openMapForPlace(self.customerName, _lat: self.lat!, _lng: self.lng!)
    }
    
    
    
    @objc func showAllContacts(){
         let customerContactViewController = CustomerContactViewController(_customerJSON: self.customerJSON)
        navigationController?.pushViewController(customerContactViewController, animated: false )
        
    }
    
    @objc func addLead(){
        let newLeadViewController = NewEditLeadViewController(_customer: self.customerID, _customerName: self.customerName)
        newLeadViewController.delegate = self
        navigationController?.pushViewController(newLeadViewController, animated: false )
        
    }
    
    @objc func addContract(){
        let newContractViewController = NewEditContractViewController(_customer: self.customerID, _customerName: self.customerName)
        newContractViewController.delegate = self
        navigationController?.pushViewController(newContractViewController, animated: false )
        
    }
    
    @objc func addWorkOrder(){
        let newWorkOrderViewController = NewEditWoViewController(_customer: self.customerID, _customerName: self.customerName)
        newWorkOrderViewController.delegate = self
        navigationController?.pushViewController(newWorkOrderViewController, animated: false )
        
    }
    
    @objc func addInvoice(){
       self.layoutVars.simpleAlert(_vc: self, _title: "New Invoice Creation Coming Soon", _message: "")
    }
    
    
    @objc func changeSearchOptions(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0://leads
            self.switchTableView(_displayMode: "LEADS")
            break
        case 1://contracts
            self.switchTableView(_displayMode: "CONTRACTS")
            break
        case 2://schedule
            self.switchTableView(_displayMode: "WORKORDERS")
            break
        case 3://Invoices
            self.switchTableView(_displayMode: "INVOICES")
            break
        case 4://images
            getImages()
            break
        default:
            
            break
        }
        
    }
    
    
    func updateLikes(_index:Int, _liked:String, _likes:String){
        //print("update likes _liked: \(_liked)  _likes\(_likes)")
        imageArray[_index].liked = _liked
        imageArray[_index].likes = _likes
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableViewMode != "IMAGES"{
            return
        }
        if (scrollView.bounds.maxY == scrollView.contentSize.height) {
            //print("scrolled to bottom")
            lazyLoad = 1
            batch += 1
            offset = batch * limit
            getImages()
        }
    }
    
    
    
    
    @objc func addImage(){
        //print("Add Image")
        
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        var selectedAssets = [DKAsset]()
        
        
        var selectedImages:[Image] = [Image]()
        
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        self.layoutVars.getTopController().present(multiPicker, animated: false) {}
        
        
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            //print("didSelectAssets")
            //print(assets)
            
            for i in 0..<assets.count
            {
                //print("looping images")
                selectedAssets.append(assets[i])
                ////print(self.selectedAssets)
                
                assets[i].fetchOriginalImage(completeBlock: { image, info in
                    
                    
                    //print("making image 1")
                    
                    let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _mediumPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), _type: "")
                    
                    imageToAdd.image = image
                    
                    
                    selectedImages.append(imageToAdd)
                    //print("selectedimages count = \(selectedImages.count)")
                    
                    if selectedImages.count == assets.count{
                      //  self.createPrepView()
                        
                        //print("making prep view")
                        //print("selectedimages count = \(selectedImages.count)")
                        ////print("selectedimages count = \(selectedImages.count)")
                        //print("customerID = \(self.customerID)")
                        
                        
                        
                        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Customer", _customerID: self.customerID, _images: selectedImages)
                        
                        
                        
                        //print("self.selectedImages.count = \(selectedImages.count)")
                        
                        
                        
                        imageUploadPrepViewController.delegate = self
                        
                        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
                        
                        imageUploadPrepViewController.layoutViews()
                        
                        
                        
                    }
                })
            }
            
            
            
            
        }
        
        
    }

    

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(portraitMode == true){
            let totalHeight: CGFloat = (self.view.frame.width / 3 - 1)
            let totalWidth: CGFloat = (self.view.frame.width / 3 - 1)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }else{
            let totalHeight: CGFloat = (self.view.frame.width / 5 - 1)
            let totalWidth: CGFloat = (self.view.frame.width / 5 - 1)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        ////print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
        ////print("name = \(self.imageArray)")
        
            //print("name = \(self.imageArray[indexPath.row].name!)")
            cell.textLabel.text = " \(self.imageArray[indexPath.row].name!)"
            cell.image = self.imageArray[indexPath.row]
            cell.activityView.startAnimating()
            
            //print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
            
        
        
        
        Alamofire.request(self.imageArray[indexPath.row].thumbPath!).responseImage { response in
            //debug//print(response)
            
            //print(response.request!)
            //print(response.response!)
            //debug//print(response.result)
            
            if let image = response.result.value {
                //print("image downloaded: \(image)")
                
                cell.imageView.image = image
                
                cell.activityView.stopAnimating()
            }
        }
        
        
        
        
        //print("view width = \(imageCollectionView?.frame.width)")
        //print("cell width = \(cell.frame.width)")
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        //print("name = \(currentCell.image.name)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image, _ID: currentCell.image.ID)
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: false)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        imageDetailViewController.imageLikeDelegate = self
        
        
        currentImageIndex = indexPath.row
        
        
    }

    
    
    /////////////// TableView Delegate Methods   ///////////////////////

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        var count:Int!
        switch self.tableViewMode{
            
        case "LEADS":
            count = self.customerLeadArray.count
            //print("schedule count = \(count)", terminator: "")
            
            break
            
        case "CONTRACTS":
            count = self.customerContractArray.count
            //print("schedule count = \(count)", terminator: "")
            
            break
        case "WORKORDERS":
            count = self.customerScheduleArray.count
            //print("schedule count = \(count)", terminator: "")
            
            break
        case "INVOICES":
            count = self.customerInvoiceArray.count
            //print("schedule count = \(count)", terminator: "")
            
            break
        
        default:
            count = 0
            break
        }
        
        return count
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customerDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
        
        switch self.tableViewMode{
            
        case "LEADS":
            
            
            //print("Leads customer")
            cell.lead = self.customerLeadArray[indexPath.row]
            cell.layoutViews(_scheduleMode: "LEAD")
            
            
            cell.dateLbl.textColor = UIColor.red
            switch cell.lead!.daysAged! {
            case "0":
                cell.dateLbl.text = "Today"
                break
            case "1":
                cell.dateLbl.text = "\(cell.lead!.daysAged!) Day Old"
                break
                
            default:
                cell.dateLbl.text = "\(cell.lead!.daysAged!) Days Old"
            }
            
            
            
            
            cell.firstItemLbl.text = cell.lead!.description!
            cell.setStatus(status: cell.lead!.statusId)
            
            
            
            break
            
        case "CONTRACTS":
            
            //print("Contracts customer")
            
            cell.contract = self.customerContractArray[indexPath.row]
            cell.layoutViews(_scheduleMode: "CONTRACT")
            
            cell.dateLbl.textColor = UIColor.red
            switch cell.contract!.daysAged! {
            case "0":
                cell.dateLbl.text = "Today"
                break
            case "1":
                cell.dateLbl.text = "\(cell.contract!.daysAged!) Day Old"
                break
                
            default:
                cell.dateLbl.text = "\(cell.contract!.daysAged!) Days Old"
            }
            
            
            cell.firstItemLbl.text = "\(String(describing: cell.contract!.title!)) #\(cell.contract!.ID!)"
            cell.setStatus(status: (cell.contract!.status)!,type:"CONTRACT")
            
            
            
            break
            
            
            
        case "WORKORDERS":
            
            //print("Schedule customer")
            cell.workOrder = self.customerScheduleArray[indexPath.row]
            cell.layoutViews(_scheduleMode: "CUSTOMER")
            cell.dateLbl.text = cell.workOrder.date
            cell.firstItemLbl.text = "\(cell.workOrder.title!) #\(cell.workOrder.ID!)"
            cell.setStatus(status: cell.workOrder.statusId)
           
            
            
            
            cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
            
          
            cell.priceLbl.text = cell.workOrder.totalPrice!
             //print("cell.workOrder.totalPrice! = \(cell.workOrder.totalPrice!)")
            
            cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
            
            
            
            
            
            
            break
        
        case "INVOICES":
            
            //print("invoice customer")
            cell.invoice = self.customerInvoiceArray[indexPath.row]
            
            cell.layoutViews(_scheduleMode: "INVOICE")
            cell.dateLbl.text = cell.invoice!.date!
            cell.titleLbl.text = cell.invoice!.title!
            cell.IDLbl.text = cell.invoice!.ID!
            cell.priceLbl.text = cell.invoice!.totalPrice!

            
            //print("set invoice cell status = \(cell.invoice!.status!)")
            cell.setStatus(status: cell.invoice!.status!, type: "INVOICE")
            
            
            
        
            break
        default:
            
            break
        }
        
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! ScheduleTableViewCell;
        
        
        
        switch self.tableViewMode{
            
        case "LEADS":
            let leadViewController = LeadViewController(_lead: currentCell.lead!)
        
            navigationController?.pushViewController(leadViewController, animated: false )
            
            leadViewController.delegate = self
            
            
            tableView.deselectRow(at: indexPath!, animated: false)
            break
        case "CONTRACTS":
            let contractViewController = ContractViewController(_contract: currentCell.contract!)
            
            navigationController?.pushViewController(contractViewController, animated: false )
            
            contractViewController.delegate = self
            
            tableView.deselectRow(at: indexPath!, animated: false)
            break
        case "WORKORDERS":
            let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.workOrder.ID)
            navigationController?.pushViewController(workOrderViewController, animated: false )
            
            workOrderViewController.scheduleDelegate = self
            
            workOrderViewController.scheduleIndex = indexPath?.row
            
            
            tableView.deselectRow(at: indexPath!, animated: false)
            break
        case "INVOICES":
           
            
            let invoiceViewController = InvoiceViewController(_invoice: currentCell.invoice!)
            invoiceViewController.delegate = self
            invoiceViewController.index = indexPath?.row
            
            navigationController?.pushViewController(invoiceViewController, animated: false )
            
            tableView.deselectRow(at: indexPath!, animated: false)
            break
        default:
            
            break
        }
        
        
        
        
    }
    
    
    
    //for redrawing tables after status change
    func reDrawSchedule(_index:Int, _status:String, _price: String, _cost: String, _priceRaw: String, _costRaw: String){
        //print("reDraw Schedule")
        //print("_status =  \(_status)")
        //print("_price =  \(_price)")
        //print("_cost =  \(_cost)")
        //print("_index =  \(_index)")
        
        
        
                
            customerScheduleArray[_index].statusId = _status
            customerScheduleArray[_index].totalPrice = _price
            customerScheduleArray[_index].totalCost = _cost
            customerScheduleArray[_index].totalPriceRaw = _priceRaw
            customerScheduleArray[_index].totalCostRaw = _costRaw
        
            self.customerDetailsTableView.reloadData()
 
        
    }

    
    
    
    
    
    
    func getPrevNextImage(_next:Bool){
            if(_next == true){
                if(currentImageIndex + 1) > (self.imageArray.count - 1){
                    currentImageIndex = 0
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                    
                    
                }else{
                    currentImageIndex = currentImageIndex + 1
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imageArray.count - 1
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex - 1
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
            }
        
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: true)
        
        
        
    }
    
    
    
    
    func refreshImages(_images:[Image], _scoreAdjust:Int){
        //print("refreshImages")
        
        self.noImagesLbl.isHidden = true
        for insertImage in _images{
            
            imageArray.insert(insertImage, at: 0)
        }
        
        
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
    }
    
    
   
    
    func updateSchedule() {
        //print("update schedule")
    }
    
    // not used, just to have this class conform to schedule delegate protocol
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _mowSort:String, _plowSort:String, _plowDepth:String){
        //print("update settings")
    }
    
    
    
    func switchTableView(_displayMode:String){
        //print("switch table view")
        
        
        switch _displayMode {
        case "LEADS":
            self.tableViewMode = "LEADS"
            self.customerDetailsTableView.reloadData()
            self.imageCollectionView?.isHidden = true
            
            
            addLeadBtn.isHidden = false
            addContractBtn.isHidden = true
            addWorkOrderBtn.isHidden = true
            addInvoiceBtn.isHidden = true
            addImageBtn.isHidden = true
            
            noContractsLabel.isHidden = true
            noScheduleLabel.isHidden = true
            noInvoicesLabel.isHidden = true
            noImagesLbl.isHidden = true
            
        if self.customerLeadArray.count > 0 {
            self.customerDetailsTableView.isHidden = false;
            self.customerDetailsTableView.alpha = 1.0
            self.noLeadsLabel.isHidden = true
        } else {
            //self.customerDetailsTableView.isHidden = true;
            self.customerDetailsTableView.alpha = 0.5
            self.noLeadsLabel.isHidden = false
        }
        
            break
        case "CONTRACTS":
            self.tableViewMode = "CONTRACTS"
            self.customerDetailsTableView.reloadData()
            self.imageCollectionView?.isHidden = true
            
            addLeadBtn.isHidden = true
            addContractBtn.isHidden = false
            addWorkOrderBtn.isHidden = true
            addInvoiceBtn.isHidden = true
            addImageBtn.isHidden = true
            
            noLeadsLabel.isHidden = true
            noScheduleLabel.isHidden = true
            noInvoicesLabel.isHidden = true
            noImagesLbl.isHidden = true
            
            if self.customerContractArray.count > 0 {
                self.customerDetailsTableView.isHidden = false;
                self.customerDetailsTableView.alpha = 1.0
                self.noContractsLabel.isHidden = true
            } else {
                //self.customerDetailsTableView.isHidden = true;
                self.customerDetailsTableView.alpha = 0.5
                self.noContractsLabel.isHidden = false
            }
            
            break
        case "WORKORDERS":
            self.tableViewMode = "WORKORDERS"
            self.customerDetailsTableView.reloadData()
            self.imageCollectionView?.isHidden = true
            
            addLeadBtn.isHidden = true
            addContractBtn.isHidden = true
            addWorkOrderBtn.isHidden = false
            addInvoiceBtn.isHidden = true
            addImageBtn.isHidden = true
            
            noLeadsLabel.isHidden = true
            noContractsLabel.isHidden = true
            noInvoicesLabel.isHidden = true
            noImagesLbl.isHidden = true
            
            if self.customerScheduleArray.count > 0 {
                self.customerDetailsTableView.isHidden = false;
                self.customerDetailsTableView.alpha = 1.0
                self.noScheduleLabel.isHidden = true
            } else {
                //self.customerDetailsTableView.isHidden = true;
                self.customerDetailsTableView.alpha = 0.5
                self.noScheduleLabel.isHidden = false
            }
            
            break
        case "INVOICES":
            self.tableViewMode = "INVOICES"
            self.customerDetailsTableView.reloadData()
            self.imageCollectionView?.isHidden = true
            
            addLeadBtn.isHidden = true
            addContractBtn.isHidden = true
            addWorkOrderBtn.isHidden = true
            addInvoiceBtn.isHidden = false
            addImageBtn.isHidden = true
            
            noLeadsLabel.isHidden = true
            noContractsLabel.isHidden = true
            noScheduleLabel.isHidden = true
            noImagesLbl.isHidden = true
            
            if self.customerInvoiceArray.count > 0 {
                self.customerDetailsTableView.isHidden = false;
                self.customerDetailsTableView.alpha = 1.0
                self.noInvoicesLabel.isHidden = true
            } else {
                //self.customerDetailsTableView.isHidden = true;
                self.customerDetailsTableView.alpha = 0.5
                self.noInvoicesLabel.isHidden = false
            }
            
            break
        case "IMAGES":
            
            self.customerDetailsTableView.isHidden = true
            
            addLeadBtn.isHidden = true
            addContractBtn.isHidden = true
            addWorkOrderBtn.isHidden = true
            addInvoiceBtn.isHidden = true
            addImageBtn.isHidden = false
            
            noLeadsLabel.isHidden = true
            noContractsLabel.isHidden = true
            noScheduleLabel.isHidden = true
            noInvoicesLabel.isHidden = true
            
            if self.imageArray.count > 0 {
                self.imageCollectionView!.isHidden = false;
                self.imageCollectionView!.alpha = 1.0
                self.imageCollectionView!.reloadData()
                self.noImagesLbl.isHidden = true
            } else {
                //self.customerDetailsTableView.isHidden = true;
                self.imageCollectionView!.alpha = 0.5
                self.noImagesLbl.isHidden = false
            }
            
            break
        default:
            break
            //print("default")
        }
        
        
        
    }
    
    func updateInvoice(_atIndex:Int,_status:String){
        self.customerInvoiceArray[_atIndex].status  = _status
        self.customerDetailsTableView.reloadData()
        self.switchTableView(_displayMode: "INVOICES")
    }
    
    
    func updateCustomer(_customerID:String){
        //print("updateCustomer")
        getCustomerData(_id: _customerID)
        
        
        if customerListDelegate != nil{
           customerListDelegate.updateList(_customerID: _customerID, _newCustomer: false)
        }
    }
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    
    func showCustomerImages(_customer:String){
        //print("show customer images cust: \(_customer)")
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
