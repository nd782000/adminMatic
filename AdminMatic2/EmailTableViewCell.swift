//
//  EmailTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 10/4/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class EmailTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    var email:Contact!
    var checkMarkView:UIImageView = UIImageView()
    var emailLbl: Label! = Label()
    var addTxt:PaddedTextField = PaddedTextField()
    var addBtn:Button! = Button(titleText: "+")
    var customerID:String!
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:EmailDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func layoutViews(){
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        emailLbl.text = self.email.value
        emailLbl.font = layoutVars.buttonFont
        contentView.addSubview(emailLbl)
        
        
        checkMarkView = UIImageView()
        checkMarkView.translatesAutoresizingMaskIntoConstraints = false
        checkMarkView.backgroundColor = UIColor.clear
        checkMarkView.contentMode = .scaleAspectFill
        contentView.addSubview(checkMarkView)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        setConstraintsWithCheckMark()
    }
    
    
    func setConstraintsWithCheckMark(){
        
        let viewsDictionary = ["checkMark":self.checkMarkView,"email":emailLbl] as [String:AnyObject]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth - 90] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[checkMark(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[email(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[checkMark(40)][email]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
     func layoutAddEmail(){
        
         self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
         self.selectionStyle = .none
        
         self.addTxt.text = ""
         self.addTxt.returnKeyType = .done
         self.addTxt.delegate = self
         self.addTxt.autocapitalizationType = UITextAutocapitalizationType.none
         self.addTxt.keyboardType = UIKeyboardType.emailAddress
         contentView.addSubview(self.addTxt)
         self.addBtn.addTarget(self, action: #selector(EmailTableViewCell.addEmail), for: UIControlEvents.touchUpInside)
         contentView.addSubview(self.addBtn)
        
         let viewsDictionary = ["addTxt":self.addTxt,"addBtn":self.addBtn] as [String : Any]
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addTxt]-[addBtn(40)]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[addTxt(40)]", options: [], metrics: nil, views: viewsDictionary))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
     
     }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    

    func setCheck(){
        let blueCheckImg = UIImage(named:"checkMarkBlue.png")
        checkMarkView.image = blueCheckImg
    }
    
    func unSetCheck(){
        let grayCheckImg = UIImage(named:"checkMarkGray.png")
        checkMarkView.image = grayCheckImg
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != ""{
            delegate.updateEditsMade(_editsMade: true)
        }else{
            delegate.updateEditsMade(_editsMade: false)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func validateEmail()->Bool{
        print("validateEmail")
       
        if !isValidEmail(testStr: self.addTxt.text!){
            
           
            let alertController = UIAlertController(title: "Improper Email Format", message: "Please add a proper email.", preferredStyle: UIAlertControllerStyle.alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
            }
            
            alertController.addAction(okAction)
            self.delegate.presentAlert(_alert: alertController)
        
            return false
        }
        
        return true
    }
    
    
    func editEmail(){
        print("editEmail")
        layoutAddEmail()
        self.addTxt.text = self.email.value
    }
    
    
    @objc func addEmail(){
        
        if(!validateEmail()){
            print("didn't pass validation")
            return
        }
    
        if self.email != nil{
            //edit
                
                self.delegate.showLoadingView()
                
                let parameters:[String:String]
                
            
                parameters = ["contactID": self.email.ID, "custID":self.customerID, "email":self.addTxt.text!, "name":""]
        
                print("parameters = \(parameters)")
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/customerEmail.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("send response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        if let json = response.result.value {
                            print("JSON: \(json)")
                            
                            self.delegate.updateEditsMade(_editsMade: false)
                            let emailsJSON = JSON(json)
                            self.delegate.updateTable(_newEmails: emailsJSON)
                        }
                        print(" dismissIndicator")
                        self.delegate.hideLoadingView()
                }
        }else{
            //new
            let alertController = UIAlertController(title: "Add Customer Email?", message: "Do you want to add this email to the customer file?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                
                let email:Contact = Contact(_ID: "0", _value: self.addTxt.text!)
                self.delegate.addOneTimeEmail(_email: email)
                
                self.delegate.updateEditsMade(_editsMade: false)
                
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                self.delegate.showLoadingView()
                
                let parameters:[String:String]
               
                parameters = ["contactID": "0", "custID":self.customerID, "email":self.addTxt.text!, "name":""]
                
                print("parameters = \(parameters)")
                
                self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/customerEmail.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("send response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        if let json = response.result.value {
                            print("JSON: \(json)")
                            
                            //by calling addOneTime (eventhough its saved) it allows other one timers to remain visible
                            let email:Contact = Contact(_ID: "0", _value: self.addTxt.text!)
                            self.delegate.addOneTimeEmail(_email: email)
                            
                            self.delegate.updateEditsMade(_editsMade: false)
                            
                        }
                        print(" dismissIndicator")
                        //self.indicator.dismissIndicator()
                        
                        self.delegate.hideLoadingView()
                }
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.delegate.presentAlert(_alert: alertController)
        
            }
        }
    
    
}

