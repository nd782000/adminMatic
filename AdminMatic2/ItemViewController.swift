//
//  ItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//
//  ItemViewController.swift
//  Atlantic_Blank
//
//  Created by nicholasdigiando on 11/30/15.
//  Copyright © 2015 Nicholas Digiando. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import CoreLocation
//import MapKit


//class ItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

class ItemViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    
    //let locationManager = CLLocationManager()
    var layoutVars:LayoutVars = LayoutVars()
    
    //main variables passed to this VC
    
    
    var item:Item!
    
    var itemJSON: JSON!
    //extra item properties, item object doesn't have'
    /*
     var phone: String = "No Phone Found"
     var phoneName: String = ""
     var email: String = "No Email Found"
     var emailName: String = ""
     var jobSiteAddress: String = "No Job Site Found"
     var lat: NSString?
     var lng: NSString?
     */
    
    
    //item info
    var itemView:UIView!
    var itemLbl:GreyLabel!
    
    //var itemPhoneBtn:UIButton!
    // var phoneNumberClean:String!
    //var itemEmailBtn:UIButton!
    //var itemAddressBtn:UIButton!
    // var allContactsBtn:UIButton!
    
    //details view
    var detailsView:UIView!
    
    var itemDetailsTableView:TableView = TableView()
    // var tableViewMode:String = "SCHEDULE"
    
    var itemVendors: JSON!
    var itemVendorsArray:[Vendor] = []
    
    
    
    
    
    
    
    
    init(_item:Item){
        super.init(nibName:nil,bundle:nil)
        self.item = _item
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Item"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ItemViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        getItemData(_id: self.item.ID!)
        
        
    }
    
    
    func getItemData(_id:String){
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject

        
         Alamofire.request(API.Router.item(["id":_id as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            

                   response in
            
            
       // Alamofire.request(API.Router.item(["itemID":self.item.ID as AnyObject]).responseJSON() {
           // response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.itemJSON = JSON(json)
                self.parseItemJSON()
                
            }
            
            
            
        }
        
    }
    
    func parseItemJSON(){
        
        
        /*
         print("parse itemJSON: \(self.itemJSON)")
         
         //loop through contacts and put them in appropriate places
         let contactCount:Int = self.itemJSON["item"]["contacts"].count
         print("contactCount: \(contactCount)")
         for(var i = 0; i<contactCount;i++){
         print("contactID: " + self.itemJSON["item"]["contacts"][i]["ID"].stringValue)
         switch  self.itemJSON["item"]["contacts"][i]["type"].stringValue {
         //phone
         case "1":
         print("case = phone")
         if(self.itemJSON["item"]["contacts"][i]["main"].stringValue == "1"){
         self.phone = self.itemJSON["item"]["contacts"][i]["value"].stringValue
         if self.itemJSON["item"]["contacts"][i]["name"] != nil
         {
         self.phoneName = " (" + self.itemJSON["item"]["contacts"][i]["name"].stringValue + ")"
         }
         }
         break
         //email
         case "2":
         print("case = email")
         if(self.itemJSON["item"]["contacts"][i]["main"].stringValue == "1"){
         self.email = self.itemJSON["item"]["contacts"][i]["value"].stringValue
         if self.itemJSON["item"]["contacts"][i]["name"] != nil
         {
         self.emailName =  " (" + self.itemJSON["item"]["contacts"][i]["name"].stringValue + ")"
         }
         }
         break
         
         //job site address
         case "4":
         //check if address is same as one displayed in item list
         print("case = address")
         print(self.itemJSON["item"]["contacts"][i]["main"].stringValue)
         print(self.itemJSON["item"]["contacts"][i]["ID"].stringValue)
         print(self.item.contactID)
         print(self.itemJSON["item"]["contacts"][i])
         //let street1:String = self.jobSiteAddress = self.itemJSON["item"]["contacts"][i]["street1"].stringValue
         //let street2 = self.jobSiteAddress = self.itemJSON["item"]["contacts"][i]["street2"].stringValue
         // let city = self.jobSiteAddress = self.itemJSON["item"]["contacts"][i]["city"].stringValue
         // let state = self.jobSiteAddress = self.itemJSON["item"]["contacts"][i]["state"].stringValue
         if(self.itemJSON["item"]["contacts"][i]["ID"].stringValue == self.item.contactID){
         
         
         // self.jobSiteAddress = self.itemJSON["item"]["contacts"][i]["street1"].stringValue + " " + self.itemJSON["item"]["contacts"][i]["street2"].stringValue + " " + self.itemJSON["item"]["contacts"][i]["city"].stringValue + ", " + self.itemJSON["item"]["contacts"][i]["state"].stringValue
         
         // self.jobSiteAddress = self.itemJSON["item"]["contacts"][i]["street1"].stringValue + " " + self.itemJSON["item"]["contacts"][i]["street2"].stringValue + " " + self.itemJSON["item"]["contacts"][i]["city"].stringValue + ", " + self.itemJSON["item"]["contacts"][i]["state"].stringValue
         
         
         
         self.lat = self.itemJSON["item"]["contacts"][i]["lat"].stringValue as NSString
         self.lng = self.itemJSON["item"]["contacts"][i]["lng"].stringValue as NSString
         print("set lat \(self.lat)")
         }
         break
         
         default :
         break
         
         }
         
         }
         
         
         //self.layoutViews()
         getItemSchedule(self.item.ID!)
         */
        
    }
    
    
    
    
    
    
    
    
    
    func layoutViews(){
        print("item view layoutViews")
        //////////   containers for different sections
        self.itemView = UIView()
        self.itemView.layer.borderColor = layoutVars.borderColor
        self.itemView.layer.borderWidth = 1.0
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.itemView)
        
        
        
        
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        //self.detailsView.backgroundColor = UIColor.redColor()
        
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.detailsView)
        
        
        
        print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemView,
            "view2":self.detailsView] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight - 270] as [String : Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        /*
         let view1Constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary)
         let view2Constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary)
         
         let viewsConstraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[view1(210)][view2(fullHeight)]", options:[], metrics: sizeVals, views: viewsDictionary)
         
         
         self.view.addConstraints(view1Constraint_H as [AnyObject] as [AnyObject])
         self.view.addConstraints(view2Constraint_H as [AnyObject] as [AnyObject])
         self.view.addConstraints(viewsConstraint_V as [AnyObject] as [AnyObject])
         */
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1(210)][view2(fullHeight)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
        ///////////   item contact section   /////////////
        
        print("item view layoutViews 2")
        //name
        self.itemLbl = GreyLabel()
        self.itemLbl.text = self.item.name
        self.itemLbl.font = layoutVars.largeFont
        self.itemView.addSubview(self.itemLbl)
        
        /*
         //phone
         self.phoneNumberClean = cleanPhoneNumber(self.phone)
         
         self.itemPhoneBtn = Button()
         self.itemPhoneBtn.translatesAutoresizingMaskIntoConstraints = false
         self.itemPhoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
         self.itemPhoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
         
         
         self.itemPhoneBtn.setTitle(self.phoneNumberClean + self.phoneName, forState: UIControlState.Normal)
         if self.phone != "No Phone Found" {
         self.itemPhoneBtn.addTarget(self, action: "phoneHandler", forControlEvents: UIControlEvents.TouchUpInside)
         }
         
         let phoneIcon:UIImageView = UIImageView()
         phoneIcon.backgroundColor = UIColor.clearColor()
         phoneIcon.contentMode = .ScaleAspectFill
         phoneIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
         let phoneImg = UIImage(named:"phoneIcon.png")
         phoneIcon.image = phoneImg
         self.itemPhoneBtn.titleLabel?.addSubview(phoneIcon)
         
         
         self.itemView.addSubview(self.itemPhoneBtn)
         print("item view layoutViews 3")
         
         
         
         
         self.itemEmailBtn = Button()
         self.itemEmailBtn.translatesAutoresizingMaskIntoConstraints = false
         self.itemEmailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
         self.itemEmailBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
         
         
         self.itemEmailBtn.setTitle(self.email + self.emailName, forState: UIControlState.Normal)
         if self.email != "No Email Found" {
         self.itemEmailBtn.addTarget(self, action: "emailHandler", forControlEvents: UIControlEvents.TouchUpInside)
         }
         
         let emailIcon:UIImageView = UIImageView()
         emailIcon.backgroundColor = UIColor.clearColor()
         emailIcon.contentMode = .ScaleAspectFill
         emailIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
         let emailImg = UIImage(named:"emailIcon.png")
         emailIcon.image = emailImg
         self.itemEmailBtn.titleLabel?.addSubview(emailIcon)
         
         
         self.itemView.addSubview(self.itemEmailBtn)
         
         
         
         
         self.itemAddressBtn = Button()
         self.itemAddressBtn.translatesAutoresizingMaskIntoConstraints = false
         self.itemAddressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
         self.itemAddressBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
         
         
         self.itemAddressBtn.setTitle(self.jobSiteAddress, forState: UIControlState.Normal)
         if self.jobSiteAddress != "No Job Site Found" {
         self.itemAddressBtn.addTarget(self, action: "mapHandler", forControlEvents: UIControlEvents.TouchUpInside)
         }
         
         print("item view layoutViews 4")
         
         let addressIcon:UIImageView = UIImageView()
         addressIcon.backgroundColor = UIColor.clearColor()
         addressIcon.contentMode = .ScaleAspectFill
         addressIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
         let addressImg = UIImage(named:"mapIcon.png")
         addressIcon.image = addressImg
         self.itemAddressBtn.titleLabel?.addSubview(addressIcon)
         
         
         self.itemView.addSubview(self.itemAddressBtn)
         
         
         self.allContactsBtn = Button()
         self.allContactsBtn.translatesAutoresizingMaskIntoConstraints = false
         self.allContactsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
         self.allContactsBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
         
         self.allContactsBtn.setTitle("Show All Contacts", forState: UIControlState.Normal)
         self.allContactsBtn.addTarget(self, action: "showAllContacts", forControlEvents: UIControlEvents.TouchUpInside)
         
         
         self.itemView.addSubview(self.allContactsBtn)
         
         
         
         
         
         
         
         
         //auto layout group
         let itemsViewsDictionary = [
         
         "view2":self.itemLbl,
         "view3":self.itemPhoneBtn,
         "view4":self.itemEmailBtn,
         "view5":self.itemAddressBtn,
         "view6":self.allContactsBtn
         ]
         
         */
        
        
        let itemsViewsDictionary = [
            
            "view1":self.itemLbl
        ] as [String:Any]
        /*
         print("window width = \(layoutVars.fullWidth)")
         let itemViewsConstraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view2]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary)
         
         let itemViewsConstraint_H2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary)
         let itemViewsConstraint_H3:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary)
         let itemViewsConstraint_H4:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary)
         let itemViewsConstraint_H5:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view6]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary)
         
         
         
         
         
         let itemViewsConstraint_V2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[view2(35)]-[view3(30)]-[view4(30)]-[view5(30)]-[view6(30)]", options:[], metrics: nil, views: itemsViewsDictionary)
         
         self.itemView.addConstraints(itemViewsConstraint_H as [AnyObject] as [AnyObject])
         self.itemView.addConstraints(itemViewsConstraint_H2 as [AnyObject] as [AnyObject])
         self.itemView.addConstraints(itemViewsConstraint_H3 as [AnyObject] as [AnyObject])
         self.itemView.addConstraints(itemViewsConstraint_H4 as [AnyObject] as [AnyObject])
         self.itemView.addConstraints(itemViewsConstraint_H5 as [AnyObject] as [AnyObject])
         self.itemView.addConstraints(itemViewsConstraint_V2 as [AnyObject] as [AnyObject])
         */
        
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view1]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
        /*
         self.itemView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
         self.itemView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
         self.itemView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
         self.itemView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view6]-10-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
         self.itemView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[view2(35)]-[view3(30)]-[view4(30)]-[view5(30)]-[view6(30)]", options: [], metrics: sizeVals, views: itemsViewsDictionary))
         */
        
        
        ///////////   Item Details Section   /////////////
        
        
        self.itemDetailsTableView.delegate  =  self
        self.itemDetailsTableView.dataSource = self
        self.itemDetailsTableView.rowHeight = 50.0
        self.itemDetailsTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        self.detailsView.addSubview(itemDetailsTableView)
        
        //  self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        // self.itemTableView.addSubview(refreshControl)
        
        
        
        //auto layout group
        let itemDetailsViewsDictionary = [
            
            "view1":itemDetailsTableView
        ] as [String : Any]
        /*
         print("window width = \(layoutVars.fullWidth)")
         let itemDetailsViewsConstraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view1]|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary)
         
         let itemDetailsViewsConstraint_H2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view2(width)]", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary)
         
         let itemDetailsViewsConstraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view1(35)][view2(fullHeight)]", options:[], metrics: sizeVals, views: itemDetailsViewsDictionary)
         
         self.detailsView.addConstraints(itemDetailsViewsConstraint_H as [AnyObject] as [AnyObject])
         self.detailsView.addConstraints(itemDetailsViewsConstraint_H2 as [AnyObject] as [AnyObject])
         self.detailsView.addConstraints(itemDetailsViewsConstraint_V as [AnyObject] as [AnyObject])
         */
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        // self.detailsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view2(width)]", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(35)]", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        
        
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
        
        count = self.itemVendorsArray.count
        //print("schedule count = \(count)", terminator: "")
        
        
        return count
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! VendorTableViewCell
        cell.prepareForReuse()
        
        // cell.resetCell("CUSTOMER")
        //cell.vendor = self.itemVendorsArray[indexPath.row]
        //cell.layoutViews("CUSTOMER")
        
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! VendorTableViewCell;
        
        
        
        
        let vendorViewController = VendorViewController(_vendorID: currentCell.id)
        navigationController?.pushViewController(vendorViewController, animated: false )
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
    }
    
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
