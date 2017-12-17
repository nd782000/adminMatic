//
//  UsageListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class UsageListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    
    var layoutVars:LayoutVars = LayoutVars()
    var workOrderItemID:String!
    var units:String!
    var total:String!
    var usageListTableView: TableView!
    var usageJSON: JSON!
    var usages: [Usage] = []
    var usageTotalLbl: Label!
    let shortDateFormatter = DateFormatter()
    
    let tableHead:UIView! = UIView()
    let nameTH: THead = THead(text: "Employee")
    let dateTH: THead = THead(text: "Date")
    let qtyTH: THead = THead(text: "Qty.")
   
    init(_workOrderItemID:String,_units:String){
        super.init(nibName:nil,bundle:nil)
        self.workOrderItemID = _workOrderItemID
        self.units = _units
        //self.total = _total
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = layoutVars.backgroundColor
        title = "Full Usage History"
        
         self.shortDateFormatter.dateFormat = "MM/dd/yy"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(UsageListViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        tableHead.addSubview(nameTH)
        tableHead.addSubview(dateTH)
        tableHead.addSubview(qtyTH)
        self.view.addSubview(tableHead)
        
        self.usageListTableView =  TableView()
        self.usageListTableView.delegate  =  self
        self.usageListTableView.dataSource  =  self
        self.usageListTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.usageListTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        self.view.addSubview(self.usageTotalLbl)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        
        
                
         getAllUsage()
        
    }
    
    
    
    
    func getAllUsage(){
        print("get all usage")
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.usage(["woItemID":self.workOrderItemID as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
            print("response = \(response)")
            if let json = response.result.value {
                print("usage JSON: \(json)")
                self.usageJSON = JSON(json)
                self.parseUsageJSON()
                
            }
        }
    }
    
    func parseUsageJSON(){
        
        
        print("parse usageJSON: \(self.usageJSON)")
        
        
        let usageCount = self.usageJSON["usage"].count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        for n in 0 ..< usageCount {
            let startDate = dateFormatter.date(from: self.usageJSON["usage"][n]["start"].string!)!
            
            
            let usage:Usage!
            
            
            if(self.usageJSON["usage"][n]["stop"].string != "0000-00-00 00:00:00"){
                let stopDate = dateFormatter.date(from: self.usageJSON["usage"][n]["stop"].string!)!
                
                usage = Usage(_ID: self.usageJSON["usage"][n]["ID"].stringValue,
                                  _empID: self.usageJSON["usage"][n]["empID"].stringValue,
                                  _depID: self.usageJSON["usage"][n]["depID"].stringValue,
                                  _woID: self.usageJSON["usage"][n]["woID"].stringValue,
                                  _start: startDate,
                                  _stop: stopDate,
                                  _lunch: self.usageJSON["usage"][n]["lunch"].stringValue,
                                  _qty: self.usageJSON["usage"][n]["qty"].stringValue,
                                  _empName: self.usageJSON["usage"][n]["empName"].stringValue,
                                  _type: self.usageJSON["usage"][n]["type"].stringValue,
                                  _itemID: self.usageJSON["usage"][n]["woItemID"].stringValue,
                                  _unitPrice: self.usageJSON["usage"][n]["unitPrice"].stringValue,
                                  _totalPrice: self.usageJSON["usage"][n]["totalPrice"].stringValue,
                                  _vendor: self.usageJSON["usage"][n]["vendor"].stringValue,
                                  _unitCost: self.usageJSON["usage"][n]["unitCost"].stringValue,
                                  _totalCost: self.usageJSON["usage"][n]["totalCost"].stringValue,
                                  _chargeType: self.usageJSON["usage"][n]["chargeID"].stringValue,
                                  _override: self.usageJSON["usage"][n]["override"].stringValue,
                                  _empPic: self.usageJSON["usage"][n]["empPic"].stringValue,
                                  _locked: true,
                                  _addedBy: self.usageJSON["usage"][n]["addedBy"].stringValue,
                                  _del: ""
                )
                
            }else{
                
                usage = Usage(_ID: self.usageJSON["usage"][n]["ID"].stringValue,
                                  _empID: self.usageJSON["usage"][n]["empID"].stringValue,
                                  _depID: self.usageJSON["usage"][n]["depID"].stringValue,
                                  _woID: self.usageJSON["usage"][n]["woID"].stringValue,
                                  _start: startDate,
                                  _lunch: self.usageJSON["usage"][n]["lunch"].stringValue,
                                  _qty: self.usageJSON["usage"][n]["qty"].stringValue,
                                  _empName: self.usageJSON["usage"][n]["empName"].stringValue,
                                  _type: self.usageJSON["usage"][n]["type"].stringValue,
                                  _itemID: self.usageJSON["usage"][n]["woItemID"].stringValue,
                                  _unitPrice: self.usageJSON["usage"][n]["unitPrice"].stringValue,
                                  _totalPrice: self.usageJSON["usage"][n]["totalPrice"].stringValue,
                                  _vendor: self.usageJSON["usage"][n]["vendor"].stringValue,
                                  _unitCost: self.usageJSON["usage"][n]["unitCost"].stringValue,
                                  _totalCost: self.usageJSON["usage"][n]["totalCost"].stringValue,
                                  _chargeType: self.usageJSON["usage"][n]["chargeID"].stringValue,
                                  _override: self.usageJSON["usage"][n]["override"].stringValue,
                                  _empPic: self.usageJSON["usage"][n]["empPic"].stringValue,
                                  _locked: true,
                                  _addedBy: self.usageJSON["usage"][n]["addedBy"].stringValue,
                                  _del: ""
                )
                
                
            }

            self.usages.append(usage)
        }
        self.total = self.usageJSON["total"].stringValue
        self.usageTotalLbl.text = "Total: \(self.total!) \(self.units!)(s)"
        
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            
            "name":nameTH,
            "date":dateTH,
            "qty":qtyTH
            ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[name]-15-[date(75)]-[qty(100)]-5-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[name(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[qty(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        let usageViewsDictionary = ["th":self.tableHead,"view1": self.usageListTableView,"view2": self.usageTotalLbl] as [String:Any]
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[th]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(fullWidth)]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view1(fullWidth)]-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-77-[th(40)][view1]-[view2(30)]-15-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        

        self.usageListTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.usages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UsageTableViewCell = usageListTableView.dequeueReusableCell(withIdentifier: "cell") as! UsageTableViewCell
        
         cell.layoutForHistory()
        
        cell.usageNameLbl.text = usages[indexPath.row].empName
        
        
        cell.usageDateLbl.text = self.shortDateFormatter.string(from: usages[indexPath.row].start!)
        
        
        print("usages[indexPath.row].qty = \(String(describing: usages[indexPath.row].qty))")
        print("self.units = \(self.units)")
        cell.usageTotalLbl.text = "\(usages[indexPath.row].qty!) \(self.units!)(s)"
        
        //cell.setStatus(status: usages[indexPath.row].woStatus!)
        
        
        return cell;
    }
   
    
    @objc func goBack(){
        
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
