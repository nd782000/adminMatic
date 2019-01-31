//
//  InvoiceListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/27/19.
//  Copyright © 2019 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

/*
 Status
 0 = syncing to QB
 1 = pending
 2 = final
 3 = sent (printed/emailed)
 4 = paid
 5 = void
 */

protocol InvoiceListDelegate{
    func updateInvoice(_atIndex:Int,_status:String)
    
}

class InvoiceListViewController: ViewControllerWithMenu, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, InvoiceListDelegate{
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var searchController:UISearchController!
    var invoices:JSON!
    var invoiceArray:[Invoice] = []
    var invoiceSearchResults:[Invoice] = []
    var shouldShowSearchResults:Bool = false
    
    
    //var refreshControl: UIRefreshControl!
    var invoiceTableView: TableView!
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    var addInvoiceBtn:Button = Button(titleText: "Add New Invoice")
    var invoiceSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    //settings
    var salesRep:String = ""
    var salesRepName:String = ""
    var custID:String = ""
    var custName:String = ""
    var startDate:String = ""
    var endDate:String = ""
    var sort:String = "0"
    var status:String = ""
    
    var invoiceViewController:InvoiceViewController!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading..."
        indicator = SDevIndicator.generate(self.view)!
        getInvoices()
    }
    
    
    func getInvoices(){
        print("getInvoices")
        
        
        self.invoiceArray = []
        
       
        //Get lead list
        var parameters:[String:String]
        parameters = ["status":self.status,"salesRep":self.salesRep,"custID":self.custID,"startDate":self.startDate,"endDate":self.endDate,"sort":self.sort]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/invoices.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("invoice response")
            }
            .responseJSON() {
                response in
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let invoices = json["invoices"] as? [[String: Any]] {
                        
                        let invoiceCount = invoices.count
                        print("invoice count = \(invoiceCount)")
                        
                        
                        for i in 0 ..< invoiceCount {
                            print("invoice status = \(String(describing: invoices[i]["status"] as? String))!)")
                            
                            //create an object
                            print("create a invoice object \(i)")
                            let invoice = Invoice(_ID: (invoices[i]["ID"] as? String)!, _date: (invoices[i]["invoiceDate"] as? String)!, _customer: (invoices[i]["customer"] as? String)!, _customerName: (invoices[i]["custName"] as? String)!, _totalPrice: self.layoutVars.numberAsCurrency(_number: (invoices[i]["total"] as? String)!), _status: (invoices[i]["invoiceStatus"] as? String)!)
                            
                            self.invoiceArray.append(invoice)
                          
                            
                        }
                        
                        self.indicator.dismissIndicator()
                        
                        
                        self.layoutViews()
                    }
                   
                    
                   
                    
                   
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
                
        }
        
    }
    
    
    func layoutViews(){
        print("Layout Views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        title = "Invoice List"
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Invoices"
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
        
        
        
        self.invoiceTableView =  TableView()
        
        self.invoiceTableView.delegate  =  self
        self.invoiceTableView.dataSource  =  self
        self.invoiceTableView.rowHeight = 60.0
        self.invoiceTableView.register(InvoiceTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.invoiceTableView)
        
        //refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //invoiceTableView.addSubview(refreshControl)
        //refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        
       
       
        
        let viewsDictionary = [
            "invoiceTable":self.invoiceTableView,
            "countView":self.countView
            ] as [String : Any]
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[invoiceTable(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[invoiceTable][countView(30)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[invoiceTable][countView(30)]|", options: [], metrics: sizeVals, views: viewsDictionary))
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
        self.invoiceSearchResults = []
        
        self.invoiceSearchResults = self.invoiceArray.filter({( aInvoice: Invoice) -> Bool in
            
          //search by 4 fields (ID, customerName, date, totalPrice)
            
            return (aInvoice.customerName!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil  || aInvoice.ID!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil || aInvoice.date!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil || aInvoice.totalPrice!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
            
        })
        
        
        
        self.invoiceTableView.reloadData()
    }
    
   
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.invoiceTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.invoiceTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.invoiceTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if shouldShowSearchResults{
            
            self.countLbl.text = "\(self.invoiceSearchResults.count) Invoice(s) Found"
            return self.invoiceSearchResults.count
        } else {
            
            self.countLbl.text = "\(self.invoiceArray.count) Invoices(s) "
            return self.invoiceArray.count
            
        }
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print("cellForRowAt")
        
        let cell:InvoiceTableViewCell = invoiceTableView.dequeueReusableCell(withIdentifier: "cell") as! InvoiceTableViewCell
    
        if shouldShowSearchResults{
            
            cell.invoice = self.invoiceSearchResults[indexPath.row]
            
            
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            let baseString1:NSString = cell.invoice.customerName as NSString
            let highlightedText1 = NSMutableAttributedString(string: cell.invoice.customerName!)
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
                    highlightedText1.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            cell.titleLbl.attributedText = highlightedText1
            
            
            
            let baseString2:NSString = cell.invoice.ID as NSString
            let highlightedText2 = NSMutableAttributedString(string: cell.invoice.ID!)
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
            
            
            cell.IDLbl.attributedText = highlightedText2
            
            
            
            let baseString3:NSString = cell.invoice.date as NSString
            let highlightedText3 = NSMutableAttributedString(string: cell.invoice.date!)
            var error3: NSError?
            let regex3: NSRegularExpression?
            do {
                regex3 = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error3a as NSError {
                error3 = error3a
                regex3 = nil
            }
            if let regexError3 = error3 {
                print("Oh no! \(regexError3)")
            } else {
                for match in (regex3?.matches(in: baseString3 as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString3.length)))! as [NSTextCheckingResult] {
                    highlightedText3.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            
            
            cell.dateLbl.attributedText = highlightedText3
            
            
            let baseString4:NSString = cell.invoice.totalPrice as NSString
            let highlightedText4 = NSMutableAttributedString(string: cell.invoice.totalPrice!)
            var error4: NSError?
            let regex4: NSRegularExpression?
            do {
                regex4 = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error4a as NSError {
                error4 = error4a
                regex4 = nil
            }
            if let regexError4 = error4 {
                print("Oh no! \(regexError4)")
            } else {
                for match in (regex4?.matches(in: baseString4 as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString4.length)))! as [NSTextCheckingResult] {
                    highlightedText4.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
            cell.totalLbl.attributedText = highlightedText4
            cell.setStatus(status: cell.invoice.status)
            
        } else {
            print("count = \(self.invoiceArray.count)")
            cell.layoutViews()
            cell.invoice = self.invoiceArray[indexPath.row]
            
            cell.titleLbl.text = self.invoiceArray[indexPath.row].customerName!
            cell.totalLbl.text = self.invoiceArray[indexPath.row].totalPrice!
            cell.IDLbl.text = self.invoiceArray[indexPath.row].ID!
            cell.dateLbl.text = self.invoiceArray[indexPath.row].date!
            cell.setStatus(status: self.invoiceArray[indexPath.row].status)
            
            
        }
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! InvoiceTableViewCell;
        self.invoiceViewController = InvoiceViewController(_invoice: currentCell.invoice)
        self.invoiceViewController.delegate = self
        self.invoiceViewController.index = indexPath?.row
        
        tableView.deselectRow(at: indexPath!, animated: true)
       navigationController?.pushViewController(self.invoiceViewController, animated: false )
    }
    
    func updateInvoice(_atIndex:Int,_status:String){
        self.invoiceArray[_atIndex].status  = _status
        self.invoiceTableView.reloadData()
    }
    
    /*
    
    @objc func refresh(_ sender: AnyObject){
        //print("refresh")
        //refreshFromTable = true
        getInvoices()
        
    }
 */
    
    
    
    /*
    
    @objc func addInvoice(){
        print("Add Invoice")
       // let editContractViewController = NewEditContractViewController()
       // editInvoiceViewController.delegate = self
        //navigationController?.pushViewController(editContractViewController, animated: false )
    }
    
    @objc func contractSettings(){
        print("contract settings")
        
        let contractSettingsViewController = ContractSettingsViewController(_status: self.status,_salesRep: self.salesRep,_salesRepName: self.salesRepName)
        contractSettingsViewController.contractSettingsDelegate = self
        navigationController?.pushViewController(contractSettingsViewController, animated: false )
        
        
        
    }
    
    
    func updateSettings(_status:String, _salesRep:String, _salesRepName:String){
        print("update settings status = \(_status) salesRep = \(_salesRep) salesRepName = \(_salesRepName)")
        self.status = _status
        self.salesRep = _salesRep
        self.salesRepName = _salesRepName
        //self.getContracts(_openNewContract: false)
        self.showLoadingScreen()
    }
    
    */
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


