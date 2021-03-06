//
//  VendorViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import CoreLocation

 

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
    var currentLocation: CLLocation?
    var foundLocation:Bool = false
    
    
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
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(VendorViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
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
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.vendorView = UIView()
        self.vendorView.layer.borderColor = layoutVars.borderColor
        self.vendorView.layer.borderWidth = 1.0
        self.vendorView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.vendorView)
        
        
        
        print("1")
        //auto layout group
        let viewsDictionary = [
        "view1":self.vendorView] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
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
        self.vendorPhoneBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.vendorPhoneBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        //print("vendor phone = \(vendor.phone)")
        //print("vendor phoneNumberClean = \(self.phoneNumberClean)")
        if self.vendor.phone == "" {
            self.vendorPhoneBtn.setTitle("No Phone Saved", for: UIControl.State.normal)
            
        }else{
            self.vendorPhoneBtn.setTitle(self.vendor.phone, for: UIControl.State.normal)
            self.vendorPhoneBtn.addTarget(self, action: #selector(self.phoneHandler), for: UIControl.Event.touchUpInside)
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
        self.vendorWebsiteBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.vendorWebsiteBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        
        
        if self.vendor.website == "" {
            self.vendorWebsiteBtn.setTitle("No Website Saved", for: UIControl.State.normal)
            
        }else{
            self.vendorWebsiteBtn.setTitle(self.vendor.website, for: UIControl.State.normal)
            self.vendorWebsiteBtn.addTarget(self, action: #selector(VendorViewController.webHandler), for: UIControl.Event.touchUpInside)
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
        self.vendorAddressBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.vendorAddressBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        if (self.vendor.address == "") {
            self.vendorAddressBtn.setTitle("No Location Saved", for: UIControl.State.normal)
            
           
        }else{
            self.vendorAddressBtn.setTitle(self.vendor.address, for: UIControl.State.normal)
            
            self.vendorAddressBtn.addTarget(self, action: #selector(VendorViewController.mapHandler), for: UIControl.Event.touchUpInside)
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
        
        //let span = MKCoordinateSpanMake(0.5, 0.5)
        //let region = MKCoordinateRegion(center: location, span: span)
        
        //mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = self.vendor.name
        //annotation.subtitle = "Honduras"
        
        mapView.addAnnotation(annotation)
            
            mapView.showsUserLocation = true
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            
        
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
        //print("window width = \(layoutVars.fullWidth)")
       
        
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[balance]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[map]-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view2(35)]-[balance(25)]-[view3(40)]-[view4(40)]-[view5(40)]-[map]-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        
    }
    
    
        
    @objc func phoneHandler(){
            
            callPhoneNumber(self.phoneNumberClean)
        }
        
        
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("monitoring")
        
        
    }
    
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updating location")
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
 */
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        print("didUpdateLocations \(foundLocation)")
        if(foundLocation == false){
            var zoomRect:MKMapRect = MKMapRect.null
            for  annotation in mapView.annotations {
                let annotationPoint:MKMapPoint = MKMapPoint.init(annotation.coordinate)
                let pointRect:MKMapRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0);
                if zoomRect.isNull {
                    zoomRect = pointRect;
                } else {
                    zoomRect = zoomRect.union(pointRect);
                }
            }
        
            mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets.init(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            foundLocation = true
        }
        
        
        
       
        
    }
    
    
    
    @objc func webHandler(){
        // sendEmail(self.email)
        openWebLink(self.vendor.website)
    }
    
    @objc func mapHandler() {
        print("map handler")
        //need to set lat and lng
        openMapForPlace(self.vendor.name, _lat: self.vendor.lat! as NSString, _lng: self.vendor.lng! as NSString)
        
    }
    
    
    
    @objc func goBack(){
     _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
