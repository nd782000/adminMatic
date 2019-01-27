//
//  UsageListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
//import SwiftyJSON

 
class UsageListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var layoutVars:LayoutVars = LayoutVars()
    var workOrderItemID:String!
    var type:String!
    var indicator: SDevIndicator!
    
    var units:String!
    var total:String!
    var usageListTableView: TableView!
    //var usageJSON: JSON!
    var usages: [Usage] = []
    var usageTotalLbl: Label!
    let shortDateFormatter = DateFormatter()
    
    let tableHead:UIView! = UIView()
    let nameTH: THead = THead(text: "Employee")
    let dateTH: THead = THead(text: "Date")
    let qtyTH: THead = THead(text: "Qty.")
    let unitCostTH: THead = THead(text: "Cost")
    let totalCostTH: THead = THead(text: "Total")
    let receiptTH: THead = THead(text: "Rec.")
   
    init(_workOrderItemID:String,_units:String,_type:String){
        super.init(nibName:nil,bundle:nil)
        self.workOrderItemID = _workOrderItemID
        self.units = _units
        self.type = _type
        //self.total = _total
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = layoutVars.backgroundColor
        title = "Full Usage History"
        
         self.shortDateFormatter.dateFormat = "MM/dd"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(UsageListViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        
        
                
         getAllUsage()
        
    }
    
    
    
    
    func getAllUsage(){
        print("get all usage")
        
        self.indicator = SDevIndicator.generate(self.view)!
        
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
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        
                        let usages = json["usage"] as? [[String: Any]]{
                        
                        let usageCount = usages.count
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        self.total = json["total"] as! String
                        
                        for n in 0 ..< usageCount {
                            let startDate = dateFormatter.date(from: usages[n]["start"] as! String)!
                            
                            
                            let usage:Usage!
                            
                            
                            if(usages[n]["stop"] as! String != "0000-00-00 00:00:00"){
                                let stopDate = dateFormatter.date(from: usages[n]["stop"] as! String)!
                                
                                usage = Usage(_ID: usages[n]["ID"] as? String,
                                              _empID: usages[n]["empID"] as? String,
                                              _depID: usages[n]["depID"] as? String,
                                              _woID: usages[n]["woID"] as? String,
                                              _start: startDate,
                                              _stop: stopDate,
                                              _lunch: usages[n]["lunch"] as? String,
                                              _qty: usages[n]["qty"] as? String,
                                              _empName: usages[n]["empName"] as? String,
                                              _type: usages[n]["type"] as? String,
                                              _itemID: usages[n]["woItemID"] as? String,
                                              _unitPrice: usages[n]["unitPrice"] as? String,
                                              _totalPrice: usages[n]["totalPrice"] as? String,
                                              _vendor: usages[n]["vendor"] as? String,
                                              _unitCost: usages[n]["unitCost"] as? String,
                                              _totalCost: usages[n]["totalCost"] as? String,
                                              _chargeType: usages[n]["chargeID"] as? String,
                                              _override: usages[n]["override"] as? String,
                                              _empPic: usages[n]["empPic"] as? String,
                                              _locked: true,
                                              _addedBy: usages[n]["addedBy"] as? String,
                                              _del: ""
                                )
                                
                                if usages[n]["hasReceipt"] as? String == "1"{
                                    usage.hasReceipt = "1"
                                    /*
                                    usage.receipt = Image(_id: usages[n]["receipt"]["ID"] as? String, _thumbPath:"https://www.atlanticlawnandgarden.com/uploads/general/thumbs/\(usages[n]["receipt"]["fileName"] as? String)", _mediumPath: "https://www.atlanticlawnandgarden.com/uploads/general/medium/\(usages[n]["receipt"]["fileName"] as? String)", _rawPath: "https://www.atlanticlawnandgarden.com/uploads/general/\(usages[n]["receipt"]["fileName"] as? String)", _name: usages[n]["receipt"]["name"] as? String, _width: usages[n]["receipt"]["width"] as? String, _height: usages[n]["receipt"]["height"] as? String, _description: usages[n]["description"]["ID"] as? String, _dateAdded: usages[n]["receipt"]["dateAdded"] as? String, _createdBy: usages[n]["receipt"]["createdBy"] as? String, _type: usages[n]["receipt"]["type"] as? String)
 */
                                    
                                    
                                }else{
                                    usage.hasReceipt = "0"
                                }
                                
                            }else{
                                
                                usage = Usage(_ID: usages[n]["ID"] as? String,
                                              _empID: usages[n]["empID"] as? String,
                                              _depID: usages[n]["depID"] as? String,
                                              _woID: usages[n]["woID"] as? String,
                                              _start: startDate,
                                              _lunch: usages[n]["lunch"] as? String,
                                              _qty: usages[n]["qty"] as? String,
                                              _empName: usages[n]["empName"] as? String,
                                              _type: usages[n]["type"] as? String,
                                              _itemID: usages[n]["woItemID"] as? String,
                                              _unitPrice: usages[n]["unitPrice"] as? String,
                                              _totalPrice: usages[n]["totalPrice"] as? String,
                                              _vendor: usages[n]["vendor"] as? String,
                                              _unitCost: usages[n]["unitCost"] as? String,
                                              _totalCost: usages[n]["totalCost"] as? String,
                                              _chargeType: usages[n]["chargeID"] as? String,
                                              _override: usages[n]["override"] as? String,
                                              _empPic: usages[n]["empPic"] as? String,
                                              _locked: true,
                                              _addedBy: usages[n]["addedBy"] as? String,
                                              _del: ""
                                )
                                if usages[n]["hasReceipt"] as? String == "1"{
                                    usage.hasReceipt = "1"
                                }else{
                                    usage.hasReceipt = "0"
                                }
                                
                                
                            }
                            
                            self.usages.append(usage)
                        }
                        // Close Indicator
                        self.indicator.dismissIndicator()
                        
                        if self.type == "1"{
                            self.layoutLaborView()
                        }else{
                            self.layoutMaterialView()
                        }
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
                
                
                
            }
        }
    }
    
    
    func layoutLaborView(){
        //self.total = self.usageJSON["total"].stringValue
        
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        print("layoutLaborView")
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        safeContainer.addSubview(tableHead)
        
        self.usageListTableView =  TableView()
        self.usageListTableView.delegate  =  self
        self.usageListTableView.dataSource  =  self
        self.usageListTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.usageListTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.usageTotalLbl)
        
        
        
        tableHead.addSubview(nameTH)
        tableHead.addSubview(dateTH)
        tableHead.addSubview(qtyTH)
        
        
        self.usageTotalLbl.text = "Total: \(total!) \(self.units!)(s)"
        
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            
            "name":self.nameTH,
            "date":self.dateTH,
            "qty":self.qtyTH
            ] as [String:AnyObject]
        
        self.tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[name]-15-[date(75)]-[qty(100)]-5-|", options: [], metrics: metricsDictionary, views: thDictionary))
        self.tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[name(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        self.tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        self.tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[qty(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        let usageViewsDictionary = ["th":self.tableHead,"view1": self.usageListTableView,"view2": self.usageTotalLbl] as [String:Any]
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2]-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[th(40)][view1]-[view2(30)]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        
        self.usageListTableView.reloadData()
        
    }
    
    
    func layoutMaterialView(){
        //self.total = self.usageJSON["total"].stringValue
        
        print("layoutMaterialView")
        
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.layer.cornerRadius = 4.0
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        
        safeContainer.addSubview(tableHead)
        
        self.usageListTableView =  TableView()
        self.usageListTableView.delegate  =  self
        self.usageListTableView.dataSource  =  self
        self.usageListTableView.register(UsageTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.usageListTableView)
        
        self.usageTotalLbl = Label()
        self.usageTotalLbl.font =  UIFont.boldSystemFont(ofSize: 16.0)
        self.usageTotalLbl.textAlignment = NSTextAlignment.right
        safeContainer.addSubview(self.usageTotalLbl)
        
        
        
        tableHead.addSubview(dateTH)
        tableHead.addSubview(qtyTH)
        tableHead.addSubview(unitCostTH)
        tableHead.addSubview(totalCostTH)
        tableHead.addSubview(receiptTH)
        
        self.usageTotalLbl.text = "Total: \(total!) \(self.units!)(s)"
        print("layoutMaterialView 1")
        let metricsDictionary = ["fullWidth": self.view.frame.size.width - 30,"fullHeight":self.view.frame.size.height-126] as [String:Any]
        
        // Tablehead
        let thDictionary = [
            
            "date":self.dateTH,
            "qty":self.qtyTH,
            "cost":self.unitCostTH,
            "total":self.totalCostTH,
            "rec":self.receiptTH
            ] as [String:AnyObject]
        
        print("layoutMaterialView 2")
        self.tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[date(65)]-[qty(50)]-[cost(75)]-[total(100)]-[rec(50)]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: thDictionary))
        print("layoutMaterialView 3")
        self.tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(20)]", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        print("layoutMaterialView 4")
        let usageViewsDictionary = ["th":self.tableHead,"view1": self.usageListTableView,"view2": self.usageTotalLbl] as [String:Any]
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[th]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        print("layoutMaterialView 5")
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2]-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        print("layoutMaterialView 6")
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[th(40)][view1]-[view2(30)]|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        
        self.usageListTableView.reloadData()
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.usages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UsageTableViewCell = usageListTableView.dequeueReusableCell(withIdentifier: "cell") as! UsageTableViewCell
        if self.type == "1"{
            cell.layoutForLabor()
            cell.usageNameLbl.text = usages[indexPath.row].empName
            cell.usageDateLbl.text = self.shortDateFormatter.string(from: usages[indexPath.row].start!)
            cell.usageTotalLbl.text = "\(usages[indexPath.row].qty!) \(self.units!)(s)"
        }else{
            cell.layoutForMaterial()
            cell.usageDateLbl.text = self.shortDateFormatter.string(from: usages[indexPath.row].start!)
            cell.usageQtyLbl.text = "\(usages[indexPath.row].qty!) \(self.units!)(s)"
            cell.usageUnitCostLbl.text = "$\(usages[indexPath.row].unitCost!)"
            cell.usageTotalLbl.text = "$\(usages[indexPath.row].totalCost!)"
            if usages[indexPath.row].hasReceipt == "1"{
                //cell.usageReceiptLbl.text = usages[indexPath.row].
                 cell.setCheck()
            }else{
                cell.unSetCheck()
            }
            
            
            
            
        }
        
        cell.selectionStyle = .none
        //cell.setStatus(status: usages[indexPath.row].woStatus!)
        
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        /*
        let currentCell = tableView.cellForRow(at: indexPath) as! UsageTableViewCell
        let customerViewController = CustomerViewController(_customerID: currentCell.id,_customerName: currentCell.name)
        customerViewController.customerListDelegate = self
        navigationController?.pushViewController(customerViewController, animated: false )
        */
        
        /*
        if usages[indexPath.row].hasReceipt == "1"{
            let imageFullViewController = ImageFullViewController(_image: usages[indexPath.row].receipt!)
            self.navigationController?.pushViewController(imageFullViewController, animated: false )
         //   tableView.deselectRow(at: indexPath, animated: true)
        }
        */
        
        
        
        
        
        
        
    }
    
    
   
    
    @objc func goBack(){
        
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
