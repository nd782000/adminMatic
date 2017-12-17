//
//  CustomerContactViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/13/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class CustomerContactViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    var loadingLabel:UILabel!
    var totalCustomers:Int!
    var loadedCustomers:Int!
    var loadingString:String = "Connecting..."
    var searchController:UISearchController!
    
    var currentSearchMode = SearchMode.name
    
    var contactTableView:TableView = TableView()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var customerJSON: JSON!
    
    
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    
    init(_customerJSON:JSON){
        super.init(nibName:nil,bundle:nil)
        self.customerJSON = _customerJSON
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerContactViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        view.backgroundColor = layoutVars.backgroundColor
        self.layoutViews()
    }
    
    
    func layoutViews(){
        
        
        
        self.contactTableView.delegate  =  self
        self.contactTableView.dataSource = self
        self.contactTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.contactTableView.sectionHeaderHeight = 0
        self.contactTableView.tableHeaderView = UIView(frame: CGRect(x:0, y:0, width:self.contactTableView.bounds.size.width, height:5));
        
        self.view.addSubview(self.contactTableView)
        //auto layout group
        let viewsDictionary = [
            "view1":self.contactTableView
        ]  as [String : Any]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth ,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - 10]  as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(height)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.customerJSON["customer"]["contacts"].count 
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "cell") as! ContactTableViewCell
        contactTableView.rowHeight = 50.0
        
        cell.contact = Contact(_ID: self.customerJSON["customer"]["contacts"][indexPath.row]["ID"].stringValue, _sort: self.customerJSON["customer"]["contacts"][indexPath.row]["sort"].stringValue, _value: self.customerJSON["customer"]["contacts"][indexPath.row]["value"].stringValue, _type: self.customerJSON["customer"]["contacts"][indexPath.row]["type"].stringValue, _contactName: self.customerJSON["customer"]["contacts"][indexPath.row]["contactName"].stringValue, _main: self.customerJSON["customer"]["contacts"][indexPath.row]["main"].stringValue, _name: self.customerJSON["customer"]["contacts"][indexPath.row]["name"].stringValue,_street1:self.customerJSON["customer"]["contacts"][indexPath.row]["street1"].stringValue,_street2:self.customerJSON["customer"]["contacts"][indexPath.row]["street2"].stringValue,_city:self.customerJSON["customer"]["contacts"][indexPath.row]["city"].stringValue,_state:self.customerJSON["customer"]["contacts"][indexPath.row]["state"].stringValue,_zip:self.customerJSON["customer"]["contacts"][indexPath.row]["zip"].stringValue,_zone:self.customerJSON["customer"]["zone"][indexPath.row]["street1"].stringValue,_zoneName:self.customerJSON["customer"]["contacts"][indexPath.row]["zoneName"].stringValue,_color:self.customerJSON["customer"]["contacts"][indexPath.row]["color"].stringValue,_lat:self.customerJSON["customer"]["contacts"][indexPath.row]["lat"].stringValue as NSString,_lng:self.customerJSON["customer"]["contacts"][indexPath.row]["lng"].stringValue as NSString)
        
        switch  self.customerJSON["customer"]["contacts"][indexPath.row]["type"].stringValue {
        //main phone
        case "1":
            cell.iconView.image = UIImage(named:"phoneIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Main Phone"
            
            break
        //main email
        case "2":
            cell.iconView.image = UIImage(named:"emailIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Main Email"
            break
            
        //billing  address
        case "3":
            cell.iconView.image = UIImage(named:"mapIcon.png")
            
           // cell.nameLbl?.text = cell.contact.street1 + " " + cell.contact.street2 + " " + cell.contact.city + ", " + cell.contact.state
            cell.detailLbl?.text = "Billing Address"
            break
            
        //jobSite address
        case "4":
            cell.iconView.image = UIImage(named:"mapIcon.png")
            
           // cell.nameLbl?.text = cell.contact.street1 + " " + cell.contact.street2 + " " + cell.contact.city + ", " + cell.contact.state
            cell.detailLbl?.text = "Jobsite Address"
            
            break
            
        //website
        case "5":
            cell.iconView.image = UIImage(named:"webIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Website"
            
            break
            
        //alt contact
        case "6":
            cell.iconView.image = UIImage(named:"personIcon.png")
            
            cell.nameLbl?.text = cell.contact.name
            cell.detailLbl?.text = "Alt Contact"
            
            break
            
        //fax
        case "7":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"phoneIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Fax"
            
            
            break
        //alt phone
        case "8":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"phoneIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Alt Phone"
            
            
            break
        //alt email
        case "9":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"emailIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Alt Email"
            
            
            break
        //mobile
        case "10":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"phoneIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Mobile"
            
            
            break
        //alt mobile
        case "11":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"phoneIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Alt Mobile"
            
            
            break
        //home phone
        case "12":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"phoneIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Home Phone"
            
            
            break
        //alt email
        case "13":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"emailIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Alt Email"
            
            
            break
        //invoice address
        case "14":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"mapIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Invoice Address"
            
            
            break
        //alt jobsite
        case "15":
            //cell.type = .fax
            cell.iconView.image = UIImage(named:"mapIcon.png")
            
            cell.nameLbl?.text = cell.contact.value
            cell.detailLbl?.text = "Alt Jobsite"
            
            
            break
            
            
        default :
            break
            
        }
        
        
        
        
        
        
        
        
        // println("self.customersArray!.count = \(self.customersArray.count)")
        
        
        
        
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! ContactTableViewCell;
        
        
        switch  currentCell.contact.type!{
        //phone
        case "1":
            
            
            callPhoneNumber(currentCell.contact.value!)
            
            break
        case "2":
            sendEmail(currentCell.contact.value)
            break
        case "3":
            openMapForPlace(currentCell.contact.name, _lat: currentCell.contact.lat!, _lng: currentCell.contact.lng!)
            break
        case "4":
            openMapForPlace(currentCell.contact.name, _lat: currentCell.contact.lat!, _lng: currentCell.contact.lng!)
            break
        case "5":
            openWebLink(currentCell.contact.value)
            break
        case "6":
            //openWebLink(currentCell.contact.value)
            break
        case "7":
            //openWebLink(currentCell.contact.value)
            break
        case "8":
            callPhoneNumber(currentCell.contact.value!)
            break
        case "9":
            sendEmail(currentCell.contact.value)
            break
        case "10":
            callPhoneNumber(currentCell.contact.value!)
            break
        case "11":
            callPhoneNumber(currentCell.contact.value!)
            break
        case "12":
            callPhoneNumber(currentCell.contact.value!)
            break
        case "13":
            sendEmail(currentCell.contact.value)
            break
        case "14":
            //callPhoneNumber(currentCell.contact.value!)
            break
        case "15":
            openMapForPlace(currentCell.contact.name, _lat: currentCell.contact.lat!, _lng: currentCell.contact.lng!)
            break


            //not doing anything for person or fax
            
        default:
            break
            
            
        }
        
        
        
        /*
         if(currentCell.customer != nil){
         
         
         let customerViewController = CustomerViewController(_customer: currentCell.customer)
         navigationController?.pushViewController(customerViewController, animated: true )
         
         tableView.deselectRowAtIndexPath(indexPath!, animated: true)
         }
         */
        
    }
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
