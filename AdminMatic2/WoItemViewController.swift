//
//  WoItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol WoItemDelegate{
    func refreshWoItem()
}

 
class WoItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WoItemDelegate, AttachmentDelegate, EditLeadDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var indicator: SDevIndicator!
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var woDelegate:WoDelegate!
    var leadDelegate:EditLeadDelegate!
    
    var woID:String!
    var woItem:WoItem2!
    var empsOnWo:[Employee2]!
    
    var itemView:UIView!
    var itemNameView:UIView!
    var itemLbl:GreyLabel!
    
    var chargeTypeView:UIView!
    var chargeTypeLabel:Label!
    var chargeTypeValueLabel:Label!
    var totalLabel:Label!
    var taxLabel:Label!
    var totalValueLabel:Label!
    
    var estimatedView:UIView!
    var estLabel:Label!
    var estValueLabel:Label!
    var actualLabel:Label!
    var actualValueLabel:Label!
    var remainLabel:Label!
    var remainValueLabel:Label!
    
    
    var profitView:UIView!
    
    var costLabel:Label!
    var costValueLabel:Label!
    
    var profitLabel:Label!
    var profitValueLabel:Label!
    
    
    var profitBarView:UIView!
    var incomeView:UIView!
    var costView:UIView!
    
    
    
    var usageView:UIView!
    var usageBtn:UIButton!

    //details view
    var detailsView:UIView!
    
    var itemDetailsTableView:TableView!
    
    
    var newWoStatus:String!
    var tasksJson:JSON?
    
    var customerID:String = ""
    var customerName:String = ""
    
    
    var saleRepName:String = ""
    
    
    var json:JSON!
    
    var lead:Lead2?
    var leadTasksWaiting:String?
    var leadTasksWaitingBtn:Button = Button(titleText: "Open LeadTasks to Assign...")
    
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    
    
    var editsMade:Bool = false
    
    var usageEntryViewController:UsageEntryViewController?
    
    init(_woID:String,_woItem:WoItem2,_empsOnWo:[Employee2],_woStatus:String){
        super.init(nibName:nil,bundle:nil)
        self.woID = _woID
        self.woItem = _woItem
        self.empsOnWo = _empsOnWo
        self.newWoStatus = _woStatus
        
        print("woItem view init chargeID = \(self.woItem.charge)")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "W.O. Item #" + self.woItem.ID
        
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
    }
    
    
    func getWoItem(woItemID:String){
        print("getWoItem \(String(describing: self.woItem.ID))")
        
        
            indicator = SDevIndicator.generate(self.view)!
            
            self.woItem.usages = []
            self.woItem.tasks = []
            
            var parameters:[String:String]
            parameters = [
                "woItemID": "\(woItemID)"
                
            ]
            
            print("parameters = \(parameters)")
            
            
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/workOrderItem.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("woItem response = \(response)")
                }
                .responseJSON { response in
                    print("woItem json response = \(response)")
                    
                    
                    
                    
                    do{
                        //created the json decoder
                        
                        let json = response.data
                        let decoder = JSONDecoder()
                        let parsedData = try decoder.decode(WoItem2.self, from: json!)
                        print("parsedData = \(parsedData)")
                        
                        self.woItem = parsedData
                        print("woItem.usage = \(String(describing: self.woItem.usages))")
                        
                        for task in self.woItem.tasks!{
                            for image in task.images!{
                                image.setImagePaths()
                            }
                            
                        }
                        
                        
                        
                       
                        
                        
                        
                        
                        let usageCount = self.woItem.usages!.count
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        for n in 0 ..< usageCount {
                            
                            print("self.woItem.usages![n].startString = \(String(describing: self.woItem.usages![n].startString))")
                             print("self.woItem.usages![n].stopString = \(String(describing: self.woItem.usages![n].stopString))")
                            
                            //set Start and Stop Dates
                            if self.woItem.usages![n].startString != nil &&  self.woItem.usages![n].startString != "0000-00-00 00:00:00"{
                                self.woItem.usages![n].start = dateFormatter.date(from: self.woItem.usages![n].startString!)!
                            }
                            if self.woItem.usages![n].stopString != nil &&  self.woItem.usages![n].stopString != "0000-00-00 00:00:00"{
                                self.woItem.usages![n].stop = dateFormatter.date(from: self.woItem.usages![n].stopString!)!
                            }
                            
                            //set chargeType
                            self.woItem.usages![n].chargeType = self.woItem.charge
                           
                            //set Locked
                            if(Double(self.woItem.usages![n].qty!)! > 0.0 && self.woItem.usages![n].addedBy != self.appDelegate.loggedInEmployee?.ID){
                                self.woItem.usages![n].locked = true
                            }else{
                                self.woItem.usages![n].locked = false
                            }
                          
                        }
                        
                        
                        
                        
                        if self.usageEntryViewController != nil{
                            self.usageEntryViewController?.woItem = self.woItem
                            self.usageEntryViewController?.addActiveUsage()
                        }
                        
                        self.indicator.dismissIndicator()
                        self.layoutViews()
                        
                        
                    }catch let err{
                        print(err)
                    }
                    
            }
        
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func layoutViews(){
        //print("item view layoutViews \(woItem.usageQty)")
        //////////   containers for different sections
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        self.itemView = UIView()
        self.itemView.backgroundColor = layoutVars.backgroundColor
        self.itemView.layer.borderColor = layoutVars.borderColor
        self.itemView.layer.borderWidth = 1.0
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.itemView)
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.detailsView)
        
        
        
        ////print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemView,
        "view2":self.detailsView] as [String:AnyObject]
        
        let sizeVals = ["width": layoutVars.fullWidth as AnyObject,"height": 24  as AnyObject,"fullHeight":layoutVars.fullHeight - 224  as AnyObject]  as [String:AnyObject]
        
        //////////////////   auto layout position constraints   /////////////////////////////
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(165)][view2(fullHeight)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        ///////////   wo item header section   /////////////
        
        //name
        self.itemNameView = UIView()
        self.itemNameView.backgroundColor = layoutVars.backgroundColor
        self.itemNameView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.itemNameView)
        
        
        self.chargeTypeView = UIView()
        self.chargeTypeView.backgroundColor = layoutVars.backgroundColor
        self.chargeTypeView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.chargeTypeView)
        
        self.estimatedView = UIView()
        self.estimatedView.backgroundColor = layoutVars.backgroundColor
        self.estimatedView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.estimatedView)
        
        self.profitView = UIView()
        self.profitView.backgroundColor = layoutVars.backgroundColor
        self.profitView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.profitView)
        
        self.usageView = UIView()
        self.usageView.backgroundColor = layoutVars.backgroundColor
        self.usageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.usageView)
    
        let containersViewsDictionary = [
            "itemNameView":self.itemNameView,
            "chargeTypeView":self.chargeTypeView,
            "estimatedView":self.estimatedView,
            "profitView":self.profitView,
            "usageView":self.usageView
        ]  as [String:AnyObject]
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[itemNameView(width)]", options: [], metrics: sizeVals, views: containersViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[chargeTypeView(width)]", options: [], metrics: sizeVals, views: containersViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[estimatedView(width)]", options: [], metrics: sizeVals, views: containersViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[profitView(width)]", options: [], metrics: sizeVals, views: containersViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[usageView(width)]", options: [], metrics: sizeVals, views: containersViewsDictionary))
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[itemNameView(40)][chargeTypeView(25)][estimatedView(25)][profitView(25)][usageView(50)]", options: [], metrics: sizeVals, views: containersViewsDictionary))

        self.itemLbl = GreyLabel()
        self.itemLbl.text = self.woItem.item
        self.itemLbl.font = layoutVars.labelFont
        self.itemNameView.addSubview(self.itemLbl)
        
        let itemNameViewsDictionary = ["itemLbl":self.itemLbl]  as [String:AnyObject]
        

        self.itemNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[itemLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: sizeVals, views: itemNameViewsDictionary))
        
        self.itemNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(30)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        
        //charge Info
        self.chargeTypeLabel = Label()
        self.chargeTypeLabel.text = "Charge Type:"
        self.chargeTypeView.addSubview(self.chargeTypeLabel)
        
       // let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        
        self.chargeTypeValueLabel = Label()
        self.chargeTypeValueLabel.text = self.woItem.chargeName
        self.chargeTypeView.addSubview(self.chargeTypeValueLabel)
        
        self.totalLabel = Label()
        self.totalLabel.text = "Total:"
        self.chargeTypeView.addSubview(self.totalLabel)
    
        self.totalValueLabel = Label()
        self.totalValueLabel.text = "$\(self.woItem.total)"
        self.chargeTypeView.addSubview(self.totalValueLabel)
        
        self.taxLabel = Label()
        if woItem.tax == "1"{
            self.taxLabel.text = "Taxable"
        }else{
            self.taxLabel.text = "Non-Taxable"
        }
        
        self.chargeTypeView.addSubview(self.taxLabel)
        
        let chargeViewsDictionary = [
            "chargeTypeLabel":self.chargeTypeLabel,
            "chargeTypeValueLabel":self.chargeTypeValueLabel,
            "totalLabel":self.totalLabel,
            "totalValueLabel":self.totalValueLabel,
            "taxLabel":self.taxLabel
        ]  as [String:AnyObject]
        
        self.chargeTypeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[chargeTypeLabel][chargeTypeValueLabel]-[totalLabel][totalValueLabel]-[taxLabel]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: sizeVals, views: chargeViewsDictionary))
        self.chargeTypeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[chargeTypeLabel(20)]", options: [], metrics: sizeVals, views: chargeViewsDictionary))
        
        
        
        //Estimated Info
    
        
        self.estLabel = Label()
        self.estLabel.text = "Est: "
        self.estimatedView.addSubview(self.estLabel)
        
        
        self.estValueLabel = Label()
        self.estValueLabel.text = self.woItem.est
        self.estimatedView.addSubview(self.estValueLabel)
        
        self.actualLabel = Label()
        self.actualLabel.text = "Act: "
        self.estimatedView.addSubview(self.actualLabel)
        
        
        self.actualValueLabel = Label()
        self.actualValueLabel.text = self.woItem.usageQty
        self.estimatedView.addSubview(self.actualValueLabel)
        
        
        
        self.remainLabel = Label()
        self.remainLabel.text = "Remaining: "
        self.estimatedView.addSubview(self.remainLabel)
        
        
        var remainingValue = Float(self.woItem.est!)! - Float(self.woItem.usageQty!)!
        
        if(remainingValue < 0){
            remainingValue = 0.00
        }
        
        self.remainValueLabel = Label()
        self.remainValueLabel.text = String(format: "%.2f", remainingValue)
        self.estimatedView.addSubview(self.remainValueLabel)
        
        let estimatedViewsDictionary = [
            "estLabel":self.estLabel,
            "estValueLabel":self.estValueLabel,
            "actualLabel":self.actualLabel,
            "actualValueLabel":self.actualValueLabel,
            "remainLabel":self.remainLabel,
            "remainValueLabel":self.remainValueLabel
        ]  as [String:AnyObject]
        
        self.estimatedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[estLabel][estValueLabel]-[actualLabel][actualValueLabel]-[remainLabel][remainValueLabel]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: sizeVals, views: estimatedViewsDictionary))
        self.estimatedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[estLabel(20)]", options: [], metrics: sizeVals, views: estimatedViewsDictionary))
        self.estimatedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[remainLabel(20)]", options: [], metrics: sizeVals, views: estimatedViewsDictionary))
        
        
        //Profit Info
        
        // profit bar vars
        let profitBarWidth = Float(100.00)
        
      
        
        let income = Float(self.woItem.total)
        let cost = Float(self.woItem.totalCost!)
        
        var scaleFactor = Float(0.00)
        var costWidth = Float(0.00)
        
        if(Float(income!) > 0.0){
            //print("greater")
            scaleFactor = Float(Float(profitBarWidth) / Float(income!))
            costWidth = cost! * scaleFactor
            if(costWidth > profitBarWidth){
                costWidth = profitBarWidth
            }
        }else{
            costWidth = profitBarWidth
        }
        
        
        let costBarOffset = profitBarWidth - costWidth
        
        //print("income = \(income!)")
        //print("cost = \(cost!)")
        //print("scaleFactor = \(scaleFactor)")
        //print("costWidth = \(costWidth)")
        //print("profitBarWidth = \(profitBarWidth)")
        //print("costBarOffset = \(costBarOffset)")
        
        self.costLabel = Label()
        self.costLabel.text = "Cost: "
        self.profitView.addSubview(self.costLabel)
        
        
        self.costValueLabel = Label()
        self.costValueLabel.text = "$\(self.woItem.totalCost!)"
        self.profitView.addSubview(self.costValueLabel)

    
        self.profitLabel = Label()
        self.profitLabel.text = "Profit: "
        self.profitView.addSubview(self.profitLabel)
        
        
        self.profitValueLabel = Label()
        self.profitValueLabel.text = "$\(String(format: "%.2f", income! - cost!))"
        self.profitView.addSubview(self.profitValueLabel)
        
    
        self.profitBarView = UIView()
        self.profitBarView.backgroundColor = UIColor.gray
        self.profitBarView.layer.borderColor = layoutVars.borderColor
        self.profitBarView.layer.borderWidth = 1.0
        self.profitBarView.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(self.profitBarView)
        
        
        //profit label goes here
        
        let profitViewsDictionary = [
            "costLabel":self.costLabel, "costValueLabel":self.costValueLabel,"profitLabel":self.profitLabel, "profitValueLabel":self.profitValueLabel,"profitBarView":self.profitBarView
            
        ]  as [String:AnyObject]
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[costLabel][costValueLabel]-[profitLabel][profitValueLabel]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: sizeVals, views: profitViewsDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[profitLabel(20)]", options: [], metrics: sizeVals, views: profitViewsDictionary))
        
        
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[profitBarView]-10-|", options: [], metrics: sizeVals, views: profitViewsDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[profitBarView(10)]", options: [], metrics: sizeVals, views: profitViewsDictionary))
        
        
        
        incomeView = UIView()
        incomeView.layer.cornerRadius = 5
        incomeView.layer.masksToBounds = true
        incomeView.backgroundColor = layoutVars.buttonColor1
        incomeView.translatesAutoresizingMaskIntoConstraints = false
        self.profitBarView.addSubview(self.incomeView)
        
        costView = UIView()
        costView.layer.cornerRadius = 5
        costView.layer.masksToBounds = true
        costView.backgroundColor = UIColor.red
        costView.translatesAutoresizingMaskIntoConstraints = false
        self.profitBarView.addSubview(self.costView)
        
        
        let profitBarViewsDictionary = [
            
            "incomeView":self.incomeView,
            "costView":self.costView
        ]  as [String:AnyObject]
        
        let profitBarSizeVals = ["profitBarWidth":profitBarWidth as AnyObject,"costWidth":costWidth as AnyObject,"costBarOffset":costBarOffset as AnyObject]  as [String:AnyObject]
        
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[incomeView(profitBarWidth)]|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[costView(costWidth)]-costBarOffset-|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[incomeView(10)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[costView(10)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        
        self.usageBtn = Button(titleText: "Add Usage")
        self.usageBtn.backgroundColor = UIColor(hex:0xE09E43, op:1)
        let usageIcon:UIImageView = UIImageView()
        usageIcon.backgroundColor = UIColor.clear
        usageIcon.contentMode = .scaleAspectFill
        usageIcon.frame = CGRect(x: (layoutVars.fullWidth/2)-84, y: 10, width: 20, height: 20)
        let usageImg = UIImage(named:"clockIcon.png")
        usageIcon.image = usageImg
        self.usageBtn.addSubview(usageIcon)
        self.usageView.addSubview(usageBtn)
        
        //just a temp hook up to usage view controller
        self.usageBtn.addTarget(self, action: #selector(WoItemViewController.enterUsage), for: UIControl.Event.touchUpInside)
        
        
        let usageViewsDictionary = [
            "usageBtn":self.usageBtn
        ]  as [String:AnyObject]
        
        
        self.usageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[usageBtn]-10-|", options: [], metrics: sizeVals, views: usageViewsDictionary))
        
        self.usageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[usageBtn(40)]", options: [], metrics: sizeVals, views: usageViewsDictionary))
        
        ///////////   Item Details Section   /////////////
        
        self.leadTasksWaitingBtn.addTarget(self, action: #selector(ContractItemViewController.assignLeadTasks), for: UIControl.Event.touchUpInside)
        self.detailsView.addSubview(self.leadTasksWaitingBtn)
        
        self.itemDetailsTableView = TableView()
        self.itemDetailsTableView.delegate  =  self
        self.itemDetailsTableView.dataSource = self
        
        self.itemDetailsTableView.rowHeight = UITableView.automaticDimension
        self.itemDetailsTableView.estimatedRowHeight = 100.0
        
        
        self.itemDetailsTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "cell")
        self.detailsView.addSubview(itemDetailsTableView)
        
        
        if self.leadTasksWaiting! == "1" && self.woItem.type == "1"{
            showLeadTaskBtn()
        }else{
            hideLeadTaskBtn()
        }
        
    }
    
    
    func showLeadTaskBtn(){
        print("showLeadTaskBtn")
        self.detailsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.detailsView.addSubview(self.leadTasksWaitingBtn)
        self.detailsView.addSubview(itemDetailsTableView)
        
        //auto layout group
        let itemDetailsViewsDictionary = [
            "view1":leadTasksWaitingBtn,
            "view2":itemDetailsTableView
            ]  as [String:AnyObject]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)][view2]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        
    }
    
    func hideLeadTaskBtn(){
        print("hideLeadTaskBtn")
        self.detailsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.detailsView.addSubview(itemDetailsTableView)
        
        let itemDetailsViewsDictionary = [
            "view1":itemDetailsTableView
            ]  as [String:AnyObject]
        
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
    }
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        count = self.woItem.tasks!.count + 1
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! TaskTableViewCell
        cell.prepareForReuse()
        
        
        if(indexPath.row == self.woItem.tasks!.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            
            cell.task = self.woItem.tasks![indexPath.row]
            cell.layoutViews()
            cell.taskLbl.text = self.woItem.tasks![indexPath.row].task
            
            
            
            
            if(self.woItem.tasks![indexPath.row].images!.count == 0){
                cell.imageQtyLbl.text = "No Images"
            }else{
                if(self.woItem.tasks![indexPath.row].images!.count == 1){
                    cell.imageQtyLbl.text = "1 Image"
                    
                }else{
                    cell.imageQtyLbl.text = "\(self.woItem.tasks![indexPath.row].images!.count) Images"
                }
            }
 
            
            
            
            
            cell.setStatus(status: self.woItem.tasks![indexPath.row].status)
            
            print("image count = \(self.woItem.tasks![indexPath.row].images!.count)")
            
            if(self.woItem.tasks![indexPath.row].images!.count > 0){
                print("image path = \(String(describing: self.woItem.tasks![indexPath.row].images![0].thumbPath))")
                cell.activityView.startAnimating()
                
                self.woItem.tasks![indexPath.row].images![0].setImagePaths()
                
                if self.woItem.tasks![indexPath.row].images![0].thumbPath != nil{
                    cell.setImageUrl(_url: "\(self.woItem.tasks![indexPath.row].images![0].thumbPath!)")
                }
                
            }else{
                print("set blank image")
                cell.setBlankImage()
            }
            
        }
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //////print("You selected cell #\(indexPath.row)!")
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
        if(indexPath.row == self.woItem.tasks!.count){
            self.addTask()
        }else{
            imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _taskID: self.woItem.tasks![indexPath.row].ID, _customerID: self.customerID, _images: self.woItem.tasks![indexPath.row].images!)
            
            
           // let ID = self.woItem.tasks![indexPath.row].ID
            //imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _taskID: ID, _customerID: self.customerID, _images: self.woItem.tasks![indexPath.row].images!)
            //imageUploadPrepViewController.images = self.woItem.tasks![indexPath.row].images!
            imageUploadPrepViewController.layoutViews()
            imageUploadPrepViewController.groupDescriptionTxt.text = self.woItem.tasks![indexPath.row].task
            imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
            imageUploadPrepViewController.taskStatus = self.woItem.tasks![indexPath.row].status
            imageUploadPrepViewController.selectedID = self.customerID
            imageUploadPrepViewController.woID = self.woID
            imageUploadPrepViewController.groupImages = true
            imageUploadPrepViewController.attachmentDelegate = self
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
 
            
            
            
        }
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
  
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let ID = self.woItem.tasks![indexPath.row].ID
        var newItemStatus:String?
        
        //indexPath
        let none = UITableViewRowAction(style: .normal, title: "None") { action, index in
            //print("none button tapped")
            self.woItem.tasks![indexPath.row].status = "1"
            newItemStatus = self.setTaskStatus(_ID: ID!, _status: "1", _row: indexPath.row)
            
        }
        none.backgroundColor = UIColor.gray
        let progress = UITableViewRowAction(style: .normal, title: "Prog.") { action, index in
            //print("progress button tapped")
            self.woItem.tasks![indexPath.row].status = "2"
            newItemStatus = self.setTaskStatus(_ID: ID!, _status: "2", _row: indexPath.row)
            self.showImageActionSheet(_ID: ID!, _row: indexPath.row)
        }
        progress.backgroundColor = UIColor.orange
        
        let done = UITableViewRowAction(style: .normal, title: "Done") { action, index in
            //print("done button tapped")
            self.woItem.tasks![indexPath.row].status = "3"
            newItemStatus = self.setTaskStatus(_ID: ID!, _status: "3", _row: indexPath.row)
            self.showImageActionSheet(_ID: ID!, _row: indexPath.row)
        }
        done.backgroundColor = layoutVars.buttonColor1
        
        let cancel = UITableViewRowAction(style: .normal, title: "Cancel") { action, index in
            //print("cancel button tapped")
            self.woItem.tasks![indexPath.row].status = "4"
            newItemStatus = self.setTaskStatus(_ID: ID!, _status: "4", _row: indexPath.row)
        }
        cancel.backgroundColor = UIColor.red
        
        //print("newItemStatus! = \(newItemStatus!)")
        
        
       //self.woItem.status = newItemStatus!
        return [cancel, done, progress, none]
    }
    
   
    
    
    
    
    func setTaskStatus(_ID:String,_status:String,_row:Int)->String{
        self.woItem.tasks![_row].status = _status
        self.itemDetailsTableView.reloadData()
        editsMade = true
        var newItemStatus:String = "1"
        var parameters:[String:String]
        parameters = [
            "taskID":_ID,
            "status":_status,
            "empID":(self.appDelegate.loggedInEmployee?.ID)!,
            "woItemID":self.woItem.ID,
            "woID":self.woID
            
        ]
        
        print("parameters = \(parameters)")
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/taskStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            if let json = response.result.value {
                print("JSON: \(json)")
                
                newItemStatus = JSON(json)["newItemStatus"].stringValue
                self.newWoStatus = JSON(json)["newWoStatus"].stringValue
            }
            }.responseString { response in
                //print("response = \(response)")
        }
        return newItemStatus
    }
    
    func showImageActionSheet(_ID:String, _row:Int){
        print("photo action sheet")
        //photos for done action
        
        let actionSheet = UIAlertController(title: "Add image(s) of completed work ", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.view.backgroundColor = UIColor.white
        actionSheet.view.layer.cornerRadius = 5;
        
        actionSheet.addAction(UIAlertAction(title: "Add Task Image(s)", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _taskID: _ID, _customerID: self.customerID, _images: [])
            imageUploadPrepViewController.customerName = self.customerName
            imageUploadPrepViewController.selectedID = self.customerID
            imageUploadPrepViewController.taskStatus = self.woItem.tasks![_row].status
            imageUploadPrepViewController.layoutViews()
            imageUploadPrepViewController.groupDescriptionTxt.text = self.woItem.tasks![_row].task
            imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
            imageUploadPrepViewController.woID = self.woID
            imageUploadPrepViewController.groupImages = true
            imageUploadPrepViewController.attachmentDelegate = self
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
            imageUploadPrepViewController.addImages()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
        }))
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
            
            break
        // It's an iPhone
        case .pad:
            let nav = UINavigationController(rootViewController: actionSheet)
            nav.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover:UIPopoverPresentationController = nav.popoverPresentationController! 
            
            //let popover = nav.popoverPresentationController as! UIPopoverPresentationController
            actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
            
            self.layoutVars.present(nav, animated: true, completion: nil)
            break
        // It's an iPad
        case .unspecified:
            break
        default:
            self.layoutVars.present(actionSheet, animated: true, completion: nil)
            break
            
            // Uh, oh! What could it be?
        }
        
        
    }
     
    
    func addTask(){
        print("add task")
        
        
        if(self.woItem.charge == "2"){
            var message:String = ""
            if(self.saleRepName != "No Rep"){
                message = "Contact sales rep: \(self.saleRepName) or the office to add tasks to this item."
            }else{
                message = "Contact the office to add tasks to this item."
            }
            let alertController = UIAlertController(title: "Flat Price Item", message: message, preferredStyle: UIAlertController.Style.alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            return
        }

        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _taskID: "0", _customerID: self.customerID, _images: [])
        
        imageUploadPrepViewController.selectedID = self.woItem.ID
        imageUploadPrepViewController.customerID = self.customerID
        imageUploadPrepViewController.layoutViews()
        
        imageUploadPrepViewController.woID = self.woID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.attachmentDelegate = self
        
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    
    
    
    
    func updateTable(_points:Int){
        print("updateTable")
        //getTasks()
        
        
        self.getWoItem(woItemID: self.woItem.ID)
    }

    
    
    
    /*
    func getTasks(){
        print("get tasks")
        
        
        editsMade = true
        
        /*
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        */
        
        let parameters:[String:String]
        parameters = ["woItemID": self.woItem.ID]
        
        print("parameters = \(parameters)")
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/tasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("get tasks response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                
                
                
                
                
                
                do{
                    //created the json decoder
                    
                    let json = response.data
                    let decoder = JSONDecoder()
                    let parsedData = try decoder.decode(WoItem2.self, from: json!)
                    print("parsedData = \(parsedData)")
                    
                    self.woItem = parsedData
                    print("woItem.usage = \(String(describing: self.woItem.usages))")
                    self.indicator.dismissIndicator()
                    
                    
                    
                    
                    let usageCount = self.woItem.usages!.count
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    for n in 0 ..< usageCount {
                        //let startDate:Date
                        
                        print("self.woItem.usages![n].startString = \(String(describing: self.woItem.usages![n].startString))")
                        print("self.woItem.usages![n].stopString = \(String(describing: self.woItem.usages![n].stopString))")
                        
                        //set Start and Stop Dates
                        if self.woItem.usages![n].startString != nil &&  self.woItem.usages![n].startString != "0000-00-00 00:00:00"{
                            self.woItem.usages![n].start = dateFormatter.date(from: self.woItem.usages![n].startString!)!
                        }
                        if self.woItem.usages![n].stopString != nil &&  self.woItem.usages![n].stopString != "0000-00-00 00:00:00"{
                            self.woItem.usages![n].stop = dateFormatter.date(from: self.woItem.usages![n].stopString!)!
                        }
                        
                        //set chargeType
                        self.woItem.usages![n].chargeType = self.woItem.charge
                        
                        //set Locked
                        if(Double(self.woItem.usages![n].qty!)! > 0.0 && self.woItem.usages![n].addedBy != self.appDelegate.loggedInEmployee?.ID){
                            self.woItem.usages![n].locked = true
                        }else{
                            self.woItem.usages![n].locked = false
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    self.layoutViews()
                    
                    if self.usageEntryViewController != nil{
                        self.usageEntryViewController?.woItem = self.woItem
                        self.usageEntryViewController?.addActiveUsage()
                    }
                }catch let err{
                    print(err)
                }

                
                
                
                
                
                
                /*
                
                print(response.request ?? "")  // original URL request
                print(response.response ?? "") // URL response
                print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("Tasks Json = \(json)")
                    self.tasksJson = JSON(json)
                    
                    let ts = self.tasksJson?["tasks"]
                    
                    self.woItem.tasks! = []
                    print("Task Count = \(String(describing: ts?.count))")
                    
                    for n in 0 ..< Int((ts?.count)!) {
                        var taskImages:[Image]  = []
                        let imageCount = Int((ts?[n]["images"].count)!)
                        print("imageCount: \(imageCount)")
                        
                        
                        for i in 0 ..< imageCount {
                            
                            let fileName:String = (ts?[n]["images"][i]["fileName"].stringValue)!
                            
                            let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                            let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                            let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                            
                            //create a item object
                            print("create an image object \(i)")
                            
                            print("rawPath = \(rawPath)")
                            
                            let image = Image(_id: ts?[n]["images"][i]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: ts?[n]["images"][i]["name"].stringValue,_width: ts?[n]["images"][i]["width"].stringValue,_height: ts?[n]["images"][i]["height"].stringValue,_description: ts?[n]["images"][i]["description"].stringValue,_dateAdded: ts?[n]["images"][i]["dateAdded"].stringValue,_createdBy: ts?[n]["images"][i]["createdByName"].stringValue,_type: ts?[n]["images"][i]["type"].stringValue)
                            
                            image.customer = (ts?[n]["images"][i]["customer"].stringValue)!
                            image.tags = (ts?[n]["images"][i]["tags"].stringValue)!
                            
                            taskImages.append(image)
                            
                        }
                        
                        let task = Task2(_ID: (ts?[n]["ID"].stringValue)!, _sort: (ts?[n]["sort"].stringValue)!, _status: (ts?[n]["status"].stringValue)!, _task: (ts?[n]["task"].stringValue)!)
                        
                        
                        
                        
                        /*
                        task.images = taskImages
                        
                        */
                        
                        
                        
                        
                       // let task = Task(_ID: ts?[n]["ID"].stringValue, _sort: ts?[n]["sort"].stringValue, _status: ts?[n]["status"].stringValue, _task: ts?[n]["task"].stringValue, _images: taskImages)
                        self.woItem.tasks!.append(task)
                        
                    }
                    
                    self.itemDetailsTableView.reloadData()
                    let indexPath = IndexPath(row: self.woItem.tasks!.count, section: 0)
                    self.itemDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
                
                */
                
                
        }
        
    }
 
 */
    
    
    
    
    @objc func assignLeadTasks(){
        print("assign lead tasks")
        let leadTaskAssignViewController:LeadTaskAssignViewController = LeadTaskAssignViewController(_leadFromWorkOrderItem: self.lead!, _workOrderItem:self.woItem)
        leadTaskAssignViewController.editDelegate = self
        self.navigationController?.pushViewController(leadTaskAssignViewController, animated: false)
    }
    
    
    @objc func enterUsage(){
        
       // editsMade = true
        
        //let usageEntryViewController = UsageEntryViewController(_workOrderID: woID,_workOrderItem:self.woItem,_empsOnWo:self.empsOnWo)
        
        self.usageEntryViewController = UsageEntryViewController(_workOrderID: woID,_workOrderItem:self.woItem,_empsOnWo:self.empsOnWo)
        usageEntryViewController!.customerID = self.customerID
        usageEntryViewController!.delegate = self
        navigationController?.pushViewController(usageEntryViewController!, animated: false )
        
    }
    
    
    
    
    
    
    
    func updateLead(_lead: Lead2, _newStatusValue:String){
        print("update Lead")
        editsMade = true
        self.lead = _lead
        
        if self.lead?.statusID == "3"{
            self.hideLeadTaskBtn()
        }
        
        getLead()
    }
    
    func getLead() {
        //print(" GetLead  Lead Id \(self.lead!.ID)")
        
        
        //self.getTasks()
        
        self.getWoItem(woItemID: self.woItem.ID)
        
        
        // Show Loading Indicator
        //indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.lead!.tasksArray = []
        let parameters:[String:String]
        parameters = ["leadID": self.lead!.ID]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/leadTasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("lead response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    self.parseJSON()
                }
                print(" dismissIndicator")
                //self.indicator.dismissIndicator()
        }
    }
    
    
    func parseJSON(){
        //tasks
        let taskCount = self.json["leadTasks"].count
        for n in 0 ..< taskCount {
            var taskImages:[Image] = []
            
            let imageCount = Int((self.json["leadTasks"][n]["images"].count))
            print("imageCount: \(imageCount)")
            for p in 0 ..< imageCount {
                let fileName:String = (self.json["leadTasks"][n]["images"][p]["fileName"].stringValue)
                let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                print("rawPath = \(rawPath)")
                
                let image = Image(_id: self.json["leadTasks"][n]["images"][p]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["leadTasks"][n]["images"][p]["name"].stringValue,_width: self.json["leadTasks"][n]["images"][p]["width"].stringValue,_height: self.json["leadTasks"][n]["images"][p]["height"].stringValue,_description: self.json["leadTasks"][n]["images"][p]["description"].stringValue,_dateAdded: self.json["leadTasks"][n]["images"][p]["dateAdded"].stringValue,_createdBy: self.json["leadTasks"][n]["images"][p]["createdByName"].stringValue,_type: self.json["leadTasks"][n]["images"][p]["type"].stringValue)
                image.customer = (self.json["leadTasks"][n]["images"][p]["customer"].stringValue)
                image.tags = (self.json["leadTasks"][n]["images"][p]["tags"].stringValue)
                print("appending image")
                taskImages.append(image)
            }
           // let task = Task(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue, _images:taskImages)
            
            let task = Task2(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue)
           
            
            
            
            
            //task.images = taskImages
            
            
            
            
            
            self.lead!.tasksArray!.append(task)
        }
        //getStack()
        // self.layoutViews()
        
        //call delegatemethod in contract view to update the lead
    }
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        if woDelegate != nil && editsMade == true{
            woDelegate.refreshWo(_refeshWoID: self.woItem.ID, _newWoStatus: self.newWoStatus)
        }
        
        /*
        if leadDelegate != nil && editsMade == true{
            leadDelegate.updateLead(_lead: self.lead!, _newStatusValue: (self.lead?.statusId)!)
        }
 */
        
        
    }
    
    func refreshWoItem(){
        print("refresh Wo Item")
        editsMade = true
        self.getWoItem(woItemID:self.woItem.ID)
        //self.usageEntryViewController.
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
