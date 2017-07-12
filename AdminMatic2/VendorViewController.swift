//
//  VendorViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

import MapKit
import CoreLocation
//import CoreLocation
//import MapKit


class VendorViewController: ViewControllerWithMenu, CLLocationManagerDelegate{
    
    //let locationManager = CLLocationManager()
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    //main variables passed to this VC
    var vendorID:String
    var vendor:Vendor!
    
    var vendorJSON: JSON!
    //extra vendor properties, vendor object doesn't have'
    var phone: String = "No Phone Found"
    //var phoneName: String = ""
    // var website: String = "No Website Found"
    //var emailName: String = ""
    //var address: String = "No Address Found"
    var lat: NSString?
    var lng: NSString?
    
    //vendor info
    var vendorView:UIView!
    var vendorLbl:GreyLabel!
    var balanceLbl:GreyLabel!
    var vendorPhoneBtn:UIButton!
    var phoneNumberClean:String!
    var vendorWebsiteBtn:UIButton!
    var vendorAddressBtn:UIButton!
    
    var mapView:MKMapView!
    var locationManager: CLLocationManager!
    
    
    init(_vendorID:String){
        self.vendorID = _vendorID
        
        super.init(nibName:nil,bundle:nil)
        
        print("init vendorID = \(self.vendorID)")
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Vendor"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(VendorViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
         getVendorData(_id: self.vendorID)
        
        
       
        
    }
    
    
     func getVendorData(_id:String){
        print("getVendorData id: \(_id)")
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject

        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        Alamofire.request(API.Router.vendor(["id":_id as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.vendorJSON = JSON(json)
                self.parseVendorJSON()
                self.indicator.dismissIndicator()
            }
            
            
            
        }
        
        
     }
     
     func parseVendorJSON(){
     
     
     print("parse vendorJSON")
     
        
        self.vendor = Vendor(_name: self.vendorJSON["vendor"]["name"].stringValue, _id: self.vendorJSON["vendor"]["ID"].stringValue, _address: self.vendorJSON["vendor"]["mainAddr"].stringValue, _phone: self.vendorJSON["vendor"]["mainPhone"].stringValue, _website: self.vendorJSON["vendor"]["website"].stringValue, _balance: self.vendorJSON["vendor"]["balance"].stringValue, _lng: self.vendorJSON["vendor"]["lng"].stringValue, _lat: self.vendorJSON["vendor"]["lat"].stringValue)
        
        
     //loop through contacts and put them in appropriate places
     let contactCount:Int = self.vendorJSON["vendor"]["contacts"].count
     print("contactCount: \(contactCount)")
    // for(i in 0 ..< contactCount){
for i in 0 ..< contactCount {
     print("contactID: " + self.vendorJSON["vendor"]["contacts"][i]["ID"].stringValue)
     switch  self.vendorJSON["vendor"]["contacts"][i]["type"].stringValue {
     //phone
     case "1":
     print("case = phone")
     if(self.vendorJSON["vendor"]["contacts"][i]["main"].stringValue == "1"){
     self.phone = self.vendorJSON["vendor"]["contacts"][i]["value"].stringValue
     if self.vendorJSON["vendor"]["contacts"][i]["name"] != JSON.null
     {
     
     }
     }
     break
     //email
     case "2":
     print("case = email")
     if(self.vendorJSON["vendor"]["contacts"][i]["main"].stringValue == "1"){
    
     }
     break
    
            
     default :
        break
     }
        }
     
     
     self.layoutViews()
     
     }
     
     
     
     
    
    
    
    
    func layoutViews(){
        print("vendor view layoutViews")
        //////////   containers for different sections
        self.vendorView = UIView()
        self.vendorView.layer.borderColor = layoutVars.borderColor
        self.vendorView.layer.borderWidth = 1.0
        self.vendorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.vendorView)
        
        
        
        print("1")
        //auto layout group
        let viewsDictionary = [
        "view1":self.vendorView] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        ///////////   vendor contact section   /////////////
        
        print("vendor view layoutViews 2")
        //name
        self.vendorLbl = GreyLabel()
        self.vendorLbl.text = self.vendor.name
        self.vendorLbl.font = layoutVars.largeFont
        self.vendorView.addSubview(self.vendorLbl)
        
        //balance
        self.balanceLbl = GreyLabel()
        
        //let formatter = NumberFormatter()
        
        /*
        
        if(self.vendor.balance == ""){
            self.balanceLbl.text =  "$0.00"
        }else{
            
            formatter.numberStyle = .currency
            formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
            _ = NSString(string: self.vendor.balance).doubleValue
           
        }
        
        */
        
        
        
        
        self.balanceLbl.font = layoutVars.smallFont
        self.balanceLbl.text = "Balance = $\(self.vendor.balance!)"
        self.vendorView.addSubview(self.balanceLbl)
        
        //phone
        self.phoneNumberClean = cleanPhoneNumber(self.vendor.phone)
        
        self.vendorPhoneBtn = Button()
        self.vendorPhoneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.vendorPhoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.vendorPhoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        print("vendor phone = \(vendor.phone)")
        print("vendor phoneNumberClean = \(self.phoneNumberClean)")
        if self.vendor.phone == "" {
            self.vendorPhoneBtn.setTitle("No Phone Saved", for: UIControlState.normal)
            
        }else{
            self.vendorPhoneBtn.setTitle(self.vendor.phone, for: UIControlState.normal)
            self.vendorPhoneBtn.addTarget(self, action: #selector(self.phoneHandler), for: UIControlEvents.touchUpInside)
        }
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.contentMode = .scaleAspectFill
        phoneIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.vendorPhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        
        self.vendorView.addSubview(self.vendorPhoneBtn)
        print("vendor view layoutViews 3")
        
        
        
        
        self.vendorWebsiteBtn = Button()
        self.vendorWebsiteBtn.translatesAutoresizingMaskIntoConstraints = false
        self.vendorWebsiteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.vendorWebsiteBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        
        
        if self.vendor.website == "" {
            self.vendorWebsiteBtn.setTitle("No Website Saved", for: UIControlState.normal)
            
        }else{
            self.vendorWebsiteBtn.setTitle(self.vendor.website, for: UIControlState.normal)
            self.vendorWebsiteBtn.addTarget(self, action: #selector(VendorViewController.webHandler), for: UIControlEvents.touchUpInside)
        }
        
        let websiteIcon:UIImageView = UIImageView()
        websiteIcon.backgroundColor = UIColor.clear
        websiteIcon.contentMode = .scaleAspectFill
        websiteIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let websiteImg = UIImage(named:"webIcon.png")
        websiteIcon.image = websiteImg
        self.vendorWebsiteBtn.titleLabel?.addSubview(websiteIcon)
        
        
        self.vendorView.addSubview(self.vendorWebsiteBtn)
        
        
        
        
        self.vendorAddressBtn = Button()
        self.vendorAddressBtn.translatesAutoresizingMaskIntoConstraints = false
        self.vendorAddressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.vendorAddressBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        if (self.vendor.address == "") {
            self.vendorAddressBtn.setTitle("No Location Saved", for: UIControlState.normal)
            
           
        }else{
            self.vendorAddressBtn.setTitle(self.vendor.address, for: UIControlState.normal)
            
            self.vendorAddressBtn.addTarget(self, action: #selector(VendorViewController.mapHandler), for: UIControlEvents.touchUpInside)
        }
        
        print("vendor view layoutViews 4")
        
        let addressIcon:UIImageView = UIImageView()
        addressIcon.backgroundColor = UIColor.clear
        addressIcon.contentMode = .scaleAspectFill
        addressIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let addressImg = UIImage(named:"mapIcon.png")
        addressIcon.image = addressImg
        self.vendorAddressBtn.titleLabel?.addSubview(addressIcon)
        
        
        self.vendorView.addSubview(self.vendorAddressBtn)
        
        print("vendor view layoutViews 5")
        
         mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        if(self.vendor.lat != ""){
            
        
       
        mapView.setCenter(CLLocationCoordinate2D(latitude: Double(self.vendor.lat)!,longitude:
            Double(self.vendor.lng)!), animated: true)
        
       
        
        let location = CLLocationCoordinate2D(
            latitude: Double(self.vendor.lat)!,
            longitude: Double(self.vendor.lng)!
        )
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = self.vendor.name
        //annotation.subtitle = "Honduras"
        
        mapView.addAnnotation(annotation)
        
        }
        
        
        self.vendorView.addSubview(mapView)
        
        if (CLLocationManager.locationServicesEnabled())
        {
            print("location available")
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
        
        
        
        
        
        
        print("vendor view layoutViews 6")
        
        //auto layout group
        let vendorsViewsDictionary = [
            
            "view2":self.vendorLbl,
            "balance":self.balanceLbl,
            "view3":self.vendorPhoneBtn,
            "view4":self.vendorWebsiteBtn,
            "view5":self.vendorAddressBtn,
            "map":self.mapView
            
            
        ] as [String : Any]
        print("window width = \(layoutVars.fullWidth)")
       
        
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[balance]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[map]-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view2(35)]-[balance(25)]-[view3(30)]-[view4(30)]-[view5(30)]-[map]-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        
    }
        
        func phoneHandler(){
            
            callPhoneNumber(self.phoneNumberClean)
        }
        
        
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("monitoring")
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updating location")
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func webHandler(){
        // sendEmail(self.email)
        openWebLink(self.vendor.website)
    }
    
    func mapHandler() {
        print("map handler")
        //need to set lat and lng
        openMapForPlace(self.vendor.name, _lat: self.vendor.lat! as NSString, _lng: self.vendor.lng! as NSString)
        
    }
    
    
    
    func goBack(){
     _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
