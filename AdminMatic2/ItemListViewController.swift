//
//  ItemListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON



class ItemListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating{
    var indicator: SDevIndicator!
    var totalItems:Int!
    //var loadedItems:Int!
    //var refreshControl:UIRefreshControl!
    var searchController:UISearchController!
    
    var currentSearchMode = SearchMode.name
    
    var itemTableView:TableView = TableView()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    var items: JSON!
    var itemsArray:[Item] = []
    var itemsSearchResults:[Item] = []
    var shouldShowSearchResults:Bool = false
    
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Item List"
        view.backgroundColor = layoutVars.backgroundColor
        getItemList()
    }
    
    
    func getItemList() {
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
        
        
        Alamofire.request(API.Router.itemList(["cb":timeStamp as AnyObject])).responseJSON(){ response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.items = JSON(json)
                self.parseJSON()
                
            }
        }
        
        
    }
    func parseJSON(){
        let jsonCount = self.items["items"].count
        self.totalItems = jsonCount
        print("JSONcount: \(jsonCount)")
        for i in 0 ..< jsonCount {
            
            //create a item object
            let item = Item( _name: self.items["items"][i]["name"].stringValue, _id: self.items["items"][i]["ID"].stringValue, _type: self.items["items"][i]["type"].stringValue, _price: self.items["items"][i]["price"].stringValue, _units: self.items["items"][i]["unit"].stringValue)
            
            self.itemsArray.append(item)
            
        }
        let item = Item(_name:"# \(jsonCount) Items", _id: "", _type: "", _price: "", _units: "")
        self.itemsArray.append(item)
        
        
        
        // build sections based on first letter(json is already sorted alphabetically)
        
        var index = 0;
        var firstCharacterArray:[String] = [" "]
        
        for i in 0 ..< self.itemsArray.count {
            print("loop for first character")
            let stringToTest = self.itemsArray[i].name.uppercased()
            print("stringToTest = \(stringToTest)")
            let firstCharacter = String(stringToTest[stringToTest.startIndex])
            print("firstCharacter = \(firstCharacter)")
            if(i == 0){
                firstCharacterArray.append(firstCharacter)
            }
            
            
            
            
            if !firstCharacterArray.contains(firstCharacter) {
                
                print("new")
                let title = firstCharacterArray[firstCharacterArray.count - 1]
                firstCharacterArray.append(firstCharacter)
                
                let newSection = (index: index, length: i - index, title: title)
                sections.append(newSection)
                print("firstCharacterArray = \(firstCharacterArray)")
                index = i;
            }
            if(i == self.itemsArray.count - 1){
                let title = firstCharacterArray[firstCharacterArray.count - 1]
                
                //let title = "count: #  \(jsonCount)  Items Found"
                let newSection = (index: index, length: i - index, title: title)
                sections.append(newSection)
            }
        }
        print("sections = \(sections)")
        self.layoutViews()
        
    }
    
    
    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Items"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        self.itemTableView.delegate  =  self
        self.itemTableView.dataSource = self
        self.itemTableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.itemTableView)
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemTableView
        ] as [String : Any]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[view1(height)]", options:[], metrics: sizeVals, views: viewsDictionary))
        
        
    }
    
    
    /////////////// Search Methods   ///////////////////////
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResultsForSearchController \(searchController.searchBar.text)")
        filterSearchResults()
    }
   
    func filterSearchResults(){
            self.itemsSearchResults = self.itemsArray.filter({( aItem: Item) -> Bool in
                return (aItem.name!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
            self.itemTableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.itemTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        shouldShowSearchResults = false
        self.itemTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.itemTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
        shouldShowSearchResults = false;
    }
    
    func willPresentSearchController(_ searchController: UISearchController){
        
        
    }
    
    
    func presentSearchController(searchController: UISearchController){
        
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
        if shouldShowSearchResults{
            return nil
        }else{
            if(sections[section].title == "#"){
                return "    # \(itemsArray.count)  Items Found"
            }else{
                return "    " + sections[section].title //hack way of indenting section text
                
            }
        }
        
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if shouldShowSearchResults{
            return nil
        }else{
            
            return sections.map { $0.title }
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
        if shouldShowSearchResults{
            return self.itemsSearchResults.count 
        } else {
            //return self.itemsArray.count ?? 0
            return sections[section].length 
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "cell") as! ItemTableViewCell
        itemTableView.rowHeight = 50.0
        // cell.textLabel?.text = array[sections[indexPath.section].index + indexPath.row]
        
        print("self.itemsArray!.count = \(self.itemsArray.count)")
        
        if shouldShowSearchResults{
            cell.item = self.itemsSearchResults[indexPath.row]
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            // if(currentSearchMode == .name){
            
            //text highlighting
            let baseString:NSString = cell.item.name as NSString
            let highlightedText = NSMutableAttributedString(string: cell.item.name!)
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
            //cell.addressLbl.text = cell.item.address
            
            
            
        } else {
            
            
            cell.item = self.itemsArray[sections[indexPath.section].index + indexPath.row]
            cell.nameLbl.text = self.itemsArray[sections[indexPath.section].index + indexPath.row].name
                       
        }
        
        cell.typeLbl.text = "\(cell.item.type!) Type"
        cell.priceLbl.text = "$\(cell.item.price!)/\(cell.item.units!)"
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! ItemTableViewCell;
        
        if(currentCell.item != nil && currentCell.item.ID != ""){
            
            searchController.isActive = false
            let itemViewController = ItemViewController(_item: currentCell.item)
            navigationController?.pushViewController(itemViewController, animated: false )
            
            tableView.deselectRow(at: indexPath!, animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
