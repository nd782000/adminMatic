//
//  ContractListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//
 
//  Edited for safeView


import Foundation
import UIKit
import Alamofire
//import SwiftyJSON

// updates status icons without getting new db data
protocol ContractListDelegate{
    func getContracts(_openNewContract:Bool)
    
}

protocol ContractSettingsDelegate{
    func updateSettings(_status:String, _salesRep:String, _salesRepName:String)
}


class ContractListViewController: ViewControllerWithMenu, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, ContractListDelegate, ContractSettingsDelegate{
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var searchController:UISearchController!
    //var contractsSearchResults:[Contract] = []
    var shouldShowSearchResults:Bool = false
    
    
    var refreshControl: UIRefreshControl!
    var contractTableView: TableView!
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    var addContractBtn:Button = Button(titleText: "Add New Contract")
    var contractSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    //settings
    var status:String = ""
    var salesRep:String = ""
    var salesRepName:String = ""
    
    var contractViewController:ContractViewController!
    //var contracts:JSON!
    //var contractsArray:[Contract] = []
    
    var contractsArray:ContractArray = ContractArray(_contracts: [])
    var contractsSearchResults:ContractArray = ContractArray(_contracts: [])
    
    
    var names = [String]()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading..."
        indicator = SDevIndicator.generate(self.view)!
        getContracts(_openNewContract:false)
    }
    
    
    func getContracts(_openNewContract:Bool){
        print("getContracts _openNewContract = \(_openNewContract)")
        
        self.contractsArray.contracts = []
        //self.contractsArray = []
        self.names = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["status":self.status,"salesRep":self.salesRep,"cb":"\(timeStamp)"]
        //print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/contracts.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("contract response = \(response)")
            }
            .responseJSON() {
                response in
                
                
                do{
                    //created the json decoder
                    let json = response.data
                    
                    //print("json = \(json)")
                    
                    let decoder = JSONDecoder()
                    
                    let parsedData = try decoder.decode(ContractArray.self, from: json!)
                    print("parsedData = \(parsedData)")
                    let contracts = parsedData
                   
                    
                    let contractCount = contracts.contracts.count
                    print("contract count = \(contractCount)")
                    
                    for i in 0 ..< contractCount {
                        //create an object
                        print("create a contract object \(i)")
                        
                        contracts.contracts[i].custNameAndID = "\(contracts.contracts[i].customerName!) \(contracts.contracts[i].ID)"
                        
                    
                        self.contractsArray.contracts.append(contracts.contracts[i])
                    }
                    
                    self.indicator.dismissIndicator()
                    
                    
                    
                    if _openNewContract == true{
                        // let indexPath = tableView.indexPathForSelectedRow;
                        //let currentCell = tableView.cellForRow(at: indexPath!) as! ContractTableViewCell;
                        self.contractViewController = ContractViewController(_contract: self.contractsArray.contracts[0])
                        self.contractViewController.delegate = self
                        
                        self.navigationController?.pushViewController(self.contractViewController, animated: false )
                    }else{
                        self.layoutViews()
                    }
                    
                }catch let err{
                    print(err)
                }
                

                
                
                
                
                
                //native way
                /*
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let contracts = json["contracts"] as? [[String: Any]] {
                        
                        let contractCount = contracts.count
                        //print("contract count = \(contractCount)")
                        
                        
                        for i in 0 ..< contractCount {
                            
                            
                            //create an object
                            //print("create a contract object \(i)")
                            
                            
                            //as! String
                            let contract = Contract(_ID: contracts[i]["ID"] as? String, _title: contracts[i]["title"] as? String, _status: contracts[i]["status"] as? String, _statusName: contracts[i]["statusName"] as? String, _chargeType: contracts[i]["chargeType"] as? String, _customer: contracts[i]["customer"] as? String, _customerName: contracts[i]["custName"] as? String, _notes: contracts[i]["notes"] as? String, _salesRep: contracts[i]["salesRep"] as? String, _repName: contracts[i]["repName"] as? String, _createdBy: contracts[i]["createdBy"] as? String, _createDate: contracts[i]["createDate"] as? String, _subTotal: contracts[i]["subTotal"] as? String, _taxTotal: contracts[i]["taxTotal"] as? String, _total: contracts[i]["total"] as? String, _terms: contracts[i]["termsDescription"] as? String, _daysAged: contracts[i]["daysAged"] as? String)
                            
                            
                            
                            
                            contract.custNameAndID = "\(contract.customerName!) #\(contract.ID!)"
                            
                            contract.customerSignature  = contracts[i]["customerSigned"]as! String
                            
                            
                            
                            self.contractsArray.append(contract)
                            self.names.append("\(contract.customerName!) #\(contract.ID!)")
                            
                            
                            
                            
                        }
                    }
                    
                    
                    
                    
                    
                    
                  
                    
                    self.indicator.dismissIndicator()
                    
                    
                    self.layoutViews()
                    
                    if _openNewContract == true{
                       // let indexPath = tableView.indexPathForSelectedRow;
                        //let currentCell = tableView.cellForRow(at: indexPath!) as! ContractTableViewCell;
                        self.contractViewController = ContractViewController(_contract: self.contractsArray[0])
                        self.contractViewController.delegate = self
                        
                        self.navigationController?.pushViewController(self.contractViewController, animated: false )
                    }
                    
                    
                } catch {
                    //print("Error deserializing JSON: \(error)")
                }
                */
                
        }
        
    }
    
    
    func layoutViews(){
        //print("Layout Views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        title = "Contract List"
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Contracts"
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
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.contractTableView =  TableView()
        
        self.contractTableView.delegate  =  self
        self.contractTableView.dataSource  =  self
        self.contractTableView.rowHeight = 60.0
        self.contractTableView.register(ContractTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.contractTableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        contractTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        self.addContractBtn.layer.borderColor = UIColor.white.cgColor
        self.addContractBtn.layer.borderWidth = 1.0
        self.addContractBtn.addTarget(self, action: #selector(ContractListViewController.addContract), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.addContractBtn)
        
        
        
        self.contractSettingsBtn.addTarget(self, action: #selector(ContractListViewController.contractSettings), for: UIControl.Event.touchUpInside)
        
        self.contractSettingsBtn.layer.borderColor = UIColor.white.cgColor
        self.contractSettingsBtn.layer.borderWidth = 1.0
        safeContainer.addSubview(self.contractSettingsBtn)
        
        self.contractSettingsBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        
        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 11, y: 11, width: 28, height: 28)
        
        
        if(self.status != "" || self.salesRep != ""){
            //print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }
        
        
        
        self.contractSettingsBtn.addSubview(settingsIcon)
        
        
        
        //auto layout group
        let viewsDictionary = [
            "contractTable":self.contractTableView,
            "countView":self.countView,
            "addContractBtn":self.addContractBtn,"contractSettingsBtn":contractSettingsBtn
            ] as [String : Any]
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contractTable(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addContractBtn][contractSettingsBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contractTable][countView(30)][addContractBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contractTable][countView(30)][contractSettingsBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
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
        
        //print("filterSearchResults")
        self.contractsSearchResults.contracts = []
       
        
       
        
        self.contractsSearchResults.contracts = self.contractsArray.contracts.filter({( aContract: Contract2) -> Bool in
            
            //return type name or name
            return (aContract.custNameAndID!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil  || aContract.title.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
        })
        
        
        self.contractTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.contractTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.contractTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.contractTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if shouldShowSearchResults{
            self.countLbl.text = "\(self.contractsSearchResults.contracts.count) Contract(s) Found"
            return self.contractsSearchResults.contracts.count
        } else {
            //print("self.contractsArray.count = \(self.contractsArray.count)")
            self.countLbl.text = "\(self.contractsArray.contracts.count) Active Contract(s) "
            return self.contractsArray.contracts.count
        }
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print("cellForRowAt")
        
        let cell:ContractTableViewCell = contractTableView.dequeueReusableCell(withIdentifier: "cell") as! ContractTableViewCell
        
        if shouldShowSearchResults{
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            //text highlighting
            
            let baseString:NSString = self.contractsSearchResults.contracts[indexPath.row].custNameAndID! as NSString
            let highlightedText = NSMutableAttributedString(string: self.contractsSearchResults.contracts[indexPath.row].custNameAndID!)
            
            
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
            
            let baseString2:NSString = self.contractsSearchResults.contracts[indexPath.row].title  as NSString
            let highlightedText2 = NSMutableAttributedString(string: self.contractsSearchResults.contracts[indexPath.row].title)
            
            
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
            
            
            cell.contract = self.contractsSearchResults.contracts[indexPath.row]
            cell.layoutViews()
            
            cell.titleLbl.attributedText = highlightedText
            
            cell.descriptionLbl.attributedText = highlightedText2
            
        } else {
            cell.contract = self.contractsArray.contracts[indexPath.row]
            cell.layoutViews()
        }
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! ContractTableViewCell;
        self.contractViewController = ContractViewController(_contract: currentCell.contract)
        contractViewController.delegate = self
        tableView.deselectRow(at: indexPath!, animated: true)
        navigationController?.pushViewController(self.contractViewController, animated: false )
    }
    
    
    
    
    
    @objc func refresh(_ sender: AnyObject){
        //print("refresh")
        //refreshFromTable = true
        getContracts(_openNewContract: false)
        
    }
    
    
    
    
    @objc func addContract(){
        //print("Add Contract")
        let editContractViewController = NewEditContractViewController()
        editContractViewController.delegate = self
        navigationController?.pushViewController(editContractViewController, animated: false )
    }
    
    @objc func contractSettings(){
        //print("contract settings")
        
        let contractSettingsViewController = ContractSettingsViewController(_status: self.status,_salesRep: self.salesRep,_salesRepName: self.salesRepName)
        contractSettingsViewController.contractSettingsDelegate = self
        navigationController?.pushViewController(contractSettingsViewController, animated: false )
        
        
        
    }
    
    
    func updateSettings(_status:String, _salesRep:String, _salesRepName:String){
        //print("update settings status = \(_status) salesRep = \(_salesRep) salesRepName = \(_salesRepName)")
        self.status = _status
        self.salesRep = _salesRep
        self.salesRepName = _salesRepName
        //self.getContracts(_openNewContract: false)
        self.showLoadingScreen()
    }
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


