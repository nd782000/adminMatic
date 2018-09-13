//
//  LeadListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 11/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON

// updates status icons without getting new db data
protocol LeadListDelegate{
    func getLeads(_openNewLead:Bool)
    func cancelSearch()
    
}

protocol LeadSettingsDelegate{
    func updateSettings(_status: String, _salesRep: String, _salesRepName: String, _zoneID: String, _zoneName: String)
}


class LeadListViewController: ViewControllerWithMenu, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, LeadListDelegate, LeadSettingsDelegate{
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    
    var searchController:UISearchController!
    var searchTerm:String = ""
    var leadsSearchResults:[Lead] = []
    var shouldShowSearchResults:Bool = false
   // var searchTerm:String = "" // used to retain search when leaving this view and having to deactivate
    
    var refreshControl: UIRefreshControl!
    var leadTableView: TableView!
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    var addLeadBtn:Button = Button(titleText: "Add New Lead")
    var leadViewController:LeadViewController!
    var leads:JSON!
    var leadsArray:[Lead] = []
    
    
    
    
    //settings
    
    var leadSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    
    var status:String = ""
    var salesRep:String = ""
    var salesRepName:String = ""
    var zoneID:String = ""
    var zoneName:String = ""
    
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Lead List"
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading..."
        indicator = SDevIndicator.generate(self.view)!
        getLeads(_openNewLead:false)
    }
    
    
    func getLeads(_openNewLead:Bool){
        print("getLeads")
        
        self.leadsArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        //parameters = ["cb":"\(timeStamp)"]
         parameters = ["status":self.status,"salesRep":self.salesRep,"zone":self.zoneID,"cb":"\(timeStamp)"]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leads.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("lead response = \(response)")
            }
            .responseJSON() {
                response in
                if let json = response.result.value {
                    self.leads = JSON(json)
                    
                    let jsonCount = self.leads["leads"].count
                    print("JSONcount: \(jsonCount)")
                    for i in 0 ..< jsonCount {
                        let lead =  Lead(_ID: self.leads["leads"][i]["ID"].stringValue, _statusID: self.leads["leads"][i]["status"].stringValue, _scheduleType: self.leads["leads"][i]["timeType"].stringValue, _date: self.leads["leads"][i]["date"].stringValue, _time: self.leads["leads"][i]["time"].stringValue, _statusName: self.leads["leads"][i]["statusName"].stringValue, _customer: self.leads["leads"][i]["customer"].stringValue, _customerName: self.leads["leads"][i]["custName"].stringValue, _urgent: self.leads["leads"][i]["urgent"].stringValue, _description: self.leads["leads"][i]["description"].stringValue, _rep: self.leads["leads"][i]["salesRep"].stringValue, _repName: self.leads["leads"][i]["repName"].stringValue, _deadline: self.leads["leads"][i]["deadline"].stringValue, _requestedByCust: self.leads["leads"][i]["requestedByCust"].stringValue, _createdBy: self.leads["leads"][i]["createdBy"].stringValue, _daysAged: self.leads["leads"][i]["daysAged"].stringValue)
                        
                        lead.dateNice = self.leads["leads"][i]["dateNice"].stringValue
                        
                        lead.custNameAndID = "\(lead.customerName!) #\(lead.ID!)"
                        
                        print("json zone = \(self.leads["leads"][i]["zone"].stringValue)")
                        for var n in 0 ..< self.appDelegate.zones.count{
                            print(" zone names = \(self.appDelegate.zones[n].name)")
                            print(" zone names = \(self.appDelegate.zones[n].ID)")
                            print(" zone names = \(self.appDelegate.zones[n].name!)")
                            print(" zone names = \(self.appDelegate.zones[n].ID!)")
                            if self.leads["leads"][i]["zone"].stringValue == self.appDelegate.zones[n].ID!{
                                lead.zone = self.appDelegate.zones[n]
                                print(" matching zone names = \(lead.zone.name)")
                                n = self.appDelegate.zones.count
                            }
                        }
                        
                        if lead.zone == nil{
                            let zone:Zone = Zone(_ID: "0", _name: "None")
                            lead.zone = zone
                        }
                        
                        
                        lead.custNameAndZone = "\(lead.customerName!) \(lead.zone.name!)"
                        
                        lead.description = "Zone: \(lead.zone.name!) - \(lead.description!)"
                        
                        
                        self.leadsArray.append(lead)
                    }
                    self.indicator.dismissIndicator()
                    
                    
                        self.layoutViews()
                    
                    
                    if _openNewLead {
                        print("open new lead")
                        
                        
                        self.leadViewController = LeadViewController(_lead: self.leadsArray[0])
                        self.leadViewController.delegate = self
                        self.navigationController?.pushViewController(self.leadViewController, animated: false )
                        
                        
                    }
                }
        }
        
    }
    
    
    func layoutViews(){
        print("Layout Views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Leads"
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
        
        
        
        if self.searchTerm != ""{
            self.searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
        
        
        
        self.leadTableView =  TableView()
        
        self.leadTableView.delegate  =  self
        self.leadTableView.dataSource  =  self
        self.leadTableView.rowHeight = 60.0
        self.leadTableView.register(LeadTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.leadTableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        leadTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged)
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        self.addLeadBtn.layer.borderColor = UIColor.white.cgColor
        self.addLeadBtn.layer.borderWidth = 1.0
        self.addLeadBtn.addTarget(self, action: #selector(LeadListViewController.addLead), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.addLeadBtn)
        
        
        
        
        self.leadSettingsBtn.addTarget(self, action: #selector(LeadListViewController.leadSettings), for: UIControlEvents.touchUpInside)
        
        // self.contractSettingsBtn.frame = CGRect(x:self.view.frame.width - 50, y: self.view.frame.height - 50, width: 50, height: 50)
        //self.contractSettingsBtn.translatesAutoresizingMaskIntoConstraints = true
        self.leadSettingsBtn.layer.borderColor = UIColor.white.cgColor
        self.leadSettingsBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.leadSettingsBtn)
        
        self.leadSettingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        
        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 11, y: 11, width: 28, height: 28)
        
        
        if(self.status != "" || self.salesRep != "" || self.zoneID != "" ){
            print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }
        
        
        
        self.leadSettingsBtn.addSubview(settingsIcon)
        
        
        
        
        
        
    //auto layout group
        let viewsDictionary = [
            "leadTable":self.leadTableView,
            "countView":self.countView,
            "addLeadBtn":self.addLeadBtn,"leadSettingsBtn":leadSettingsBtn
            ] as [String : Any]
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
    //////////////   auto layout position constraints   /////////////////////////////
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leadTable(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addLeadBtn(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addLeadBtn][leadSettingsBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[leadTable][countView(30)][addLeadBtn(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[leadTable][countView(30)][leadSettingsBtn(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
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
        
        print("filterSearchResults")
        self.leadsSearchResults = []
        
       
        
        self.leadsSearchResults = self.leadsArray.filter({( aLead: Lead) -> Bool in
            
            //return type name or name
            return (aLead.custNameAndID!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil  || aLead.description!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
        })
        
        
        
        
        self.leadTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.leadTableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.leadTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.leadTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("self.leadsArray.count = \(self.leadsArray.count)")
        
        
        if shouldShowSearchResults{
            self.countLbl.text = "\(self.leadsSearchResults.count) Lead(s) Found"
            return self.leadsSearchResults.count
        } else {
            print("self.leadsArray.count = \(self.leadsArray.count)")
            self.countLbl.text = "\(self.leadsArray.count) Active Lead(s) "
            return self.leadsArray.count
        }
        
        
        //return self.leadsArray.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print("cellForRowAt")
        /*
        let cell:LeadTableViewCell = leadTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTableViewCell
        cell.lead = self.leadsArray[indexPath.row]
        cell.layoutViews(_scheduleMode: "SCHEDULE")
        return cell;
        */
        
        
        
        let cell:LeadTableViewCell = leadTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTableViewCell
        
        if shouldShowSearchResults{
            
            cell.lead = self.leadsSearchResults[indexPath.row]
            
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            //text highlighting
            
            
            
            
            let baseString:NSString = self.leadsSearchResults[indexPath.row].custNameAndID! as NSString
            let highlightedText = NSMutableAttributedString(string: self.leadsSearchResults[indexPath.row].custNameAndID!)
            
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
            
            
            let baseString2:NSString = self.leadsSearchResults[indexPath.row].description!  as NSString
            let highlightedText2 = NSMutableAttributedString(string: self.leadsSearchResults[indexPath.row].description!)
            
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
            
            
            
            
            
            
            cell.layoutViews()
            
            cell.titleLbl.attributedText = highlightedText
            
            cell.descriptionLbl.attributedText = highlightedText2
            
            
           
            
            
            
            
            
        } else {
            cell.lead = self.leadsArray[indexPath.row]
           // cell.name = "\(cell.lead.customerName!) #\(cell.lead.ID!)"
            cell.layoutViews()
        }
        
        return cell;
        
        
        
        
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! LeadTableViewCell;
        self.leadViewController = LeadViewController(_lead: currentCell.lead)
        tableView.deselectRow(at: indexPath!, animated: true)
        self.leadViewController.delegate = self
        self.searchTerm = self.searchController.searchBar.text!
        navigationController?.pushViewController(self.leadViewController, animated: false )
        
        if(self.searchController.isActive == true){
            self.searchTerm = self.searchController.searchBar.text!
            self.searchController.isActive = false
        }
        
        
    }
    
    
    
    
    
    @objc func refresh(_ sender: AnyObject){
        print("refresh")
        //refreshFromTable = true
        //self.refreshControl.endRefreshing()
        //tableRefresh = true
        shouldShowSearchResults = false
        showLoadingScreen()
        //getLeads(_openNewLead: false)
        
    }
    
    
    
    
    @objc func addLead(){
        print("Add Lead")
        let editLeadViewController = NewEditLeadViewController()
        editLeadViewController.delegate = self
        navigationController?.pushViewController(editLeadViewController, animated: false )
    }
    
    
    
    func cancelSearch() {
        print("cancel search")
        if(self.searchController.isActive == true){
            self.searchController.isActive = false
            self.leadTableView.reloadData()
        }
    }
    
    
    @objc func leadSettings(){
        print("lead settings")
        
        let leadSettingsViewController = LeadSettingsViewController(_status: self.status,_salesRep: self.salesRep,_salesRepName: self.salesRepName,_zoneID: self.zoneID,_zoneName: self.zoneName)
        leadSettingsViewController.leadSettingsDelegate = self
        navigationController?.pushViewController(leadSettingsViewController, animated: false )
        
        
        
    }
    
    
    
    func updateSettings(_status: String, _salesRep: String, _salesRepName: String, _zoneID: String, _zoneName: String){
        print("update settings status = \(_status) salesRep = \(_salesRep) salesRepName = \(_salesRepName)")
        self.status = _status
        self.salesRep = _salesRep
        self.salesRepName = _salesRepName
        self.zoneID = _zoneID
        self.zoneName = _zoneName
        
        self.getLeads(_openNewLead: false)
    }
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        if self.searchTerm != ""{
            self.searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

