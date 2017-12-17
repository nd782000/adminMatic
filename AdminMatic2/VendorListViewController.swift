//
//  VendorListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON

//extension String: SequenceType {}


class VendorListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating{
    var indicator: SDevIndicator!
    var totalVendors:Int!
    
    //data arrays
    var ids = [String]()
    var names = [String]()
    var addresses = [String]()
    var phones = [String]()
    
    
    //var loadedVendors:Int!
    // var loadingString:String = "Connecting..."
    //var refreshControl:UIRefreshControl!
    var searchController:UISearchController!
    
    //var currentSearchMode = SearchMode.name
    
    var vendorTableView:TableView = TableView()
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    //var vendors: JSON!
    //var vendorsArray:[Vendor] = []
    var vendorsSearchResults:[String] = []
    var shouldShowSearchResults:Bool = false
    
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vendor List"
        view.backgroundColor = layoutVars.backgroundColor
        getVendorList()
    }
    
    
    func getVendorList() {
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
        
        Alamofire.request(API.Router.vendorList(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let vendors = json["vendors"] as? [[String: Any]] {
                    for vendor in vendors {
                        if let id = vendor["ID"] as? String {
                            self.ids.append(id)
                        }
                        if let name = vendor["name"] as? String {
                            self.names.append(name)
                            print("vendor name = \(name)")
                        }
                        
                        if let address = vendor["address"] as? String {
                            self.addresses.append(address)
                        }
                        
                        if let phone = vendor["phone"] as? String {
                            self.phones.append(phone)
                        }
                        
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            /*
            // build sections based on first letter(json is already sorted alphabetically)
            var index = 0;
            var firstCharacterArray:[String] = [" "]
            for i in 0 ..< self.names.count {
                if(self.names[i] != ""){
                print("stringToTest = \(self.names[i].uppercased())")
                
                
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
                
                }
                if(i == self.names.count - 1){
                    let title = firstCharacterArray[firstCharacterArray.count - 1]
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
 */
            
            
            
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
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
            
            
            
            
            self.layoutViews()
        }
        
        
        
        
        
    }
    
    
    
    
    
    func layoutViews(){
        
        //title = "Vendor List"
        
        // Close Indicator
        indicator.dismissIndicator()
        
        
        // Initialize and perform a minimum configuration to the search controller.
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Vendors"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.barTintColor = layoutVars.buttonBackground
        
        //navigationItem.titleView = searchController.searchBar
        
        
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
        /*
        searchController.searchBar.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController?.searchBar
        }
 */
        
        
        
        
        self.vendorTableView.delegate  =  self
        self.vendorTableView.dataSource = self
        self.vendorTableView.register(VendorTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.vendorTableView)

        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        //self.countView.layer.borderColor = layoutVars.borderColor
        //self.countView.layer.borderWidth = 1.0
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        self.countLbl.text = "\(self.ids.count) Active Vendors "
        self.countView.addSubview(self.countLbl)
        
        
        //auto layout group
        let viewsDictionary = [
            "view1":self.vendorTableView,
            "view2":self.countView
        ] as [String : Any]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[view1][view2(30)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
        
         
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
    
    func filterSearchResults(){
        vendorsSearchResults = []
      
            self.vendorsSearchResults = self.names.filter({( aVendor: String ) -> Bool in
                return (aVendor.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
        
        self.vendorTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.vendorTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.vendorTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.vendorTableView.reloadData()
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
                return "    # \(self.totalVendors)  Vendors Found"
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
            return self.vendorsSearchResults.count
        } else {
            return sections[section].length
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = vendorTableView.dequeueReusableCell(withIdentifier: "cell") as! VendorTableViewCell
        vendorTableView.rowHeight = 50.0
        if shouldShowSearchResults{
            let searchString = self.searchController.searchBar.text!.lowercased()
           // if(currentSearchMode == .name){
                cell.nameLbl.text = self.vendorsSearchResults[indexPath.row]
                cell.name = self.vendorsSearchResults[indexPath.row]
            
                if let i = self.names.index(of: cell.nameLbl.text!) {
                    //print("\(cell.nameLbl.text!) is at index \(i)")
                    cell.addressLbl.text = self.addresses[i]
                    cell.address = self.addresses[i]
                    cell.id = self.ids[i]
                    cell.phone = self.phones[i]
                } else {
                    cell.addressLbl.text = ""
                    cell.address = ""
                    cell.id = ""
                    cell.phone = ""
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
                        highlightedText.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: match.range)
                    }
                }
                cell.nameLbl.attributedText = highlightedText
                
            
            
        } else {
            //print("make cell")
            cell.id = self.ids[sections[indexPath.section].index + indexPath.row]
            cell.name = self.names[sections[indexPath.section].index + indexPath.row]
            cell.address = self.addresses[sections[indexPath.section].index + indexPath.row]
            cell.phone = self.phones[sections[indexPath.section].index + indexPath.row]
            
            cell.nameLbl.text = self.names[sections[indexPath.section].index + indexPath.row]
            cell.addressLbl.text = self.addresses[sections[indexPath.section].index + indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! VendorTableViewCell
        let vendorViewController = VendorViewController(_vendorID: currentCell.id)
        navigationController?.pushViewController(vendorViewController, animated: false )
        
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   //cell editing
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! VendorTableViewCell;
        
        let call = UITableViewRowAction(style: .normal, title: "Phone") { action, index in
            print("call button tapped")
            
            if (cleanPhoneNumber(currentCell.phone) != ""){
                
                UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(currentCell.phone))")! as URL, options: [:], completionHandler: nil)
            }
            
            
        }
        call.backgroundColor = layoutVars.buttonTint
        return [call]
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }

    
    
    
    

    
    
    
    
}
