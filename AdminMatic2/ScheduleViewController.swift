//
//  ScheduleViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/4/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
//import SwiftyJSON

 
// updates status icons without getting new db data
protocol ScheduleDelegate{
    func updateSchedule() //from edit/new view for new work orders made
    func reDrawSchedule(_index:Int, _status:String, _price: String, _cost: String, _priceRaw: String, _costRaw: String)
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _mowSort:String, _plowSort:String, _plowDepth:String)
    //func cancelSearch()//to resolve problem with imageSelection bug when search mode is active
}


class ScheduleViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ScheduleDelegate{

    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()

    
    //var customSC:SegmentedControl!
    
    var searchController:UISearchController!
    
    
    var refreshControl: UIRefreshControl!
    var refreshFromTable:Bool = false
    var scheduleTableView: TableView!
    var personalScheduleBtn:Button!
    var employeeImage:UIImageView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    
    var tableViewMode:String = "SCHEDULE"
    var employeeID : String!
    var allDates:String = "1"
    var startDate:String = ""
    var endDate:String = ""
    var startDateDB:String = ""
    var endDateDB:String = ""
    var mowSort:String = "0"
    var plowSort:String = "0"
    var plowDepth:String = "0"
    
    
    //var fullScheduleJSON:JSON!
    var fullScheduleArray:[WorkOrder2] = []
    //var personalScheduleJSON:JSON!
    var personalScheduleArray:[WorkOrder2] = []
    
    //var fullHistoryJSON: JSON!
   // var fullHistoryArray:[WorkOrder2] = []
    //var personalHistoryJSON: JSON!
   // var personalHistoryArray:[WorkOrder2] = []
    
    var workOrdersSearchResults:[WorkOrder2] = []
    var shouldShowSearchResults:Bool = false
    var personalMode:Bool = true
    
    var layoutViewsCalled:Bool = false
    var fullScheduleLoaded:Bool = false
    var personalScheduleLoaded:Bool = false
    //var fullHistoryLoaded:Bool = false
   // var personalHistoryLoaded:Bool = false
    
    
    var cellClick:Bool = false
    
    
    var addWorkOrderBtn:Button = Button(titleText: "Add")

    
    var scheduleSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    var methodStart:Date!
    var methodFinish:Date!
    
    init(_employeeID:String){
        super.init(nibName:nil,bundle:nil)
        self.employeeID = _employeeID
        title = "Work Orders"
        //print("empID = \(String(describing: self.employeeID))")
        self.view.backgroundColor = layoutVars.backgroundColor
        self.personalScheduleBtn = Button()
       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        //print("self.tableViewMode = \(self.tableViewMode)")
         //print("personalMode = \(self.personalMode)")
        
        cellClick = false
        
        if(shouldShowSearchResults == true){
            scheduleTableView.reloadData()
        }else{
            if(self.personalMode == false){
                print("------FULL-------")
                
               // if(self.tableViewMode == "SCHEDULE"){
                    if(fullScheduleLoaded != true){
                        getSchedule(_empID: "")
                    }else{
                        scheduleTableView.reloadData()
                    }
               // }else{
                   // if(fullHistoryLoaded != true){
                        //getHistory(_empID: "")
                    //}else{
                        scheduleTableView.reloadData()
                   // }
               // }
                
            }else{
                print("------PERSONAL-------")
                
               // if(self.tableViewMode == "SCHEDULE"){
                    
                    if(personalScheduleLoaded != true){
                        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
                    }else{
                        scheduleTableView.reloadData()
                    }
               // }else{
                    //if(personalHistoryLoaded != true){
                       // getHistory(_empID: (appDelegate.loggedInEmployee?.ID)!)
                    //}else{
                      //  scheduleTableView.reloadData()
                   // }
                    
                //}
            }
            
        }
        
    }
    
    
    
        
    
    
    
    
    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
        layoutViewsCalled = true
        
        print("layout views")
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Schedule"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = layoutVars.buttonBackground
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
       
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        print("calling tableView")
        self.scheduleTableView =  TableView()
        self.scheduleTableView.delegate  =  self
        self.scheduleTableView.dataSource  =  self
        self.scheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        self.scheduleTableView.rowHeight = 50.0
        safeContainer.addSubview(self.scheduleTableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        scheduleTableView.addSubview(refreshControl)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        //self.countView.layer.borderColor = layoutVars.borderColor
        //self.countView.layer.borderWidth = 1.0
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        
        self.addWorkOrderBtn.addTarget(self, action: #selector(ScheduleViewController.addWorkOrder), for: UIControl.Event.touchUpInside)
       // self.addWorkOrderBtn.layer.borderColor = UIColor.white.cgColor
       // self.addWorkOrderBtn.layer.borderWidth = 1.0
        safeContainer.addSubview(self.addWorkOrderBtn)
        
       // self.personalScheduleBtn.layer.borderColor = UIColor.white.cgColor
        //self.personalScheduleBtn.layer.borderWidth = 1.0
        safeContainer.addSubview(self.personalScheduleBtn)
        
        
        
        self.scheduleSettingsBtn.addTarget(self, action: #selector(ScheduleViewController.scheduleSettings), for: UIControl.Event.touchUpInside)
        //self.scheduleSettingsBtn.layer.borderColor = UIColor.white.cgColor
        //self.scheduleSettingsBtn.layer.borderWidth = 1.0
       // self.scheduleSettingsBtn.frame = CGRect(x:self.view.frame.width - 40, y: self.view.frame.height - 40, width: 40, height: 40)
        //self.scheduleSettingsBtn.translatesAutoresizingMaskIntoConstraints = true
       // self.imageSettingsBtn.layer.borderColor = UIColor.white.cgColor
       // self.imageSettingsBtn.layer.borderWidth = 1.0
        safeContainer.addSubview(self.scheduleSettingsBtn)
        
        self.scheduleSettingsBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        
        settingsIcon.image = settingsImg
        self.scheduleSettingsBtn.addSubview(settingsIcon)
        
        
        
        
       refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        
        
        setScheduleButton()
    
       
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height - self.layoutVars.navAndStatusBarHeight - 80,"navHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        //auto layout group
        
        //"segmentedSwitch":customSC,
        
        let viewsDictionary : [String:Any] = [
            
            "table":self.scheduleTableView,
            "countView":self.countView,
            "addBtn":self.addWorkOrderBtn,
            "switchBtn":self.personalScheduleBtn,
            "settingsBtn":self.scheduleSettingsBtn
        ] as [String : Any]
        
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addBtn(100)]-[switchBtn]-[settingsBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        //safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[view1(40)][view2][countView(30)][view3(40)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table][countView(30)][addBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table][countView(30)][switchBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table][countView(30)][settingsBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
         
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    

    func getSchedule(_empID:String) {
        print("getSchedule empID:\(_empID)")
        
        
        methodStart = Date()
        
        if(refreshFromTable == true){
            self.refreshControl.endRefreshing()
        }
        refreshFromTable = false
        
        
        
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        
        var sort:String = "0"
        
        if(mowSort == "1"){
            sort = "1"
            plowDepth = "0"
        }else if(plowSort == "1"){
            sort = "2"
        }
        
        
        print("call alamofire")
       
            
        
        
        Alamofire.request(API.Router.workOrderList(["employeeID":_empID as AnyObject,"custID":"" as AnyObject,"startDate":self.startDateDB as AnyObject,"endDate":self.endDateDB as AnyObject,"sort":sort as AnyObject,"plowDepth":self.plowDepth as AnyObject,"active":"1" as AnyObject, "cb":timeStamp as AnyObject])).responseString() {
            response in
            
            print("response string")
            
            print(response.request ?? "")
            print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            print(response.result)
                
            }
            
            .responseJSON() {
            response in
            
            print("response")
            
            print(response.request ?? "")  // original URL request
            // //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            if(_empID == ""){
                self.fullScheduleArray = []
                
                self.fullScheduleLoaded = true
                
                
                
                do{
                    //created the json decoder
                    let json = response.data
                    //print("json = \(json)")
                    
                    let decoder = JSONDecoder()
                    let parsedData = try decoder.decode(WorkOrderArray.self, from: json!)
                    
                    print("parsedData = \(parsedData)")
                    
                    let workOrders = parsedData
                   
                    let workOrderCount = workOrders.workOrders.count
                    print("workOrder count = \(workOrderCount)")
                    
                    for i in 0 ..< workOrderCount {
                        //create an object
                        print("create a workOrder object \(i)")
                        
                        workOrders.workOrders[i].customerTitleAndID = "\(workOrders.workOrders[i].custName!) \(workOrders.workOrders[i].title) #\(workOrders.workOrders[i].ID)"
                        self.fullScheduleArray.append(workOrders.workOrders[i])
                    }
                    
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                    
                }catch let err{
                    print(err)
                }

                
                
           
                
            }else{
                self.personalScheduleArray = []
                self.personalScheduleLoaded = true
                
                
                do{
                    //created the json decoder
                    let json = response.data
                    //print("json = \(json)")
                    
                    let decoder = JSONDecoder()
                    let parsedData = try decoder.decode(WorkOrderArray.self, from: json!)
                    
                    print("parsedData = \(parsedData)")
                    
                    let workOrders = parsedData
                    
                    let workOrderCount = workOrders.workOrders.count
                    print("workOrder count = \(workOrderCount)")
                    
                    for i in 0 ..< workOrderCount {
                        //create an object
                        print("create a workOrder object \(i)")
                        workOrders.workOrders[i].customerTitleAndID = "\(workOrders.workOrders[i].custName!) \(workOrders.workOrders[i].title) #\(workOrders.workOrders[i].ID)"
                        self.personalScheduleArray.append(workOrders.workOrders[i])
                    }
                    
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                    
                    
                    //check if personal schedule is empty, switch to full and re get data
                    
                    if self.personalScheduleArray.count == 0{
                        print("personal schedule is empty")
                        
                        let alertController = UIAlertController(title: "No Work Orders", message: "There are no work orders assigned to you.  Would you like to load the full schedule?", preferredStyle: UIAlertController.Style.alert)
                        
                        let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            print("YES")
                            self.filterUsersSchedule()
                        }
                        
                        let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel) {
                            (result : UIAlertAction) -> Void in
                            print("NO")
                        }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                        
                    }
                    
                }catch let err{
                    print(err)
                }

                
                
               
            }
            
        }
        
    }
    

    
    @objc func addWorkOrder(){
        print("Add Work Order")
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        
        let newEditWoViewController = NewEditWoViewController()
        newEditWoViewController.delegate = self
        navigationController?.pushViewController(newEditWoViewController, animated: false )
        
        
        
    }
    
    
    @objc func scheduleSettings(){
        print("schedule settings")
        
        let scheduleSettingsViewController = ScheduleSettingsViewController(_allDates:self.allDates, _startDate: self.startDate, _endDate: self.endDate,_startDateDB: self.startDateDB, _endDateDB: self.endDateDB, _mowSort: self.mowSort, _plowSort: self.plowSort, _plowDepth: self.plowDepth)
        scheduleSettingsViewController.delegate = self
        navigationController?.pushViewController(scheduleSettingsViewController, animated: false )
        
        
        
    }
    
    
    
   
    
    
    
    
    
    /////////////  Table View Methods  /////////////////////////////////////////////
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        
        print("numberOfRowsInSection")
        if (shouldShowSearchResults == true) {
            count = self.workOrdersSearchResults.count
            print("search count = \(self.workOrdersSearchResults.count)")
            self.countLbl.text = "\(count!) Work Order(s) Found"
            return count
            
        } else {
            
            
                if(personalMode == false){
                    print("------FULL-------")
                    count = self.fullScheduleArray.count
                    print("full schedule count = \(String(describing: count))")
                }else{
                    count = self.personalScheduleArray.count
                    print("personal schedule count = \(String(describing: count))")
                }
                self.countLbl.text = "\(count!) Scheduled Work Order(s)"
            
           
                
           
            
            
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell:ScheduleTableViewCell = scheduleTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
        
        
            
            if (shouldShowSearchResults == true){
                //print("make cell for schedule search mode row: \(indexPath.row)")
                print("cell 1")
                cell.workOrder = self.workOrdersSearchResults[indexPath.row]
                if(plowSort == "1"){
                    cell.layoutViews(_scheduleMode: "PLOWING")
                }else{
                    cell.layoutViews(_scheduleMode: "SCHEDULE")
                }
                
                cell.setStatus(status: cell.workOrder.status)
                cell.setProfitBar(_price:cell.workOrder.totalPriceRaw, _cost:cell.workOrder.totalCostRaw)
                
                let searchString = self.searchController.searchBar.text!.lowercased()
                
                let baseString:NSString = cell.workOrder.customerTitleAndID as NSString
                let highlightedText = NSMutableAttributedString(string: cell.workOrder.customerTitleAndID)
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
                cell.customerLbl.attributedText = highlightedText
                
                
                cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge!) //chargeTypeName
                cell.priceLbl.text = cell.workOrder.totalPrice
                
                
                cell.setProfitBar(_price:cell.workOrder.totalPriceRaw, _cost:cell.workOrder.totalCostRaw)
                
                
                
                
            } else {
                
                print("cell non search")
                
                
                //print("make cell for schedule reg mode row: \(indexPath.row)")
                if(personalMode == false){
                    print("------FULL-------")
                    print("array count \(self.fullScheduleArray.count)")
                    
                    cell.workOrder = self.fullScheduleArray[indexPath.row]
                }else{
                    cell.workOrder = self.personalScheduleArray[indexPath.row]
                }
                if(plowSort == "1"){
                    print("cell 2a")
                    cell.layoutViews(_scheduleMode: "PLOWING")
                }else{
                    cell.layoutViews(_scheduleMode: "SCHEDULE")
                    cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge!) //chargeTypeName
                    
                    cell.priceLbl.text = cell.workOrder.totalPrice
                }
                cell.customerLbl.text = cell.workOrder.customerTitleAndID
                cell.setStatus(status: cell.workOrder.status)
                cell.setProfitBar(_price:cell.workOrder.totalPriceRaw, _cost:cell.workOrder.totalCostRaw)
                
                
                
                
                
            }
            
            
            
        
        print("cell 3")
        if(plowSort == "1"){
            cell.depthLbl.text = "\(String(describing: cell.workOrder.plowDepth))\""
            cell.priorityLbl.text = "Priority: \(String(describing: cell.workOrder.plowPriority))"
            if(cell.workOrder.plowMonitoring == "1"){
                cell.monitoringLbl.text = "Monitor: Y"
            }else{
                cell.monitoringLbl.text = "Monitor: N"
            }
            
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        
        cellClick = true
    
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! ScheduleTableViewCell;
        
        //print("currentCell.workOrder.ID #\(currentCell.workOrder.ID)!")
        //print("currentCell.workOrder.customer: \(currentCell.workOrder.customer)!")
        
        let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.workOrder.ID)
        navigationController?.pushViewController(workOrderViewController, animated: false )
        
        workOrderViewController.scheduleDelegate = self
        workOrderViewController.scheduleIndex = indexPath?.row
        
        
    }

    
    
    
    ///////  search methods   ////////////////////
    
    func updateSearchResults(for searchController: UISearchController){
        
        if(cellClick == false){
            //print("updateSearchResultsForSearchController \(searchController.searchBar.text)")
            filterSearchResults()

        }
        
        
    }
    
    func filterSearchResults(){
        //print("filterSearchResults")
        switch self.tableViewMode{
        case "SCHEDULE":
            //print("Schedule filterSearchResults")
            
            if(self.personalMode == false){
                //print("------FULL-------")
                
                
                self.workOrdersSearchResults = self.fullScheduleArray.filter({( aWorkOrder: WorkOrder2) -> Bool in
                    return aWorkOrder.customerTitleAndID.lowercased().range(of:self.searchController.searchBar.text!.lowercased(), options:.regularExpression) != nil
                })
                
            }else{
                self.workOrdersSearchResults = self.personalScheduleArray.filter({( aWorkOrder: WorkOrder2) -> Bool in
                    return aWorkOrder.customerTitleAndID.lowercased().range(of:self.searchController.searchBar.text!.lowercased(), options:.regularExpression) != nil
                })
                
            }
        
        default:
            
            break
        }
        self.scheduleTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //print("searchBarCancelButtonClicked")
        shouldShowSearchResults = false
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print("searchBarSearchButtonClicked")
        if (shouldShowSearchResults == false) {
            shouldShowSearchResults = true
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
    }
    
    func willPresentSearchController(_ searchController: UISearchController){
    }
    
    
    func presentSearchController(searchController: UISearchController){
        
    }
    
    
    func togglePersonalMode(){
        
        
        //self.searchController.searchBar.text = ""
        //shouldShowSearchResults = false
        
        
        if(self.personalMode == false){
            self.personalMode = true
        }else{
            self.personalMode = false
        }
        
        setScheduleButton()
    }
    
    func setScheduleButton(){
        //print("setScheduleButton")
        //print("personalMode = \(personalMode)")
         //print("tableViewMode = \(tableViewMode)")
        
        
        self.personalScheduleBtn.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
        
        
            if(personalMode == true){
                self.personalScheduleBtn.setTitle("Full Schedule", for: UIControl.State.normal)
                
            }else{
            self.personalScheduleBtn.setTitle("\(appDelegate.loggedInEmployee!.fname!)'s Schedule", for: UIControl.State.normal)
               
            }
            self.personalScheduleBtn.addTarget(self, action: #selector(ScheduleViewController.filterUsersSchedule), for: UIControl.Event.touchUpInside)
    }
    
    
    @objc func refresh(_ sender: AnyObject){
        print("refresh")
        refreshFromTable = true
        if personalMode == true{
            getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)

        }else{
            getSchedule(_empID: "")

        }
       // getSchedule()
    }
    
    
    
    @objc func filterUsersSchedule(){
        //print("filterUsersSchedule")
        //print("personalMode \(personalMode)")
        //print("personalScheduleLoaded \(personalScheduleLoaded)")
        //print("personalHistoryLoaded \(personalHistoryLoaded)")
        //print("fullScheduleLoaded \(fullScheduleLoaded)")
        //print("fullHistoryLoaded \(fullHistoryLoaded)")
        
        
        //self.searchController.searchBar.text = ""
        //shouldShowSearchResults = false

        //cancelSearch()
        
        ///// PERSONAL  ///////////////
        if(personalMode == false){
            //show personal schedule
            print("personal Mode")
                    if(personalScheduleLoaded != true){
                        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
                       // getSchedule()
                    }else{
                        //print("reload Data schedule")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                    }
                    

            
            
            ///// FULL  ///////////////
        }else{
            //show full schedule
            print("full Mode")
            
            
                    if(fullScheduleLoaded != true){
                        getSchedule(_empID: "")
                    }else{
                        //print("reload Data schedule")
                        DispatchQueue.main.async{
                            
                            self.scheduleTableView.reloadData()
                            
                        }
                    }
                    

            
           
        }
        
        togglePersonalMode()
    }
    
    
    

     func displayEmployeeList(){
        appDelegate.menuChange(3)
    }
    
    func updateSchedule() {
        print("update schedule")
        self.getSchedule(_empID: (self.appDelegate.loggedInEmployee?.ID!)!)
    }
    
    
    func reDrawSchedule(_index:Int, _status:String, _price: String, _cost: String, _priceRaw: String, _costRaw: String){
        //print("reDraw Schedule")
        if(shouldShowSearchResults == true){
            workOrdersSearchResults[_index].status = _status
            workOrdersSearchResults[_index].totalPrice = _price
            workOrdersSearchResults[_index].totalCost = _cost
            workOrdersSearchResults[_index].totalPriceRaw = _priceRaw
            workOrdersSearchResults[_index].totalCostRaw = _costRaw
        }else{
                if(self.personalMode == true){
                    personalScheduleArray[_index].status = _status
                    personalScheduleArray[_index].totalPrice = _price
                    personalScheduleArray[_index].totalCost = _cost
                    personalScheduleArray[_index].totalPriceRaw = _priceRaw
                    personalScheduleArray[_index].totalCostRaw = _costRaw
                }else{
                    fullScheduleArray[_index].status = _status
                    fullScheduleArray[_index].totalPrice = _price
                    fullScheduleArray[_index].totalCost = _cost
                    fullScheduleArray[_index].totalPriceRaw = _priceRaw
                    fullScheduleArray[_index].totalCostRaw = _costRaw
                }

        }
        self.scheduleTableView.reloadData()
        
    }
    
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _mowSort:String, _plowSort:String, _plowDepth:String){
        print("update settings")
        //let editsMade:Bool = false
        self.allDates = _allDates
        self.startDate = _startDate
        self.endDate = _endDate
        self.startDateDB = _startDateDB
        self.endDateDB = _endDateDB
        self.mowSort = _mowSort
        self.plowSort = _plowSort
        self.plowDepth = _plowDepth
        
        
        /*
 var allDates:String = "1"
 var startDate:String = ""
 var endDate:String = ""
 var startDateDB:String = ""
 var endDateDB:String = ""
 var sort:String = "0"
 */
        
        if(self.allDates != "1" || self.startDate != "" || self.endDate != "" || self.mowSort != "0" || self.plowSort != "0" || self.plowDepth != "0"){
            print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }
        
        shouldShowSearchResults = false
         fullScheduleLoaded = false
         personalScheduleLoaded = false
        
        
        
        //decideWhichScheduleToPresent()
        
        //getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
        
    }
    
    func cancelSearch() {
        print("cancel search")
        if(self.searchController.isActive == true){
            self.searchController.isActive = false
        }
    }
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

