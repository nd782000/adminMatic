//
//  CustomerListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


enum SearchMode{
    case name
    case address
}

class CustomerListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating{
    
    var indicator: SDevIndicator!
    var totalCustomers:Int!
    //data arrays
    var ids = [String]()
    var names = [String]()
    var addresses = [String]()
    
    var searchController:UISearchController!
    var currentSearchMode = SearchMode.name
    var customerTableView:TableView = TableView()
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    
    var layoutVars:LayoutVars = LayoutVars()
    var sections : [(index: Int, length :Int, title: String)] = Array()
    var customersSearchResults:[String] = []
    var shouldShowSearchResults:Bool = false
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customer List"
        view.backgroundColor = layoutVars.backgroundColor
        getCustomerList()
    }
    
    
    func getCustomerList() {
        //remove any added views (needed for table refresh
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
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
                        if let id = customer["ID"] as? String {
                            self.ids.append(id)
                        }
                        if let name = customer["name"] as? String {
                            self.names.append(name)
                        }
                        
                        if let address = customer["mainAddr"] as? String {
                            self.addresses.append(address)
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            // build sections based on first letter(json is already sorted alphabetically)
            var index = 0;
            var firstCharacterArray:[String] = [" "]
            for i in 0 ..< self.names.count {
                let stringToTest = self.names[i].uppercased()
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
                if(i == self.names.count - 1){
                    let title = firstCharacterArray[firstCharacterArray.count - 1]
                    let newSection = (index: index, length: i - index, title: title)
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
        navigationItem.titleView = searchController.searchBar
        
        let items = ["Name","Address"]
        let customSC = SegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        
        customSC.addTarget(self, action: #selector(self.changeSearchOptions(sender:)), for: .valueChanged)
        self.view.addSubview(customSC)
        
        self.customerTableView.delegate  =  self
        self.customerTableView.dataSource = self
        self.customerTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.customerTableView)
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        //self.countView.layer.borderColor = layoutVars.borderColor
        //self.countView.layer.borderWidth = 1.0
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        self.countLbl.text = "\(self.ids.count) Active Customers "
        self.countView.addSubview(self.countLbl)
        
        
        
        //auto layout group
        let viewsDictionary = [
            "view2":customSC,
            "view3":self.customerTableView,
            "view4":self.countView
        ]as [String:AnyObject]
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - 100] as [String:Any]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view4(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[view2(40)][view3][view4(30)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
   
    
/////////////// Search Methods   ///////////////////////
    
    func changeSearchOptions(sender: UISegmentedControl) {
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
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
    
    func filterSearchResults(){
        customersSearchResults = []
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
                return "    # \(self.totalCustomers)  Customers Found"
            }else{
                return "    " + sections[section].title //hack way of indenting section text
                
            }
        }
        
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]?{
        print("sectionIndexTitlesForTableView 1")
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
            return self.customersSearchResults.count
        } else {
            return sections[section].length
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customerTableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerTableViewCell
        customerTableView.rowHeight = 50.0
        if shouldShowSearchResults{
            let searchString = self.searchController.searchBar.text!.lowercased()
            if(currentSearchMode == .name){
                cell.nameLbl.text = self.customersSearchResults[indexPath.row]
                cell.name = self.customersSearchResults[indexPath.row]
                if let i = self.names.index(of: cell.nameLbl.text!) {
                    //print("\(cell.nameLbl.text!) is at index \(i)")
                    cell.addressLbl.text = self.addresses[i]
                    cell.address = self.addresses[i]
                    cell.id = self.ids[i]
                } else {
                    cell.addressLbl.text = ""
                    cell.address = ""
                    cell.id = ""
                }
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
                    print("Oh no! \(regexError)")
                } else {
                    for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                        highlightedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: match.range)
                    }
                }
                cell.nameLbl.attributedText = highlightedText
 
            }else{//address search mode
                cell.addressLbl.text = self.customersSearchResults[indexPath.row]
                cell.address = self.customersSearchResults[indexPath.row]
                
                if let i = self.addresses.index(of: cell.addressLbl.text!) {
                    cell.nameLbl.text = self.names[i]
                    cell.name = self.names[i]
                    cell.id = self.ids[i]
                } else {
                    cell.nameLbl.text = ""
                    cell.name = ""
                    cell.id = ""
                }
                //text highlighting
                let baseString:NSString = cell.address as NSString
                let highlightedText = NSMutableAttributedString(string: cell.address)
                var error: NSError?
                let regex: NSRegularExpression?
                do {
                    regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
                } catch let error1 as NSError {
                    error = error1
                    regex = nil
                }
                if let regexError = error {
                    print("Oh no! \(regexError)")
                } else {
                    for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                        highlightedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: match.range)
                    }
                    
                }
                cell.addressLbl.attributedText = highlightedText
            }
        } else {
            //print("make cell")
            cell.id = self.ids[sections[indexPath.section].index + indexPath.row]
            cell.name = self.names[sections[indexPath.section].index + indexPath.row]
            cell.address = self.addresses[sections[indexPath.section].index + indexPath.row]

            cell.nameLbl.text = self.names[sections[indexPath.section].index + indexPath.row]
            cell.addressLbl.text = self.addresses[sections[indexPath.section].index + indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! CustomerTableViewCell
        let customerViewController = CustomerViewController(_customerID: currentCell.id,_customerName: currentCell.name)
        navigationController?.pushViewController(customerViewController, animated: false )
        
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




