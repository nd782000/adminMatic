//
//  GroupMessageViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/3/17.
//  Copyright © 2017 Nick. All rights reserved.
//
import Foundation
import UIKit
import MessageUI


class GroupMessageViewController: ViewControllerWithMenu, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    /////////////////////////////////
    //number of texts to send at once
    let textBatchQty:Int = 7
    /////////////////////////////////
    var messageTxt: PaddedTextField = PaddedTextField()
    var messagePlaceHolder:String!
    var selectNoneBtn:Button = Button(titleText: "Select None")
    var selectAllBtn:Button = Button(titleText: "Select All")
    var selectedStates:[Bool] = [Bool]()
    var employeeTableView: TableView!
    var sendMessageBtn:Button = Button(titleText: "Send Message")
    
    // for batch sending
    var textBatchNumber:Int = 0
    var textRecipients:[String] = [String]()
    var batchOfTexts:[String] = [String]()
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        view.backgroundColor = layoutVars.backgroundColor
        title = "Group Text"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(GroupMessageViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem

        
        for emp in self.appDelegate.employeeArray{
            selectedStates.append(true)
        }
        layoutViews()
    }
    
    
    func layoutViews(){
        
        
        messagePlaceHolder = "Message..."
        self.messageTxt.text = messagePlaceHolder
        self.messageTxt.textColor = UIColor.lightGray
        
        self.messageTxt.translatesAutoresizingMaskIntoConstraints = false
        self.messageTxt.delegate = self
        self.messageTxt.font = layoutVars.smallFont
        self.messageTxt.returnKeyType = UIReturnKeyType.done
        self.messageTxt.layer.cornerRadius = 4
        
        self.messageTxt.clipsToBounds = true
        self.messageTxt.backgroundColor = layoutVars.backgroundLight
        self.view.addSubview(self.messageTxt)
        
        self.selectNoneBtn.addTarget(self, action: #selector(GroupMessageViewController.handleSelectNone), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.selectNoneBtn)
        self.selectAllBtn.addTarget(self, action: #selector(GroupMessageViewController.handleSelectAll), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.selectAllBtn)
        
        self.employeeTableView =  TableView()
        self.employeeTableView.delegate  =  self
        self.employeeTableView.dataSource  =  self
        self.employeeTableView.rowHeight = 60.0
        self.employeeTableView.tableHeaderView = nil;
        self.employeeTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.employeeTableView)
        
        self.sendMessageBtn.addTarget(self, action: #selector(GroupMessageViewController.buildRecipientList), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.sendMessageBtn)
        
        //auto layout group
        let viewsDictionary = [
            "messageTxt":self.messageTxt,
            "selectNoneBtn":self.selectNoneBtn,
            "selectAllBtn":self.selectAllBtn,
            "empTable":self.employeeTableView,
            "sendMessageBtn":self.sendMessageBtn
            ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth":(layoutVars.fullWidth - 15)/2,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight + 5] as [String : Any]
        
    //////////////   auto layout position constraints   /////////////////////////////
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[messageTxt]-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[selectNoneBtn(halfWidth)]-5-[selectAllBtn(halfWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[empTable]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[sendMessageBtn]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[messageTxt(90)]-[selectNoneBtn(40)]-[empTable]-[sendMessageBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[messageTxt(90)]-[selectAllBtn(40)]-[empTable]-[sendMessageBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("appDelegate.employeeArray.count = \(appDelegate.employeeArray.count)")
        return appDelegate.employeeArray.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:EmployeeTableViewCell = employeeTableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeTableViewCell
        cell.employee = appDelegate.employeeArray[indexPath.row]
        cell.setPhone()
        cell.activityView.startAnimating()
        cell.nameLbl.text = cell.employee.name
        cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.employee.pic!)
        if(self.selectedStates[indexPath.row] == true){
            cell.accessoryType = .checkmark
            cell.isSelected = true
        }else{
            cell.accessoryType = .none
            cell.isSelected = false
        }
        if(cell.employee.phone == ""){
            cell.isUserInteractionEnabled = false
            self.selectedStates[indexPath.row] = false
            cell.accessoryType = .none
            cell.isSelected = false
            //cell.alpha = 0.5
        }else{
            cell.isUserInteractionEnabled = true
        }
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if let cell = tableView.cellForRow(at: indexPath) {
            if(self.selectedStates[indexPath.row] == true){
                cell.accessoryType = .none
                cell.isSelected = false
                self.selectedStates[indexPath.row] = false
            }else{
                cell.accessoryType = .checkmark
                cell.isSelected = true
                self.selectedStates[indexPath.row] = true
            }
            
        }
    }
 
    func textField(_ textField: UITextField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            messageTxt.resignFirstResponder()
            return false
        }
        return true
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.messageTxt.textColor == UIColor.lightGray {
            self.messageTxt.text = nil
            self.messageTxt.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.messageTxt.text?.isEmpty)! {
            self.messageTxt.text = messagePlaceHolder
            self.messageTxt.textColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    func handleSelectNone(){
        for index in 0 ..< selectedStates.count {
            selectedStates[index] = false
        }
        self.employeeTableView.reloadData()
    }
    
    func handleSelectAll(){
        for index in 0 ..< selectedStates.count {
            selectedStates[index] = true
        }
        self.employeeTableView.reloadData()
    }
    
    func buildRecipientList(){
        print("buildRecipientList")
        
        for index in 0 ..< appDelegate.employeeArray.count {
            if(selectedStates[index] == true){
                textRecipients.append(appDelegate.employeeArray[index].phone)
                print("phone = \(appDelegate.employeeArray[index].phone)")
            }
        }
        
        if(textRecipients.count == 0){
            let alertController = UIAlertController(title: "Select some recipients", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }else{
            //at least 1 recipient
            getBatch()
        }
    }
    
    
    func getBatch(){
        print("get batch")
        batchOfTexts = []
    //get next 5 numbers in list
        for index in 1...self.textBatchQty{
            print("adding index \(index) to batch")
            if((textRecipients.count) > i){
                batchOfTexts.append(textRecipients[i])
            }
            i += 1
        }
        textBatchNumber += 1
        sendTexts()
    }

    func sendTexts(){
        print("Send texts")
        if(batchOfTexts.count == 0){
            print("no texts to send")
            doneSendingBatches()
            return
        }
        if(self.messageTxt.text == self.messagePlaceHolder){
            let alertController = UIAlertController(title: "Message is Empty", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            let title:String!
            var message:String = ""
            if(batchOfTexts.count == 1){
                title = "Send \(batchOfTexts.count) Text?"
            }else{
                title = "Send \(batchOfTexts.count) Texts?"
            }
            if(textRecipients.count <= self.textBatchQty){
                message = ""
            }else{
                message = "Batch \(textBatchNumber)"
            }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = "\(self.messageTxt.text!) ~ Atlantic Group Message by \((self.appDelegate.loggedInEmployee?.name!)!)"
                    controller.recipients = self.batchOfTexts
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
        getBatch()
    }
    
    func doneSendingBatches(){
        print ("done with batches")
        self.messageTxt.text = self.messagePlaceHolder
        self.messageTxt.textColor = UIColor.lightGray
        textBatchNumber = 0
        i = 0
        textRecipients = []
        batchOfTexts = []
    }
    
    func goBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
