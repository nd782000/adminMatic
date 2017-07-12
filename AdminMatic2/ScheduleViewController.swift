//
//  ScheduleViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/4/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


// updates status icons without getting new db data
protocol ScheduleDelegate{
    func reDrawSchedule(_index:Int, _status:String, _price: String, _cost: String, _priceRaw: String, _costRaw: String)
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _sort:String)
}


class ScheduleViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ScheduleDelegate{

    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()

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
    var sort:String = "0"
    
    var fullScheduleJSON:JSON!
    var fullScheduleArray:[WorkOrder] = []
    var personalScheduleJSON:JSON!
    var personalScheduleArray:[WorkOrder] = []
    
    var fullHistoryJSON: JSON!
    var fullHistoryArray:[WorkOrder] = []
    var personalHistoryJSON: JSON!
    var personalHistoryArray:[WorkOrder] = []
    
    var workOrdersSearchResults:[WorkOrder] = []
    var shouldShowSearchResults:Bool = false
    var personalMode:Bool = true
    
    var layoutViewsCalled:Bool = false
    var fullScheduleLoaded:Bool = false
    var personalScheduleLoaded:Bool = false
    var fullHistoryLoaded:Bool = false
    var personalHistoryLoaded:Bool = false
    
    
    var cellClick:Bool = false
    
    
    var scheduleSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    
    
    init(_employeeID:String){
        super.init(nibName:nil,bundle:nil)
        self.employeeID = _employeeID
        title = "Schedule"
        print("empID = \(self.employeeID)")
        self.view.backgroundColor = layoutVars.backgroundColor
        self.personalScheduleBtn = Button()
       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //print("viewWillAppear")
        
        //print("self.tableViewMode = \(self.tableViewMode)")
         //print("personalMode = \(self.personalMode)")
        
        cellClick = false
        
        if(shouldShowSearchResults == true){
             scheduleTableView.reloadData()
        }else{
            if(self.personalMode == false){
                //print("------FULL-------")
                
                if(self.tableViewMode == "SCHEDULE"){
                    if(fullScheduleLoaded != true){
                        getSchedule(_empID: "")
                    }else{
                        scheduleTableView.reloadData()
                    }
                }else{
                    if(fullHistoryLoaded != true){
                        getHistory(_empID: "")
                    }else{
                        scheduleTableView.reloadData()
                    }
                }
                
            }else{
                //print("------PERSONAL-------")
                
                if(self.tableViewMode == "SCHEDULE"){
                    
                    if(personalScheduleLoaded != true){
                        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
                    }else{
                        scheduleTableView.reloadData()
                    }
                }else{
                    if(personalHistoryLoaded != true){
                        getHistory(_empID: (appDelegate.loggedInEmployee?.ID)!)
                    }else{
                        scheduleTableView.reloadData()
                    }
                    
                }
            }

        }
        
    }
    
    
    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
        layoutViewsCalled = true
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Schedule"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        let items = ["Active","History"]
        let customSC = SegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        
        
        
        
        customSC.addTarget(self, action: #selector(ScheduleViewController.changeSearchOptions(sender:)), for: .valueChanged)
        self.view.addSubview(customSC)
        
        
        
        self.scheduleTableView =  TableView()
        self.scheduleTableView.delegate  =  self
        self.scheduleTableView.dataSource  =  self
        self.scheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        self.scheduleTableView.rowHeight = 50.0
        self.view.addSubview(self.scheduleTableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        
        scheduleTableView.addSubview(refreshControl)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        //self.countView.layer.borderColor = layoutVars.borderColor
        //self.countView.layer.borderWidth = 1.0
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        
        
        
         self.view.addSubview(self.personalScheduleBtn)
        
        
        
        self.scheduleSettingsBtn.addTarget(self, action: #selector(ScheduleViewController.scheduleSettings), for: UIControlEvents.touchUpInside)
        
        self.scheduleSettingsBtn.frame = CGRect(x:self.view.frame.width - 40, y: self.view.frame.height - 40, width: 40, height: 40)
        self.scheduleSettingsBtn.translatesAutoresizingMaskIntoConstraints = true
       // self.imageSettingsBtn.layer.borderColor = UIColor.white.cgColor
       // self.imageSettingsBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.scheduleSettingsBtn)
        
        self.scheduleSettingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 6, y: 6, width: 28, height: 28)
        
        settingsIcon.image = settingsImg
        self.scheduleSettingsBtn.addSubview(settingsIcon)
        
        
        
        
       refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged)
        
        
        setScheduleButton()
    
       
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height - self.layoutVars.navAndStatusBarHeight - 80,"navHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        //auto layout group
        let viewsDictionary : [String:Any] = [
            "view1":customSC,
            "view2":self.scheduleTableView,
            "countView":self.countView,
            "view3":self.personalScheduleBtn,
            "view4":self.scheduleSettingsBtn
        ] as [String : Any]
        
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[view1(40)][view2][countView(30)][view3(40)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[view2][countView(30)][view3(40)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    

    func getSchedule(_empID:String) {
        //print("getSchedule empID:\(_empID)")
        
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
        
        
        Alamofire.request(API.Router.workOrderList(["employeeID":_empID as AnyObject,"custID":"" as AnyObject,"startDate":self.startDateDB as AnyObject,"endDate":self.endDateDB as AnyObject,"sort":self.sort as AnyObject,"active":"1" as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
            
            print(response.request ?? "")  // original URL request
            // //print(response.response) // URL response
            ////print(response.data)     // server data
            // //print(response.result)   // result of response serialization
            
            if(_empID == ""){
                self.fullScheduleLoaded = true
                if let json = response.result.value {
                     print("json = \(json)")
                    self.fullScheduleJSON = JSON(json)
                    self.parseSchedule(_empID: _empID)
                }
            }else{
                self.personalScheduleLoaded = true
                if let json = response.result.value {
                     print("json = \(json)")
                    self.personalScheduleJSON = JSON(json)
                    self.parseSchedule(_empID: _empID)
                    
                    
                }
            }
            
        }
        
    }
    

    func parseSchedule(_empID:String){
        //print("parseSchedule empID:\(_empID)")
        if(_empID == ""){
            let workOrderCount:Int = self.fullScheduleJSON["workOrder"].count
            ////print("workOrderCount: \(workOrderCount)")
            
            self.fullScheduleArray = []
            for i in 0 ..< workOrderCount {
                
                let workOrder = WorkOrder(_ID: self.fullScheduleJSON["workOrder"][i]["ID"].stringValue, _statusID: self.fullScheduleJSON["workOrder"][i]["statusID"].stringValue, _date: self.fullScheduleJSON["workOrder"][i]["date"].stringValue, _firstItem: self.fullScheduleJSON["workOrder"][i]["firstItem"].stringValue, _statusName: self.fullScheduleJSON["workOrder"][i]["statusName"].stringValue, _customer: self.fullScheduleJSON["workOrder"][i]["customer"].stringValue, _type: self.fullScheduleJSON["workOrder"][i]["type"].stringValue, _progress: self.fullScheduleJSON["workOrder"][i]["progress"].stringValue, _totalPrice: self.fullScheduleJSON["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.fullScheduleJSON["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.fullScheduleJSON["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.fullScheduleJSON["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.fullScheduleJSON["workOrder"][i]["charge"].stringValue)
                self.fullScheduleArray.append(workOrder)
            }
        }else{
            let workOrderCount:Int = self.personalScheduleJSON["workOrder"].count
            ////print("workOrderCount: \(workOrderCount)")
            
            self.personalScheduleArray = []
            for i in 0 ..< workOrderCount {
                ////print("ID: " + self.scheduleJSON["workOrder"][i]["ID"].stringValue)
                
                let workOrder = WorkOrder(_ID: self.personalScheduleJSON["workOrder"][i]["ID"].stringValue, _statusID: self.personalScheduleJSON["workOrder"][i]["statusID"].stringValue, _date: self.personalScheduleJSON["workOrder"][i]["date"].stringValue, _firstItem: self.personalScheduleJSON["workOrder"][i]["firstItem"].stringValue, _statusName: self.personalScheduleJSON["workOrder"][i]["statusName"].stringValue, _customer: self.personalScheduleJSON["workOrder"][i]["customer"].stringValue, _type: self.personalScheduleJSON["workOrder"][i]["type"].stringValue, _progress: self.personalScheduleJSON["workOrder"][i]["progress"].stringValue, _totalPrice: self.personalScheduleJSON["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.personalScheduleJSON["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.personalScheduleJSON["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.personalScheduleJSON["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.personalScheduleJSON["workOrder"][i]["charge"].stringValue)
                self.personalScheduleArray.append(workOrder)
            }
        }
        
        
        
        if(layoutViewsCalled == false ){
            self.layoutViews()
        }else{
            DispatchQueue.main.async {
                self.scheduleTableView.reloadData()
            }
        }
        // Close Indicator
        indicator.dismissIndicator()
    }
    
    
    
    func getHistory(_empID:String){
        //print("getHistory empID:\(_empID)")
        // Show Indicator
        
        //limited history message
        let alertController = UIAlertController(title: "Limited History", message: "This is the current year's history.  Go to customer screen to view full history for a given customer.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            //print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        
        
        indicator = SDevIndicator.generate(self.view)!
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        //print("year = \(year)")
        let month = calendar.component(.month, from: date)
        //print("month = \(month)")
        let day = calendar.component(.day, from: date)
        //print("day = \(day)")
               
        
        let startDate:String = "\(year)-01-01"
        let endDate:String = "\(year)-\(month)-\(day)"
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.workOrderList(["employeeID":self.employeeID as AnyObject,"custID":"" as AnyObject,"active":"0" as AnyObject,"startDate":startDate as AnyObject,"endDate":endDate as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            
            response in
            
            //print(response.request ?? "")  // original URL request
            
            if(_empID == ""){
                
                if let json = response.result.value {
                    self.fullHistoryJSON = JSON(json)
                    self.parseHistoryJSON(_empID: _empID)
                }
                
                self.fullHistoryLoaded = true
            }else{
                if let json = response.result.value {
                    self.personalHistoryJSON = JSON(json)
                    self.parseHistoryJSON(_empID: _empID)
                }
                
                self.personalHistoryLoaded = true
            }
        }
        
    }
    

    func parseHistoryJSON(_empID:String){
        if(_empID == ""){
            
            //loop through contacts and put them in appropriate places
            let workOrderCount:Int = self.fullHistoryJSON["workOrder"].count
            //print("workOrderCount: \(workOrderCount)")
            fullHistoryArray = []
            for i in 0 ..< workOrderCount {
                // //print("ID: " + self.historyJSON["workOrder"][i]["ID"].stringValue)
                let workOrder = WorkOrder(_ID: self.fullHistoryJSON["workOrder"][i]["ID"].stringValue, _statusID: self.fullHistoryJSON["workOrder"][i]["statusID"].stringValue, _date: self.fullHistoryJSON["workOrder"][i]["date"].stringValue, _firstItem: self.fullHistoryJSON["workOrder"][i]["firstItem"].stringValue, _statusName: self.fullHistoryJSON["workOrder"][i]["statusName"].stringValue, _customer: self.fullHistoryJSON["workOrder"][i]["customer"].stringValue, _type: self.fullHistoryJSON["workOrder"][i]["type"].stringValue, _progress: self.fullHistoryJSON["workOrder"][i]["progress"].stringValue, _totalPrice: self.fullHistoryJSON["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.fullHistoryJSON["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.fullHistoryJSON["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.fullHistoryJSON["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.fullHistoryJSON["workOrder"][i]["charge"].stringValue)
                self.fullHistoryArray.append(workOrder)
            }
        }else{
            
            //loop through contacts and put them in appropriate places
            let workOrderCount:Int = self.personalHistoryJSON["workOrder"].count
            //print("workOrderCount: \(workOrderCount)")
            personalHistoryArray = []
            for i in 0 ..< workOrderCount {
                let workOrder = WorkOrder(_ID: self.personalHistoryJSON["workOrder"][i]["ID"].stringValue, _statusID: self.personalHistoryJSON["workOrder"][i]["statusID"].stringValue, _date: self.personalHistoryJSON["workOrder"][i]["date"].stringValue, _firstItem: self.personalHistoryJSON["workOrder"][i]["firstItem"].stringValue, _statusName: self.personalHistoryJSON["workOrder"][i]["statusName"].stringValue, _customer: self.personalHistoryJSON["workOrder"][i]["customer"].stringValue, _type: self.personalHistoryJSON["workOrder"][i]["type"].stringValue, _progress: self.personalHistoryJSON["workOrder"][i]["progress"].stringValue, _totalPrice: self.personalHistoryJSON["workOrder"][i]["totalPrice"].stringValue, _totalCost: self.personalHistoryJSON["workOrder"][i]["totalCost"].stringValue, _totalPriceRaw: self.personalHistoryJSON["workOrder"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.personalHistoryJSON["workOrder"][i]["totalCostRaw"].stringValue, _charge: self.personalHistoryJSON["workOrder"][i]["charge"].stringValue)
                self.personalHistoryArray.append(workOrder)
            }
        }
        
        DispatchQueue.main.async {
            self.scheduleTableView.reloadData()
        }
        
        // Close Indicator
        indicator.dismissIndicator()
    }
    
    
    func scheduleSettings(){
        print("schedule settings")
        
        let scheduleSettingsViewController = ScheduleSettingsViewController(_allDates:self.allDates, _startDate: self.startDate, _endDate: self.endDate,_startDateDB: self.startDateDB, _endDateDB: self.endDateDB, _sort: self.sort)
        scheduleSettingsViewController.delegate = self
        navigationController?.pushViewController(scheduleSettingsViewController, animated: false )
        
        
        
    }
    
    
    
   
    
    
    
    
    
    /////////////  Table View Methods  /////////////////////////////////////////////
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        
        if (shouldShowSearchResults == true) {
            count = self.workOrdersSearchResults.count
            //print("search count = \(self.workOrdersSearchResults.count)")
            self.countLbl.text = "\(count!) Work Order(s) Found"
            return count
            
        } else {
            
            switch self.tableViewMode{
            case "SCHEDULE":
                if(personalMode == false){
                    //print("------FULL-------")
                    count = self.fullScheduleArray.count
                    //print("full schedule count = \(count)")
                }else{
                    count = self.personalScheduleArray.count
                    //print("personal schedule count = \(count)")
                }
                self.countLbl.text = "\(count!) Scheduled Work Order(s)"
                break
            case "HISTORY":
                if(personalMode == false){
                    count = self.fullHistoryArray.count
                    //print("full history count = \(count)")
                }else{
                    count = self.personalHistoryArray.count
                    //print("personal history count = \(count)")
                }
                
                self.countLbl.text = "\(count!) Completed/Cancelled Work Order(s)"
                
                break
                
            default:
                
                break
            }
            
            
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell:ScheduleTableViewCell = scheduleTableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleTableViewCell
        
        switch self.tableViewMode{
        case "SCHEDULE":
            
            if (shouldShowSearchResults == true){
                //print("make cell for schedule search mode row: \(indexPath.row)")
                
                cell.workOrder = self.workOrdersSearchResults[indexPath.row]
                cell.layoutViews(_scheduleMode: "SCHEDULE")
                cell.setStatus(status: cell.workOrder.statusId)
                 cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
                
                let searchString = self.searchController.searchBar.text!.lowercased()
                
                let baseString:NSString = cell.workOrder.title as NSString
                let highlightedText = NSMutableAttributedString(string: cell.workOrder.title!)
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
                cell.customerLbl.attributedText = highlightedText
                
                
                cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
                cell.priceLbl.text = cell.workOrder.totalPrice!
                
                
                 cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
                
                
            } else {
                
                //print("make cell for schedule reg mode row: \(indexPath.row)")
                if(personalMode == false){
                    // //print("------FULL-------")
                    cell.workOrder = self.fullScheduleArray[indexPath.row]
                }else{
                    cell.workOrder = self.personalScheduleArray[indexPath.row]
                }
                cell.layoutViews(_scheduleMode: "SCHEDULE")
                cell.customerLbl.text = cell.workOrder.title
                cell.setStatus(status: cell.workOrder.statusId)
                
                cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
                
                cell.priceLbl.text = cell.workOrder.totalPrice!
                
                 cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
                
                
            }
            
            
            break
        case "HISTORY":
            
            if (shouldShowSearchResults == true){
                //print("make cell for history search mode row: \(indexPath.row)")
                
                cell.workOrder = self.workOrdersSearchResults[indexPath.row]
                cell.layoutViews(_scheduleMode: "SCHEDULE")
                cell.setStatus(status: cell.workOrder.statusId)
                
                let searchString = self.searchController.searchBar.text!.lowercased()
                //text highlighting
                let baseString:NSString = cell.workOrder.title as NSString
                let highlightedText = NSMutableAttributedString(string: cell.workOrder.title!)
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
                        highlightedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: match.range)
                    }
                    
                }
                cell.customerLbl.attributedText = highlightedText
              
                cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
                
                cell.priceLbl.text = cell.workOrder.totalPrice!
                
                
                cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)
            } else {
                
                //print("make cell for history reg mode row: \(indexPath.row)")
                if(personalMode == false){
                    ////print("------FULL-------")
                    cell.workOrder = self.fullHistoryArray[indexPath.row]
                }else{
                    
                    cell.workOrder = self.personalHistoryArray[indexPath.row]
                }
                cell.layoutViews(_scheduleMode: "SCHEDULE")
                cell.customerLbl.text = cell.workOrder.title
                cell.setStatus(status: cell.workOrder.statusId)
                
                
                cell.chargeLbl.text = getChargeName(_charge:cell.workOrder.charge) //chargeTypeName
                
                cell.priceLbl.text = cell.workOrder.totalPrice!
                
                cell.setProfitBar(_price:cell.workOrder.totalPriceRaw!, _cost:cell.workOrder.totalCostRaw!)

            }
            
            break
            
        default:
            
            break
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
        
        let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.workOrder.ID,_customerName: currentCell.workOrder.customer)
        navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
        
        workOrderViewController.scheduleDelegate = self
        workOrderViewController.scheduleIndex = indexPath?.row
        
        self.searchController.isActive = false
        
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
                
                
                self.workOrdersSearchResults = self.fullScheduleArray.filter({( aWorkOrder: WorkOrder) -> Bool in
                    return aWorkOrder.title!.lowercased().range(of:self.searchController.searchBar.text!.lowercased(), options:.regularExpression) != nil
                })
                
            }else{
                self.workOrdersSearchResults = self.personalScheduleArray.filter({( aWorkOrder: WorkOrder) -> Bool in
                    return aWorkOrder.title!.lowercased().range(of:self.searchController.searchBar.text!.lowercased(), options:.regularExpression) != nil
                })
                
            }
        case "HISTORY":
            //print("history filterSearchResults")
            if(self.personalMode == false){
                //print("------FULL-------")
                self.workOrdersSearchResults = self.fullHistoryArray.filter({( aWorkOrder: WorkOrder) -> Bool in
                    return aWorkOrder.title!.lowercased().range(of:self.searchController.searchBar.text!.lowercased(), options:.regularExpression) != nil
                })
            }else{
                self.workOrdersSearchResults = self.personalHistoryArray.filter({( aWorkOrder: WorkOrder) -> Bool in
                    return aWorkOrder.title!.lowercased().range(of:self.searchController.searchBar.text!.lowercased(), options:.regularExpression) != nil
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
        
        
        self.personalScheduleBtn.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        
        
            if(personalMode == true){
                if(self.tableViewMode == "SCHEDULE"){
                    self.personalScheduleBtn.setTitle("View Full Schedule", for: UIControlState.normal)
                }else{
                    self.personalScheduleBtn.setTitle("View Full History", for: UIControlState.normal)
                }
            }else{
                if(self.tableViewMode == "SCHEDULE"){
                    self.personalScheduleBtn.setTitle("View \(appDelegate.loggedInEmployee!.fname!)'s Schedule", for: UIControlState.normal)
                }else{
                    self.personalScheduleBtn.setTitle("View \(appDelegate.loggedInEmployee!.fname!)'s History", for: UIControlState.normal)
                }
            }
            self.personalScheduleBtn.addTarget(self, action: #selector(ScheduleViewController.filterUsersSchedule), for: UIControlEvents.touchUpInside)
    }
    
    
    func refresh(_ sender: AnyObject){
        //print("refresh")
        refreshFromTable = true
        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
       // getSchedule()
    }
    
    
    
    func filterUsersSchedule(){
        //print("filterUsersSchedule")
        //print("personalMode \(personalMode)")
        //print("personalScheduleLoaded \(personalScheduleLoaded)")
        //print("personalHistoryLoaded \(personalHistoryLoaded)")
        //print("fullScheduleLoaded \(fullScheduleLoaded)")
        //print("fullHistoryLoaded \(fullHistoryLoaded)")
        
        ///// PERSONAL  ///////////////
        if(personalMode == false){
            //show personal schedule
            
            
            
            shouldShowSearchResults = false
            
            
            if(self.tableViewMode == "SCHEDULE"){
              
                    if(personalScheduleLoaded != true){
                        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
                       // getSchedule()
                    }else{
                        //print("reload Data schedule")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                    }
                    
            }else{//HISTORY MODE
                
              
                    if(self.personalHistoryLoaded != true){
                        getHistory(_empID: (appDelegate.loggedInEmployee?.ID)!)
                    
                    }else{
                        //print("reload Data history")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                        
                    }
            }
            
            
            ///// FULL  ///////////////
        }else{
            //show full schedule
            //print("full Mode")
            
            if(self.tableViewMode == "SCHEDULE"){
              
                    if(fullScheduleLoaded != true){
                        getSchedule(_empID: "")
                    }else{
                        //print("reload Data schedule")
                        DispatchQueue.main.async{
                            
                            self.scheduleTableView.reloadData()
                            
                        }
                    }
                    
            }else{//HISTORY MODE
              
                    if(self.fullHistoryLoaded != true){
                        getHistory(_empID: "")
                    }else{
                        //print("reload Data history")
                        DispatchQueue.main.async{
                            
                            self.scheduleTableView.reloadData()
                        }
                    }
            }
            
           
        }
        
        togglePersonalMode()
    }
    
    
    func changeSearchOptions(sender: UISegmentedControl) {
        //print("personalMode = \(personalMode)")
        //print("personalScheduleLoaded = \(personalScheduleLoaded)")
        //print("fullScheduleLoaded = \(fullScheduleLoaded)")
        //print("personalHistoryLoaded = \(personalHistoryLoaded)")
        //print("fullHistoryLoaded = \(fullHistoryLoaded)")
        //print("shouldShowSearchResults = \(shouldShowSearchResults)")
        
        
        switch sender.selectedSegmentIndex {
        case 0:
            
            
            //print("changeSearchOptions 0")
            self.tableViewMode = "SCHEDULE"
            ///// PERSONAL  ///////////////
            if(personalMode == true){
                if shouldShowSearchResults{
                    self.updateSearchResults(for:self.searchController)
                } else {
                    if(personalScheduleLoaded != true){
                        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
                        
                    }else{
                        
                        //print("reload Data personal schedule ")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                    }
                    
                }
            }else{
                ///// FULL  ///////////////
                if shouldShowSearchResults{
                    self.updateSearchResults(for:self.searchController)
                } else {
                    if(fullScheduleLoaded != true){
                        getSchedule(_empID: "")
                        
                    }else{
                        //print("reload Data full schedule ")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                    }
                    
                }
                
            }
            
        case 1:
            self.tableViewMode = "HISTORY"
            //print("changeSearchOptions 1")
            
            
            
            ///// PERSONAL  ///////////////
            if(personalMode == true){
                if shouldShowSearchResults{
                    self.updateSearchResults(for:self.searchController)
                } else {
                    if(personalHistoryLoaded  != true){
                        getHistory(_empID: (appDelegate.loggedInEmployee?.ID)!)
                        
                    }else{
                        
                        //print("reload Data personal history")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                    }
                    
                }
            }else{
                ///// FULL  ///////////////
                if shouldShowSearchResults{
                    self.updateSearchResults(for:self.searchController)
                } else {
                    if(fullHistoryLoaded != true){
                        getHistory(_empID: "")
                        
                    }else{
                        
                        //print("reload Data full history")
                        DispatchQueue.main.async{
                            self.scheduleTableView.reloadData()
                        }
                    }
                    
                }
                
            }
            
        default:
            //print("changeSearchOptions default")
            DispatchQueue.main.async{
                self.scheduleTableView.reloadData()
            }
        }
        
        setScheduleButton()
        
    }

     func displayEmployeeList(){
        appDelegate.menuChange(3)
    }
    
    func reDrawSchedule(_index:Int, _status:String, _price: String, _cost: String, _priceRaw: String, _costRaw: String){
        //print("reDraw Schedule")
        if(shouldShowSearchResults == true){
            workOrdersSearchResults[_index].statusId = _status
            workOrdersSearchResults[_index].totalPrice = _price
            workOrdersSearchResults[_index].totalCost = _cost
            workOrdersSearchResults[_index].totalPriceRaw = _priceRaw
            workOrdersSearchResults[_index].totalCostRaw = _costRaw
        }else{
            if(self.tableViewMode == "SCHEDULE"){
                if(self.personalMode == true){
                    personalScheduleArray[_index].statusId = _status
                    personalScheduleArray[_index].totalPrice = _price
                    personalScheduleArray[_index].totalCost = _cost
                    personalScheduleArray[_index].totalPriceRaw = _priceRaw
                    personalScheduleArray[_index].totalCostRaw = _costRaw
                }else{
                    fullScheduleArray[_index].statusId = _status
                    fullScheduleArray[_index].totalPrice = _price
                    fullScheduleArray[_index].totalCost = _cost
                    fullScheduleArray[_index].totalPriceRaw = _priceRaw
                    fullScheduleArray[_index].totalCostRaw = _costRaw
                }
            }else{//HISTORY
                if(self.personalMode == true){
                    personalHistoryArray[_index].statusId = _status
                    personalHistoryArray[_index].totalPrice = _price
                    personalHistoryArray[_index].totalCost = _cost
                    personalHistoryArray[_index].totalPriceRaw = _priceRaw
                    personalHistoryArray[_index].totalCostRaw = _costRaw
                }else{
                    fullHistoryArray[_index].statusId = _status
                    fullHistoryArray[_index].totalPrice = _price
                    fullHistoryArray[_index].totalCost = _cost
                    fullHistoryArray[_index].totalPriceRaw = _priceRaw
                    fullHistoryArray[_index].totalCostRaw = _costRaw
                }
            }
        }
        self.scheduleTableView.reloadData()
        
    }
    
    func updateSettings(_allDates:String, _startDate:String, _endDate:String,_startDateDB:String, _endDateDB:String, _sort:String){
        print("update settings")
        //let editsMade:Bool = false
        self.allDates = _allDates
        self.startDate = _startDate
        self.endDate = _endDate
        self.startDateDB = _startDateDB
        self.endDateDB = _endDateDB
        self.sort = _sort
        
        
        /*
 var allDates:String = "1"
 var startDate:String = ""
 var endDate:String = ""
 var startDateDB:String = ""
 var endDateDB:String = ""
 var sort:String = "0"
 */
        
        if(self.allDates != "1" || self.startDate != "" || self.endDate != "" || self.sort != "0"){
            print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }
        
        getSchedule(_empID: (appDelegate.loggedInEmployee?.ID)!)
        
    }
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

