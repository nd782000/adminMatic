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


protocol EquipmentListDelegate{
    func reDrawEquipmentList()
    func disableSearch()
}



class EquipmentListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, EquipmentListDelegate{
    var indicator: SDevIndicator!
    var totalEquipment:Int!
    
    var searchController:UISearchController!
    var customSC:SegmentedControl!
    var currentSortMode = "CREW"
    
    var equipmentTableView:TableView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    var statusNames :[String] = ["Online", "Needs Repair", "Broken", "Winterized"]
    
    var equipment: JSON!
    var equipmentArray:[Equipment] = []
    var equipmentSearchResults:[Equipment] = []
    var shouldShowSearchResults:Bool = false
    
    var refresher:UIRefreshControl!
    var refreshFromTable:Bool = false
    
    var addEquipmentBtn:Button = Button(titleText: "Add Equipment")
    var editFieldsBtn:Button = Button(titleText: "Edit Fields")
    
    
    
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
        
        equipmentTableView = TableView()
        equipmentArray = []
        
        if(refreshFromTable == true){
            self.refresher.endRefreshing()
        }
        refreshFromTable = false
        
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/equipmentList.php",method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("equipment response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    //print("JSON: \(json)")
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
            let equipment = Equipment(_ID: self.equipment["equipment"][i]["equipID"].stringValue, _name: self.equipment["equipment"][i]["eName"].stringValue, _make: self.equipment["equipment"][i]["make"].stringValue, _model: self.equipment["equipment"][i]["model"].stringValue, _serial: self.equipment["equipment"][i]["serial"].stringValue, _crew: self.equipment["equipment"][i]["crew"].stringValue, _crewName: self.equipment["equipment"][i]["crewName"].stringValue, _status: self.equipment["equipment"][i]["status"].stringValue, _type: self.equipment["equipment"][i]["type"].stringValue, _typeName: self.equipment["equipment"][i]["typeName"].stringValue, _fuelType: self.equipment["equipment"][i]["fuelType"].stringValue, _fuelTypeName: self.equipment["equipment"][i]["fuelName"].stringValue, _engineType: self.equipment["equipment"][i]["engineType"].stringValue, _engineTypeName: self.equipment["equipment"][i]["engineName"].stringValue, _mileage: self.equipment["equipment"][i]["mileage"].stringValue, _dealer: self.equipment["equipment"][i]["vendorID"].stringValue, _dealerName: self.equipment["equipment"][i]["vendorName"].stringValue, _purchaseDate: self.equipment["equipment"][i]["purchaseDate"].stringValue, _description: self.equipment["equipment"][i]["description"].stringValue)
            
            
            if self.equipment["equipment"][i]["pic"].stringValue == "0"{
                let image:Image = Image(_ID: "0", _noPicPath: self.equipment["equipment"][i]["picInfo"].stringValue)
                equipment.image = image
            }else{
                let image:Image = Image(_ID: self.equipment["equipment"][i]["pic"].stringValue)
                equipment.image = image
                
                print("pic path = \(equipment.image.thumbPath)")
            }
            
            
            self.equipmentArray.append(equipment)
            
        }
       
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
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.crewName < $1.crewName }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.crewName < $1.crewName })[i].crewName!
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
                if(i == self.equipmentArray.sorted(by: { $0.crewName < $1.crewName }).count - 1){
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
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.typeName < $1.typeName }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.typeName < $1.typeName })[i].typeName!
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
                if(i == self.equipmentArray.sorted(by: { $0.typeName < $1.typeName }).count - 1){
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
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.status > $1.status }).count {
                let stringToTest = self.statusNames[Int(self.equipmentArray.sorted(by: { $0.status > $1.status })[i].status!)!]
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
                if(i == self.equipmentArray.sorted(by: { $0.status > $1.status }).count - 1){
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
            for i in 0 ..< self.equipmentArray.sorted(by: { $0.crewName < $1.crewName }).count {
                let stringToTest = self.equipmentArray.sorted(by: { $0.crewName < $1.crewName })[i].crewName!
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
                if(i == self.equipmentArray.sorted(by: { $0.crewName < $1.crewName }).count - 1){
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
         customSC = SegmentedControl(items: items)
        
        
        
        customSC.addTarget(self, action: #selector(self.changeSort(sender:)), for: .valueChanged)
        
        switch currentSortMode {
        case "CREW":
            //equipmentArray.sorted(by: { $0.crewName > $1.crewName })
            customSC.selectedSegmentIndex = 0
            break
        case "TYPE":
            //equipmentArray.sorted(by: { $0.type > $1.type })
            customSC.selectedSegmentIndex = 1
            break
        case "STATUS":
            //equipmentArray.sorted(by: { $0.type > $1.type })
            customSC.selectedSegmentIndex = 2
            break
        default:
            //equipmentArray.sorted(by: { $0.status > $1.status })
            customSC.selectedSegmentIndex = 0
            break
        }
        
        
        self.view.addSubview(customSC)
        
        
        
        self.equipmentTableView.delegate  =  self
        self.equipmentTableView.dataSource = self
        equipmentTableView.rowHeight = 60.0
        self.equipmentTableView.register(EquipmentTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.equipmentTableView)
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        equipmentTableView.addSubview(refresher)
        
        refresher.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged)
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        self.addEquipmentBtn.addTarget(self, action: #selector(EquipmentListViewController.addEquipment), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.addEquipmentBtn)
        
        self.editFieldsBtn.addTarget(self, action: #selector(EquipmentListViewController.editFields), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.editFieldsBtn)
        
        
        
        
        //auto layout group
        let viewsDictionary = [
            "view1":customSC,
            "view2":self.equipmentTableView,
            "view3":self.countView,
            "view4":self.addEquipmentBtn,
            "view5":self.editFieldsBtn
            ] as [String : Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth, "fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4(halfWidth)]-5-[view5(halfWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[view1(40)][view2][view3(30)][view4(40)]-10-|", options:[], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view5(40)]-10-|", options:[], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        
    }
    
    
    @objc func refresh(_ sender: AnyObject){
        //print("refresh")
        refreshFromTable = true
        getEquipmentList()
    }
    
    
    
    
    /////////////// Search Methods   ///////////////////////
    
    @objc func changeSort(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentSortMode = "CREW"
            break
        case 1:
            currentSortMode = "TYPE"
            break
        default:
            currentSortMode = "STATUS"
            break
        }
        createSections()
        equipmentTableView.reloadData()
        equipmentTableView.reloadSectionIndexTitles()
        
        scrollToTop()
       
    }
    
    func scrollToTop() {
        if (self.equipmentTableView.numberOfSections > 0 ) {
            let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
            self.equipmentTableView.scrollToRow(at: top as IndexPath, at: .top, animated: true);
        }
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(String(describing: searchController.searchBar.text))")
        filterSearchResults()
    }
    
    func filterSearchResults(){
        self.equipmentSearchResults = self.equipmentArray.filter({( aEquipment: Equipment) -> Bool in
            
           
            
            
            //return type name or name
            return (aEquipment.name!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil  || aEquipment.typeName!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)

        })
        self.equipmentTableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        searchBar.setShowsCancelButton(true, animated: true)
        customSC.isEnabled = false
        self.equipmentTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        shouldShowSearchResults = false
        searchBar.setShowsCancelButton(false, animated: true)
        customSC.isEnabled = true
        self.equipmentTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print("searchBarSearchButtonClicked")
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            searchBar.setShowsCancelButton(true, animated: true)
            customSC.isEnabled = false
            self.equipmentTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    /*
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
        shouldShowSearchResults = false
        searchBar.setShowsCancelButton(false, animated: true)
        customSC.isEnabled = true
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
        
        
        
        if shouldShowSearchResults{
            print("cell should show search results")
            
            switch self.currentSortMode {
            case "CREW":
                //equipmentArray.sorted(by: { $0.crewName > $1.crewName })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.crewName < $1.crewName })[indexPath.row]
                break
            case "TYPE":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.typeName < $1.typeName })[indexPath.row]
                break
            case "STATUS":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.status > $1.status })[indexPath.row]
                break
            default:
                //CREW
                //equipmentArray.sorted(by: { $0.status > $1.status })
                cell.equipment = self.equipmentSearchResults.sorted(by: { $0.crewName < $1.crewName })[indexPath.row]
                
                break
            }
            
            
            let searchString = self.searchController.searchBar.text!.lowercased()
            
           
            
            let baseString1:NSString = cell.equipment.typeName as NSString
            let highlightedText1 = NSMutableAttributedString(string: cell.equipment.typeName!)
            var error1: NSError?
            let regex1: NSRegularExpression?
            do {
                regex1 = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1a as NSError {
                error1 = error1a
                regex1 = nil
            }
            if let regexError1 = error1 {
                print("Oh no! \(regexError1)")
            } else {
                for match in (regex1?.matches(in: baseString1 as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString1.length)))! as [NSTextCheckingResult] {
                    highlightedText1.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            //cell.nameLbl.attributedText = highlightedText
            cell.typeValueLbl.attributedText = highlightedText1
            
            
            
            let baseString2:NSString = cell.equipment.name as NSString
            let highlightedText2 = NSMutableAttributedString(string: cell.equipment.name!)
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
                    highlightedText2.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            //cell.nameLbl.attributedText = highlightedText
            cell.nameLbl.attributedText = highlightedText2
            
            
            
            
            
        } else {
            print("cell should not show search results")
            print("cell name = \(self.equipmentArray[indexPath.row].name)")
            
            switch self.currentSortMode {
            case "CREW":
                
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.crewName < $1.crewName })[sections[indexPath.section].index + indexPath.row]
                
                
                break
            case "TYPE":
                
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.typeName < $1.typeName })[sections[indexPath.section].index + indexPath.row]
                
                break
            case "STATUS":
                
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.status > $1.status })[sections[indexPath.section].index + indexPath.row]
                break
            default:
                //CREW
                
                
                cell.equipment = self.equipmentArray.sorted(by: { $0.crewName < $1.crewName })[sections[indexPath.section].index + indexPath.row]
                
                break
            }
            
            
            
            
            cell.typeValueLbl.text = cell.equipment.typeName!
        }
        
        cell.activityView.startAnimating()
        
       // cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.equipment.pic!)
        cell.setImageUrl(_url: cell.equipment.image.thumbPath!)
        
        
        cell.nameLbl.text = cell.equipment.name!
        cell.crewLbl.text = "Crew: \(cell.equipment.crewName!)"
        cell.statusIcon.image = nil
        cell.setStatus(status: cell.equipment.status)
        
        //print("cell status name = \(cell.equipment.statusName)")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentTableViewCell;
        
        
        let equipmentViewController = EquipmentViewController(_equipment: currentCell.equipment)
        navigationController?.pushViewController(equipmentViewController, animated: false )
        equipmentViewController.equipmentDelegate = self
        equipmentViewController.equipmentIndex = indexPath?.row
        
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let ID:String!
        
        
        if shouldShowSearchResults{
           // ID = self.equipmentSearchResults[indexPath.row].ID
            
            switch self.currentSortMode {
            case "CREW":
                //equipmentArray.sorted(by: { $0.crewName > $1.crewName })
                ID = self.equipmentSearchResults.sorted(by: { $0.crewName < $1.crewName })[indexPath.row].ID
                break
            case "TYPE":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                ID = self.equipmentSearchResults.sorted(by: { $0.typeName < $1.typeName })[indexPath.row].ID
                break
            case "STATUS":
                //equipmentArray.sorted(by: { $0.type > $1.type })
                ID = self.equipmentSearchResults.sorted(by: { $0.status > $1.status })[indexPath.row].ID
                break
            default:
                //CREW
                //equipmentArray.sorted(by: { $0.status > $1.status })
                ID = self.equipmentSearchResults.sorted(by: { $0.crewName < $1.crewName })[indexPath.row].ID
                
                break
            }
            
            
        }else{
            //ID = self.equipmentArray[indexPath.row].ID
            switch self.currentSortMode {
            case "CREW":
                ID = self.equipmentArray.sorted(by: { $0.crewName < $1.crewName })[sections[indexPath.section].index + indexPath.row].ID
                break
            case "TYPE":
                ID = self.equipmentArray.sorted(by: { $0.typeName < $1.typeName })[sections[indexPath.section].index + indexPath.row].ID
                break
            case "STATUS":
                ID = self.equipmentArray.sorted(by: { $0.status > $1.status })[sections[indexPath.section].index + indexPath.row].ID
                break
            default:
                //CREW
                ID = self.equipmentArray.sorted(by: { $0.crewName < $1.crewName })[sections[indexPath.section].index + indexPath.row].ID
                break
            }
        }
        
        print("row = \(indexPath.row)")
        print("ID = \(ID)")
        
        //indexPath
        let deActivate = UITableViewRowAction(style: .normal, title: "deactivate") { action, index in
            //print("none button tapped")
            //need user level greater then 1 to access this
            
            self.deActivateEquipment(_ID:ID!)
        }
        deActivate.backgroundColor = UIColor.red
        return [deActivate]
    }
    
    func deActivateEquipment(_ID:String){
        print("deActivate Equipment \(_ID)")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            let alertController = UIAlertController(title: "De-Activate Equipment?", message: "Are you sure you want to de-activate this equipment?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                let parameters:[String:String]
                parameters = ["equipmentID": _ID]
                print("parameters = \(parameters)")
                
                // Show Indicator
                self.indicator = SDevIndicator.generate(self.view)!
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/equipmentActive.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        //print("equipment response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        // self.shouldShowSearchResults = false
                        //self.searchController.isActive = false
                        self.getEquipmentList()
                        
                }
                
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    @objc func addEquipment(){
        print("Add Equipment")
        
        self.disableSearch()
        
        let newEquipmentViewController = NewEditEquipmentViewController()
        newEquipmentViewController.delegate = self
        navigationController?.pushViewController(newEquipmentViewController, animated: false )
    }
    
    @objc func editFields(){
        print("Edit Fields")
        let equipmentFieldsListViewController = EquipmentFieldsListViewController()
        equipmentFieldsListViewController.equipmentListDelegate = self
        navigationController?.pushViewController(equipmentFieldsListViewController, animated: false )
    }
    
    
    
    func disableSearch(){
        if(self.searchController != nil){
            self.searchController.isActive = false
            shouldShowSearchResults = false
            customSC.isEnabled = true
            equipmentTableView.reloadData()
        }
    }
    
    
    
    func reDrawEquipmentList(){
        print("reDraw Equipment List")
       
            
            getEquipmentList()
            
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

