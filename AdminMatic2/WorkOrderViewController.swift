//
//  WorkOrderViewController.swift
//  AdminMatic2
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


//  Edited for safeView

import Foundation

import UIKit
import Alamofire

protocol WoDelegate{
    func refreshWo()
    func refreshWo(_refeshWoID:String, _newWoStatus:String)
}

 
class WorkOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, WoDelegate, StackDelegate, EditLeadDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    
    
    var editButton:UIBarButtonItem!
    var editsMade:Bool = false
    
    
    var tapBtn:UIButton!
    
    var scheduleDelegate:ScheduleDelegate!
    var scheduleIndex:Int!
    
   
    var workOrder:WorkOrder2!
    
    var workOrderID:String!
    
    
    var editLeadDelegate:EditLeadDelegate!
    var stackController:StackController!
    
    var statusIcon:UIImageView = UIImageView()
    
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Not Started","In Progress","Done","Cancel","Waiting"]
    
    
    var statusValueToUpdate: String!
    
    var workOrderView:UIView!
    var customerBtn: Button!
    var locationValue:String?
    var infoMode:Int! = 0
    var infoView: UIView! = UIView()

    var scheduleLbl:GreyLabel!
    var schedule:GreyLabel!
    
    var scheduleDateFormatter:DateFormatter!
    
   
    
    var scheduleKeyWordValue:String?
    
    
    var deadLineValue:String = ""
    
    var titleLbl:GreyLabel!
    var titleValue:GreyLabel!
    
    var chargeLbl:GreyLabel!
    var charge:GreyLabel!
    
    var crewLbl:GreyLabel!
    var crew:GreyLabel!
    var crewsValue:String?
    
    var salesRepLbl:GreyLabel!
    var salesRep:GreyLabel!

    
    //attachments is disabled for now
    var attachmentsView: UIView! = UIView()
    var attachmentsLbl:GreyLabel!
    var attachmentsTxt:GreyLabel!
    var attachments:[Attachment] = []
    var numberAttachmentPics: Int = 0
 
    
    
    
    var woItemViewController:WoItemViewController?
    var refreshWoID:String?
    var currentWoItem:WoItem2?
    
    
    
    var itemsTableView: TableView!
    
    var profitView: UIView! = UIView()
    
    var priceLbl:GreyLabel!
    var price:GreyLabel!
    
    
    var costLbl:GreyLabel!
    var cost:GreyLabel!
    
    
    var profitLbl:GreyLabel!
    var profit:GreyLabel!
    
    var percentLbl:GreyLabel!
    var percent:GreyLabel!
    
    var profitBarView:UIView!
    var incomeView:UIView!
    var costView:UIView!
    
    var tableCellID:Int? //used to store the cell ID of cell clicked to update status
    
    var leadTasksWaiting:String?
    
    var usageDelegate:UsageListDelegate?
    
   
    
    //var customerDelegate:CustomerDelegate!
    
    
    init(_workOrderID:String){
        
        
        super.init(nibName:nil,bundle:nil)
        print("workorder init ID = \(_workOrderID)")
        self.workOrderID = _workOrderID
        
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshWo(){
        print("refreshWo")
        
        numberAttachmentPics = 0
        
        
        self.workOrder.woItems = []
        self.workOrder.crews = []
        
        self.workOrder.emps = []
        
        self.deadLineValue = ""
        self.attachments = []
        self.getWorkOrder()
    }
    
    func refreshWo(_refeshWoID _refreshWoID:String, _newWoStatus:String){
        print("refreshWo 1")
        print("_newWoStatus = \(_newWoStatus)")
        
        
        self.refreshWoID = _refreshWoID
        numberAttachmentPics = 0
       
        
        self.workOrder.woItems = []
        
        
        self.workOrder.crews = []
        
        self.workOrder.emps = []
        
        self.deadLineValue = ""
        self.attachments = []
    
        print("self.workOrder.status = \(self.workOrder.status)")
        print("_newWoStatus = \(_newWoStatus)")
        
        
        if(self.workOrder.status != _newWoStatus && _newWoStatus != "na"){
            
            switch (_newWoStatus) {
            case "1":
                self.workOrder.statusName = "Un-Done"
                break;
            case "2":
                self.workOrder.statusName = "In Progress"
                break;
            case "3":
                self.workOrder.statusName = "Done"
                break;
            case "4":
                self.workOrder.statusName = "Cancel"
                break;
                
            default:
                self.workOrder.statusName = ""
                break;
            }

            
            
            
            let alertController = UIAlertController(title: "Set Work Order to \(String(describing: self.workOrder.statusName!))", message: "", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                
                self.getWorkOrder()
                
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                
                var parameters:[String:String]
                parameters = [
                    "woID":self.workOrder.ID,
                    "status":_newWoStatus,
                    "empID":(self.appDelegate.loggedInEmployee?.ID)!
                ]
                
                print("parameters = \(parameters)")
                
                
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/workOrderStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    print(response.request ?? "")  // original URL request
                    //print(response.response ?? "") // URL response
                    //print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    self.layoutVars.playSaveSound()
                    
                     self.getWorkOrder()
                    
                    
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)

        }else{
            getWorkOrder()

        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        // Do any additional setup after loading the view.
        //custom back button
       
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
        
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        title = "Loading..."
        getWorkOrder()
    }
    

    
    //sends request for wo Data
    func getWorkOrder() {
        print(" GetWo  Work Order Id \(String(describing: workOrderID))")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        
        
       
        
        
        
        
        let woURL = "https://www.atlanticlawnandgarden.com/cp/app/functions/get/workOrder.php?woID=\(self.workOrderID!)"
        
       print(woURL)
        
        
            //Performing an Alamofire request to get the data from the URL
        Alamofire.request(woURL).responseJSON { response in
                //now here we have the response data that we need to parse
            
            do{
                //created the json decoder
                
                let json = response.data
                
                
                //print("json = \(json)")
                
                let decoder = JSONDecoder()
               
                
                
                let parsedData = try decoder.decode(WorkOrder2.self, from: json!)
                
                
                print("parsedData = \(parsedData)")
                
                self.workOrder = parsedData
                
                self.statusValueToUpdate = self.workOrder.status
            
                
                print("self.workOrder.status = \(self.workOrder.status)")
                
                
                print("crews.count = \(self.workOrder.crews!.count)")
                
                
                self.workOrder.setEmps()
                
                print("emps.count = \(self.workOrder.emps!.count)")
                
                self.indicator.dismissIndicator()
                
                
                self.layoutViews()
                
                
                
              
                
            }catch let err{
                print(err)
            }
            
          
            
                
        }
   
    }
    
  
    
    
    func layoutViews(){
       
        title =  "Work Order #" + self.workOrder.ID
        
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(WorkOrderViewController.displayEditView))
        navigationItem.rightBarButtonItem = editButton
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        if(self.attachmentsView != nil){
            self.attachmentsView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        if(self.profitView != nil){
            self.profitView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        
        self.workOrderView = UIView()
        self.workOrderView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.workOrderView)
        
        stackController = StackController()
        stackController.delegate = self
        stackController.getStack(_type:2,_ID:self.workOrderID)
        self.workOrderView.addSubview(stackController)
        
        
        
        
        switch (self.workOrder.status) {
        case "1":
            self.workOrder.statusName = "Un-Started"
            break;
        case "2":
            self.workOrder.statusName = "In Progress"
            break;
        case "3":
            self.workOrder.statusName = "Done"
            break;
        case "4":
            self.workOrder.statusName = "Cancelled"
            break;
            
        default:
            self.workOrder.statusName = "Un-Started"//online
            break;
        }
        
        
        //statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        self.workOrderView.addSubview(statusIcon)
        //setStatus(status: self.json["status"].stringValue)
        setStatus(status: self.workOrder.status)
        
        //status picker
        self.statusPicker = Picker()
        //print("statusValue : \(statusValue)")
        print("set picker position : \(Int(self.workOrder.status)! - 1)")
        
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
        
        self.statusPicker.selectRow(Int(self.workOrder.status)! - 1, inComponent: 0, animated: false)
        
        self.statusTxtField = PaddedTextField(placeholder: "")
        self.statusTxtField.textAlignment = NSTextAlignment.center
        self.statusTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.statusTxtField.tag = 1
        self.statusTxtField.delegate = self
        self.statusTxtField.tintColor = UIColor.clear
        self.statusTxtField.backgroundColor = UIColor.clear
        self.statusTxtField.inputView = statusPicker
        self.statusTxtField.layer.borderWidth = 0
        self.workOrderView.addSubview(self.statusTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(WorkOrderViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = BarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(WorkOrderViewController.handleStatusChange))
        
        toolBar.setItems([closeButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        statusTxtField.inputAccessoryView = toolBar

        
        
        
        
        if self.workOrder.custAddress != nil{
            self.customerBtn = Button(titleText: "\(self.workOrder.custName!) \(self.workOrder.custAddress!)" )
        }else{
            self.customerBtn = Button(titleText: "\(self.workOrder.custName!)" )
        }
        
        
        
        
        self.customerBtn.contentHorizontalAlignment = .left
        let custIcon:UIImageView = UIImageView()
        custIcon.backgroundColor = UIColor.clear
        custIcon.contentMode = .scaleAspectFill
        custIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        let custImg = UIImage(named:"custIcon.png")
        custIcon.image = custImg
        self.customerBtn.addSubview(custIcon)
        self.customerBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.customerBtn.addTarget(self, action: #selector(self.showCustInfo), for: UIControl.Event.touchUpInside)
        
        
        self.workOrderView.addSubview(customerBtn)
        
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.infoView.layer.cornerRadius = 4
        self.workOrderView.addSubview(infoView)
        
        
        //schedule
        self.scheduleLbl = GreyLabel()
        self.scheduleLbl.text = "Schedule:"
        self.scheduleLbl.textAlignment = .left
        self.scheduleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(scheduleLbl)
        
        self.schedule = GreyLabel()
        if self.workOrder.date != nil{
            self.schedule.text = self.workOrder.date!
        }else{
            self.schedule.text = "Not Scheduled"
        }
        
        self.schedule.font = layoutVars.labelBoldFont
        self.schedule.textAlignment = .left
        self.schedule.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(schedule)
        
        
        //title
        self.titleLbl = GreyLabel()
        self.titleLbl.text = "Title:"
        self.titleLbl.textAlignment = .left
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleLbl)
        
        self.titleValue = GreyLabel()
        self.titleValue.text = self.workOrder.title
        self.titleValue.font = layoutVars.labelBoldFont
        self.titleValue.textAlignment = .left
        self.titleValue.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleValue)
        
        
        //charge
        
        
        switch (self.workOrder.charge!) {
        case "1":
            self.workOrder.chargeName = "NC $0.00"
            break;
        case "2":
            self.workOrder.chargeName = "FL \(self.workOrder.totalPrice)"
            break;
        case "3":
            self.workOrder.chargeName = "T & M"
            break;
            
        default:
            self.workOrder.chargeName = ""//online
            break;
        }
        
        
        self.chargeLbl = GreyLabel()
        self.chargeLbl.text = "Charge:"
        self.chargeLbl.textAlignment = .left
        self.chargeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeLbl)
        
        self.charge = GreyLabel()
        self.charge.text = self.workOrder.chargeName!
        self.charge.font = layoutVars.labelBoldFont
        self.charge.textAlignment = .left
        self.charge.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(charge)
        
        //crew
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew(s):"
        self.crewLbl.textAlignment = .left
        self.crewLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(crewLbl)
        
        self.crew = GreyLabel()
        //self.crew.text = self.crewsValue
        
        
        
        
        if self.workOrder.crews!.count > 0{
            self.crewsValue = ""
            
           // self.crewsValue = self.workOrder.crews
            //print(str)
            var i = 0
            for crewName in self.workOrder.crews! {
                if i == 0{
                    self.crewsValue = "\(crewName.name) "
                }else{
                    self.crewsValue = "\(self.crewsValue!),  \(crewName.name)"
                }
                i += 1
                
            }
            self.crew.text = self.crewsValue!
        }else{
            self.crew.text = "No Crew"
        }
        self.crew.font = layoutVars.labelBoldFont
        self.crew.textAlignment = .left
        self.crew.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(crew)
        
        
        //sales rep
        self.salesRepLbl = GreyLabel()
        self.salesRepLbl.text = "Rep:"
        self.salesRepLbl.textAlignment = .left
        self.salesRepLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRepLbl)
        
        self.salesRep = GreyLabel()
        
        
        
        
        self.salesRep.text = self.workOrder.repName
        self.salesRep.font = layoutVars.labelBoldFont
        self.salesRep.textAlignment = .left
        self.salesRep.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRep)
        
        
        /*
        // Field Notes Window
        
        self.attachmentsView.translatesAutoresizingMaskIntoConstraints = false
        self.attachmentsView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.attachmentsView.layer.cornerRadius = 4
        self.workOrderView.addSubview(attachmentsView)
        
        
        let smallCameraIcon:UIImageView = UIImageView()
        smallCameraIcon.backgroundColor = UIColor.clear
        smallCameraIcon.contentMode = .scaleAspectFill
        smallCameraIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let smallCameraImg = UIImage(named:"smallCameraIcon.png")
        smallCameraIcon.image = smallCameraImg
        
        
        self.attachmentsLbl = GreyLabel(icon: true)
        self.attachmentsLbl.text = "Attachments"
        self.attachmentsLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.attachmentsLbl.addSubview(smallCameraIcon)
        
        self.attachmentsView.addSubview(attachmentsLbl)
        
        self.attachmentsTxt = GreyLabel()
        var picString:String = ""
        if(self.numberAttachmentPics > 0){
            picString = "(\(self.numberAttachmentPics) Images)"
        }
        if(self.attachments.count == 0){
            self.attachmentsTxt.text = "None Saved"
        }else{
            self.attachmentsTxt.text = "\(self.attachments.count) w/ \(picString)"
        }
        
        self.attachmentsTxt.translatesAutoresizingMaskIntoConstraints = false
        
        self.attachmentsView.addSubview(attachmentsTxt)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WorkOrderViewController.showAttachmentsList))
        attachmentsView.addGestureRecognizer(tapGesture)
        */
        
        
        let tableHead:UIView! = UIView()
        let statusTH: THead = THead(text: "Sts.")
        let nameTH: THead = THead(text: "Name")
        let estTH: THead = THead(text: "Est.")
        let actTH: THead = THead(text: "Act.")
        
        tableHead.backgroundColor = layoutVars.buttonTint
        tableHead.translatesAutoresizingMaskIntoConstraints = false
        tableHead.addSubview(statusTH)
        tableHead.addSubview(nameTH)
        tableHead.addSubview(estTH)
        tableHead.addSubview(actTH)
        
        self.workOrderView.addSubview(tableHead)
        
        self.itemsTableView  =   TableView()
        self.itemsTableView.autoresizesSubviews = true
        self.itemsTableView.delegate  =  self
        self.itemsTableView.dataSource  =  self
        self.itemsTableView.layer.cornerRadius = 0
        
        self.itemsTableView.layer.borderWidth = 1
        self.itemsTableView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        
        self.itemsTableView.register(WoItemTableViewCell.self, forCellReuseIdentifier: "cell")
        self.workOrderView.addSubview(self.itemsTableView)
        
    
        
    // Profit View
        
        self.profitView.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.profitView.layer.cornerRadius = 4
        
        self.workOrderView.addSubview(self.profitView)
        
        
        self.priceLbl = GreyLabel(icon: false)
        self.priceLbl.text = "Price:"
        self.priceLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(priceLbl)
        
        
        self.price = GreyLabel()
        self.price.text = self.workOrder.totalPrice
        self.price.font = layoutVars.labelBoldFont
        self.price.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(price)

        self.costLbl = GreyLabel(icon: false)
        self.costLbl.text = "Cost:"
        self.costLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(costLbl)
        
        self.cost = GreyLabel()
        self.cost.text = self.workOrder.totalCost
        self.cost.font = layoutVars.labelBoldFont
        self.cost.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(cost)
        
        self.profitLbl = GreyLabel(icon: false)
        self.profitLbl.text = "Profit:"
        self.profitLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(profitLbl)
        
        self.profit = GreyLabel()
        self.profit.text = self.workOrder.profitValue
        self.profit.font = layoutVars.labelBoldFont
        self.profit.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(profit)
        
        self.percentLbl = GreyLabel(icon: false)
        self.percentLbl.text = "Profit %:"
        self.percentLbl.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(percentLbl)
        
        self.percent = GreyLabel()
        self.percent.text = self.workOrder.percentValue
        self.percent.font = layoutVars.labelBoldFont
        self.percent.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(percent)
        
        
        self.profitBarView = UIView()
        self.profitBarView.backgroundColor = UIColor.gray
        self.profitBarView.layer.borderColor = layoutVars.borderColor
        self.profitBarView.layer.borderWidth = 1.0
        self.profitBarView.translatesAutoresizingMaskIntoConstraints = false
        self.profitView.addSubview(self.profitBarView)
        
        
        //Profit Info
        let profitBarWidth = Float(layoutVars.fullWidth - 20)
        
       
        let totalRaw = Float(self.workOrder.totalPriceRaw)
        let totalCostRaw = Float(self.workOrder.totalCostRaw)
        
        
        
        var scaleFactor = Float(0.00)
        var costWidth = Float(0.00)
        
        if(totalRaw! > 0.0){
            ////print("greater")
            scaleFactor = Float(profitBarWidth / totalRaw!)
            costWidth = totalCostRaw! * scaleFactor
            if(costWidth > profitBarWidth){
                costWidth = profitBarWidth
            }
        }else{
            costWidth = profitBarWidth
        }
        
        
        let costBarOffset = profitBarWidth - costWidth
        
        //////print("income = \(income)")
        //////print("cost = \(cost)")
        ////print("scaleFactor = \(scaleFactor)")
        ////print("costWidth = \(costWidth)")
        ////print("profitBarWidth = \(profitBarWidth)")
        ////print("costBarOffset = \(costBarOffset)")
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        self.workOrderView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.workOrderView.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        self.workOrderView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
       // self.workOrderView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        self.workOrderView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "stackController":self.stackController,
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "th":tableHead,
            "table":self.itemsTableView,
            "profitView":self.profitView,
        ] as [String:AnyObject]
        
        
        
         self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackController]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusIcon(40)]-15-[customerBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[info]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[table]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[th]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[profitView]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
         self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(120)]-[th][table]-[profitView(85)]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.workOrderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        //auto layout group
        let infoDictionary = [
            "titleLbl":self.titleLbl,
            "title":self.titleValue,
            "scheduleLbl":self.scheduleLbl,
            "schedule":self.schedule,
            "chargeLbl":self.chargeLbl,
            "charge":self.charge,
            "crewLbl":self.crewLbl,
            "crew":self.crew,
            "salesRepLbl":self.salesRepLbl,
            "salesRep":self.salesRep
        ] as [String:AnyObject]
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-[title]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[scheduleLbl]-[schedule]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[chargeLbl]-[charge]-[salesRepLbl]-[salesRep]-10-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[crewLbl]-[crew]-10-|", options: [], metrics: metricsDictionary, views: infoDictionary))
       
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)]-[scheduleLbl(22)]-[chargeLbl(22)]-[crewLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title(22)]-[schedule(22)]-[charge(22)]-[crew(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
       
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)]-[scheduleLbl(22)]-[chargeLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)]-[scheduleLbl(22)]-[charge(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)]-[scheduleLbl(22)]-[salesRepLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)]-[scheduleLbl(22)]-[salesRep(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        /*
        //auto layout group
        let attachmentsDictionary = [
            "attachmentsLbl":self.attachmentsLbl,
            "attachmentsTxt":self.attachmentsTxt
        ] as [String:AnyObject]
        
        
        self.attachmentsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[attachmentsLbl(130)]-[attachmentsTxt]-10-|", options: [], metrics: metricsDictionary, views: attachmentsDictionary))
        self.attachmentsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[attachmentsLbl]", options: [], metrics: metricsDictionary, views: attachmentsDictionary))
        self.attachmentsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[attachmentsTxt]", options: [], metrics: metricsDictionary, views: attachmentsDictionary))
        */
        
        
        // Tablehead
        let thDictionary = [
            "sts":statusTH,
            "name":nameTH,
            "est":estTH,
            "act":actTH
        ] as [String:AnyObject]
        
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[sts(40)]-10-[name]-5-[est(50)]-10-[act(50)]-5-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[sts(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[name(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[est(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        tableHead.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[act(20)]-3-|", options: [], metrics: metricsDictionary, views: thDictionary))
        
        
        //print("6")

        //auto layout group
        let profitDictionary = [
            "priceLbl":self.priceLbl,
            "costLbl":self.costLbl,
            "profitLbl":self.profitLbl,
            "percentLbl":self.percentLbl,
            "price":self.price,
            "cost":self.cost,
            "profit":self.profit,
            "percent":self.percent,
            "profitBar":self.profitBarView
            ] as [String:AnyObject]
        
        
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[priceLbl]-[price]", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[profitLbl]-[profit]-10-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[costLbl]-[cost]", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[percentLbl]-[percent]-10-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[profitBar]-10-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[priceLbl]-[costLbl]", options: [], metrics: metricsDictionary, views: profitDictionary))
         self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[price]-[cost]", options: [], metrics: metricsDictionary, views: profitDictionary))
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[profitLbl]-[percentLbl]", options: [], metrics: metricsDictionary, views: profitDictionary))
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[profit]-[percent]", options: [], metrics: metricsDictionary, views: profitDictionary))
        
        self.profitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[profitBar(10)]-|", options: [], metrics: metricsDictionary, views: profitDictionary))
        
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
        
        
        //print("7")

        
        let profitBarViewsDictionary = [
            
            "incomeView":self.incomeView,
            "costView":self.costView
            ]  as [String:AnyObject]
        
        let profitBarSizeVals = ["profitBarWidth":profitBarWidth as AnyObject,"costWidth":costWidth as AnyObject,"costBarOffset":costBarOffset as AnyObject]  as [String:AnyObject]
        
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[incomeView(profitBarWidth)]|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[costView(costWidth)]-costBarOffset-|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[incomeView(10)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[costView(10)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        //print("8")
    }
    
    @objc func showAttachmentsList(){
       
        /*
        
        let attachmentsListViewControler:AttachmentListViewController = AttachmentListViewController(_workOrderID: self.workOrder.ID,_customerID: self.workOrder.customer, _attachments: self.attachments)
        attachmentsListViewControler.woDelegate = self
        navigationController?.pushViewController(attachmentsListViewControler, animated: false )
 */
        
        
        
    }
    
   
    
    @objc func showCustInfo() {
        ////print("SHOW CUST INFO")
        let customerViewController = CustomerViewController(_customerID: self.workOrder.customer!,_customerName: self.workOrder.custName!)
        navigationController?.pushViewController(customerViewController, animated: false )
    }
    
    
   
    
    func removeViews(){
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    //picker methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
   
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
       // shows first 3 status options, not cancel or waiting
        return self.statusArray.count - 2
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:60))
        
        let myImageView = UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
        
        var rowString = String()
        rowString = statusArray[row]
        
        switch row {
        case 0:
            
            myImageView.image = UIImage(named:"unDoneStatus.png")
            break
        case 1:
            myImageView.image = UIImage(named:"inProgressStatus.png")
            break
        case 2:
            myImageView.image = UIImage(named:"doneStatus.png")
            break
        case 3:
            myImageView.image = UIImage(named:"cancelStatus.png")
            break
        case 4:
            myImageView.image = UIImage(named:"waitingStatus.png")
            break
        default:
            myImageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
        myLabel.font = layoutVars.smallFont
        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        self.statusValueToUpdate = "\(row + 1)"
    }
    
    @objc func cancelPicker(){
         //self.statusValueToUpdate = self.statusValue
        self.statusTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        
        self.statusTxtField.resignFirstResponder()
    
        var parameters:[String:String]
        parameters = [
            "woID":self.workOrder.ID,
            "status":self.statusValueToUpdate,
            "empID":(self.appDelegate.loggedInEmployee?.ID)!
        ]
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/workOrderStatus.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            
            self.layoutVars.playSaveSound()
            
            self.workOrder.status = self.statusValueToUpdate
            self.setStatus(status: self.workOrder.status)
          
        if(self.scheduleDelegate != nil){
                self.scheduleDelegate.reDrawSchedule(_index: self.scheduleIndex, _status: self.workOrder.status, _price: self.workOrder.totalPrice, _cost: self.workOrder.totalCost, _priceRaw: self.workOrder.totalPriceRaw, _costRaw: self.workOrder.totalCostRaw)
                }
            }.responseString() {
                response in
                print(response)  // original URL request
            }
        
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //return self.woItemsArray.count
       // var count:Int!
       // count = self.woItemsArray.count + 1
        
        return self.workOrder.woItems!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:WoItemTableViewCell = itemsTableView.dequeueReusableCell(withIdentifier: "cell") as! WoItemTableViewCell
        
       // if(indexPath.row == self.woItemsArray.count){
        if(indexPath.row == self.workOrder.woItems!.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            
            print("item count = \(self.workOrder.woItems!.count)")
            cell.woItem = self.workOrder.woItems![indexPath.row]
            
            cell.layoutViews()
            
            
            cell.setStatus(status: cell.woItem.status)
            cell.nameLbl.text = cell.woItem.item
            cell.estLbl.text = cell.woItem.est!
            cell.actLbl.text = cell.woItem.usageQty!
        }
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        
        
        if(indexPath.row == self.workOrder.woItems!.count){
            self.addItem()
            let indexPath = tableView.indexPathForSelectedRow
            tableView.deselectRow(at: indexPath!, animated: false)
        }else{
            let indexPath = tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRow(at: indexPath!) as! WoItemTableViewCell;
            
            
            if(currentCell.woItem != nil && currentCell.woItem.ID != ""){
                self.woItemViewController = WoItemViewController(_woID: self.workOrder.ID, _woItem: currentCell.woItem, _empsOnWo: self.workOrder.emps!, _woStatus: self.workOrder.status)
                
                
                woItemViewController?.leadDelegate = self
                
                
                self.woItemViewController?.customerID = self.workOrder.customer!
                self.woItemViewController?.customerName = self.workOrder.custName!
                
                
                
                
                
                
                self.woItemViewController?.saleRepName = self.workOrder.repName!
                
                self.woItemViewController!.woDelegate = self
               // print("task count = \(currentCell.woItem.tasks!.count)")
                // print("task image  count = \(currentCell.woItem.tasks)")
                
                
                self.woItemViewController?.leadTasksWaiting = self.leadTasksWaiting
                //self.woItemViewController?.layoutViews()
                
                self.woItemViewController?.getWoItem(woItemID: currentCell.woItem.ID)
                
                navigationController?.pushViewController(self.woItemViewController!, animated: false )
                tableView.deselectRow(at: indexPath!, animated: false)
            }
        }
        
        
    }
    
    
    
    func addItem(){
        //print("add item rep: \(self.workOrder.repName)")
        
        
        if(self.workOrder.charge! == "2" && self.appDelegate.loggedInEmployee?.ID != self.workOrder.rep){
            var message:String = ""
            if(self.workOrder.repName != nil){
                message = "Contact sales rep: \(self.workOrder.repName!) or the office to add items to this work order."
            }else{
                message = "Contact the office to add items to this work order."
            }
            let alertController = UIAlertController(title: "Flat Price Work Order", message: message, preferredStyle: UIAlertController.Style.alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //self.popView()
            }
            
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            return
        }
        
        
        
        
        
        
        let newWoItemViewController:NewWoItemViewController = NewWoItemViewController(_woID: self.workOrder.ID, _charge: self.workOrder.charge!)
        
        newWoItemViewController.delegate = self
        
      
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        newWoItemViewController.loadLinkList(_linkType: "items", _loadScript: API.Router.itemList(["cb":timeStamp as AnyObject]))
        
        
        //imageUploadPrepViewController.delegate = self
        
        self.navigationController?.pushViewController(newWoItemViewController, animated: false )
        

    }
    
    
    
    func handleDatePicker()
    {
        ////print("DATE: \(dateFormatter.stringFromDate(datePickerView.date))")
       // self.dateTxtField.text =  dateFormatter.string(from: datePickerView.date)
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //let offset = (textField.frame.origin.y - 150)
        //let scrollPoint : CGPoint = CGPoint(x: 0, y: offset)
        //self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       // self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    // This triggers the textFieldDidEndEditing method that has the textField within it.
    //  This then triggers the resign() method to remove the keyboard.
    //  We use this in the "done" button action.
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    
    func setStatus(status: String) {
        
        
        switch (status) {
        case "1":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "4":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        case "5":
            let statusImg = UIImage(named:"waitingStatus.png")
            statusIcon.image = statusImg
            break;
            
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }

        
    }
    
    
    
    
    
    @objc func displayEditView(){
        print("display Edit View")
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        
        let newEditWorkOrderViewController = NewEditWoViewController(_wo:self.workOrder )
        newEditWorkOrderViewController.editDelegate = self
        navigationController?.pushViewController(newEditWorkOrderViewController, animated: false )
        
    }
    
    
    
    //Stack Delegates
    func displayAlert(_title: String) {
        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: _title, _message: "")
    }
    
   
    func newLeadView(_lead:Lead2){
        
        let leadViewController:LeadViewController = LeadViewController(_lead: _lead)
        //leadViewController
        self.navigationController?.pushViewController(leadViewController, animated: false )
        
    }
    
    
    func newContractView(_contract:Contract2){
        
        let contractViewController:ContractViewController = ContractViewController(_contract: _contract)
        contractViewController.editLeadDelegate = self
        self.navigationController?.pushViewController(contractViewController, animated: false )
        
    }
    
    func newWorkOrderView(_workOrder:WorkOrder2){
        
    }
    
    func newInvoiceView(_invoice:Invoice2){
        
        
        let invoiceViewController:InvoiceViewController = InvoiceViewController(_invoice: _invoice)
        self.navigationController?.pushViewController(invoiceViewController, animated: false )
        
        
        //self.navigationController?.pushViewController(_view, animated: false )
        
    }
    
    
    func setLeadTasksWaiting(_leadTasksWaiting:String){
        self.leadTasksWaiting = _leadTasksWaiting
    
    }
    
    //following 3 functions not used in this view
    func suggestNewContractFromLead(){
        print("suggestNewContractFromLead")
    }
    func suggestNewWorkOrderFromLead(){
        print("suggestNewWorkOrderFromLead")
    }
    func suggestNewWorkOrderFromContract(){
        print("suggestNewWorkOrderFromContract")
    }
    
    
    
    
    //lead Delegate
    func updateLead(_lead:Lead2,_newStatusValue:String){
        print("updateLead in work order view")
        
        
        
        
        
        /*
        self.workOrder.lead = _lead
        self.editsMade = true
        if self.editLeadDelegate != nil{
            self.editLeadDelegate.updateLead(_lead: self.workOrder.lead!, _newStatusValue: (self.workOrder.lead?.statusId)!)
        }
        */
        
        
        
        
        
        
        
    }
    
    /*
    func updateLead(_lead:Lead,_newStatusValue:String){
        self.workOrder.lead = _lead
        
    }
 */
    
    @objc func goBack(){
        if((self.usageDelegate) != nil){
            if(self.tableCellID! >= 0){
                self.usageDelegate?.reDrawList(_index: self.tableCellID!, _status: self.workOrder.status)
            }
        }
        
        
        
        /*
        print("go back editsMade: \(self.editsMade)")
        if editLeadDelegate != nil && self.editsMade == true{
            editLeadDelegate.updateLead(_lead: self.workOrder.lead!, _newStatusValue: (self.workOrder.lead?.statusId!)!)
        }
        */
        
        
        
        
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    
    
}









