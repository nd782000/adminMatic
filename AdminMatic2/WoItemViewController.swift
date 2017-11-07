//
//  WoItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class WoItemViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, FieldNoteDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var woDelegate:WoDelegate!
    
    
    var woID:String!
    var woItem:WoItem!
    var empsOnWo:[Employee]!
    
    var itemView:UIView!
    var itemNameView:UIView!
    var itemLbl:GreyLabel!
    
    var chargeTypeView:UIView!
    var chargeTypeLabel:Label!
    var chargeTypeValueLabel:Label!
    var totalLabel:Label!
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
    
    //the profit progress bar
    
    var profitBarView:UIView!
    var incomeView:UIView!
    var costView:UIView!
    
    
    
    var usageView:UIView!
    var usageBtn:UIButton!
    
   
    
    //details view
    var detailsView:UIView!
    
    var itemDetailsTableView:TableView = TableView()
    
    
    var newWoStatus:String!
    
    var editsMade:Bool = false
    var tasksJson:JSON?
    
    var customerID:String = ""
    
    var tasks: [Task] = []//data array
    
    var saleRepName:String = ""
    
    var imageUploadPrepViewController:ImageUploadPrepViewController!
    
    
    
    
    init(_woID:String,_woItem:WoItem,_empsOnWo:[Employee],_woStatus:String){
        super.init(nibName:nil,bundle:nil)
        self.woID = _woID
        self.woItem = _woItem
        self.empsOnWo = _empsOnWo
        self.newWoStatus = _woStatus
        //print("wo item init")
        
        
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        ////print("view will appear")
        if(self.itemView != nil){
            woDelegate.refreshWo(_refeshWoID: self.woItem.ID, _newWoStatus: self.newWoStatus)
        }
        
        ////print("woItem = \(woItem)")
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "W.O. Item #" + self.woItem.ID
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(WoItemViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        //layoutViews()
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    func layoutViews(){
        //print("item view layoutViews \(woItem.usageQty)")
        //////////   containers for different sections
        self.itemView = UIView()
        self.itemView.backgroundColor = layoutVars.backgroundColor
        self.itemView.layer.borderColor = layoutVars.borderColor
        self.itemView.layer.borderWidth = 1.0
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.itemView)
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.detailsView)
        
        
        
        ////print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemView,
        "view2":self.detailsView] as [String:AnyObject]
        
        let sizeVals = ["width": layoutVars.fullWidth as AnyObject,"height": 24  as AnyObject,"fullHeight":layoutVars.fullHeight - 224  as AnyObject]  as [String:AnyObject]
        
        //////////////////   auto layout position constraints   /////////////////////////////
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1(160)][view2(fullHeight)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
        ///////////   wo item header section   /////////////
        
        ////print("item view layoutViews 2")
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
        
        //self.usageView.backgroundColor = UIColor.redColor();
        
        
        
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
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[itemNameView(35)][chargeTypeView(25)][estimatedView(25)][profitView(25)][usageView(50)]", options: [], metrics: sizeVals, views: containersViewsDictionary))
        
        
        
        
        
        
        
        self.itemLbl = GreyLabel()
        self.itemLbl.text = self.woItem.input
        self.itemLbl.font = layoutVars.labelFont
        self.itemNameView.addSubview(self.itemLbl)
        
        let itemNameViewsDictionary = [
            
            
            "itemLbl":self.itemLbl       ]  as [String:AnyObject]
        
        
        
        
        
        self.itemNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[itemLbl]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: sizeVals, views: itemNameViewsDictionary))
        
        self.itemNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(20)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        
        
        
        
        //charge Info
        
        
        
        
        self.chargeTypeLabel = Label()
        self.chargeTypeLabel.text = "Charge Type:"
        self.chargeTypeView.addSubview(self.chargeTypeLabel)
        
        
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var chargeTypeName:String
        
        switch (self.woItem.chargeID) {
        case "1":
            chargeTypeName = appDelegate.fieldsJson["charges"][0][1].stringValue
            break;
        case "2":
            chargeTypeName = appDelegate.fieldsJson["charges"][1][1].stringValue
            break;
        case "3":
            chargeTypeName = appDelegate.fieldsJson["charges"][2][1].stringValue
            break;
        default:
            chargeTypeName = "Null"//online
            break;
        }
        
        self.chargeTypeValueLabel = Label()
        self.chargeTypeValueLabel.text = chargeTypeName
        self.chargeTypeView.addSubview(self.chargeTypeValueLabel)
        
        
        
        
        self.totalLabel = Label()
        self.totalLabel.text = "Total:"
        self.chargeTypeView.addSubview(self.totalLabel)
        
        
        
        
        
        
        self.totalValueLabel = Label()
        self.totalValueLabel.text = "$\(self.woItem.total!)"
        self.chargeTypeView.addSubview(self.totalValueLabel)
        
        
        
        
        
        
        
        
        
        
        
        
        let chargeViewsDictionary = [
            "chargeTypeLabel":self.chargeTypeLabel,
            "chargeTypeValueLabel":self.chargeTypeValueLabel,
            "totalLabel":self.totalLabel,
            "totalValueLabel":self.totalValueLabel
        ]  as [String:AnyObject]
        
        self.chargeTypeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[chargeTypeLabel][chargeTypeValueLabel]-[totalLabel][totalValueLabel]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: sizeVals, views: chargeViewsDictionary))
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
        
        
        var remainingValue = Float(self.woItem.est)! - Float(self.woItem.usageQty)!
        
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
        
        self.estimatedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[estLabel][estValueLabel]-[actualLabel][actualValueLabel]-[remainLabel][remainValueLabel]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: sizeVals, views: estimatedViewsDictionary))
        self.estimatedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[estLabel(20)]", options: [], metrics: sizeVals, views: estimatedViewsDictionary))
        self.estimatedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[remainLabel(20)]", options: [], metrics: sizeVals, views: estimatedViewsDictionary))
        
        
        //Profit Info
        
        // profit bar vars
        let profitBarWidth = Float(100.00)
        
      
        
        let income = Float(self.woItem.total!)
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
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[costLabel][costValueLabel]-[profitLabel][profitValueLabel]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: sizeVals, views: profitViewsDictionary))
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
        self.usageBtn.addTarget(self, action: #selector(WoItemViewController.enterUsage), for: UIControlEvents.touchUpInside)
        
        
        let usageViewsDictionary = [
            
            "usageBtn":self.usageBtn
        ]  as [String:AnyObject]
        
        
        
        self.usageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[usageBtn]-10-|", options: [], metrics: sizeVals, views: usageViewsDictionary))
        
        self.usageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[usageBtn(40)]", options: [], metrics: sizeVals, views: usageViewsDictionary))
        
        ///////////   Item Details Section   /////////////
        
        
        self.itemDetailsTableView.delegate  =  self
        self.itemDetailsTableView.dataSource = self
        
        self.itemDetailsTableView.rowHeight = UITableViewAutomaticDimension
        self.itemDetailsTableView.estimatedRowHeight = 100.0
        
        
        self.itemDetailsTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "cell")
        self.detailsView.addSubview(itemDetailsTableView)
        
        
        //auto layout group
        let itemDetailsViewsDictionary = [
            
            "view1":itemDetailsTableView
        ]  as [String:AnyObject]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(fullHeight)]", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        
        
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
        count = self.tasks.count + 1
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! TaskTableViewCell
        cell.prepareForReuse()
        
        
        if(indexPath.row == self.tasks.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            
            cell.task = self.tasks[indexPath.row]
            cell.layoutViews()
            cell.taskLbl.text = self.tasks[indexPath.row].task
            
            if(self.tasks[indexPath.row].images.count == 0){
                cell.imageQtyLbl.text = "No Images"
            }else{
                if(self.tasks[indexPath.row].images.count == 1){
                    cell.imageQtyLbl.text = "1 Image"
                    
                }else{
                    cell.imageQtyLbl.text = "\(self.tasks[indexPath.row].images.count) Images"
                }
            }
            
            
            cell.setStatus(status: self.tasks[indexPath.row].status)
            
            print("image count = \(self.tasks[indexPath.row].images.count)")
            
            if(self.tasks[indexPath.row].images.count > 0){
                print("image path = \(self.tasks[indexPath.row].images[0].thumbPath!)")
                cell.activityView.startAnimating()
                cell.setImageUrl(_url: "\(self.tasks[indexPath.row].images[0].thumbPath!)")
            }else{
                cell.setBlankImage()
            }
            
        }
        
        
        
        
        return cell
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //////print("You selected cell #\(indexPath.row)!")
        
        //let indexPath = tableView.indexPathForSelectedRow;
        if(indexPath.row == self.tasks.count){
            self.addTask()
        }else{
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _ID: self.tasks[indexPath.row].ID)
            imageUploadPrepViewController.images = self.tasks[indexPath.row].images
            imageUploadPrepViewController.layoutViews()
            imageUploadPrepViewController.groupDescriptionTxt.text = self.tasks[indexPath.row].task
            imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
            imageUploadPrepViewController.selectedID = self.customerID
            imageUploadPrepViewController.woID = self.woID
            imageUploadPrepViewController.groupImages = true
            imageUploadPrepViewController.fieldNoteDelegate = self
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
        
        let ID = self.tasks[indexPath.row].ID
        
        var newItemStatus:String?
        
        
        //print("ID = \(ID)")
        //print("empID = \(self.appDelegate.loggedInEmployee?.ID)")
        //print("woItemID = \(self.woItem.ID)")
        //print("woID = \(self.woID)")
        
        
        //indexPath
        let none = UITableViewRowAction(style: .normal, title: "None") { action, index in
            //print("none button tapped")
            
            self.tasks[indexPath.row].status = "1"
            tableView.reloadData()
            
            
            
        var parameters:[String:String]
            parameters = [
                "taskID":ID!,
                "status":"1",
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
                    //self.self.employeeJSON = JSON(json)
                    //self.self.parseEmployeeJSON()
                    newItemStatus = JSON(json)["newItemStatus"].stringValue
                    self.newWoStatus = JSON(json)["newWoStatus"].stringValue
                    
                }
                
                
                
                }.responseString { response in
                    //print("response = \(response)")
            }

            
            
            
        }
        none.backgroundColor = UIColor.gray
        
        
        let progress = UITableViewRowAction(style: .normal, title: "Prog.") { action, index in
            //print("progress button tapped")
            
            self.tasks[indexPath.row].status = "2"
            tableView.reloadData()
            
            
            var parameters:[String:String]
            parameters = [
                "taskID":ID!,
                "status":"2",
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
                    //self.self.employeeJSON = JSON(json)
                    //self.self.parseEmployeeJSON()
                    
                    newItemStatus = JSON(json)["newItemStatus"].stringValue
                    self.newWoStatus = JSON(json)["newWoStatus"].stringValue
                    
                    
                    
                }
                
                
                
                }.responseString { response in
                    //print("response = \(response)")
            }
            
            
        }
        progress.backgroundColor = UIColor.orange
        
        let done = UITableViewRowAction(style: .normal, title: "Done") { action, index in
            //print("done button tapped")
            self.tasks[indexPath.row].status = "3"
            tableView.reloadData()
            
            var parameters:[String:String]
            parameters = [
                "taskID":ID!,
                "status":"3",
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
                    //self.self.employeeJSON = JSON(json)
                    //self.self.parseEmployeeJSON()
                    
                    newItemStatus = JSON(json)["newItemStatus"].stringValue
                    self.newWoStatus = JSON(json)["newWoStatus"].stringValue
                    
                }
                
                
                
                }.responseString { response in
                    //print("response = \(response)")
            }
            
            
        }
        done.backgroundColor = layoutVars.buttonColor1
        
        let cancel = UITableViewRowAction(style: .normal, title: "Cancel") { action, index in
            //print("cancel button tapped")
            self.tasks[indexPath.row].status = "4"
            tableView.reloadData()
            
            var parameters:[String:String]
            parameters = [
                "taskID":ID!,
                "status":"4",
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
                    //self.self.employeeJSON = JSON(json)
                    //self.self.parseEmployeeJSON()
                    
                    newItemStatus = JSON(json)["newItemStatus"].stringValue
                    self.newWoStatus = JSON(json)["newWoStatus"].stringValue
                    
                }
                
                
                
                }.responseString { response in
                    //print("response = \(response)")
            }
            
            
        }
        cancel.backgroundColor = UIColor.red
        
        
        self.woItem.itemStatus = newItemStatus
        //tableView.reloadData()
        
        return [cancel, done, progress, none]
    }
     
    
    func addTask(){
        print("add task")
        
        
        if(self.woItem.chargeID == "2"){
            var message:String = ""
            if(self.saleRepName != "No Rep"){
                message = "Contact sales rep: \(self.saleRepName) or the office to add tasks to this item."
            }else{
                message = "Contact the office to add tasks to this item."
            }
            let alertController = UIAlertController(title: "Flat Price Item", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //self.popView()
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        
        
        
        
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Task", _ID: "0")
        imageUploadPrepViewController.selectedID = self.woItem.ID
        imageUploadPrepViewController.customerID = self.customerID
       // imageUploadPrepViewController.itemID = self.woItem.
        imageUploadPrepViewController.layoutViews()
        
        imageUploadPrepViewController.woID = self.woID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.fieldNoteDelegate = self
        
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )

        
        
        
    }
    
    /*
    func updateTable(){
        print("updateTable")
        self.editsMade = true
        getTasks()
    }*/
    
    
    func updateTable(_points:Int){
        print("updateTable")
        //self.imageUploadPrepViewController.goBack()
        self.appDelegate.showMessage(_message: "earned \(_points) App Points!")
        
        self.editsMade = true
        getTasks()
    }

    
    func getTasks(){
        print("get tasks")
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        let parameters = ["woItemID": self.woItem.ID as AnyObject, "cb":timeStamp as AnyObject]
        
        print("parameters = \(parameters)")
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/tasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("get tasks response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                print(response.request ?? "")  // original URL request
                print(response.response ?? "") // URL response
                print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("Tasks Json = \(json)")
                    self.tasksJson = JSON(json)
                    
                    let ts = self.tasksJson?["tasks"]
                    
                    self.tasks = []
                    
                    
                    //FieldNotes
                    print("Task Count = \(ts?.count)")
                    
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
                        let task = Task(_ID: ts?[n]["ID"].stringValue, _sort: ts?[n]["sort"].stringValue, _status: ts?[n]["status"].stringValue, _task: ts?[n]["task"].stringValue, _images: taskImages)
                        
                        
                        self.tasks.append(task)
                        
                    }
                    
                    // let scoreJSON =  JSON(json)["scoreAdjust"]
                    
                    /*
                     //add appPoints
                     var points:Int = JSON(json)["scoreAdjust"].intValue
                     //print("points = \(points)")
                     if(points > 0){
                     self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                     }else if(points < 0){
                     points = points * -1
                     self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                     
                     }
                     */
                    
                    //}
                    
                    self.itemDetailsTableView.reloadData()
                    
                    let indexPath = IndexPath(row: self.tasks.count, section: 0)
                    self.itemDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    
                    
                }
                
                
        }
        
    }

   
    
    
    
    func enterUsage(){
        let usageEntryViewController = UsageEntryViewController(_workOrderID: woID,_workOrderItem:self.woItem,_empsOnWo:self.empsOnWo)
        navigationController?.pushViewController(usageEntryViewController, animated: false )
        
    }
    
    
    func goBack(){
        
        
        
       
        
         //woDelegate.refreshWo(_refeshWoID: self.woItem.ID)
        
        
        _ = navigationController?.popViewController(animated: true)
        
         woDelegate.refreshWo(_refeshWoID: self.woItem.ID, _newWoStatus: self.newWoStatus)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
