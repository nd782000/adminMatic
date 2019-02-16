//
//  CustomerListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView


import Foundation
import UIKit
import Alamofire
//import SwiftyJSON

 /*
enum SearchMode{
    case name
    case address
}
*/
protocol CustomerListDelegate{
    func cancelSearch()//to resolve problem with imageSelection bug when search mode is active
    func updateList(_customerID:String,_newCustomer:Bool)
}



class CustomerListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, CustomerListDelegate{
    
    var indicator: SDevIndicator!
    var totalCustomers:Int!
    //data arrays
    //var ids = [String]()
    //var names = [String]()
   // var addresses = [String]()
    
    var customerArray = [Customer]()
    var customersSearchResults = [Customer]()
    
    var searchController:UISearchController!
   // var currentSearchMode = SearchMode.name
    var customerTableView:TableView = TableView()
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    
    var layoutVars:LayoutVars = LayoutVars()
    var sections : [(index: Int, length :Int, title: String)] = Array()
   // var customersSearchResults:[String] = []
    var shouldShowSearchResults:Bool = false
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    var addCustomerBtn:Button = Button(titleText: "Add Customer")
    var newCustomerLookUpViewController:NewCustomerLookUpViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customer List"
        view.backgroundColor = layoutVars.backgroundColor
        
       // print("test for network")
        if(self.appDelegate.isConnectedToNetwork() == true){
           // print("network good")
        }else{
            //print("network bad")
        }
        
        
        getCustomerList()
    }
    
    
    func getCustomerList() {
        //remove any added views (needed for table refresh
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        
        self.customerArray = []
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject

        
        Alamofire.request(API.Router.customerList(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let customers = json["customers"] as? [[String: Any]] {
                    for customer in customers {
                        let customer = Customer(_name: customer["name"] as? String, _id: customer["ID"] as? String, _address: customer["mainAddr"] as? String, _contactID: customer["contactID"] as? String)
                        self.customerArray.append(customer)
                    }
                    /*for customer in customers {
                        if let id = customer["ID"] as? String {
                            self.ids.append(id)
                        }
                        if let name = customer["name"] as? String {
                            self.names.append(name)
                        }
                        
                        if let address = customer["mainAddr"] as? String {
                            self.addresses.append(address)
                        }
                    }*/
                }
            } catch {
                //print("Error deserializing JSON: \(error)")
            }
            // build sections based on first letter(json is already sorted alphabetically)
            var index = 0;
            var firstCharacterArray:[String] = [" "]
            for i in 0 ..< self.customerArray.count {
                let stringToTest = self.customerArray[i].name.uppercased()
                let firstCharacter = String(stringToTest[stringToTest.startIndex])
                
                if(i == 0){
                    firstCharacterArray.append(firstCharacter)
                }
                if !firstCharacterArray.contains(firstCharacter) {
                    let title = firstCharacterArray[firstCharacterArray.count - 1]
                    firstCharacterArray.append(firstCharacter)
                    let newSection = (index: index, length: i - index, title: title)
                    self.sections.append(newSection)
                    index = i;
                }
                if(i == self.customerArray.count - 1){
                    let title = firstCharacterArray[firstCharacterArray.count - 1]
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
            self.layoutViews()
        }
    }
    
    
    func layoutViews(){
        indicator.dismissIndicator()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Customers"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = layoutVars.buttonBackground
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
        
       
        /*
        let items = ["Name","Address"]
        let customSC = SegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        
        customSC.addTarget(self, action: #selector(self.changeSearchOptions(sender:)), for: .valueChanged)
        self.view.addSubview(customSC)
        */
        
        
        self.customerTableView.delegate  =  self
        self.customerTableView.dataSource = self
        self.customerTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.customerTableView)
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        //self.addCustomerBtn.addTarget(self, action: #selector(CustomerListViewController.addCustomer), for: UIControl.Event.touchUpInside)
        addCustomerBtn.addTarget(self, action: #selector(CustomerListViewController.addCustomer), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addCustomerBtn)
      
        /*
        customSC.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        customSC.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        customSC.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        customSC.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        */
        
        
        
       // print("customSC height = \(customSC.frame.size.height)")
        self.customerTableView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.customerTableView.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        self.customerTableView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.customerTableView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -80.0).isActive = true
        
        self.countView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.countView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -40.0).isActive = true
        self.countView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.countView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        self.addCustomerBtn.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.addCustomerBtn.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        self.addCustomerBtn.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.addCustomerBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        
        
        self.countLbl.leftAnchor.constraint(equalTo: countView.safeLeftAnchor, constant: 10.0).isActive = true
        self.countLbl.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor, constant: -40.0).isActive = true
        self.countLbl.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20.0).isActive = true
        self.countLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
    }
    
   
    /*
/////////////// Search Methods   ///////////////////////
    
    @objc func changeSearchOptions(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentSearchMode = .name
            break
        case 1:
            currentSearchMode = .address
            break
        default:
            currentSearchMode = .name
            break
        }
        filterSearchResults()
    }
    
    */
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
    
    func filterSearchResults(){
        customersSearchResults = []
        /*
        switch  currentSearchMode {
        case .name:
            self.customersSearchResults = self.names.filter({( aCustomer: String ) -> Bool in
                return (aCustomer.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
            break
        case .address:
            self.customersSearchResults = self.addresses.filter({( aCustomer: String) -> Bool in
                return (aCustomer.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
            })
            break
        }
 */
        //switch  currentSearchMode {
       // case .name:
            self.customersSearchResults = self.customerArray.filter({( aCustomer: Customer ) -> Bool in
                return (aCustomer.name.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil  || aCustomer.address.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
            //self.customersSearchResults = self.names.filter({( aCustomer: String ) -> Bool in
                //return (aCustomer.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
            //break
        //case .address:
            
            //self.customersSearchResults = self.customerArray.filter({( aCustomer: Customer) -> Bool in
               // return (aCustomer.address.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
            //})
            
           // self.customersSearchResults = self.addresses.filter({( aCustomer: String) -> Bool in
               // return (aCustomer.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
            //})
            //break
        //}
        
        
        self.customerTableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.customerTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.customerTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.customerTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    /////////////// TableView Delegate Methods   ///////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowSearchResults{
            return 1
        }else{
            return sections.count
        }
    }
 
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         //print("titleForHeaderInSection")
        if shouldShowSearchResults{
            return nil
        }else{
            if(sections[section].title == "#"){
                return "    # \(String(describing: self.totalCustomers))  Customers Found"
            }else{
                return "    " + sections[section].title //hack way of indenting section text
                
            }
        }
        
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]?{
       // print("sectionIndexTitlesForTableView 1")
        if shouldShowSearchResults{
            return nil
        }else{
            //print("sectionIndexTitlesForTableView \(sections.map { $0.title })")
            return sections.map { $0.title }
            
        }
    }
    
    
 
   
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //print("heightForHeaderInSection")
        if shouldShowSearchResults{
            return 0
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection")
        if shouldShowSearchResults{
            self.countLbl.text = "\(self.customersSearchResults.count) Customer(s) Found "
            return self.customersSearchResults.count
        } else {
            self.countLbl.text = "\(self.customerArray.count) Active Customer(s) "
            return sections[section].length
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customerTableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerTableViewCell
        customerTableView.rowHeight = 50.0
        if shouldShowSearchResults{
            let searchString = self.searchController.searchBar.text!.lowercased()
           // if(currentSearchMode == .name){
                //cell.nameLbl.text = self.customersSearchResults[indexPath.row]
                //cell.name = self.customersSearchResults[indexPath.row]
                //if let i = self.names.index(of: cell.nameLbl.text!) {
                
                cell.name = self.customersSearchResults[indexPath.row].name
                cell.nameLbl.text = cell.name
                cell.id = self.customersSearchResults[indexPath.row].ID
                cell.address = self.customersSearchResults[indexPath.row].address
                cell.addressLbl.text = cell.address
                /*if let i = self.names.index(of: cell.nameLbl.text!) {
                    //print("\(cell.nameLbl.text!) is at index \(i)")
                    cell.addressLbl.text = self.addresses[i]
                    cell.address = self.addresses[i]
                    cell.id = self.ids[i]
                } else {
                    cell.addressLbl.text = ""
                    cell.address = ""
                    cell.id = ""
                }*/
                
                //text highlighting
                let baseString:NSString = cell.name as NSString
                let highlightedText = NSMutableAttributedString(string: cell.name)
                var error: NSError?
                let regex: NSRegularExpression?
                do {
                    regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
                } catch let error1 as NSError {
                    error = error1
                    regex = nil
                }
                if let regexError = error {
                   // print("Oh no! \(regexError)")
                } else {
                    for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                        highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                    }
                }
                cell.nameLbl.attributedText = highlightedText
 
            
            let baseString2:NSString = cell.address as NSString
            let highlightedText2 = NSMutableAttributedString(string: cell.address)
            var error2: NSError?
            let regex2: NSRegularExpression?
            do {
                regex2 = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error2a as NSError {
                error2 = error2a
                regex2 = nil
            }
            if let regexError2 = error2 {
                print("Oh no! \(regexError2)")
            } else {
                for match in (regex2?.matches(in: baseString2 as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString2.length)))! as [NSTextCheckingResult] {
                    highlightedText2.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            //cell.nameLbl.attributedText = highlightedText
            cell.addressLbl.attributedText = highlightedText2
            
            
            
//            }else{//address search mode
//                cell.addressLbl.text = self.customersSearchResults[indexPath.row].address
//                cell.address = self.customersSearchResults[indexPath.row].address
//
//                cell.name = self.customersSearchResults[indexPath.row].name
//                cell.nameLbl.text = cell.name
//                cell.id = self.customersSearchResults[indexPath.row].ID
//
//                /*
//                if let i = self.addresses.index(of: cell.addressLbl.text!) {
//                    cell.nameLbl.text = self.names[i]
//                    cell.name = self.names[i]
//                    cell.id = self.ids[i]
//                } else {
//                    cell.nameLbl.text = ""
//                    cell.name = ""
//                    cell.id = ""
//                }
// */
//
//                //text highlighting
//                let baseString:NSString = cell.address as NSString
//                let highlightedText = NSMutableAttributedString(string: cell.address)
//                var error: NSError?
//                let regex: NSRegularExpression?
//                do {
//                    regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
//                } catch let error1 as NSError {
//                    error = error1
//                    regex = nil
//                }
//                if let regexError = error {
//                  //  print("Oh no! \(regexError)")
//                } else {
//                    for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
//                        highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
//                    }
//
//                }
//                cell.addressLbl.attributedText = highlightedText
//            }
        } else {
            //print("make cell")
            cell.id = self.customerArray[sections[indexPath.section].index + indexPath.row].ID
            cell.name = self.customerArray[sections[indexPath.section].index + indexPath.row].name
            cell.address = self.customerArray[sections[indexPath.section].index + indexPath.row].address

            cell.nameLbl.text = self.customerArray[sections[indexPath.section].index + indexPath.row].name
            cell.addressLbl.text = self.customerArray[sections[indexPath.section].index + indexPath.row].address
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! CustomerTableViewCell
        let customerViewController = CustomerViewController(_customerID: currentCell.id,_customerName: currentCell.name)
        customerViewController.customerListDelegate = self
        navigationController?.pushViewController(customerViewController, animated: false )
        
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    
    
    
    func cancelSearch() {
       // print("cancel search")
        if(self.searchController.isActive == true){
            self.searchController.isActive = false
            shouldShowSearchResults = false
            self.customerTableView.reloadData()
        }
    }
    
    func updateList(_customerID:String,_newCustomer:Bool = false){
        print("update customer list")
        
        self.searchController.isActive = false
        shouldShowSearchResults = false
        
        if self.newCustomerLookUpViewController != nil{
            navigationController?.popViewController(animated: false)
        }
        
        if _newCustomer{
            let customerViewController = CustomerViewController(_customerID: _customerID,_customerName: "")
            customerViewController.customerListDelegate = self
            navigationController?.pushViewController(customerViewController, animated: false )
        }
        
        getCustomerList()
    }
    
    @objc func addCustomer(){
       // print("Add Customer")
        
        //self.disableSearch()
        
        self.newCustomerLookUpViewController = NewCustomerLookUpViewController(_customerArray: self.customerArray)
        self.newCustomerLookUpViewController!.delegate = self
        navigationController?.pushViewController(self.newCustomerLookUpViewController!, animated: false )
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}




