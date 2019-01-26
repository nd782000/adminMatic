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


class GroupMessageViewController: ViewControllerWithMenu, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    /////////////////////////////////
    //number of texts to send at once
    let textBatchQty:Int = 7
    /////////////////////////////////
    //var messageTxt: PaddedTextField = PaddedTextField()
    
    var messageTxt:UITextView!
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
    
    
    var employees:[Employee] = []
    var mode:String?  //used for title to display "dept" or "crew"
    
    
    
    
    
    init(){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
    }
    
    //new from dept or crew view
    init(_employees:[Employee],_mode:String){
        super.init(nibName:nil,bundle:nil)
        self.employees = _employees
        self.mode = _mode
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        view.backgroundColor = layoutVars.backgroundColor
        
        if employees.count > 0{
            title = "\(self.mode!) Text"
            //handleSelectVarious()
        }else{
            title = "Group Text"
        }
        
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(GroupMessageViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem

        for index in 0 ..< self.appDelegate.employeeArray.count {
            print("emp phone = \(appDelegate.employeeArray[index].phone)")
        //for _ in self.appDelegate.employeeArray{
              if  appDelegate.employeeArray[index].phone! != "No Phone Number"{
                selectedStates.append(true)
            }else{
                selectedStates.append(false)
            }
        }
        layoutViews()
    }
    
    
    func layoutViews(){
        
       
        
        
        messagePlaceHolder = "Message..."
        
        
        
        self.messageTxt = UITextView()
        self.messageTxt.textColor = UIColor.lightGray
        self.messageTxt.layer.cornerRadius = 4
        self.messageTxt.layer.borderColor = layoutVars.buttonColor1.cgColor
        self.messageTxt.layer.borderWidth = 1.0
        self.messageTxt.returnKeyType = .done
        self.messageTxt.text = messagePlaceHolder
        self.messageTxt.font = layoutVars.smallFont
        self.messageTxt.isEditable = true
        self.messageTxt.delegate = self
        self.messageTxt.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.messageTxt)
        
       
        
        
        
        self.selectNoneBtn.addTarget(self, action: #selector(GroupMessageViewController.handleSelectNone), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.selectNoneBtn)
        self.selectAllBtn.addTarget(self, action: #selector(GroupMessageViewController.handleSelectAll), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.selectAllBtn)
        
        self.employeeTableView =  TableView()
        self.employeeTableView.delegate  =  self
        self.employeeTableView.dataSource  =  self
        self.employeeTableView.rowHeight = 60.0
        self.employeeTableView.tableHeaderView = nil;
        self.employeeTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.employeeTableView)
        
        
        
        if employees.count > 0{
            handleSelectVarious()
        }
        
        
        self.sendMessageBtn.addTarget(self, action: #selector(GroupMessageViewController.buildRecipientList), for: UIControl.Event.touchUpInside)
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
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[messageTxt(90)]-[selectNoneBtn(40)]-[empTable]-[sendMessageBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[messageTxt(90)]-[selectAllBtn(40)]-[empTable]-[sendMessageBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
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
        
        if appDelegate.employeeArray[indexPath.row].phone != "" && appDelegate.employeeArray[indexPath.row].phone != "No Phone Number"{
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
        
    }
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange")
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textFieldDidBeginEditing")
        
        if self.messageTxt.textColor == UIColor.lightGray {
            self.messageTxt.text = nil
            self.messageTxt.textColor = UIColor.black
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        if (self.messageTxt.text?.isEmpty)! {
            self.messageTxt.text = messagePlaceHolder
            self.messageTxt.textColor = UIColor.lightGray
        }
    }
    
    
    func handleSelectVarious(){
        
        print("select various")
        for index in 0 ..< selectedStates.count {
            selectedStates[index] = false
        }
        
        for i in 0 ..<  self.employees.count{
            for n in 0 ..<  self.appDelegate.employeeArray.count{
                if appDelegate.employeeArray[n].ID == self.employees[i].ID {
                    selectedStates[n] = true
                }
                
                print("emp phone = \(appDelegate.employeeArray[n].phone)")
                if appDelegate.employeeArray[n].phone == "" || appDelegate.employeeArray[n].phone == "No Phone Number"{
                    selectedStates[n] = false
                }
            }
            
        }
        
        /*
            if self.employees[index] == nil{
                selectedStates[index] = false
            }else{
                if appDelegate.employeeArray[index].ID == self.employees[index].ID {
                    selectedStates[index] = true
                }else{
                    selectedStates[index] = false
                }
            }
            
        }
        */
        
         self.employeeTableView.reloadData()
        
        /*
        for index in 0 ..< selectedStates.count {
            
            
            selectedStates[index] = false
        }
       
 */
        
        
    }
    
   

    
    @objc func handleSelectNone(){
        for index in 0 ..< selectedStates.count {
            selectedStates[index] = false
        }
        self.employeeTableView.reloadData()
    }
    
    @objc func handleSelectAll(){
        for index in 0 ..< selectedStates.count {
            selectedStates[index] = true
        }
        self.employeeTableView.reloadData()
    }
    
    @objc func buildRecipientList(){
        print("buildRecipientList")
        
        for index in 0 ..< appDelegate.employeeArray.count {
            if(selectedStates[index] == true){
                textRecipients.append(appDelegate.employeeArray[index].phone)
               // print("phone = \(appDelegate.employeeArray[index].phone)")
            }
        }
        
        if(textRecipients.count == 0){
            let alertController = UIAlertController(title: "Select some recipients", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
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
            let alertController = UIAlertController(title: "Message is Empty", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
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
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
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
            //layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
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
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
