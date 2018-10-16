//
//  CustomerViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
//import Nuke
import DKImagePickerController

protocol CustomerDelegate{
    func cancelSearch()//to resolve problem with imageSelection bug when search mode is active
}


class CustomerViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, ScheduleDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ImageViewDelegate, ImageLikeDelegate, CustomerDelegate, LeadListDelegate{
    
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
    let items = ["Leads","Schedule","History","Images"]
    var customSC:SegmentedControl!
    
    
    var customerDetailsTableView:TableView = TableView()
    var tableViewMode:String = "SCHEDULE"
    
    var leadsLoaded:Bool = false
    var customerLeads: JSON!
    var customerLeadArray:[Lead] = []
    
    var leadViewController:LeadViewController!
    
    var addLeadBtn:Button!
    
    var scheduleLoaded:Bool = false
    var customerSchedule: JSON!
    var customerScheduleArray:[WorkOrder] = []
    
    var historyLoaded:Bool = false
    var customerHistory: JSON!
    var customerHistoryArray:[WorkOrder] = []
    
    //var customerCommunication: JSON!
    
    var noLeadsLabel:Label = Label()
    var noScheduleLabel:Label = Label()
    var noHistoryLabel:Label = Label()
    
    var totalImages:Int!
    var images: JSON!
    var imageArray:[Image] = []
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    var addImageBtn:Button = Button(titleText: "Add Images")
    
    var imagesLoadedInitial:Bool = false
    var imagesLoaded:Bool = false
    var currentImageIndex:Int = 0
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var refresher:UIRefreshControl!
    var displayImages:Bool?
    var customerListDelegate:CustomerListDelegate!
    
    //var leadListDelegate:LeadListDelegate!
    
    var noImagesLbl:Label = Label()
    
    
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
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
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
                print("JSON: \(json)")
                self.customerJSON = JSON(json)
                self.parseCustomerJSON()
                
            }
        }
        
    }
    
    func parseCustomerJSON(){
        
        
        print("parse customerJSON: \(self.customerJSON)")
        
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
                //check if address is same as one displayed in customer list
                //print("case = address")
                //print(self.customerJSON["customer"]["contacts"][i]["main"].stringValue)
                //print(self.customerJSON["customer"]["contacts"][i]["ID"].stringValue)
                ////print(self.customer.contactID)
                //print(self.customerJSON["customer"]["contacts"][i])
                
                self.jobSiteAddress = self.customerJSON["customer"]["contacts"][i]["fullAddress"].stringValue
                self.lat = self.customerJSON["customer"]["contacts"][i]["lat"].stringValue as NSString
                self.lng = self.customerJSON["customer"]["contacts"][i]["lng"].stringValue as NSString
                //print(" lat \(self.lat)")
                
                
            break
                
            default :
                break
                
            }
            
        }
        
        //getCustomerSchedule(_id: self.customerID)
        self.getLeads(_openNewLead:false)
    }
    
    
    func getLeads(_openNewLead:Bool){
        print("getLeads")
        
        self.customerLeadArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)", "custID":self.customerID]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leads.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("lead response = \(response)")
            }
            .responseJSON() {
                response in
                if let json = response.result.value {
                    self.customerLeads = JSON(json)
                    
                    let jsonCount = self.customerLeads["leads"].count
                    print("JSONcount: \(jsonCount)")
                    for i in 0 ..< jsonCount {
                        let lead =  Lead(_ID: self.customerLeads["leads"][i]["ID"].stringValue, _statusID: self.customerLeads["leads"][i]["status"].stringValue, _scheduleType: self.customerLeads["leads"][i]["timeType"].stringValue, _date: self.customerLeads["leads"][i]["date"].stringValue, _time: self.customerLeads["leads"][i]["time"].stringValue, _statusName: self.customerLeads["leads"][i]["statusName"].stringValue, _customer: self.customerLeads["leads"][i]["customer"].stringValue, _customerName: self.customerLeads["leads"][i]["custName"].stringValue, _urgent: self.customerLeads["leads"][i]["urgent"].stringValue, _description: self.customerLeads["leads"][i]["description"].stringValue, _rep: self.customerLeads["leads"][i]["salesRep"].stringValue, _repName: self.customerLeads["leads"][i]["repName"].stringValue, _deadline: self.customerLeads["leads"][i]["deadline"].stringValue, _requestedByCust: self.customerLeads["leads"][i]["requestedByCust"].stringValue, _createdBy: self.customerLeads["leads"][i]["createdBy"].stringValue, _daysAged: self.customerLeads["leads"][i]["daysAged"].stringValue)
                        
                        lead.dateNice = self.customerLeads["leads"][i]["dateNice"].stringValue
                        
                        lead.custNameAndID = "\(lead.customerName!) #\(lead.ID!)"
                        self.customerLeadArray.append(lead)
                    }
                    //self.indicator.dismissIndicator()
                    
                    //if self.tableRefresh {
                    // self.leadTableView.reloadData()
                    //}else{
                   // self.layoutViews()
                    //}
                    
                    
                    
                    
                    
                    self.leadsLoaded = true
                    
                    if self.customerLeadArray.count > 0 {
                        self.customerDetailsTableView.isHidden = false
                        self.customerDetailsTableView.alpha = 1.0
                        self.noLeadsLabel.isHidden = true
                    } else {
                        //self.customerDetailsTableView.isHidden = true
                        self.customerDetailsTableView.alpha = 0.5
                        self.noLeadsLabel.isHidden = false
                    }
                    
                    
                    
                    
                    if _openNewLead {
                        print("open new lead")
                        
                        
                        
                        self.customerDetailsTableView.reloadData()
                        
                        self.leadViewController = LeadViewController(_lead: self.customerLeadArray[0])
                        self.leadViewController.delegate = self
                        self.navigationController?.pushViewController(self.leadViewController, animated: false )
                        
                        
                        
                    }else{
                        if !self.scheduleLoaded{
                            //for initial view, continue on to load cust schedule
                            self.getCustomerSchedule(_id: self.customerID)
                            
                        }else{
                            //for returning views
                            self.customerDetailsTableView.reloadData()
                        }
                        
                    }
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
            
            if let json = response.result.value {
                self.customerSchedule = JSON(json)
                self.parseCustomerScheduleJSON()
                
            }
        }
        
    }
    
    
    
    func parseCustomerScheduleJSON(){
        
        
        //print("parse customerSchedule: \(self.customerSchedule)")
        
        //loop through contacts and put them in appropriate places
        let workOrderCount:Int = self.customerSchedule["workOrder"].count
        //print("workOrderCount: \(workOrderCount)")
        for i in 0 ..< workOrderCount {
            //print("ID: " + self.customerSchedule["workOrder"][i]["ID"].stringValue)
            let workOrder = WorkOrder(_ID: self.customerSchedule["workOrder"][i]["ID"].stringValue, _statusID: self.customerSchedule["workOrder"][i]["statusID"].stringValue, _date: self.customerSchedule["workOrder"][i]["date"].stringValue, _firstItem: self.customerSchedule["workOrder"][i]["firstItem"].stringValue, _statusName: self.customerSchedule["workOrder"][i]["statusName"].stringValue, _customer: self.customerSchedule["workOrder"][i]["customer"].stringValue, _type: self.customerSchedule["workOrder"][i]["type"].stringValue, _progress: self.customerSchedule["workOrder"][i]["progress"].stringValue, _totalPrice: self.customerSchedule["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.customerSchedule["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.customerSchedule["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.customerSchedule["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.customerSchedule["workOrder"][i]["charge"].stringValue, _title: self.customerSchedule["workOrder"][i]["title"].stringValue, _customerName: self.customerSchedule["workOrder"][i]["customerName"].stringValue)
            self.customerScheduleArray.append(workOrder)
        }
        scheduleLoaded = true
        self.indicator.dismissIndicator()
      //self.getImages()
        
        self.layoutViews()
    }
    

    func getImages() {
        //remove any added views (needed for table refresh
        
        print("get images")
       // imageArray = []
       
        indicator = SDevIndicator.generate(self.view)!
        
        //let parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "customer": self.customerID as AnyObject]
        let parameters:[String:String]
        parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID!,"limit": "\(self.limit)","offset": "\(self.offset)", "order":self.order, "customer": self.customerID] as! [String : String] 
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("images response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.images = JSON(json)
                    
                    self.imagesLoadedInitial = true
                    self.imagesLoaded = true
                    
                    
                    self.parseJSON()
                    
                }
                
               
                self.indicator.dismissIndicator()
        }
    }
    
    
    func parseJSON(){
        let jsonCount = self.images["images"].count
        self.totalImages = jsonCount
        print("JSONcount: \(jsonCount)")
        
        
        
        let thumbBase:String = self.images["thumbBase"].stringValue
        let mediumBase:String = self.images["mediumBase"].stringValue
        let rawBase:String = self.images["rawBase"].stringValue
        
        for i in 0 ..< jsonCount {
            
            let thumbPath:String = "\(thumbBase)\(self.images["images"][i]["fileName"].stringValue)"
            let mediumPath:String = "\(mediumBase)\(self.images["images"][i]["fileName"].stringValue)"
            let rawPath:String = "\(rawBase)\(self.images["images"][i]["fileName"].stringValue)"
            
            //create a item object
            print("create an image object \(i)")
            
            let image = Image(_id: self.images["images"][i]["ID"].stringValue,_thumbPath: thumbPath, _mediumPath: mediumPath,_rawPath: rawPath,_name: self.images["images"][i]["name"].stringValue,_width: self.images["images"][i]["width"].stringValue,_height: self.images["images"][i]["height"].stringValue,_description: self.images["images"][i]["description"].stringValue,_dateAdded: self.images["images"][i]["dateAdded"].stringValue,_createdBy: self.images["images"][i]["createdByName"].stringValue,_type: self.images["images"][i]["type"].stringValue)
            
            image.customer = self.images["images"][i]["customer"].stringValue
            image.customerName = self.images["images"][i]["customerName"].stringValue
            image.tags = self.images["images"][i]["tags"].stringValue
            image.liked = self.images["images"][i]["liked"].stringValue
            image.likes = self.images["images"][i]["likes"].stringValue
            image.index = i
            
            self.imageArray.append(image)
            
        }        
        //self.layoutViews()
        
        if self.self.imageArray.count > 0 {
            self.noImagesLbl.isHidden = true
        } else {
            self.noImagesLbl.isHidden = false
        }
        
        if imagesLoadedInitial{
            self.imageCollectionView?.reloadData()
        }
        
        if(lazyLoad != 0){
            lazyLoad = 0
            self.imageCollectionView?.reloadData()
        }
        
        
        
    }
    

    //history is delayed until user clicks history tab
    
    func getCustomerHistory(_id:String){
        
        indicator = SDevIndicator.generate(self.view)!
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)

        
        Alamofire.request(API.Router.workOrderList(["empID":"" as AnyObject,"custID":_id as AnyObject,"active":"0" as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {

            
            
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                //print("JSON: \(json)")
                self.customerHistory = JSON(json)
                self.parseCustomerHistoryJSON()
                self.historyLoaded = true
                
            }
        }
    }
    
    
    
    func parseCustomerHistoryJSON(){
        
        //print("parse customerHistory: \(self.customerHistory)")
        
        //loop through contacts and put them in appropriate places
        let workOrderCount:Int = self.customerHistory["workOrder"].count
        //print("workOrderCount: \(workOrderCount)")
        for i in 0 ..< workOrderCount {
            //print("ID: " + self.customerHistory["workOrder"][i]["ID"].stringValue)
            let workOrder = WorkOrder(_ID: self.customerHistory["workOrder"][i]["ID"].stringValue, _statusID: self.customerHistory["workOrder"][i]["statusID"].stringValue, _date: self.customerHistory["workOrder"][i]["date"].stringValue, _firstItem: self.customerHistory["workOrder"][i]["firstItem"].stringValue, _statusName: self.customerHistory["workOrder"][i]["statusName"].stringValue, _customer: self.customerHistory["workOrder"][i]["customer"].stringValue, _type: self.customerHistory["workOrder"][i]["type"].stringValue, _progress: self.customerHistory["workOrder"][i]["progress"].stringValue, _totalPrice: self.customerHistory["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.customerHistory["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.customerHistory["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.customerHistory["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.customerSchedule["workOrder"][i]["charge"].stringValue, _title: self.customerSchedule["workOrder"][i]["title"].stringValue, _customerName: self.customerSchedule["workOrder"][i]["customerName"].stringValue)
            self.customerHistoryArray.append(workOrder)
        }
        
        
        
        self.customerDetailsTableView.reloadData()
        
        if self.customerHistoryArray.count > 0 {
            //self.customerDetailsTableView.isHidden = false;
            self.customerDetailsTableView.alpha = 1.0
            self.noHistoryLabel.isHidden = true
        } else {
            //self.customerDetailsTableView.isHidden = true;
            self.customerDetailsTableView.alpha = 0.5
            self.noHistoryLabel.isHidden = false
        }
        
        self.indicator.dismissIndicator()
        
        
    }
    
    
    
    
    
    func layoutViews(){
        //print("customer view layoutViews")
        //////////   containers for different sections
        self.customerView = UIView()
        self.customerView.layer.borderColor = layoutVars.borderColor
        self.customerView.layer.borderWidth = 1.0
        self.customerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.customerView)
        
        
        
        
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.detailsView)
        
        
        
        //print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.customerView,
        "view2":self.detailsView] as [String:Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth,"width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight - 235,"collectionViewOffset":(layoutVars.navAndStatusBarHeight - 35) * -1] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1(250)][view2]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
        ///////////   customer contact section   /////////////
        
        //print("customer view layoutViews 2")
        //name
        self.customerLbl = GreyLabel()
        self.customerLbl.text = self.customerName
        self.customerLbl.font = layoutVars.largeFont
        self.customerView.addSubview(self.customerLbl)
        
        //phone
        self.phoneNumberClean = cleanPhoneNumber(self.phone)
        
        self.customerPhoneBtn = Button()
        self.customerPhoneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerPhoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.customerPhoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 40.0, 0.0, 0.0)
        
        //print("phone = \(self.phone)")
        //print("phoneName = \(self.phoneName)")
        //print("phone clean = \(self.phoneNumberClean)")
        self.customerPhoneBtn.setTitle(self.phone + self.phoneName, for: UIControlState.normal)
        if self.phone != "No Phone Found" {
            self.customerPhoneBtn.addTarget(self, action: #selector(CustomerViewController.phoneHandler), for: UIControlEvents.touchUpInside)
        }
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.contentMode = .scaleAspectFill
        phoneIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.customerPhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        
        self.customerView.addSubview(self.customerPhoneBtn)
        //print("customer view layoutViews 3")
        
        
        
        
        self.customerEmailBtn = Button()
        self.customerEmailBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerEmailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.customerEmailBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 40.0, 0.0, 0.0)
        
        
        self.customerEmailBtn.setTitle(self.email + self.emailName, for: UIControlState.normal)
        if self.email != "No Email Found" {
            self.customerEmailBtn.addTarget(self, action: #selector(CustomerViewController.emailHandler), for: UIControlEvents.touchUpInside)
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
        self.customerAddressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.customerAddressBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 40.0, 0.0, 0.0)
        
        
        self.customerAddressBtn.setTitle(self.jobSiteAddress, for: UIControlState.normal)
        if self.jobSiteAddress != "No Job Site Found" {
            self.customerAddressBtn.addTarget(self, action: #selector(CustomerViewController.mapHandler), for: UIControlEvents.touchUpInside)
        }
        
        //print("customer view layoutViews 4")
        
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
        self.allContactsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        self.allContactsBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        self.allContactsBtn.setTitle("More Info", for: UIControlState.normal)
        self.allContactsBtn.addTarget(self, action: #selector(CustomerViewController.showAllContacts), for: UIControlEvents.touchUpInside)
        
        
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
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view6]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view2(35)]-[view3(40)]-[view4(40)]-[view5(40)]-[view6(40)]", options: [], metrics: sizeVals, views: customersViewsDictionary))
        
        
        
        ///////////   Customer Details Section   /////////////
        
       
        customSC = SegmentedControl(items: items)
        customSC.selectedSegmentIndex = 1
        customSC.layer.cornerRadius = 0.0
        
        
        
        customSC.addTarget(self, action: #selector(self.changeSearchOptions(sender:)), for: .valueChanged)
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
        noLeadsLabel.isHidden = true
        
        self.addLeadBtn = Button()
        self.addLeadBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addLeadBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        self.addLeadBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        self.addLeadBtn.setTitle("Add Lead", for: UIControlState.normal)
        self.addLeadBtn.addTarget(self, action: #selector(CustomerViewController.addLead), for: UIControlEvents.touchUpInside)
        self.detailsView.addSubview(self.addLeadBtn)
        self.addLeadBtn.isHidden = true
        
        noScheduleLabel.text = "No Work on Schedule"
        noScheduleLabel.textAlignment = NSTextAlignment.center
        noScheduleLabel.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noScheduleLabel)
        
        noHistoryLabel.text = "No Work History"
        noHistoryLabel.textAlignment = NSTextAlignment.center
        noHistoryLabel.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noHistoryLabel);
        noHistoryLabel.isHidden = true
        
        if self.customerScheduleArray.count > 0 {
            //self.customerDetailsTableView.isHidden = false;
            self.customerDetailsTableView.alpha = 1.0
            self.noScheduleLabel.isHidden = true
        } else {
            //self.customerDetailsTableView.isHidden = true;
            self.customerDetailsTableView.alpha = 0.5
            self.noScheduleLabel.isHidden = false
        }
        
        
        
        
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
        
        let refresher = UIRefreshControl()
        self.imageCollectionView?.alwaysBounceVertical = true
        
        
        refresher.addTarget(self, action: #selector(CustomerViewController.loadData), for: .valueChanged)
        imageCollectionView?.addSubview(refresher)
        
        
        
        //self.noImagesLbl = GreyLabel()
        self.noImagesLbl.text = "No Images Uploaded"
        self.noImagesLbl.textColor = UIColor.white
        self.noImagesLbl.textAlignment = .center
        self.noImagesLbl.font = layoutVars.largeFont
        self.detailsView.addSubview(self.noImagesLbl)
        self.noImagesLbl.isHidden = true
        
        
        /*
        print("imageArray.count = \(imageArray.count)")
        if self.imageArray.count == 0{
            self.noImagesLbl.isHidden = true
        }else{
            self.noImagesLbl.isHidden = false
        }
        */
        
        
        
        
        self.addImageBtn.addTarget(self, action: #selector(CustomerViewController.addImage), for: UIControlEvents.touchUpInside)
        
        //self.addImageBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addImageBtn.layer.cornerRadius = 0.0
        self.detailsView.addSubview(self.addImageBtn)
        addImageBtn.isHidden = true
        

        
        
        
        
        
        
        //auto layout group
        let customerDetailsViewsDictionary = [
            "view1":customSC,
            "view2":customerDetailsTableView,
            "view3":imageCollectionView!,
            "view4":addImageBtn,
            "view5":self.noLeadsLabel,
            "view6":self.noScheduleLabel,
            "view7":self.noHistoryLabel,
            "view8":self.noImagesLbl,
            "view9":self.addLeadBtn
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
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)][view2]-40-|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[view3]-40-|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view4(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view5(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view6(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view7(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)]-[view8(40)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view9(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        
        if (self.displayImages == true){
            self.showImages()
        }
        
    }
    
    
    @objc func phoneHandler(){
        //print("phone handler")
        
        callPhoneNumber(self.phoneNumberClean)
    }
    
    
    @objc func emailHandler(){
        sendEmail(self.email)
    }
    
    @objc func mapHandler() {
        //print("map handler")
        openMapForPlace(self.customerName, _lat: self.lat!, _lng: self.lng!)
        
        
        
        
    }
    
    
    
    @objc func showAllContacts(){
         let customerContactViewController = CustomerContactViewController(_customerJSON: self.customerJSON)
        navigationController?.pushViewController(customerContactViewController, animated: false )
        
    }
    
    @objc func addLead(){
        self.customerListDelegate.cancelSearch()//to avoid problem with search controller blocking alerts
        let newLeadViewController = NewEditLeadViewController(_customer: self.customerID, _customerName: self.customerName)
        newLeadViewController.delegate = self
        navigationController?.pushViewController(newLeadViewController, animated: false )
        
    }
    
    
    @objc func changeSearchOptions(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
        case 0://leads
            self.tableViewMode = "LEADS"
            
            if(!self.leadsLoaded){
                getLeads(_openNewLead: false)
            }else{
                
                self.customerDetailsTableView.reloadData()
                //noResultsLabel.text = "No Work on Schedule"
                
                
                if self.customerLeadArray.count > 0 {
                    self.customerDetailsTableView.isHidden = false
                    self.customerDetailsTableView.alpha = 1.0
                    self.noLeadsLabel.isHidden = true
                } else {
                    //self.customerDetailsTableView.isHidden = true
                    self.customerDetailsTableView.alpha = 0.5
                    self.noLeadsLabel.isHidden = false
                }
                
                addLeadBtn.isHidden = false
                
                self.noScheduleLabel.isHidden = true
                self.noHistoryLabel.isHidden = true
            
                imageCollectionView?.isHidden = true
                self.noImagesLbl.isHidden = true
                addImageBtn.isHidden = true
            }
            
            
            break
            
        case 1://schedule
            self.tableViewMode = "SCHEDULE"
            self.customerDetailsTableView.reloadData()
            //noResultsLabel.text = "No Work on Schedule"
            if self.customerScheduleArray.count > 0 {
                self.customerDetailsTableView.isHidden = false
                self.customerDetailsTableView.alpha = 1.0
                self.noScheduleLabel.isHidden = true
            } else {
                //self.customerDetailsTableView.isHidden = true
                self.customerDetailsTableView.alpha = 0.5
                self.noScheduleLabel.isHidden = false
            }
            
            addLeadBtn.isHidden = true
            
            self.noLeadsLabel.isHidden = true
            self.noHistoryLabel.isHidden = true
            
            imageCollectionView?.isHidden = true
            self.noImagesLbl.isHidden = true
            addImageBtn.isHidden = true

            
            break
        case 2://history
            self.tableViewMode = "HISTORY"
            if(!self.historyLoaded){
                getCustomerHistory(_id: self.customerID)
            }else{
                self.customerDetailsTableView.reloadData()
                //noResultsLabel.text = "No Work in History"
                if self.customerHistoryArray.count > 0 {
                    self.customerDetailsTableView.isHidden = false
                    self.customerDetailsTableView.alpha = 1.0
                    self.noHistoryLabel.isHidden = true
                } else {
                    //self.customerDetailsTableView.isHidden = true
                    self.customerDetailsTableView.alpha = 0.5
                    self.noHistoryLabel.isHidden = false
                }
                
            }
            
            addLeadBtn.isHidden = true
            
            self.noLeadsLabel.isHidden = true
            self.noScheduleLabel.isHidden = true
            
            imageCollectionView?.isHidden = true
            self.noImagesLbl.isHidden = true
            addImageBtn.isHidden = true

            break
            /*
        case 2://communication
            self.tableViewMode = "COMMUNICATION"
            
            imageCollectionView?.isHidden = true
            addImageBtn.isHidden = true

            
            break
 */
        case 3://images
            
            showImages()
            
            break
        default:
            
            break
        }
        
    }
    
    func showImages(){
        print("show images")
        self.customerDetailsTableView.isHidden = true
        
        addLeadBtn.isHidden = true
        
        self.noLeadsLabel.isHidden = true
        self.noScheduleLabel.isHidden = true
        self.noHistoryLabel.isHidden = true
        
        
        print("imageArray.count = \(imageArray.count)")
        
        
        if(!self.imagesLoaded){
            getImages()
        }else{
        
            if self.imageArray.count > 0 {
                self.noImagesLbl.isHidden = true
            } else {
                self.noImagesLbl.isHidden = false
            }
            
            
            
            
            
        }
        imageCollectionView?.isHidden = false
        addImageBtn.isHidden = false
        
        customSC.selectedSegmentIndex = 3
    }
    
    
    
    @objc func loadData()
    {
        print("loadData")
        getImages()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {   print("stopRefresher")
    }
    
    
    func updateLikes(_index:Int, _liked:String, _likes:String){
        print("update likes _liked: \(_liked)  _likes\(_likes)")
        imageArray[_index].liked = _liked
        imageArray[_index].likes = _likes
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.bounds.maxY == scrollView.contentSize.height) {
            print("scrolled to bottom")
            lazyLoad = 1
            batch += 1
            offset = batch * limit
            getImages()
        }
    }
    
    
    
    
    
    @objc func addImage(){
        print("Add Image")
        

        self.dismiss(animated: false, completion: nil)
        
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        var selectedAssets = [DKAsset]()
        var selectedImages:[Image] = [Image]()
        
        
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        self.layoutVars.getTopController().present(multiPicker, animated: false) {
            print("done")
        }
        
         print("Add Image 1")
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for i in 0..<assets.count
            {
                print("looping images")
                selectedAssets.append(assets[i])
                //print(self.selectedAssets)
                
                assets[i].fetchOriginalImage(completeBlock: { image, info in
                    
                    
                    print("making image")
                    
                    let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _mediumPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), _type: "")
                    
                    imageToAdd.image = image
                    
                    
                    selectedImages.append(imageToAdd)
                    
                })
            }
            
            
            
            print("making prep view")
            print("selectedimages count = \(selectedImages.count)")
            //print("selectedimages count = \(selectedImages.count)")
            print("customerID = \(self.customerID)")
            
            
            
            let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Customer", _customerID: self.customerID, _images: selectedImages)
                
            
           // print("url = https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
            
            print("self.selectedImages.count = \(selectedImages.count)")
            
            
            
            imageUploadPrepViewController.delegate = self
            
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
            
            imageUploadPrepViewController.layoutViews()
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
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
        //print("name = \(self.imageArray)")
        
            print("name = \(self.imageArray[indexPath.row].name!)")
            cell.textLabel.text = " \(self.imageArray[indexPath.row].name!)"
            cell.image = self.imageArray[indexPath.row]
            cell.activityView.startAnimating()
            
            print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
            
           // let imgURL:URL = URL(string: self.imageArray[indexPath.row].thumbPath!)!
            
            //print("imgURL = \(imgURL)")
            
            
            /*
            Nuke.loadImage(with: imgURL, into: cell.imageView){
                //print("nuke loadImage")
                cell.imageView?.handle(response: $0, isFromMemoryCache: $1)
                cell.activityView.stopAnimating()
                
            }*/
        
        
        Alamofire.request(self.imageArray[indexPath.row].thumbPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                cell.imageView.image = image
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
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
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
        case "SCHEDULE":
            count = self.customerScheduleArray.count
            //print("schedule count = \(count)", terminator: "")
            
            break
        case "HISTORY":
            count = self.customerHistoryArray.count
            //print("history count = \(count)", terminator: "")
            
            break
            /*
        case "COMMUNICATION":
            break
 */
        case "IMAGES":
            break
        default:
            
            break
        }
        
        return count
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = customerDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
        
        self.customerListDelegate.cancelSearch()//to avoid problem with search controller blocking alerts

        
        let cell = customerDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
        
        switch self.tableViewMode{
            
        case "LEADS":
            
            //let cell = customerDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
            
            print("Leads customer")
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
        case "SCHEDULE":
            
            print("Schedule customer")
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
        case "HISTORY":
            
            //print("a")
            cell.workOrder = self.customerHistoryArray[indexPath.row]
            
            
            cell.layoutViews(_scheduleMode: "CUSTOMER")
            cell.dateLbl.text = cell.workOrder.date
            cell.firstItemLbl.text = "\(cell.workOrder.title!) #\(cell.workOrder.ID!)"
            cell.setStatus(status: cell.workOrder.statusId)
           
            
            cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
            
           
            cell.priceLbl.text = cell.workOrder.totalPrice!
            
            
            cell.priceLbl.text = cell.workOrder.totalPrice!
            
            
            
           cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
            
            //print("e")
            break
        case "COMMUNICATION":
            break
        case "IMAGES":
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
        
            navigationController?.pushViewController(leadViewController, animated: true )
            
            leadViewController.delegate = self
            //workOrderViewController.scheduleDelegate = self
            //workOrderViewController.customerDelegate = self
            
            
            //workOrderViewController.scheduleIndex = indexPath?.row
            
            
            tableView.deselectRow(at: indexPath!, animated: true)
            break
        case "SCHEDULE":
            let workOrderViewController = WorkOrderViewController(_workOrder: currentCell.workOrder,_customerName: currentCell.workOrder.customer)
            navigationController?.pushViewController(workOrderViewController, animated: true )
            
            workOrderViewController.scheduleDelegate = self
            workOrderViewController.customerDelegate = self
            
            
            workOrderViewController.scheduleIndex = indexPath?.row
            
            
            tableView.deselectRow(at: indexPath!, animated: true)
            break
        case "HISTORY":
            let workOrderViewController = WorkOrderViewController(_workOrder: currentCell.workOrder,_customerName: currentCell.workOrder.customer)
            navigationController?.pushViewController(workOrderViewController, animated: true )
            
            workOrderViewController.scheduleDelegate = self
            workOrderViewController.customerDelegate = self
            
            
            workOrderViewController.scheduleIndex = indexPath?.row
            
            
            tableView.deselectRow(at: indexPath!, animated: true)
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
        
        
            if(self.tableViewMode == "SCHEDULE"){
                
                customerScheduleArray[_index].statusId = _status
                customerScheduleArray[_index].totalPrice = _price
                customerScheduleArray[_index].totalCost = _cost
                customerScheduleArray[_index].totalPriceRaw = _priceRaw
                customerScheduleArray[_index].totalCostRaw = _costRaw
            }else{//HISTORY
               
                customerHistoryArray[_index].statusId = _status
                customerHistoryArray[_index].totalPrice = _price
                customerHistoryArray[_index].totalCost = _cost
                customerHistoryArray[_index].totalPriceRaw = _priceRaw
                customerHistoryArray[_index].totalCostRaw = _costRaw
            }
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
                                              animated: false)
        
        
        
    }
    
    
    
    
    func refreshImages(_images:[Image], _scoreAdjust:Int){
        print("refreshImages")
        
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
        print("update schedule")
    }
    
    // not used, just to have this class conform to schedule delegate protocol
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _mowSort:String, _plowSort:String, _plowDepth:String){
        print("update settings")
    }
    
    func cancelSearch() {
         print("cancelSearch")
        customerListDelegate.cancelSearch()
    }
    
   
    
    
    
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    
    func showCustomerImages(_customer:String){
        print("show customer images cust: \(_customer)")
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
