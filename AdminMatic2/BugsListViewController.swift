//
//  BugsListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/27/17.
//  Copyright © 2017 Nick. All rights reserved.
//


/*
import Foundation
import UIKit
import Alamofire
import SwiftyJSON



class BugsListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    //data
    var totalBugs:Int!
    var bugs:[Bug] = [Bug]()
    
    var bugsTableView:TableView = TableView()
    var addBugBtn:Button = Button(titleText: "Add")
    
    
    let viewsConstraint_V:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bug/Suggestion Log"
        view.backgroundColor = layoutVars.backgroundColor
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        
        backButton.addTarget(self, action: #selector(BugsListViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        

        
        getBugList()
    }
    
    
    func getBugList() {
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
        
        
        Alamofire.request(API.Router.bugs(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let bugsJson = json["bugs"] as? [[String: Any]] {
                    
                        print("bugsJson = \(bugsJson)")
                    for bug in bugsJson {
                        let _bug = Bug(_title: (bug["title"] as? String)!, _id: (bug["ID"] as? String)!, _description: (bug["description"] as? String)!, _status: (bug["status"] as? String)!, _createdBy: (bug["createdBy"] as? String)!, _created: (bug["created"] as? String)!)
                        self.bugs.append(_bug)
                    }
                    
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }

            self.layoutViews()
        }
    }
    
    
    func layoutViews(){
        indicator.dismissIndicator()
        
    
        self.bugsTableView.delegate  =  self
        self.bugsTableView.dataSource = self
        self.bugsTableView.register(BugTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.bugsTableView)
        
        
        self.addBugBtn.addTarget(self, action: #selector(BugsListViewController.addBug), for: UIControlEvents.touchUpInside)
        self.addBugBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        self.addBugBtn.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.addBugBtn)
        
        
        //auto layout group
        let viewsDictionary = [
            "table":self.bugsTableView
            ]as [String:AnyObject]
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - 100] as [String:Any]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[table]-|", options: [], metrics: sizeVals, views: viewsDictionary))
    }
    
    
    
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection")
       
            return self.bugs.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = bugsTableView.dequeueReusableCell(withIdentifier: "cell") as! BugTableViewCell
        bugsTableView.rowHeight = 50.0
        
        cell.titleLbl.text = self.bugs[indexPath.row].title
        cell.setStatus(status: self.bugs[indexPath.row].status)
        
        
        
        
        
        /*
        
        if shouldShowSearchResults{
            let searchString = self.searchController.searchBar.text!.lowercased()
            if(currentSearchMode == .name){
                cell.nameLbl.text = self.customersSearchResults[indexPath.row]
                cell.name = self.customersSearchResults[indexPath.row]
                if let i = self.names.index(of: cell.nameLbl.text!) {
                    //print("\(cell.nameLbl.text!) is at index \(i)")
                    cell.addressLbl.text = self.addresses[i]
                    cell.address = self.addresses[i]
                    cell.id = self.ids[i]
                } else {
                    cell.addressLbl.text = ""
                    cell.address = ""
                    cell.id = ""
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
                        highlightedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: match.range)
                    }
                }
                cell.nameLbl.attributedText = highlightedText
                
            }else{//address search mode
                cell.addressLbl.text = self.customersSearchResults[indexPath.row]
                cell.address = self.customersSearchResults[indexPath.row]
                
                if let i = self.addresses.index(of: cell.addressLbl.text!) {
                    cell.nameLbl.text = self.names[i]
                    cell.name = self.names[i]
                    cell.id = self.ids[i]
                } else {
                    cell.nameLbl.text = ""
                    cell.name = ""
                    cell.id = ""
                }
                //text highlighting
                let baseString:NSString = cell.address as NSString
                let highlightedText = NSMutableAttributedString(string: cell.address)
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
                cell.addressLbl.attributedText = highlightedText
            }
        } else {
            //print("make cell")
            cell.id = self.ids[sections[indexPath.section].index + indexPath.row]
            cell.name = self.names[sections[indexPath.section].index + indexPath.row]
            cell.address = self.addresses[sections[indexPath.section].index + indexPath.row]
            
            cell.nameLbl.text = self.names[sections[indexPath.section].index + indexPath.row]
            cell.addressLbl.text = self.addresses[sections[indexPath.section].index + indexPath.row]
        }
        
        */
        
        
        
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! CustomerTableViewCell
        let customerViewController = CustomerViewController(_customerID: currentCell.id,_customerName: currentCell.name)
        navigationController?.pushViewController(customerViewController, animated: false )
        
        tableView.deselectRow(at: indexPath!, animated: true)
        */
        
        
       // let indexPath = tableView.indexPathForSelectedRow;
        //let currentCell = tableView.cellForRow(at: indexPath!) as! CustomerTableViewCell
        let bugViewController = BugViewController(_bug: self.bugs[(indexPath.row)])
        navigationController?.pushViewController(bugViewController, animated: false )
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
 
    
    @objc func addBug(){
        print("add bug")
        
        let bugViewController = BugViewController()
        navigationController?.pushViewController(bugViewController, animated: false )
        
        
        
    }
    
    
    
    @objc func goBack(){
        displayHomeView()
       // _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
 
*/





