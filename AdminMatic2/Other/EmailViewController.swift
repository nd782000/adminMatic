//
//  EmailViewController.swift
//  AdminMatic2
//
//  Created by Nick on 10/3/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation

import UIKit
import Alamofire
import SwiftyJSON
 

protocol EmailDelegate{
    func showLoadingView()
    func hideLoadingView()
    func addOneTimeEmail(_email:Contact)
    func updateTable(_newEmails:JSON)
    func updateEditsMade(_editsMade:Bool)
    func presentAlert(_alert:UIAlertController)
    
    
}




class EmailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate,UITextViewDelegate, EmailDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()

    
    var emailJSON:JSON!
    var emailCount:Int!
    var emails:[Contact]!
    var selectedEmails:[Bool]!
    var emailsToSend:[String]!
    
    var editsMade:Bool = false
    
    var customerID:String!
    var customerName:String!
    var type:String!
    var docID:String!
    var emailTitle:String!
    var emailMessage:String!
    var convertToPDF:String = "0"
    var sentStatus:String = "0"
    
    var viewTitleLbl:GreyLabel!
    
    var emailTableView: TableView!
    
    var titleLbl:Label!
    var titleTxt:UITextField!
    
    var messageLbl:Label!
    var messageTxt:UITextView!
    
    var convertToPDFSwitch:UISwitch!
    var convertToPDFLabel:Label!
    
    
    
    var contractDelegate:EditContractDelegate!
    
    var sendBtn: Button!
    
    
    
    
    
    init(_customerID:String,_customerName:String,_type:String,_docID:String){
        super.init(nibName:nil,bundle:nil)
        print("email init")
        
        self.customerID = _customerID
        self.customerName = _customerName
        self.type = _type
        self.docID = _docID
        
    }
    
    
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        // Do any additional setup after loading the view.
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(WorkOrderViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        title =  "Email \(self.customerName!)"
        
        
        getEmails()
    }
    
    
    
    
    
    func getEmails() {
        //remove any added views (needed for table refresh
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
       
        let parameters:[String:String]
        parameters = ["custID":self.customerID]
        print("parameters = \(parameters)")
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/customerEmails.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("crew response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
            
                    //print("JSON: \(json)")
                    self.emailJSON = JSON(json)
                    self.parseJSON()
                }
                
        }
        
    }
    func parseJSON(){
        emailCount = self.emailJSON["contacts"].count
    
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        emails = []
        selectedEmails = []
        emailsToSend = []
        
        for i in 0 ..< emailCount {
            
            let email = Contact(_ID: self.emailJSON["contacts"][i]["ID"].stringValue, _value: self.emailJSON["contacts"][i]["value"].stringValue)
            
            //print("email  = \(email.value)")
        
            self.emails.append(email)
            self.selectedEmails.append(true)
        }
        
        self.layoutViews()
        
    }
    
    func layoutViews(){
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        //titleLbl
        self.viewTitleLbl = GreyLabel()
        self.viewTitleLbl.text = "Send to the following:"
        self.viewTitleLbl.font = layoutVars.labelFont
        self.viewTitleLbl.textAlignment = .left
        self.viewTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(viewTitleLbl)
        
        //emailTable
        self.emailTableView  =   TableView()
        self.emailTableView.autoresizesSubviews = true
        self.emailTableView.delegate  =  self
        self.emailTableView.dataSource  =  self
        self.emailTableView.layer.cornerRadius = 4.0
        self.emailTableView.rowHeight = 56.0
        self.emailTableView.register(EmailTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.emailTableView)
        
        //titleLbl
        self.titleLbl = Label()
        self.titleLbl.text = "Email Title:"
        safeContainer.addSubview(titleLbl)
        
        
        
        //titleTxtField
        self.titleTxt = PaddedTextField()
        
        self.titleTxt.returnKeyType = .done
        
        self.titleTxt.delegate = self
        safeContainer.addSubview(self.titleTxt)
        
        //messageLbl
        self.messageLbl = Label()
        self.messageLbl.text = "Email Message:"
        
        safeContainer.addSubview(messageLbl)
        
        
        //messageTxt
        var messagePlaceHolder = ""
        
        
        switch type {
        case "1":
            self.titleTxt.text = "Atlantic Invoice #\(self.docID!)"
             messagePlaceHolder = "Here is your invoice. Thank you for your business."
            break
        case "2":
            self.titleTxt.text = "Atlantic Contract #\(self.docID!)"
             messagePlaceHolder = "Here is your contract.  Please review, sign and return to us. Thanks"
            break
        default:
            self.titleTxt.text = "Atlantic Contract #\(self.docID!)"
            messagePlaceHolder = "Here is your contract.  Please review, sign and return to us. Thanks"
        }
        
        self.messageTxt = UITextView()
        self.messageTxt.text = messagePlaceHolder
        
        self.messageTxt.translatesAutoresizingMaskIntoConstraints = false
        self.messageTxt.delegate = self
        self.messageTxt.font = layoutVars.smallFont
        self.messageTxt.returnKeyType = UIReturnKeyType.done
        self.messageTxt.layer.borderWidth = 1
        self.messageTxt.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.messageTxt.layer.cornerRadius = 4.0
        safeContainer.addSubview(self.messageTxt)
        
        //pdf
        self.convertToPDFLabel = Label()
        self.convertToPDFLabel.text = "Convert document to PDF:"
        self.convertToPDFLabel.textAlignment = .left
        self.convertToPDFLabel.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(convertToPDFLabel)
        
        convertToPDFSwitch = UISwitch()
        convertToPDFSwitch.translatesAutoresizingMaskIntoConstraints = false
        convertToPDFSwitch.isOn = false
        convertToPDFSwitch.addTarget(self, action: #selector(EmailViewController.convertToPDFSwitchValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(convertToPDFSwitch)
        
        //sendBtn
        self.sendBtn = Button(titleText: "Send")
        self.sendBtn.addTarget(self, action: #selector(EmailViewController.send), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(sendBtn)
    
        /////////  Auto Layout   //////////////////////////////////////
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "viewTitleLbl":self.viewTitleLbl,
            "emailTable":self.emailTableView,
            "titleLbl":self.titleLbl,
            "titleTxt":self.titleTxt,
            "messageLbl":self.messageLbl,
            "messageTxt":self.messageTxt,
            "convertToPDFLbl":self.convertToPDFLabel,
            "convertToPDFSwitch":self.convertToPDFSwitch,
            "sendBtn":self.sendBtn
            ] as [String:AnyObject]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[viewTitleLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[emailTable]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleTxt]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[messageLbl]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[messageTxt]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[convertToPDFLbl][convertToPDFSwitch(40)]-30-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[sendBtn]-15-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[viewTitleLbl(40)]-[emailTable]-[titleLbl(30)][titleTxt(40)]-[messageLbl(30)][messageTxt(100)]-[convertToPDFLbl(30)]-[sendBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[viewTitleLbl(40)]-[emailTable]-[titleLbl(30)][titleTxt(40)]-[messageLbl(30)][messageTxt(100)]-[convertToPDFSwitch(30)]-[sendBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        count = self.emails.count + 1
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:EmailTableViewCell = emailTableView.dequeueReusableCell(withIdentifier: "cell") as! EmailTableViewCell
        
        cell.customerID = self.customerID
        cell.delegate = self
        
        
        if(indexPath.row == self.emails.count){
            //cell add btn mode
            cell.layoutAddEmail()
        }else{
            
            cell.email = self.emails[indexPath.row]
            
            cell.layoutViews()
            if self.selectedEmails[indexPath.row] == true{
                cell.setCheck()
            }else{
                cell.unSetCheck()
            }
            
        }
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if indexPath.row != self.emails.count{
            let currentCell = tableView.cellForRow(at: indexPath) as! EmailTableViewCell
            if self.selectedEmails[indexPath.row] == true{
                self.selectedEmails[indexPath.row] = false
                currentCell.unSetCheck()
            }else{
                self.selectedEmails[indexPath.row] = true
                currentCell.setCheck()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row != emails.count{
            return true
        }else{
            return false
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //indexPath
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            //print("none button tapped")
            if self.editsMade == true{
                print("Edits Made")
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Edits Made", _message: "Please save edits to email address before trying to edit another email.")
                return
            }
            
            let currentCell = tableView.cellForRow(at: indexPath) as! EmailTableViewCell
            currentCell.editEmail()
        }
        edit.backgroundColor = UIColor.gray
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("cancel button tapped")
            self.deleteEmail(_row: indexPath.row)
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, edit]
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange")
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {        print("textFieldDidBeginEditing")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y -= 250
            
            
        }, completion: { finished in
            
        })
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y += 250
                
                
            }, completion: { finished in
            })
        }
    }
    
    
    
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y -= 250
            
            
        }, completion: { finished in
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y += 250
                
                
            }, completion: { finished in
            })
        }
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    */
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    
    
    
    @objc func convertToPDFSwitchValueDidChange(sender:UISwitch!)
    {
        //print("switchValueDidChange groupImages = \(groupImages)")
        
        if (sender.isOn == true){
            print("on")
            self.convertToPDF = "1"
        }
        else{
            print("off")
            self.convertToPDF = "0"
        }
    }

    
    func deleteEmail(_row:Int){
       
        let ID = self.emails[_row].ID
         print("delete email  ID: \(ID!)")
        
        if self.editsMade == true{
            print("Edits Made")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Edits Made", _message: "Please save edits to email address before trying to delete another email.")
            return
        }
        
        
        let alertController = UIAlertController(title: "Delete Customer Email?", message: "Do you want to permenantly delete this email from the customer file?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
            
            
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
            
            
            self.indicator = SDevIndicator.generate(self.view)!
            var parameters:[String:String]
            
            
            
            parameters = ["contactID": ID!, "custID":self.customerID]
            
            print("parameters = \(parameters)")
            
            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/customerEmail.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("send response = \(response)")
                }
                .responseJSON(){
                    response in
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        
                        
                    }
                    
                    self.emails.remove(at: _row)
                    self.selectedEmails.remove(at: _row)
                    
                    self.emailTableView.reloadData()
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
            }
            
            
            
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
    }
    

    
    @objc func goBack(){
        
        _ = navigationController?.popViewController(animated: false)
        
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
    
    
    func showLoadingView(){
        indicator = SDevIndicator.generate(self.view)!
    }
    
    func hideLoadingView(){
        self.indicator.dismissIndicator()
    }
    
    func addOneTimeEmail(_email:Contact){
        self.emails.append(_email)
        self.selectedEmails.append(true)
        self.emailTableView.reloadData()
    }
    
    
    func updateTable(_newEmails:JSON){
        self.emailJSON = _newEmails
        self.parseJSON()
    }
 
    
    func updateEditsMade(_editsMade:Bool){
        self.editsMade = _editsMade
    }
    
    func presentAlert(_alert:UIAlertController){
        self.present(_alert, animated: true, completion: nil)
    }
    
   
    func validate()->Bool{
        print("validate")
        self.emailsToSend = []
        //form emails that are selected to send to send method
         for i in 0 ..< self.emails.count {
            if self.selectedEmails[i] == true{
                self.emailsToSend.append(self.emails[i].value)
            }
        }
        
        
        if self.editsMade == true{
            print("Edits Made")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Edits Made", _message: "Please save edits to email address before sending email(s).")
            return false
        }
        
        if(self.emailsToSend.count == 0){
            print("Add an Email")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Emails Selected", _message: "Please select or add an email to send to.")
            return false
        }
        
        return true
    }
    
    
    

 
 @objc func send() {
    
    if(!validate()){
        print("didn't pass validation")
        return
    }
    
    
    
    indicator = SDevIndicator.generate(self.view)!
    self.title =  "Emailing..."
    
    let parameters:[String:String]
    
    let emails:String = emailsToSend.joined(separator: ", ")
    
    
    
    
    
        switch self.type {
        case "1":
            //print("docID = \(self.docID)")
            print("title = \(self.titleTxt.text!)")
            print("emails = \(emails)")
            //print("message = \(self.messageTxt.text)")
            print("pdf = \(self.convertToPDF)")
            
            parameters = ["invoiceID": self.docID!, "emails":emails,  "title":self.titleTxt.text!, "message":self.messageTxt.text!, "pdf":self.convertToPDF, "senderID": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)!]
            
            
            print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/send/invoice.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("send response = \(response)")
                }
                .responseJSON(){
                    response in
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        
                        //self.invoiceDelegate.suggestStatusChange(_emailCount:self.emailsToSend.count)
                        
                        
                    }
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    self.title =  "Email \(self.customerName!)"
            }
        break
        case "2":
            //print("docID = \(self.docID)")
            print("title = \(self.titleTxt.text!)")
            print("emails = \(emails)")
            //print("message = \(self.messageTxt.text)")
            print("pdf = \(self.convertToPDF)")
            
            parameters = ["contractID": self.docID!, "emails":emails,  "title":self.titleTxt.text!, "message":self.messageTxt.text!, "pdf":self.convertToPDF, "senderID": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)!]
            
            
            print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/send/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("send response = \(response)")
                }
                .responseJSON(){
                    response in
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        
                        self.contractDelegate.suggestStatusChange(_emailCount:self.emailsToSend.count)
                        
                        
                    }
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    self.title =  "Email \(self.customerName!)"
            }
        break
        default:
            print("default")
        }
    
    
    
    }
    
    
}









