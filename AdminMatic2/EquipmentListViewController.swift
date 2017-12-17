//
//  EquipmentListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol EquipmentDelegate{
    func reDrawEquipmentList(_index:Int, _status:String)
}



class EquipmentListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, EquipmentDelegate{
    var indicator: SDevIndicator!
    var totalEquipment:Int!
    //var loadedItems:Int!
    //var refreshControl:UIRefreshControl!
    var searchController:UISearchController!
    
    var currentSortMode = "CREW"
    
    
    
    
    var equipmentTableView:TableView = TableView()
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
   var sections : [(index: Int, length :Int, title: String)] = Array()
    var equipment: JSON!
    var equipmentArray:[Equipment] = []
    var equipmentSearchResults:[Equipment] = []
    var shouldShowSearchResults:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Equipment List"
        view.backgroundColor = layoutVars.backgroundColor
        getEquipmentList()
    }
    
    
    func getEquipmentList() {
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
        
        
        let parameters = ["cb": timeStamp as AnyObject]
        print("parameters = \(parameters)")
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/equipment.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("equipment response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    print("JSON: \(json)")
                    self.equipment = JSON(json)
                    self.parseJSON()
                }
                
        }
        
    }
    func parseJSON(){
        let jsonCount = self.equipment["equipment"].count
        self.totalEquipment = jsonCount
        for i in 0 ..< jsonCount {
            
            //create an equipment object
            let equipment = Equipment(_ID: self.equipment["equipment"][i]["equipID"].stringValue, _name: self.equipment["equipment"][i]["eName"].stringValue, _make: self.equipment["equipment"][i]["make"].stringValue, _model: self.equipment["equipment"][i]["model"].stringValue, _serial: self.equipment["equipment"][i]["serial"].stringValue, _crew: self.equipment["equipment"][i]["crewName"].stringValue, _status: self.equipment["equipment"][i]["status"].stringValue, _statusName: self.equipment["equipment"][i]["statusName"].stringValue, _type: self.equipment["equipment"][i]["typeName"].stringValue, _fuelType: self.equipment["equipment"][i]["fuelType"].stringValue, _engineType: self.equipment["equipment"][i]["engineType"].stringValue, _mileage: self.equipment["equipment"][i]["mileage"].stringValue, _pic: self.equipment["equipment"][i]["pic"].stringValue, _dealer: self.equipment["equipment"][i]["dealer"].stringValue, _purchaseDate: self.equipment["equipment"][i]["purchaseDate"].stringValue)
            
           // let equipment = Equipment( _name: self.items["items"][i]["name"].stringValue, _id: self.items["items"][i]["ID"].stringValue, _type: self.items["items"][i]["type"].stringValue, _price: self.items["items"][i]["price"].stringValue, _units: self.items["items"][i]["unit"].stringValue, _description: self.items["items"][i]["description"].stringValue, _taxable: self.items["items"][i]["taxable"].stringValue)
            
            self.equipmentArray.append(equipment)
            
        }
        //let item = Item(_name:"# \(jsonCount) Items", _id: "", _type: "", _price: "", _units: "",_description:"",_taxable:"")
       // self.itemsArray.append(item)
        
        
        
        
        
        
        
        
        createSections()
        
        
        self.layoutViews()
        
    }
    
    func createSections(){
        sections = []
        switch self.currentSortMode {
        case "CREW":
            
            
            // build sections based on first letter(json is already sorted alphabetically)
            print("build sections")
        
            var index = 0;
            var titleArray:[String] = [" "]
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.crew < $1.crew }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.crew < $1.crew })[i].crew!
                //let firstCharacter = String(stringToTest[stringToTest.startIndex])
                if(i == 0){
                    titleArray.append(stringToTest)
                }
                if !titleArray.contains(stringToTest) {
                    //print("new")
                    let title = titleArray[titleArray.count - 1]
                    titleArray.append(stringToTest)
                    let newSection = (index: index, length: i - index, title: title)
                    sections.append(newSection)
                    index = i;
                }
                if(i == self.equipmentArray.sorted(by: { $0.crew < $1.crew }).count - 1){
                    let title = titleArray[titleArray.count - 1]
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
            
            break
        case "TYPE":
            
            print("build sections")
            var index = 0;
            var titleArray:[String] = [" "]
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.type < $1.type }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.type < $1.type })[i].type!
                //let firstCharacter = String(stringToTest[stringToTest.startIndex])
                if(i == 0){
                    titleArray.append(stringToTest)
                }
                if !titleArray.contains(stringToTest) {
                    //print("new")
                    let title = titleArray[titleArray.count - 1]
                    titleArray.append(stringToTest)
                    let newSection = (index: index, length: i - index, title: title)
                    sections.append(newSection)
                    index = i;
                }
                if(i == self.equipmentArray.sorted(by: { $0.type < $1.type }).count - 1){
                    let title = titleArray[titleArray.count - 1]
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
            
            break
        case "STATUS":
            
            print("build sections")
            var index = 0;
            var titleArray:[String] = [" "]
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.statusName < $1.statusName }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.statusName < $1.statusName })[i].statusName!
                //let firstCharacter = String(stringToTest[stringToTest.startIndex])
                if(i == 0){
                    titleArray.append(stringToTest)
                }
                if !titleArray.contains(stringToTest) {
                    //print("new")
                    let title = titleArray[titleArray.count - 1]
                    titleArray.append(stringToTest)
                    let newSection = (index: index, length: i - index, title: title)
                    sections.append(newSection)
                    index = i;
                }
                if(i == self.equipmentArray.sorted(by: { $0.statusName < $1.statusName }).count - 1){
                    let title = titleArray[titleArray.count - 1]
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
            
            
            break
        default:
            //CREW
            
            print("build sections")
            var index = 0;
            var titleArray:[String] = [" "]
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.crew < $1.crew }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.crew < $1.crew })[i].crew!
                //let firstCharacter = String(stringToTest[stringToTest.startIndex])
                if(i == 0){
                    titleArray.append(stringToTest)
                }
                if !titleArray.contains(stringToTest) {
                    //print("new")
                    let title = titleArray[titleArray.count - 1]
                    titleArray.append(stringToTest)
                    let newSection = (index: index, length: i - index, title: title)
                    sections.append(newSection)
                    index = i;
                }
                if(i == self.equipmentArray.sorted(by: { $0.crew < $1.crew }).count - 1){
                    let title = titleArray[titleArray.count - 1]
                    let newSection = (index: index, length: i - index + 1, title: title)
                    self.sections.append(newSection)
                }
            }
            
            
            break
        }
        
        print("sections \(sections)")
    }
    
    
    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Equipment"
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
        
        
        let items = ["Crew","Type","Status"]
        let customSC = SegmentedControl(items: items)
        
        
        
        customSC.addTarget(self, action: #selector(self.changeSort(sender:)), for: .valueChanged)
        self.view.addSubview(customSC)
        
        self.equipmentTableView.delegate  =  self
        self.equipmentTableView.dataSource = self
        equipmentTableView.rowHeight = 60.0
        self.equipmentTableView.register(EquipmentTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.equipmentTableView)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        
        //auto layout group
        let viewsDictionary = [
            "view1":customSC,
            "view2":self.equipmentTableView,
            "view3":self.countView
            ] as [String : Any]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[view1(30)][view2][view3(30)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        
    }
    
    
    /////////////// Search Methods   ///////////////////////
    
    @objc func changeSort(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            //equipmentArray.sorted(by: { $0.crew > $1.crew })
            currentSortMode = "CREW"
            break
        case 1:
            //equipmentArray.sorted(by: { $0.type > $1.type })
            currentSortMode = "TYPE"
            break
        default:
            //equipmentArray.sorted(by: { $0.status > $1.status })
            currentSortMode = "STATUS"
            break
        }
        createSections()
        equipmentTableView.reloadData()
        equipmentTableView.reloadSectionIndexTitles()
       // filterSearchResults()
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(String(describing: searchController.searchBar.text))")
        filterSearchResults()
    }
    
    func filterSearchResults(){
        self.equipmentSearchResults = self.equipmentArray.filter({( aEquipment: Equipment) -> Bool in
            return (aEquipment.name!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
        self.equipmentTableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.equipmentTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //print("searchBarCancelButtonClicked")
        shouldShowSearchResults = false
        self.equipmentTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print("searchBarSearchButtonClicked")
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.equipmentTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
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
        ////print("titleForHeaderInSection")
        if shouldShowSearchResults{
            return nil
        }else{
            
            return "    " + sections[section].title //hack way of indenting section text
            
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
        print("numberOfRowsInSection")
        if shouldShowSearchResults{
            self.countLbl.text = "\(self.equipmentSearchResults.count) Pieces of Equipment"
            return self.equipmentSearchResults.count
            //print("count = \(self.equipmentSearchResults.count)")
        } else {
            self.countLbl.text = "\(self.equipmentArray.count) Pieces of Equipment"
            // return self.equipmentArray.count
            //print("count = \(self.equipmentArray.count)")
            return sections[section].length
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = equipmentTableView.dequeueReusableCell(withIdentifier: "cell") as! EquipmentTableViewCell
        cell.layoutViews()
        // cell.textLabel?.text = array[sections[indexPath.section].index + indexPath.row]
        
        //print("self.itemsArray!.count = \(self.itemsArray.count)")
        
        if shouldShowSearchResults{
            print("cell should show search results")
            
            switch self.currentSortMode {
            case "CREW":
                //equipmentArray.sorted(by: { $0.crew > $1.crew })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.crew < $1.crew })[indexPath.row]
                break
            case "TYPE":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.type < $1.type })[indexPath.row]
                break
            case "STATUS":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.statusName < $1.statusName })[indexPath.row]
                break
            default:
                //CREW
                //equipmentArray.sorted(by: { $0.status > $1.status })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.crew < $1.crew })[indexPath.row]
                
                break
            }
            
            
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            // if(currentSearchMode == .name){
            
            //text highlighting
            let baseString:NSString = cell.equipment.name as NSString
            let highlightedText = NSMutableAttributedString(string: cell.equipment.name!)
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            
            if let regexError = error {
                //print("Oh no! \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            cell.nameLbl.attributedText = highlightedText
            //cell.addressLbl.text = cell.item.address
            
            
            
        } else {
            print("cell should not show search results")
            print("cell name = \(self.equipmentArray[indexPath.row].name)")
            //cell.equipment = self.equipmentArray[indexPath.row]
            
            switch self.currentSortMode {
            case "CREW":
                //equipmentArray.sorted(by: { $0.crew > $1.crew })
                //cell.textLabel?.text = array[sections[indexPath.section].index + indexPath.row]
                //cell.id = self.ids[sections[indexPath.section].index + indexPath.row]
                
                
                //cell.equipment = self.equipmentArray.sorted(by: { $0.crew > $1.crew })[indexPath.row]
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.crew < $1.crew })[sections[indexPath.section].index + indexPath.row]
                
                
                break
            case "TYPE":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                //cell.equipment = self.equipmentArray.sorted(by: { $0.type > $1.type })[indexPath.row]
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.type < $1.type })[sections[indexPath.section].index + indexPath.row]
                
                break
            case "STATUS":
                //equipmentArray.sorted(by: { $0.type > $1.type })
               // cell.equipment = self.equipmentArray.sorted(by: { $0.status > $1.status })[indexPath.row]
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.statusName < $1.statusName })[sections[indexPath.section].index + indexPath.row]
                break
            default:
                //CREW
                //equipmentArray.sorted(by: { $0.status > $1.status })
                //cell.equipment = self.equipmentArray.sorted(by: { $0.crew > $1.crew })[indexPath.row]
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.crew < $1.crew })[sections[indexPath.section].index + indexPath.row]
                
                break
            }
            
            
            
            cell.nameLbl.text = cell.equipment.name!
        }
        
        
        cell.activityView.startAnimating()
        cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.equipment.pic!)
        cell.typeLbl.text = "Type: \(cell.equipment.type!)"
        cell.crewLbl.text = "Crew: \(cell.equipment.crew!)"
        cell.setStatus(status: cell.equipment.status)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentTableViewCell;
        
        //if(currentCell.item != nil && currentCell.item.ID != ""){
        
        //searchController.isActive = false
        let equipmentViewController = EquipmentViewController(_equipment: currentCell.equipment)
        navigationController?.pushViewController(equipmentViewController, animated: false )
        equipmentViewController.equipmentDelegate = self
        equipmentViewController.equipmentIndex = indexPath?.row
        
        tableView.deselectRow(at: indexPath!, animated: true)
        //}
        
    }
    
    
    
    func reDrawEquipmentList(_index:Int, _status:String){
        //print("reDraw Schedule")
        if(shouldShowSearchResults == true){
            equipmentSearchResults[_index].status = _status
            
        }else{
            equipmentArray[_index].status = _status
        }
        self.equipmentTableView.reloadData()
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

