//
//  StackController.swift
//  AdminMatic2
//
//  Created by Nick on 10/6/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation
import UIKit
import SwiftyJSON
import  Alamofire
 
protocol StackDelegate {
    func displayAlert(_title:String)
    func newLeadView(_lead:Lead)
    func newContractView(_contract:Contract)
    func newWorkOrderView(_workOrder:WorkOrder)
    func newInvoiceView(_invoice:Invoice)
    func setLeadTasksWaiting(_leadTasksWaiting:String)
    func suggestNewContractFromLead()
    func suggestNewWorkOrderFromLead()
    func suggestNewWorkOrderFromContract()

}




class StackController:UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    //var exampleBtn:Button = Button(titleText: "Test")
    let items = ["Lead >","Contract >", "W.O. >", "Invoice"]
    var layoutVars:LayoutVars = LayoutVars()
    var stackJson:JSON!
    var type:Int!
    
    var leads:[Lead] = []
    var contracts:[Contract] = []
    var workOrders:[WorkOrder] = []
    var invoices:[Invoice] = []
    
    var leadBtn:Button = Button(titleText: "Lead(0)")
    var selectedLead: Lead!
    
    var loadingView:UIView = UIView()
    var contractBtn:Button = Button(titleText: "Contract(0)")
    var contractTxtField:PaddedTextField!
    var contractPicker: Picker!
    var selectedContract: Contract!
    
    
    var workOrderBtn:Button = Button(titleText: "W.O.(0)")
    var workOrderTxtField:PaddedTextField!
    var workOrderPicker: Picker!
    var selectedWorkOrder: WorkOrder!
    
    var invoiceBtn:Button = Button(titleText: "Invoice(0)")
    var invoiceTxtField:PaddedTextField!
    var invoicePicker: Picker!
    var selectedInvoice: Invoice!
    
    var delegate:StackDelegate!
   
    let stackHeight:CGFloat = 40.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changeStack(sender: UISegmentedControl){
        print("change stack")
        
        
        
        
    }
    
    
    
    
    func getStack(_type:Int,_ID:String){
        print("get stack")
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.type = _type
        
        
        self.leadBtn.addTarget(self, action: #selector(StackController.handleLead), for: UIControl.Event.touchUpInside)
        self.leadBtn.layer.cornerRadius = 0.0
        self.leadBtn.backgroundColor = UIColor.lightGray
        self.leadBtn.layer.borderColor = layoutVars.buttonColor1.cgColor
        self.leadBtn.layer.borderWidth = 2.0
        //self.leadBtn.titleLabel?.textColor = layoutVars.buttonColor1
        self.leadBtn.setTitleColor(layoutVars.buttonColor1, for: .normal)
        self.addSubview(self.leadBtn)
        
        self.contractBtn.addTarget(self, action: #selector(StackController.handleContract), for: UIControl.Event.touchUpInside)
        self.contractBtn.layer.cornerRadius = 0.0
        self.contractBtn.backgroundColor = UIColor.lightGray
        self.contractBtn.layer.borderColor = layoutVars.buttonColor1.cgColor
        self.contractBtn.layer.borderWidth = 2.0
        //self.contractBtn.titleLabel?.textColor = layoutVars.buttonColor1
        self.contractBtn.setTitleColor(layoutVars.buttonColor1, for: .normal)
        self.addSubview(self.contractBtn)
        
        
        //contract picker
        self.contractPicker = Picker()
        //print("contractValue : \(contractValue)")
    //print("set picker position : \(Int(self.contractValue)!)")
        
        self.contractPicker.delegate = self
        self.contractPicker.dataSource = self
        self.contractPicker.tag = 1
        
        
        //self.contractPicker.selectRow(Int(self.contractValue)!, inComponent: 0, animated: false)
        
        self.contractTxtField = PaddedTextField(placeholder: "")
        self.contractTxtField.textAlignment = NSTextAlignment.center
        self.contractTxtField.translatesAutoresizingMaskIntoConstraints = false
        
        self.contractTxtField.delegate = self
        self.contractTxtField.tintColor = UIColor.clear
        self.contractTxtField.backgroundColor = UIColor.clear
        self.contractTxtField.inputView = contractPicker
        self.contractTxtField.layer.borderWidth = 0
        //self.contractTxtField.i
        self.contractTxtField.canPaste = false
        self.addSubview(self.contractTxtField)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor(hex:0x005100, op:1)
        toolBar.sizeToFit()
        
        let contractCloseButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StackController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Go To Contract", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StackController.handleContractChange))
        
        toolBar.setItems([contractCloseButton, spaceButton, setButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        contractTxtField.inputAccessoryView = toolBar
        
        
        
        
        
        
        self.workOrderBtn.addTarget(self, action: #selector(StackController.handleWorkOrder), for: UIControl.Event.touchUpInside)
        self.workOrderBtn.layer.cornerRadius = 0.0
        self.workOrderBtn.backgroundColor = UIColor.lightGray
        self.workOrderBtn.layer.borderColor = layoutVars.buttonColor1.cgColor
        self.workOrderBtn.layer.borderWidth = 2.0
        //self.workOrderBtn.titleLabel?.textColor = layoutVars.buttonColor1
        self.workOrderBtn.setTitleColor(layoutVars.buttonColor1, for: .normal)
        self.addSubview(self.workOrderBtn)
        
        //workOrder picker
        self.workOrderPicker = Picker()
        //print("workOrderValue : \(workOrderValue)")
       // print("set picker position : \(Int(self.workOrderValue)! - 1)")
        
        self.workOrderPicker.delegate = self
        self.workOrderPicker.dataSource = self
        self.workOrderPicker.tag = 2
        
       // self.workOrderPicker.selectRow(Int(self.workOrderValue)! - 1, inComponent: 0, animated: false)
        
        self.workOrderTxtField = PaddedTextField(placeholder: "")
        self.workOrderTxtField.textAlignment = NSTextAlignment.center
        self.workOrderTxtField.translatesAutoresizingMaskIntoConstraints = false
        
        self.workOrderTxtField.delegate = self
        self.workOrderTxtField.tintColor = UIColor.clear
        self.workOrderTxtField.backgroundColor = UIColor.clear
        self.workOrderTxtField.inputView = workOrderPicker
        self.workOrderTxtField.layer.borderWidth = 0
        self.workOrderTxtField.canPaste = false
        self.addSubview(self.workOrderTxtField)
        
        let workOrderToolBar = UIToolbar()
        workOrderToolBar.barStyle = UIBarStyle.default
        workOrderToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        workOrderToolBar.sizeToFit()
        
        let workOrderCloseButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StackController.cancelPicker))
        let workOrderSetButton = UIBarButtonItem(title: "Go To WorkOrder", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StackController.handleWorkOrderChange))
        
        workOrderToolBar.setItems([workOrderCloseButton, spaceButton, workOrderSetButton], animated: false)
        workOrderToolBar.isUserInteractionEnabled = true
        
        workOrderTxtField.inputAccessoryView = workOrderToolBar
        
       
        
        
        
        self.invoiceBtn.addTarget(self, action: #selector(StackController.handleInvoice), for: UIControl.Event.touchUpInside)
        self.invoiceBtn.layer.cornerRadius = 0.0
        self.invoiceBtn.backgroundColor = UIColor.lightGray
        self.invoiceBtn.layer.borderColor = layoutVars.buttonColor1.cgColor
        self.invoiceBtn.layer.borderWidth = 2.0
        //self.invoiceBtn.titleLabel?.textColor = layoutVars.buttonColor1
        self.invoiceBtn.setTitleColor(layoutVars.buttonColor1, for: .normal)
        self.addSubview(self.invoiceBtn)
        
        
        //invoice picker
        self.invoicePicker = Picker()
        //print("invoiceValue : \(invoiceValue)")
        //print("set picker position : \(Int(self.invoiceValue)! - 1)")
        
        self.invoicePicker.delegate = self
        self.invoicePicker.dataSource = self
         self.invoicePicker.tag = 3
        //self.invoicePicker.selectRow(Int(self.invoiceValue)! - 1, inComponent: 0, animated: false)
        
        self.invoiceTxtField = PaddedTextField(placeholder: "")
        self.invoiceTxtField.textAlignment = NSTextAlignment.center
        self.invoiceTxtField.translatesAutoresizingMaskIntoConstraints = false
       
        self.invoiceTxtField.delegate = self
        self.invoiceTxtField.tintColor = UIColor.clear
        self.invoiceTxtField.backgroundColor = UIColor.clear
        self.invoiceTxtField.inputView = invoicePicker
        self.invoiceTxtField.layer.borderWidth = 0
        self.invoiceTxtField.canPaste = false
        self.addSubview(self.invoiceTxtField)
        
        let invoiceToolBar = UIToolbar()
        invoiceToolBar.barStyle = UIBarStyle.default
        invoiceToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        invoiceToolBar.sizeToFit()
        
        let invoiceCloseButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StackController.cancelPicker))
        //let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let invoiceSetButton = UIBarButtonItem(title: "Go To Invoice", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StackController.handleInvoiceChange))
        
        invoiceToolBar.setItems([invoiceCloseButton, spaceButton, invoiceSetButton], animated: false)
        invoiceToolBar.isUserInteractionEnabled = true
        
        invoiceTxtField.inputAccessoryView = invoiceToolBar
        
        
        leadBtn.isEnabled = false
        contractBtn.isEnabled = false
        workOrderBtn.isEnabled = false
        invoiceBtn.isEnabled = false
        
        contractTxtField.isHidden = true
        workOrderTxtField.isHidden = true
        invoiceTxtField.isHidden = true
        
    //loading view
        self.loadingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: layoutVars.fullWidth, height: stackHeight))
        self.loadingView.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        self.addSubview(self.loadingView)
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        let metricsDictionary = ["quarterWidth": layoutVars.fullWidth/4, "height":stackHeight] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "lead":self.leadBtn,
            "contract":self.contractBtn,
            "contractTxt":self.contractTxtField,
            "workOrder":self.workOrderBtn,
            "workOrderTxt":self.workOrderTxtField,
            "invoice":self.invoiceBtn,
            "invoiceTxt":self.invoiceTxtField
            ] as [String:AnyObject]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lead(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contract(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contractTxt(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[workOrder(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[workOrderTxt(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[invoice(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[invoiceTxt(height)]", options: [], metrics:metricsDictionary, views: viewsDictionary))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lead(quarterWidth)][contract(quarterWidth)][workOrder(quarterWidth)][invoice(quarterWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lead(quarterWidth)][contractTxt(quarterWidth)][workOrderTxt(quarterWidth)][invoiceTxt(quarterWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
       
        
        
       
        
        let parameters:[String:String]
        
        
        
         switch self.type {
         case 0:
            leadBtn.backgroundColor = layoutVars.buttonColor1
            self.leadBtn.setTitleColor(UIColor.white, for: .normal)
            parameters = ["leadID": _ID]
         break
         case 1:
            contractBtn.backgroundColor = layoutVars.buttonColor1
            self.contractBtn.setTitleColor(UIColor.white, for: .normal)
            parameters = ["contractID": _ID]
         break
         case 2:
            workOrderBtn.backgroundColor = layoutVars.buttonColor1
            self.workOrderBtn.setTitleColor(UIColor.white, for: .normal)
            parameters = ["workOrderID": _ID]
         break
         case 3:
            invoiceBtn.backgroundColor = layoutVars.buttonColor1
            self.invoiceBtn.setTitleColor(UIColor.white, for: .normal)
            parameters = ["invoiceID": _ID]
         break
         default:
            leadBtn.backgroundColor = layoutVars.buttonColor1
            self.leadBtn.setTitleColor(UIColor.white, for: .normal)
            parameters = ["leadID": _ID]
         break
         }
        
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/systemStack.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("stack response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.stackJson = JSON(json)
                    self.parseStack()
                }
                print(" dismissIndicator")
                //self.indicator.dismissIndicator()
        }
        
        
        
    }
    
    func parseStack(){
        print("parse stack")
        
        self.delegate.setLeadTasksWaiting(_leadTasksWaiting: self.stackJson["leadTasksWaiting"].stringValue)
        
        let leadCount = self.stackJson["leads"].count
        self.leadBtn.setTitle("Lead(\(leadCount))", for: .normal)
        print("leadCount: \(leadCount)")
        for i in 0 ..< leadCount {
            let lead =  Lead(_ID: self.stackJson["leads"][i]["ID"].stringValue, _statusID: self.stackJson["leads"][i]["status"].stringValue, _scheduleType: self.stackJson["leads"][i]["timeType"].stringValue, _date: self.stackJson["leads"][i]["date"].stringValue, _time: self.stackJson["leads"][i]["time"].stringValue, _statusName: self.stackJson["leads"][i]["statusName"].stringValue, _customer: self.stackJson["leads"][i]["customer"].stringValue, _customerName: self.stackJson["leads"][i]["custName"].stringValue, _urgent: self.stackJson["leads"][i]["urgent"].stringValue, _description: self.stackJson["leads"][i]["description"].stringValue, _rep: self.stackJson["leads"][i]["salesRep"].stringValue, _repName: self.stackJson["leads"][i]["repName"].stringValue, _deadline: self.stackJson["leads"][i]["deadline"].stringValue, _requestedByCust: self.stackJson["leads"][i]["requestedByCust"].stringValue, _createdBy: self.stackJson["leads"][i]["createdBy"].stringValue, _daysAged: self.stackJson["leads"][i]["daysAged"].stringValue)
            
            lead.dateNice = self.stackJson["leads"][i]["dateNice"].stringValue
            
            lead.custNameAndID = "\(lead.customerName!) #\(lead.ID!)"
            
            self.leads.append(lead)
        }
        
        //if self.leads.count > 0 {
            //delegate.getLead(_lead: self.leads[0])
        //}
        if self.leads.count > 0 {
            self.selectedLead = self.leads[0]
            }
        
        let contractCount = self.stackJson["contracts"].count
        print("contractCount: \(contractCount)")
        self.contractBtn.setTitle("Contract(\(contractCount))", for: .normal)
        
       
        
        for i in 0 ..< contractCount {
            let contract = Contract(_ID: self.stackJson["contracts"][i]["ID"].stringValue, _title: self.stackJson["contracts"][i]["title"].stringValue, _status: self.stackJson["contracts"][i]["status"].stringValue, _statusName: self.stackJson["contracts"][i]["statusName"].stringValue, _chargeType: self.stackJson["contracts"][i]["chargeType"].stringValue, _customer: self.stackJson["contracts"][i]["customer"].stringValue, _customerName: self.stackJson["contracts"][i]["custName"].stringValue, _notes: self.stackJson["contracts"][i]["notes"].stringValue, _salesRep: self.stackJson["contracts"][i]["salesRep"].stringValue, _repName: self.stackJson["contracts"][i]["repName"].stringValue, _createdBy: self.stackJson["contracts"][i]["createdBy"].stringValue, _createDate: self.stackJson["contracts"][i]["createDate"].stringValue, _subTotal: self.stackJson["contracts"][i]["subTotal"].stringValue, _taxTotal: self.stackJson["contracts"][i]["taxTotal"].stringValue, _total: self.stackJson["contracts"][i]["total"].stringValue, _terms: self.stackJson["contracts"][i]["termsDescription"].stringValue, _daysAged: self.stackJson["contracts"][i]["daysAged"].stringValue)
            
            
            
            
            contract.custNameAndID = "\(contract.customerName!) #\(contract.ID!)"
            
            contract.repSignature  = self.stackJson["contracts"][i]["companySigned"].stringValue
            contract.customerSignature  = self.stackJson["contracts"][i]["customerSigned"].stringValue
            
            
            
            self.contracts.append(contract)
            
        }
        
        if contracts.count > 1 {
            self.selectedContract = contracts[0]
        }
        
        let workOrderCount:Int = self.stackJson["workOrders"].count
        ////print("workOrderCount: \(workOrderCount)")
        self.workOrderBtn.setTitle("W.O.(\(workOrderCount))", for: .normal)

        //self.fullScheduleArray = []
        for i in 0 ..< workOrderCount {
            
            let workOrder = WorkOrder(_ID: self.stackJson["workOrders"][i]["ID"].stringValue, _statusID: self.stackJson["workOrders"][i]["statusID"].stringValue, _date: self.stackJson["workOrders"][i]["date"].stringValue, _firstItem: self.stackJson["workOrders"][i]["firstItem"].stringValue, _statusName: self.stackJson["workOrders"][i]["statusName"].stringValue, _customer: self.stackJson["workOrders"][i]["customer"].stringValue, _type: self.stackJson["workOrders"][i]["type"].stringValue, _progress: self.stackJson["workOrders"][i]["progress"].stringValue, _totalPrice: self.stackJson["workOrders"][i]["totalPrice"].stringValue, _totalCost: self.stackJson["workOrders"][i]["totalCost"].stringValue, _totalPriceRaw: self.stackJson["workOrders"][i]["totalPriceRaw"].stringValue, _totalCostRaw: self.stackJson["workOrders"][i]["totalCostRaw"].stringValue, _charge: self.stackJson["workOrders"][i]["charge"].stringValue, _title: self.stackJson["workOrders"][i]["title"].stringValue, _customerName: self.stackJson["workOrders"][i]["customerName"].stringValue)
            
           /* if(plowSort == "1"){
                workOrder.plowPriority = self.fullScheduleJSON["workOrder"][i]["plowPriority"].stringValue
                workOrder.plowDepth = self.fullScheduleJSON["workOrder"][i]["plowDepth"].stringValue
                workOrder.plowMonitoring = self.fullScheduleJSON["workOrder"][i]["plowMonitorList"].stringValue
            }
 */
            
            
            self.workOrders.append(workOrder)
        }
        
        if workOrders.count > 1 {
            self.selectedWorkOrder = workOrders[0]
        }
        
        let invoiceCount:Int = self.stackJson["invoices"].count
        ////print("workOrderCount: \(workOrderCount)")
        self.invoiceBtn.setTitle("Invoice(\(invoiceCount))", for: .normal)
        
        //self.fullScheduleArray = []
        for i in 0 ..< invoiceCount {
            
           // let invoice = Invoice(_ID: self.stackJson["invoices"][i]["ID"].stringValue, _date: self.stackJson["invoices"][i]["ID"].stringValue, _customer: self.stackJson["invoices"][i]["ID"].stringValue, _totalPrice: self.stackJson["invoices"][i]["ID"].stringValue, _totalCost: self.stackJson["invoices"][i]["ID"].stringValue, _totalPriceRaw: self.stackJson["invoices"][i]["ID"].stringValue, _totalCostRaw: self.stackJson["invoices"][i]["ID"].stringValue, _charge: self.stackJson["invoices"][i]["ID"].stringValue)
            
            
            let invoice = Invoice(_ID: self.stackJson["invoices"][i]["ID"].stringValue, _date: self.stackJson["invoices"][i]["invoiceDate"].stringValue,_customer: self.stackJson["invoices"][i]["customer"].stringValue, _customerName: self.stackJson["invoices"][i]["custName"].stringValue, _totalPrice: "$\(self.stackJson["invoices"][i]["total"].stringValue)", _status: self.stackJson["invoices"][i]["invoiceStatus"].stringValue)
            
            
            self.invoices.append(invoice)
        }
        
        if invoices.count > 1 {
            self.selectedInvoice = invoices[0]
        }
        
        
        
        if type != 1 && contracts.count > 1{
            contractTxtField.isHidden = false
        }
        if type != 2 && workOrders.count > 1 {
            workOrderTxtField.isHidden = false
        }
        if type != 3 && invoices.count > 1{
            invoiceTxtField.isHidden = false
        }
        
        leadBtn.isEnabled = true
        contractBtn.isEnabled = true
        workOrderBtn.isEnabled = true
        invoiceBtn.isEnabled = true
        
        self.hideLoadingView()
        
        
    }
    
    @objc func handleLead(){
        print("handleLead")
        
        
        
        if type != 0{
            if leads.count > 0{
                //let leadViewController:LeadViewController = LeadViewController(_lead: leads[0])
                //self.delegate.callNewView(_view: leadViewController)
                self.delegate.newLeadView(_lead: leads[0])
            }else{
                cancelPicker()
                delegate.displayAlert(_title: "No Lead Exists")
                
            }
        }
        
       
        
    }
    
    @objc func handleContract(){
        print("handleContract")
        
        if type != 1{
            if self.contracts.count > 0{
                //let contractViewController:ContractViewController = ContractViewController(_contract: self.contracts[0])
                //self.delegate.callNewView(_view: contractViewController)
                //if self.selectedLead != nil{
                    
                //}
                self.contracts[0].lead = self.selectedLead
                self.delegate.newContractView(_contract: self.contracts[0])
            }else{
                cancelPicker()
                if type == 0{
                    self.delegate.suggestNewContractFromLead()
                }else{
                    delegate.displayAlert(_title: "No Contracts Exist")
                }
                
                
            }
        }
    }
    
    @objc func handleWorkOrder(){
        print("handleWorkOrder")
        
        if type != 2{
            if workOrders.count > 0{
              //  let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrder: self.workOrders[0], _customerName: self.workOrders[0].customerName)
                //self.delegate.callNewView(_view: workOrderViewController)
                self.workOrders[0].lead = self.selectedLead
                self.delegate.newWorkOrderView(_workOrder: self.workOrders[0])
            }else{
                cancelPicker()
                //delegate.displayAlert(_title: "No Work Orders Exist")
                if type == 0{
                    self.delegate.suggestNewWorkOrderFromLead()
                }else if type == 1{
                    self.delegate.suggestNewWorkOrderFromContract()
                }else{
                    delegate.displayAlert(_title: "No WorkOrders Exist")
                }
                
            }
        }
    }
    
    @objc func handleInvoice(){
        print("handleInvoice")
        
        if type != 3{
            if invoices.count > 0{
               // let invoiceViewController:InvoiceViewController = InvoiceViewController(_invoice: invoices[0])
                self.delegate.newInvoiceView(_invoice: invoices[0])
               // self.delegate.newInvoiceView(_invoice: <#T##Invoice#>)
            }else{
                cancelPicker()
                delegate.displayAlert(_title: "No Invoices Exist")
                
            }
        }
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        switch pickerView.tag {
        case 1:
            return self.contracts.count
        case 2:
            return self.workOrders.count
        case 3:
            return self.invoices.count
            
        default:
            return self.contracts.count
        }
    }
    
    
    /*
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        //return self.contracts.count
        
        switch pickerView.tag {
        case 1:
            return self.contracts.count
        case 2:
            return self.workOrders.count
        case 3:
            return self.invoices.count
            
        default:
            return self.contracts.count
        }
    }
    */
    
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return "#\(self.contracts[row].ID) \(self.contracts[row].title )"
        
       // return self.contracts.count
        
        switch pickerView.tag {
        case 1:
            return "#\(self.contracts[row].ID!) \(self.contracts[row].title!)"
        case 2:
            return "#\(self.workOrders[row].ID!) \(self.workOrders[row].title!)"
        case 3:
            return "#\(self.invoices[row].ID!) \(self.invoices[row].customerName!)"
            
        default:
            return "default"
        }
        
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        switch pickerView.tag {
        case 1:
            self.selectedContract = self.contracts[row]
        case 2:
            self.selectedWorkOrder = self.workOrders[row]
        case 3:
            self.selectedInvoice = self.invoices[row]
            
        default:
            self.selectedContract = self.contracts[row]
        }
    }
    
    @objc func cancelPicker(){
        self.contractTxtField.resignFirstResponder()
        self.workOrderTxtField.resignFirstResponder()
        self.invoiceTxtField.resignFirstResponder()
        
    }
    
    @objc func handleContractChange(){
        
        self.contractTxtField.resignFirstResponder()
        
        //let contractViewController:ContractViewController = ContractViewController(_contract: self.selectedContract)
       // self.delegate.callNewView(_view: contractViewController)
        self.selectedContract.lead = self.selectedLead
        self.delegate.newContractView(_contract: self.selectedContract)

    }
    
    @objc func handleWorkOrderChange(){
        
        self.workOrderTxtField.resignFirstResponder()
        //let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrder: self.selectedWorkOrder, _customerName: self.selectedWorkOrder.customerName)
        //self.delegate.callNewView(_view: workOrderViewController)
        self.selectedWorkOrder.lead = self.selectedLead
        self.delegate.newWorkOrderView(_workOrder: self.selectedWorkOrder)
        
        
    }
    
    @objc func handleInvoiceChange(){
        
        self.invoiceTxtField.resignFirstResponder()
       // let invoiceViewController:InvoiceViewController = InvoiceViewController(_invoice: self.selectedInvoice)
        //self.delegate.callNewView(_view: invoiceViewController)
       // self.selectedInvoice = self.selectedInvoice
        self.delegate.newInvoiceView(_invoice: self.selectedInvoice)
        
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
    
    
    
    
    func hideLoadingView(){
        print("hide loading view")
        
        let originalTransform = self.loadingView.transform
       // let scaledTransform = originalTransform.scaledBy(x: 1.0, y: 1.0)
        let scaledAndTranslatedTransform = originalTransform.translatedBy(x: layoutVars.fullWidth, y: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.transform = scaledAndTranslatedTransform
            //self.loadingView.alpha = 0.0
        }, completion: { _ in
            print("stack loading complete")
            self.loadingView.isHidden = true
        })
    }
    
    
    
    
    
    
    
    
}
