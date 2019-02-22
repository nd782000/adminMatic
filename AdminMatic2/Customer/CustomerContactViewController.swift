//
//  CustomerContactViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/13/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol ContactListDelegate{
   
    func updateList()
}


class CustomerContactViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, ContactListDelegate{
    
    var editCustomerDelegate:EditCustomerDelegate!
    
    var loadingLabel:UILabel!
    var totalCustomers:Int!
    var loadedCustomers:Int!
    var loadingString:String = "Connecting..."
    var searchController:UISearchController!
    
    //var currentSearchMode = SearchMode.name
    
    var customerNotesLbl:GreyLabel!
    var customerNotesTxtView:UITextView = UITextView()
    
    var contactTableView:TableView!
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var customerJSON: JSON!
    var customerID:String!
    
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    
    init(_customerID:String,_customerJSON:JSON){
        super.init(nibName:nil,bundle:nil)
        self.customerJSON = _customerJSON
        self.customerID = _customerID
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customer Info"
        
        //custom back button
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerContactViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.titleLabel?.textColor = layoutVars.buttonColor1
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        view.backgroundColor = layoutVars.backgroundColor
        self.layoutViews()
    }
    
    func updateContactList(_customerJSON:JSON){
        print("update contact list")
        self.customerJSON = _customerJSON
        
        layoutViews()
        
    }
    
    func layoutViews(){
        
        print("layoutViews")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        
        DispatchQueue.main.async {
            self.customerNotesTxtView.contentOffset = CGPoint.zero
            self.customerNotesTxtView.scrollRangeToVisible(NSRange(location:0, length:0))
            
           
        }
        
        
        
        
        //instructions
        self.customerNotesLbl = GreyLabel()
        self.customerNotesLbl.text = "Customer Notes:"
        self.customerNotesLbl.textAlignment = .left
        self.customerNotesLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.customerNotesLbl)
        
        //self.instructionsView = UITextView()
        self.customerNotesTxtView.layer.borderWidth = 1
        self.customerNotesTxtView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.customerNotesTxtView.layer.cornerRadius = 4.0
        
        self.customerNotesTxtView.backgroundColor = UIColor.white
        var custNotes:String
        if self.customerJSON["customer"]["custNotes"].stringValue == ""{
            custNotes = "No notes on file."
        }else{
            custNotes = self.customerJSON["customer"]["custNotes"].stringValue
        }
        self.customerNotesTxtView.text = custNotes
        self.customerNotesTxtView.font = layoutVars.smallFont
        self.customerNotesTxtView.isEditable = false
        self.customerNotesTxtView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.customerNotesTxtView)
        
        
        
        self.contactTableView = TableView()
        self.contactTableView.delegate  =  self
        self.contactTableView.dataSource = self
        self.contactTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.contactTableView.sectionHeaderHeight = 0
        self.contactTableView.tableHeaderView = UIView(frame: CGRect(x:0, y:0, width:self.contactTableView.bounds.size.width, height:5));
        
        self.view.addSubview(self.contactTableView)
        
        
        
        self.customerNotesLbl.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.customerNotesLbl.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        self.customerNotesLbl.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.customerNotesLbl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.customerNotesTxtView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.customerNotesTxtView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 30.0).isActive = true
        self.customerNotesTxtView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.customerNotesTxtView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.contactTableView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.contactTableView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 118.0).isActive = true
        self.contactTableView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.contactTableView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true
        
        
    }
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.customerJSON["customer"]["contacts"].count + 1
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "cell") as! ContactTableViewCell
        contactTableView.rowHeight = 50.0
        
        if(indexPath.row == self.customerJSON["customer"]["contacts"].count){
            cell.layoutAddBtn()
            return cell
        }else{
            
            
            cell.contact = Contact(_ID: self.customerJSON["customer"]["contacts"][indexPath.row]["ID"].stringValue, _sort: self.customerJSON["customer"]["contacts"][indexPath.row]["sort"].stringValue, _value: self.customerJSON["customer"]["contacts"][indexPath.row]["value"].stringValue, _type: self.customerJSON["customer"]["contacts"][indexPath.row]["type"].stringValue, _contactName: self.customerJSON["customer"]["contacts"][indexPath.row]["contactName"].stringValue, _main: self.customerJSON["customer"]["contacts"][indexPath.row]["main"].stringValue, _name: self.customerJSON["customer"]["contacts"][indexPath.row]["name"].stringValue,_street1:self.customerJSON["customer"]["contacts"][indexPath.row]["street1"].stringValue,_street2:self.customerJSON["customer"]["contacts"][indexPath.row]["street2"].stringValue,_city:self.customerJSON["customer"]["contacts"][indexPath.row]["city"].stringValue,_state:self.customerJSON["customer"]["contacts"][indexPath.row]["state"].stringValue,_zip:self.customerJSON["customer"]["contacts"][indexPath.row]["zip"].stringValue,_zone:self.customerJSON["customer"]["zone"][indexPath.row]["street1"].stringValue,_zoneName:self.customerJSON["customer"]["contacts"][indexPath.row]["zoneName"].stringValue,_color:self.customerJSON["customer"]["contacts"][indexPath.row]["color"].stringValue,_lat:self.customerJSON["customer"]["contacts"][indexPath.row]["lat"].stringValue as NSString,_lng:self.customerJSON["customer"]["contacts"][indexPath.row]["lng"].stringValue as NSString,_fullAddress:self.customerJSON["customer"]["contacts"][indexPath.row]["fullAddress"].stringValue as String)
            
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
                
                cell.nameLbl?.text = cell.contact.fullAddress
                cell.detailLbl?.text = "Billing Address"
                break
                
            //jobSite address
            case "4":
                cell.iconView.image = UIImage(named:"mapIcon.png")
                
                // cell.nameLbl?.text = cell.contact.street1 + " " + cell.contact.street2 + " " + cell.contact.city + ", " + cell.contact.state
                cell.nameLbl?.text = cell.contact.fullAddress
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
            
            
            
            // set preferred state
            if self.customerJSON["customer"]["contacts"][indexPath.row]["preferred"].stringValue == "1"{
                cell.contentView.backgroundColor = UIColor.yellow
            }
            return cell
        }
            
            
            
       
        
        
        
        
        // println("self.customersArray!.count = \(self.customersArray.count)")
        
        
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print("You selected cell #\(indexPath.row)!")
        
        
        if(indexPath.row == self.customerJSON["customer"]["contacts"].count){
            tableView.deselectRow(at: indexPath, animated: false)
            self.addContact()
        }else{
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
        }
        
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.row != customerJSON["customer"]["contacts"].count){
            
            if customerJSON["customer"]["contacts"][indexPath.row]["type"].string! != "3" && customerJSON["customer"]["contacts"][indexPath.row]["type"].string! != "4" && customerJSON["customer"]["contacts"][indexPath.row]["type"].string! != "14"{
                return true
            }else{
                return false
            }
            
        }else{
            return false
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            //print("edit tapped")
            self.editContact(_row:indexPath.row)
            
        }
        edit.backgroundColor = UIColor.gray
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("delete tapped")
            self.deleteContact(_row: indexPath.row)
        }
        delete.backgroundColor = UIColor.red
        
            return [delete, edit]
        
        
    }
    
    
    
    
    
    
    
    func deleteContact(_row:Int){
        //print("delete item")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                //print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("Yes")
                
                
                
                
                var parameters:[String:String]
                parameters = [
                    "contactID":self.customerJSON["customer"]["contacts"][_row]["ID"].string!,"custID":self.customerID
                ]
                print("parameters = \(parameters)")
                
                
                
                
                
                
                
                
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/customerEmail.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        //print("delete response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        if let json = response.result.value {
                            print("JSON: \(json)")
                         self.updateList()
                            
                        }
                        
                        
                        
                }
                
                
                
                
                
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    
    func editContact(_row:Int){
        //print("edit item")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            let newEditContactViewController:NewEditContactViewController = NewEditContactViewController(_custID: self.customerID, _contactID: self.customerJSON["customer"]["contacts"][_row]["ID"].string!, _type: self.customerJSON["customer"]["contacts"][_row]["type"].string!, _typeName: self.customerJSON["customer"]["contacts"][_row]["contactName"].string!, _name: self.customerJSON["customer"]["contacts"][_row]["name"].string!, _value: self.customerJSON["customer"]["contacts"][_row]["value"].string!, _preferred: self.customerJSON["customer"]["contacts"][_row]["preferred"].string!)//NewEditContactViewController(_custID: self.customerJSON["customer"]["ID"].string!)
            newEditContactViewController.delegate = self
            self.navigationController?.pushViewController(newEditContactViewController, animated: false )
        }
    }
    
   
    
    
    func addContact(){
        //print("add item")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            let newEditContactViewController:NewEditContactViewController = NewEditContactViewController(_custID: self.customerID)
            newEditContactViewController.delegate = self
            self.navigationController?.pushViewController(newEditContactViewController, animated: false )
        }
        
    }
    
   
    
    
    
    
    
    func updateList(){
        print("update list")
       // getContacts()
        
        editCustomerDelegate.updateCustomer(_customerID: self.customerID)
        
    }
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
