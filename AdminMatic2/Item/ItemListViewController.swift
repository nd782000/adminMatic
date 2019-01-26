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
//import SwiftyJSON



class ItemListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating{
    var indicator: SDevIndicator!
    var totalItems:Int!
    
    var searchController:UISearchController!
    
    var currentSearchMode = SearchMode.name
    
    var itemTableView:TableView = TableView()
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    //var items: JSON!
    var itemsArray:[Item] = []
    var itemsSearchResults:[Item] = []
    var shouldShowSearchResults:Bool = false
    
    
    
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
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            //if let json = response.result.value {
                //print("JSON: \(json)")
               // self.items = JSON(json)
                //self.parseJSON()
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let items = json["items"] as? [[String: Any]] {
                        
                        let itemCount = items.count
                        print("item count = \(itemCount)")
                        
                        
                        for i in 0 ..< itemCount {
                            
                            
                            //create an object
                            print("create a item object \(i)")
                            
                            
                            let item = Item( _name: items[i]["name"] as? String, _id: items[i]["ID"] as? String, _type: items[i]["type"] as? String, _price: items[i]["price"] as? String, _units: items[i]["unit"] as? String, _description: items[i]["description"] as? String, _taxable: items[i]["taxable"] as? String)
                            
                            self.itemsArray.append(item)
                            
                            
                            
                        }
                    }
                    
                    
                 
                    // build sections based on first letter(json is already sorted alphabetically)
                    
                    var index = 0;
                    var firstCharacterArray:[String] = [" "]
                    
                    for i in 0 ..< self.itemsArray.count {
                        let stringToTest = self.itemsArray[i].name.uppercased()
                        let firstCharacter = String(stringToTest[stringToTest.startIndex])
                        if(i == 0){
                            firstCharacterArray.append(firstCharacter)
                        }
                        
                        
                        
                        
                        if !firstCharacterArray.contains(firstCharacter) {
                            
                            //print("new")
                            let title = firstCharacterArray[firstCharacterArray.count - 1]
                            firstCharacterArray.append(firstCharacter)
                            
                            let newSection = (index: index, length: i - index, title: title)
                            self.sections.append(newSection)
                            index = i;
                        }
                        
                        if(i == self.itemsArray.count - 1){
                            let title = firstCharacterArray[firstCharacterArray.count - 1]
                            let newSection = (index: index, length: i - index + 1, title: title)
                            self.sections.append(newSection)
                        }
                        
                        
                    }
                    
                    self.indicator.dismissIndicator()
                    
                    
                    self.layoutViews()
                    
                    
                   
                    
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
                
                
                
           // }
        }
        
        
    }
    
    /*
    func parseJSON(){
        let jsonCount = self.items["items"].count
        self.totalItems = jsonCount
        for i in 0 ..< jsonCount {
            
            //create a item object
            let item = Item( _name: self.items["items"][i]["name"].stringValue, _id: self.items["items"][i]["ID"].stringValue, _type: self.items["items"][i]["type"].stringValue, _price: self.items["items"][i]["price"].stringValue, _units: self.items["items"][i]["unit"].stringValue, _description: self.items["items"][i]["description"].stringValue, _taxable: self.items["items"][i]["taxable"].stringValue)
            
            self.itemsArray.append(item)
            
        }
        //let item = Item(_name:"# \(jsonCount) Items", _id: "", _type: "", _price: "", _units: "",_description:"",_taxable:"")
        //self.itemsArray.append(item)
        
        
        
        // build sections based on first letter(json is already sorted alphabetically)
        
        var index = 0;
        var firstCharacterArray:[String] = [" "]
        
        for i in 0 ..< self.itemsArray.count {
            let stringToTest = self.itemsArray[i].name.uppercased()
            let firstCharacter = String(stringToTest[stringToTest.startIndex])
            if(i == 0){
                firstCharacterArray.append(firstCharacter)
            }
            
            
            
            
            if !firstCharacterArray.contains(firstCharacter) {
                
                //print("new")
                let title = firstCharacterArray[firstCharacterArray.count - 1]
                firstCharacterArray.append(firstCharacter)
                
                let newSection = (index: index, length: i - index, title: title)
                sections.append(newSection)
                index = i;
            }
            
            if(i == self.itemsArray.count - 1){
                let title = firstCharacterArray[firstCharacterArray.count - 1]
                let newSection = (index: index, length: i - index + 1, title: title)
                self.sections.append(newSection)
            }
            
            
        }
        
        
        
        
        self.layoutViews()
        
    }
 */
    
    
    
    
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
        searchController.searchBar.backgroundColor = UIColor.clear
        
        
        
        
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
        
        self.itemTableView.delegate  =  self
        self.itemTableView.dataSource = self
        self.itemTableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.itemTableView)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)

        
        
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemTableView,
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
    
    
    /////////////// Search Methods   ///////////////////////
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(String(describing: searchController.searchBar.text))")
        filterSearchResults()
    }
   
    func filterSearchResults(){
        /*
            self.itemsSearchResults = self.itemsArray.filter({( aItem: Item) -> Bool in
                return (aItem.name!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
            self.itemTableView.reloadData()
 */
        
        self.itemsSearchResults = self.itemsArray.filter({( aItem: Item) -> Bool in
            
            //return type name or name
            return (aItem.name!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
        })
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
    
    /*
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
        shouldShowSearchResults = false;
    }
    */
    
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
        ////print("titleForHeaderInSection")
        if shouldShowSearchResults{
            return nil
        }else{
            
                return "    " + sections[section].title //hack way of indenting section text
                
        }
        
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if shouldShowSearchResults{
            return nil
        }else{
            
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
            
            self.countLbl.text = "\(self.itemsSearchResults.count) Item(s) Found"
            
            return self.itemsSearchResults.count
        } else {
            
            self.countLbl.text = "\(self.itemsArray.count) Active Items"
            
            return sections[section].length
        }
    }
    
    
   
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "cell") as! ItemTableViewCell
        itemTableView.rowHeight = 50.0
        // cell.textLabel?.text = array[sections[indexPath.section].index + indexPath.row]
        
        //print("self.itemsArray!.count = \(self.itemsArray.count)")
        
        if shouldShowSearchResults{
            
            print("cell for table - search")
            /*
            cell.item = self.itemsSearchResults[indexPath.row]
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            // if(currentSearchMode == .name){
            
            //text highlighting
            //let baseString:NSString = cell.item.name as NSString
            //let highlightedText = NSMutableAttributedString(string: cell.item.name!)
            
            let baseString:NSString = self.itemsSearchResults[indexPath.row].name! as NSString
            let highlightedText = NSMutableAttributedString(string: self.itemsSearchResults[indexPath.row].name!)
            
            
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
            cell.layoutViews()
            cell.nameLbl.attributedText = highlightedText
            //cell.addressLbl.text = cell.item.address
            */
            
            cell.item = self.itemsSearchResults[indexPath.row]
            
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            //text highlighting
            
            
            
            
            let baseString:NSString = self.itemsSearchResults[indexPath.row].name! as NSString
            let highlightedText = NSMutableAttributedString(string: self.itemsSearchResults[indexPath.row].name!)
            
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
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            
            
            
            
            
            
            
            cell.layoutViews()
            
            cell.nameLbl.attributedText = highlightedText
            
            //cell.descriptionLbl.attributedText = highlightedText2
            
            
            
            
            
        } else {
            
            
            cell.item = self.itemsArray[sections[indexPath.section].index + indexPath.row]
            cell.layoutViews()
            //cell.nameLbl.text = self.itemsArray[sections[indexPath.section].index + indexPath.row].name
        }
        
       
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! ItemTableViewCell;
        
        //if(currentCell.item != nil && currentCell.item.ID != ""){
            
            //searchController.isActive = false
            let itemViewController = ItemViewController(_item: currentCell.item)
            navigationController?.pushViewController(itemViewController, animated: false )
            
            tableView.deselectRow(at: indexPath!, animated: true)
        //}
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
