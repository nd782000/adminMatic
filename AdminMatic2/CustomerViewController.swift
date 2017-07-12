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
import SwiftyJSON
import Nuke
import DKImagePickerController



class CustomerViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, ScheduleDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ImageViewDelegate{
    
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
    
    var customerDetailsTableView:TableView = TableView()
    var tableViewMode:String = "SCHEDULE"
    
    var customerSchedule: JSON!
    var customerScheduleArray:[WorkOrder] = []
    
    var historyLoaded:Bool = false
    var customerHistory: JSON!
    var customerHistoryArray:[WorkOrder] = []
    
    var customerCommunication: JSON!
    
    var noResultsLabel:Label = Label();
    
    
    var totalImages:Int!
    var images: JSON!
    var imageArray:[Image] = []
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    var addImageBtn:Button = Button(titleText: "Add Images")
    
    var currentImageIndex:Int = 0
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var refresher:UIRefreshControl!
    
    
    
    
    init(_customerID:String,_customerName:String){
        self.customerID = _customerID
        self.customerName = _customerName

        super.init(nibName:nil,bundle:nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                //if(self.customerJSON["customer"]["contacts"][i]["main"].string == "1"){
                    self.phone = self.customerJSON["customer"]["contacts"][i]["value"].string!
                    if self.customerJSON["customer"]["contacts"][i]["name"] != JSON.null
                    {
                        self.phoneName = " (" + self.customerJSON["customer"]["contacts"][i]["name"].string! + ")"
                        //print("self.phoneName = \(self.phoneName)")
                    }
                //}
                break
            //email
            case "2":
                //print("case = email")
                //if(self.customerJSON["customer"]["contacts"][i]["main"].string == "1"){
                    self.email = self.customerJSON["customer"]["contacts"][i]["value"].string!
                    if self.customerJSON["customer"]["contacts"][i]["name"] != JSON.null
                    {
                        self.emailName =  " (" + self.customerJSON["customer"]["contacts"][i]["name"].string! + ")"
                    }
                //}
                break
                
            //job site address
            case "4":
                //check if address is same as one displayed in customer list
                //print("case = address")
                //print(self.customerJSON["customer"]["contacts"][i]["main"].stringValue)
                //print(self.customerJSON["customer"]["contacts"][i]["ID"].stringValue)
                ////print(self.customer.contactID)
                //print(self.customerJSON["customer"]["contacts"][i])
                
                
                //let street1:String = self.jobSiteAddress = self.customerJSON["customer"]["contacts"][i]["street1"].stringValue
                //let street2 = self.jobSiteAddress = self.customerJSON["customer"]["contacts"][i]["street2"].stringValue
                 //let city = self.jobSiteAddress = self.customerJSON["customer"]["contacts"][i]["city"].stringValue
                 self.jobSiteAddress = self.customerJSON["customer"]["contacts"][i]["fullAddress"].stringValue
                self.lat = self.customerJSON["customer"]["contacts"][i]["lat"].stringValue as NSString
                self.lng = self.customerJSON["customer"]["contacts"][i]["lng"].stringValue as NSString
                //print(" lat \(self.lat)")
                
                
            break
                
            default :
                break
                
            }
            
        }
        
        
        //self.layoutViews()
        getCustomerSchedule(_id: self.customerID)
        
    }
    
    
    
    
    func getCustomerSchedule(_id:String){
       // Alamofire.request(EquipmentAPI.Router.WorkOrderList("", _id, "1")).responseJSON() {
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        

        
        Alamofire.request(API.Router.workOrderList(["empID":"" as AnyObject,"custID":_id as AnyObject,"active":"1" as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                //print("JSON: \(json)")
                //self.vendors = JSON(json)
                // self.parseJSON()
                self.customerSchedule = JSON(json)
                self.parseCustomerScheduleJSON()
                
            }
        }
        
        /*
         
         if error == nil {
         self.customerSchedule = JSON(json!)
         self.parseCustomerScheduleJSON()
         } else {
         //print("JSON ERROR: \(json)")
         }
         }
         */
        
    }
    
    
    
    func parseCustomerScheduleJSON(){
        
        
        //print("parse customerSchedule: \(self.customerSchedule)")
        
        //loop through contacts and put them in appropriate places
        let workOrderCount:Int = self.customerSchedule["workOrder"].count
        //print("workOrderCount: \(workOrderCount)")
        for i in 0 ..< workOrderCount {
            //print("ID: " + self.customerSchedule["workOrder"][i]["ID"].stringValue)
            let workOrder = WorkOrder(_ID: self.customerSchedule["workOrder"][i]["ID"].stringValue, _statusID: self.customerSchedule["workOrder"][i]["statusID"].stringValue, _date: self.customerSchedule["workOrder"][i]["date"].stringValue, _firstItem: self.customerSchedule["workOrder"][i]["firstItem"].stringValue, _statusName: self.customerSchedule["workOrder"][i]["statusName"].stringValue, _customer: self.customerSchedule["workOrder"][i]["customer"].stringValue, _type: self.customerSchedule["workOrder"][i]["type"].stringValue, _progress: self.customerSchedule["workOrder"][i]["progress"].stringValue, _totalPrice: self.customerSchedule["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.customerSchedule["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.customerSchedule["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.customerSchedule["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.customerSchedule["workOrder"][i]["charge"].stringValue)
            self.customerScheduleArray.append(workOrder)
        }
        
        
      self.getImages()
        
        
    }
    
    
    
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        print("get images")
        //for view in self.view.subviews{
            //view.removeFromSuperview()
        //}
        
        imageArray = []
       
        
        
        //cache buster
        //let now = Date()
        //let timeInterval = now.timeIntervalSince1970
        //let timeStamp = Int(timeInterval)
        
        //let parameters = ["customer": self.customerID as AnyObject, "fieldnotes": "1" as AnyObject,]
        let parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "customer": self.customerID as AnyObject]
        
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
            image.tags = self.images["images"][i]["tags"].stringValue
            
            self.imageArray.append(image)
            
        }
       // self.imageCollectionView?.reloadData()
        
        self.layoutViews()
       // self.layoutImageViews()
        
        
        
    }
    

    //history is delayed until user clicks history tab
    
    func getCustomerHistory(_id:String){
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject

        
        Alamofire.request(API.Router.workOrderList(["empID":"" as AnyObject,"custID":_id as AnyObject,"active":"0" as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {

            
            
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                //print("JSON: \(json)")
                //self.vendors = JSON(json)
                // self.parseJSON()
                self.customerHistory = JSON(json)
                self.parseCustomerHistoryJSON()
                self.historyLoaded = true
                
            }
        }
        
        
        
        
    }
    
    
    
    func parseCustomerHistoryJSON(){
        
        // self.customerHistoryArray.
        //print("parse customerHistory: \(self.customerHistory)")
        
        //loop through contacts and put them in appropriate places
        let workOrderCount:Int = self.customerHistory["workOrder"].count
        //print("workOrderCount: \(workOrderCount)")
        for i in 0 ..< workOrderCount {
            //print("ID: " + self.customerHistory["workOrder"][i]["ID"].stringValue)
            let workOrder = WorkOrder(_ID: self.customerHistory["workOrder"][i]["ID"].stringValue, _statusID: self.customerHistory["workOrder"][i]["statusID"].stringValue, _date: self.customerHistory["workOrder"][i]["date"].stringValue, _firstItem: self.customerHistory["workOrder"][i]["firstItem"].stringValue, _statusName: self.customerHistory["workOrder"][i]["statusName"].stringValue, _customer: self.customerHistory["workOrder"][i]["customer"].stringValue, _type: self.customerHistory["workOrder"][i]["type"].stringValue, _progress: self.customerHistory["workOrder"][i]["progress"].stringValue, _totalPrice: self.customerHistory["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.customerHistory["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.customerHistory["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.customerHistory["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.customerSchedule["workOrder"][i]["charge"].stringValue)
            self.customerHistoryArray.append(workOrder)
        }
        
        
        // dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //self.customerDetailsTableView.removeFromSuperview()
        //self.detailsView.addSubview(customerDetailsTableView)
        
        self.customerDetailsTableView.reloadData()
        
        if self.customerHistoryArray.count > 0 {
            self.customerDetailsTableView.isHidden = false;
            self.noResultsLabel.isHidden = true;
        } else {
            self.customerDetailsTableView.isHidden = true;
            self.noResultsLabel.isHidden = false;
        }
        
        // })
        
        
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
        //self.detailsView.backgroundColor = UIColor.redColor()
        
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.detailsView)
        
        
        
        //print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.customerView,
        "view2":self.detailsView] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight - 235,"collectionViewOffset":(layoutVars.navAndStatusBarHeight - 35) * -1] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1(210)][view2]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
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
        self.customerPhoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        //print("phone = \(self.phone)")
        //print("phoneName = \(self.phoneName)")
        //print("phone clean = \(self.phoneNumberClean)")
        self.customerPhoneBtn.setTitle(self.phone + self.phoneName, for: UIControlState.normal)
        //self.customerPhoneBtn.setTitle(self.phoneNumberClean! + self.phoneName, for: UIControlState.normal)
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
        self.customerEmailBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        
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
        self.customerAddressBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        
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
        
        self.allContactsBtn.setTitle("Show All Contacts", for: UIControlState.normal)
        self.allContactsBtn.addTarget(self, action: #selector(CustomerViewController.showAllContacts), for: UIControlEvents.touchUpInside)
        
        
        self.customerView.addSubview(self.allContactsBtn)
        
        
        
        
       // imageCollectionView = UICollectionView()
       // imageCollectionView?.collectionViewLayout = layout
       

        
        
        
        
        
        
        
        
        
        //auto layout group
        let customersViewsDictionary = [
            
            "view2":self.customerLbl,
            "view3":self.customerPhoneBtn,
            "view4":self.customerEmailBtn,
            "view5":self.customerAddressBtn,
            "view6":self.allContactsBtn
        ] as [String : Any]
        
        
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view6]-10-|", options: [], metrics: sizeVals, views: customersViewsDictionary))
        self.customerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view2(35)]-[view3(30)]-[view4(30)]-[view5(30)]-[view6(30)]", options: [], metrics: sizeVals, views: customersViewsDictionary))
        
        
        
        ///////////   Customer Details Section   /////////////
        
        let items = ["Schedule","History","Communication","Images"]
        let customSC = SegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        
        customSC.addTarget(self, action: #selector(self.changeSearchOptions(sender:)), for: .valueChanged)
        self.detailsView.addSubview(customSC)
        
        self.customerDetailsTableView.delegate  =  self
        self.customerDetailsTableView.dataSource = self
        self.customerDetailsTableView.rowHeight = 50.0
        self.customerDetailsTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        self.detailsView.addSubview(customerDetailsTableView)
        
       
        
        noResultsLabel.text = "No Work on Schedule"
        noResultsLabel.textAlignment = NSTextAlignment.center
        noResultsLabel.font = UIFont(name: "Avenir Next", size: 24)
        self.detailsView.addSubview(self.noResultsLabel);
        
        if self.customerScheduleArray.count > 0 {
            self.customerDetailsTableView.isHidden = false;
            self.noResultsLabel.isHidden = true;
        } else {
            self.customerDetailsTableView.isHidden = true;
            self.noResultsLabel.isHidden = false;
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
        
       // self.automaticallyAdjustsScrollViewInsets = NO
        self.automaticallyAdjustsScrollViewInsets = false
        
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        
        self.edgesForExtendedLayout = UIRectEdge.top
        
        let refresher = UIRefreshControl()
        self.imageCollectionView?.alwaysBounceVertical = true
        
        
        refresher.addTarget(self, action: #selector(CustomerViewController.loadData), for: .valueChanged)
        imageCollectionView?.addSubview(refresher)
        
        
        
        
        self.addImageBtn.addTarget(self, action: #selector(CustomerViewController.addImage), for: UIControlEvents.touchUpInside)
        
        //self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        self.addImageBtn.translatesAutoresizingMaskIntoConstraints = false
        self.detailsView.addSubview(self.addImageBtn)
        addImageBtn.isHidden = true
        

        
        
        
        
        
        
        //auto layout group
        let customerDetailsViewsDictionary = [
            "view1":customSC,
            "view2":customerDetailsTableView,
            "view3":imageCollectionView,
            "view4":addImageBtn,
            "view5":self.noResultsLabel
        ] as [String : Any]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view4(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view5(width)]", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(35)][view2]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[view3]-40-|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view4(40)]|", options: [], metrics: sizeVals, views: customerDetailsViewsDictionary))
        
        
    }
    
    
    func phoneHandler(){
        //print("phone handler")
        
        callPhoneNumber(self.phoneNumberClean)
    }
    
    
    func emailHandler(){
        sendEmail(self.email)
    }
    
    func mapHandler() {
        //print("map handler")
        openMapForPlace(self.customerName, _lat: self.lat!, _lng: self.lng!)
        
         //openMapForPlace(currentCell.contact.name, _lat: currentCell.contact.lat!, _lng: currentCell.contact.lng!)
        
        
        
    }
    
    
    
    func showAllContacts(){
        //let customerContactViewController = CustomerViewController(_customerJSON:self.customerJSON!)
         let customerContactViewController = CustomerContactViewController(_customerJSON: self.customerJSON)
        navigationController?.pushViewController(customerContactViewController, animated: false )
        
    }
    
    
    func changeSearchOptions(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
        case 0://schedule
            self.tableViewMode = "SCHEDULE"
            self.customerDetailsTableView.reloadData()
            noResultsLabel.text = "No Work on Schedule"
            if self.customerScheduleArray.count > 0 {
                self.customerDetailsTableView.isHidden = false;
                self.noResultsLabel.isHidden = true;
            } else {
                self.customerDetailsTableView.isHidden = true;
                self.noResultsLabel.isHidden = false;
            }
            
            imageCollectionView?.isHidden = true
            addImageBtn.isHidden = true

            
            break
        case 1://history
            self.tableViewMode = "HISTORY"
            if(!self.historyLoaded){
                getCustomerHistory(_id: self.customerID)
            }else{
                self.customerDetailsTableView.reloadData()
                noResultsLabel.text = "No Work in History"
                if self.customerHistoryArray.count > 0 {
                    self.customerDetailsTableView.isHidden = false;
                    self.noResultsLabel.isHidden = true;
                } else {
                    self.customerDetailsTableView.isHidden = true;
                    self.noResultsLabel.isHidden = false;
                }
                
            }
            
            imageCollectionView?.isHidden = true
            addImageBtn.isHidden = true

            break
        case 2://communication
            self.tableViewMode = "COMMUNICATION"
            
            imageCollectionView?.isHidden = true
            addImageBtn.isHidden = true

            
            break
        case 3://images
            
            self.customerDetailsTableView.isHidden = true
            
            self.noResultsLabel.isHidden = true
           // self.tableViewMode = "IMAGES"
            
            //self.getImages()
            imageCollectionView?.isHidden = false
            addImageBtn.isHidden = false
            
            break
        default:
            
            break
        }
        
    }
    
    
    
    func loadData()
    {
        print("loadData")
        getImages()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {   print("stopRefresher")
    }
    
    
    
    func addImage(){
        print("Add Image")
        
       // self.view.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)

        self.dismiss(animated: false, completion: nil)
        //UISearchController.isActive = false
        //searchController.isActive = false
        
        //if(searchController != nil){
            //searchController.isActive = false
       // }
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        var selectedAssets = [DKAsset]()
        var selectedImages:[Image] = [Image]()
        
        
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        self.present(multiPicker, animated: false) {
            print("done")
        }
       // self.presentingViewController?.present(multiPicker, animated: true) {}
        
         print("Add Image 1")
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for i in 0..<assets.count
            {
                print("looping images")
                selectedAssets.append(assets[i])
                //print(self.selectedAssets)
                
                assets[i].fetchOriginalImage(true, completeBlock: { image, info in
                    
                    
                    print("making image")
                    
                    let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _mediumPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), _type: "")
                    
                    imageToAdd.image = image
                    
                    
                    selectedImages.append(imageToAdd)
                    
                })
            }
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            
            print("making prep view")
            print("selectedimages count = \(selectedImages.count)")
            
            let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Customer", _ID: "0", _images: selectedImages, _saveURLString: "https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
            imageUploadPrepViewController.customerID = self.customerID
            
            print("url = https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
            
            print("self.selectedImages.count = \(selectedImages.count)")
            
           // imageUploadPrepViewController.loadLinkList(_linkType: "customers", _loadScript: API.Router.customerList(["cb":timeStamp as AnyObject]))
            
            
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
       // if(shouldShowSearchResults == false){
            return self.imageArray.count
        //}else{
           // return self.imagesSearchResults.count
       // }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
        //print("name = \(self.imageArray)")
        
       // if(shouldShowSearchResults == false){
            print("name = \(self.imageArray[indexPath.row].name!)")
            cell.textLabel.text = " \(self.imageArray[indexPath.row].name!)"
            cell.image = self.imageArray[indexPath.row]
            cell.activityView.startAnimating()
            
            print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
            
            let imgURL:URL = URL(string: self.imageArray[indexPath.row].thumbPath!)!
            
            //print("imgURL = \(imgURL)")
            
            
            
            Nuke.loadImage(with: imgURL, into: cell.imageView){ [weak view] in
                //print("nuke loadImage")
                cell.imageView?.handle(response: $0, isFromMemoryCache: $1)
                cell.activityView.stopAnimating()
                
            }
            
            
            
            
        /*}else{
            cell.textLabel.text = " \(self.imagesSearchResults[indexPath.row].name!)"
            cell.image = self.imagesSearchResults[indexPath.row]
            cell.activityView.startAnimating()
            let imgURL:URL = URL(string: self.imagesSearchResults[indexPath.row].thumbPath!)!
            Nuke.loadImage(with: imgURL, into: cell.imageView){ [weak view] in
                cell.imageView?.handle(response: $0, isFromMemoryCache: $1)
                cell.activityView.stopAnimating()
            }
            
            
            
        }*/
        
        
        //print("view width = \(imageCollectionView?.frame.width)")
        //print("cell width = \(cell.frame.width)")
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        //print("name = \(currentCell.image.name)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image,_saveURLString:"https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php")
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        
       // searchTerm = self.searchController.searchBar.text!
        //imagesSearchResults2 = imagesSearchResults
        
       // searchController.isActive = false
        
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
        case "SCHEDULE":
            count = self.customerScheduleArray.count
            //print("schedule count = \(count)", terminator: "")
            
            break
        case "HISTORY":
            count = self.customerHistoryArray.count
            //print("history count = \(count)", terminator: "")
            
            break
        case "COMMUNICATION":
            // cell.workOrder = self.customerScheduleArray[indexPath.row]
            break
        case "IMAGES":
            // cell.workOrder = self.customerScheduleArray[indexPath.row]
            break
        default:
            
            break
        }
        
        return count
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customerDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
        //cell.prepareForReuse()
        switch self.tableViewMode{
        case "SCHEDULE":
            
            //print("Schedule customer")
            // cell.resetCell("CUSTOMER")
            cell.workOrder = self.customerScheduleArray[indexPath.row]
            cell.layoutViews(_scheduleMode: "CUSTOMER")
            cell.dateLbl.text = cell.workOrder.date
            //cell.firstItemLbl.text = cell.workOrder.firstItem
            cell.firstItemLbl.text = "\(cell.workOrder.firstItem!) #\(cell.workOrder.ID!)"
            cell.setStatus(status: cell.workOrder.statusId)
            //cell.woIDLbl.text = "#\(cell.workOrder.ID!)"
            
            //print("cell.workOrder.date \(cell.workOrder.date)")
            //print("cell.workOrder.firstItem \(cell.workOrder.firstItem)")
            
            
            /*
            var chargeTypeName:String
            switch (cell.workOrder.charge) {
            case "1":
                chargeTypeName = "NC"
                break;
            case "2":
                chargeTypeName = "FL"
                break;
            case "3":
                chargeTypeName = "T&M"
                break;
            default:
                chargeTypeName = "Null"//online
                break;
            }
            cell.chargeLbl.text = chargeTypeName
 */
            
            cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
            
           // let formatter = NumberFormatter()
           // formatter.numberStyle = .currency
            // formatter.locale = NSLocale.currentLocale() // This is the default
            //formatter.string(from: cell.workOrder.totalPrice as NSNumber) // "$123.44"
            
            //print("cell.workOrder.totalPrice! = \(cell.workOrder.totalPrice!)")
            cell.priceLbl.text = cell.workOrder.totalPrice!
             //print("cell.workOrder.totalPrice! = \(cell.workOrder.totalPrice!)")
            
            //cell.setProfitBar(_price:self.customerScheduleArray[indexPath.row].totalPrice!, _cost:self.customerScheduleArray[indexPath.row].totalCost!)
            cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
            
            
            
            
            
            
            break
        case "HISTORY":
            // cell.resetCell("CUSTOMER")
            
            //print("a")
            cell.workOrder = self.customerHistoryArray[indexPath.row]
            
            //print("self.customerHistoryArray[indexPath.row] = \(self.customerHistoryArray[indexPath.row])")
            //print("cell.workOrder.price = \(cell.workOrder.totalPrice)")
            
            cell.layoutViews(_scheduleMode: "CUSTOMER")
            cell.dateLbl.text = cell.workOrder.date
            cell.firstItemLbl.text = "\(cell.workOrder.firstItem!) #\(cell.workOrder.ID!)"
            cell.setStatus(status: cell.workOrder.statusId)
           // cell.woIDLbl.text = "#\(cell.workOrder.ID!)"
            ////print("b")
            
            cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
            
            /*
            var chargeTypeName:String
            switch (cell.workOrder.charge) {
            case "1":
                chargeTypeName = "NC"
                break;
            case "2":
                chargeTypeName = "FL"
                break;
            case "3":
                chargeTypeName = "T&M"
                break;
            default:
                chargeTypeName = ""//online
                break;
            }
            cell.chargeLbl.text = chargeTypeName
 */
            
           // //print("c")
            //let formatter = NumberFormatter()
            //formatter.numberStyle = .currency
            // formatter.locale = NSLocale.currentLocale() // This is the default
            //formatter.string(from: cell.workOrder.totalPrice as NSNumber) // "$123.44"
            
            
            //cell.priceLbl.text = formatter.string(from: cell.workOrder.totalPrice as NSNumber)
            
            cell.priceLbl.text = cell.workOrder.totalPrice!
            
            //print("d")
            
            //print("cell.workOrder.totalPrice! = \(cell.workOrder.totalPrice!)")
            cell.priceLbl.text = cell.workOrder.totalPrice!
            //print("cell.workOrder.totalPrice! = \(cell.workOrder.totalPrice!)")
            
            //cell.setProfitBar(_price:self.customerHistoryArray[indexPath.row].totalPrice!, _cost:self.customerHistoryArray[indexPath.row].totalCost!)
            
            
           cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
            
            //print("e")
            break
        case "COMMUNICATION":
            // cell.workOrder = self.customerScheduleArray[indexPath.row]
            break
        case "IMAGES":
            // cell.workOrder = self.customerScheduleArray[indexPath.row]
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
        
        
        
        
        let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.workOrder.ID,_customerName: currentCell.workOrder.customer)
        navigationController?.pushViewController(workOrderViewController, animated: true )
        
        workOrderViewController.scheduleDelegate = self
        
        workOrderViewController.scheduleIndex = indexPath?.row
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
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
        //print("IN  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
       // if(shouldShowSearchResults == false){
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
               //print("OUT  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        
        //if(shouldShowSearchResults == false){
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: false)
        //}
        
        
    }
    
    
    
    
    func refreshImages(_images:[Image], _scoreAdjust:Int){
        print("refreshImages")
        
        for insertImage in _images{
            
            imageArray.insert(insertImage, at: 0)
        }
        
        
        //shouldShowSearchResults = false
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
        
        
        
        print("scoreAdjust")
        
        print("scoreAdjust = \(_scoreAdjust)")
        
        //add appPoints
        var points:Int = _scoreAdjust
        
        print("points = \(points)")
        
        if(points > 0){
            self.appDelegate.showMessage(_message: "earned \(points) App Points!")
        }else if(points < 0){
            points = points * -1
            self.appDelegate.showMessage(_message: "lost \(points) App Points!")
            
        }
        
        
        
    }
    
    
  
    
    
    
    // not used, just to have this class conform to schedule delegate protocol
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _sort:String){
        print("update settings")
    }
    
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
