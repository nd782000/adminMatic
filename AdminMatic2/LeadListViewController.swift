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
    func getLeads()
    
}


class LeadListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, LeadListDelegate{
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var refreshControl: UIRefreshControl!
    var leadTableView: TableView!
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    var addLeadBtn:Button = Button(titleText: "Add New Lead")
    var leadViewController:LeadViewController!
    var leads:JSON!
    var leadsArray:[Lead] = []
    
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
        getLeads()
    }
    
    
    func getLeads(){
        print("getLeads")
        
        self.leadsArray = []
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        //Get lead list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)"]
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
                        let lead =  Lead(_ID: self.leads["leads"][i]["ID"].stringValue, _statusID: self.leads["leads"][i]["status"].stringValue, _scheduleType: self.leads["leads"][i]["timeType"].stringValue, _date: self.leads["leads"][i]["date"].stringValue, _time: self.leads["leads"][i]["time"].stringValue, _statusName: self.leads["leads"][i]["statusName"].stringValue, _customer: self.leads["leads"][i]["customer"].stringValue, _customerName: self.leads["leads"][i]["custName"].stringValue, _urgent: self.leads["leads"][i]["urgent"].stringValue, _description: self.leads["leads"][i]["description"].stringValue, _rep: self.leads["leads"][i]["salesRep"].stringValue, _repName: self.leads["leads"][i]["repName"].stringValue, _deadline: self.leads["leads"][i]["deadline"].stringValue, _requestedByCust: self.leads["leads"][i]["requestedByCust"].stringValue, _createdBy: self.leads["leads"][i]["createdBy"].stringValue)
                        
                        lead.dateNice = self.leads["leads"][i]["dateNice"].stringValue
                       // lead.dateRaw = self.leads["leads"][i]["aptDate"].stringValue
                        
                        self.leadsArray.append(lead)
                    }
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                }
        }
        
    }
    
    
    func layoutViews(){
        print("Layout Views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
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
        self.countLbl.text = "\(self.leadsArray.count) Active Leads "
        self.countView.addSubview(self.countLbl)
        
        self.addLeadBtn.addTarget(self, action: #selector(LeadListViewController.addLead), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.addLeadBtn)
        
    //auto layout group
        let viewsDictionary = [
            "leadTable":self.leadTableView,
            "countView":self.countView,
            "addLeadBtn":self.addLeadBtn
            ] as [String : Any]
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
    //////////////   auto layout position constraints   /////////////////////////////
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leadTable(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addLeadBtn(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[leadTable][countView(30)][addLeadBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        let viewsDictionary2 = [
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
    //////////////   auto layout position constraints   /////////////////////////////
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("self.leadsArray.count = \(self.leadsArray.count)")
        return self.leadsArray.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print("cellForRowAt")
        let cell:LeadTableViewCell = leadTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTableViewCell
        cell.lead = self.leadsArray[indexPath.row]
        cell.layoutViews(_scheduleMode: "SCHEDULE")
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! LeadTableViewCell;
        self.leadViewController = LeadViewController(_lead: currentCell.lead)
        tableView.deselectRow(at: indexPath!, animated: true)
        self.leadViewController.delegate = self
        navigationController?.pushViewController(self.leadViewController, animated: false )
    }
    
    
    
    
    //cell swipe action
  /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! EmployeeTableViewCell;
        let call = UITableViewRowAction(style: .normal, title: "Call") { action, index in
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                
                UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(currentCell.employee.phone))")! as URL, options: [:], completionHandler: nil)
            }
            
            tableView.setEditing(false, animated: true)
        }
        
        call.backgroundColor = self.layoutVars.buttonColor1
        let text = UITableViewRowAction(style: .normal, title: "Text") { action, index in
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                
                
                if (MFMessageComposeViewController.canSendText()) {
                    self.controller = MFMessageComposeViewController()
                    
                    self.controller.recipients = [currentCell.employee.phone]
                    self.controller.messageComposeDelegate = self
                    
                    self.controller.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                    self.controller.navigationBar.shadowImage = UIImage()
                    self.controller.navigationBar.isTranslucent = true
                  
                    self.controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EmployeeListViewController.dismissMessage))
                    self.controller.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blue]
                    self.present(self.controller, animated: true, completion: nil)
                    
                    tableView.setEditing(false, animated: true)
                }
                
            }
        }
        
        
        text.backgroundColor = UIColor.orange
        return [call,text]
       
    }
     
     
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // the cells you would like the actions to appear needs to be editable
     return true
     }
     
     
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     // you need to implement this method too or you can't swipe to display the actions
     }
    
    */
    
    @objc func refresh(_ sender: AnyObject){
        //print("refresh")
        //refreshFromTable = true
        getLeads()
        
    }
    
    
    
    
    @objc func addLead(){
        print("Add Lead")
        let editLeadViewController = NewEditLeadViewController()
        editLeadViewController.delegate = self
        navigationController?.pushViewController(editLeadViewController, animated: false )
    }
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

