//
//  TermsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/13/18.
//  Copyright © 2018 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class TermsViewController: UIViewController, UITextViewDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    
    var termsView:UITextView = UITextView()
    
    
    var contractID:String!
    var terms:String!
    
    
    var editsMade:Bool = false
    
    var delegate:EditTermsDelegate!
    
    
    var submitButton:UIBarButtonItem!
    
    var indicator: SDevIndicator!
    var regenerateBtn:Button = Button(titleText: "Regenerate Terms")
    var json:JSON!
    
    init(_terms:String, _contractID:String){
        
        
        super.init(nibName:nil,bundle:nil)
        self.terms = _terms
        self.contractID = _contractID
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //print(currentReachabilityStatus) //true connected
        //print(currentReachabilityStatus != .notReachable) //true connected
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Terms"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditContractViewController.submit))
        navigationItem.rightBarButtonItem = submitButton
        
        layoutViews()
    }
    
    
    
    
    
    
    
    
    func layoutViews(){
       
        
        self.termsView.layer.borderWidth = 1
        self.termsView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.termsView.layer.cornerRadius = 4.0
        //self.termsView.returnKeyType = .done
 
        
        
        self.termsView.text = self.terms
        
        self.termsView.delegate = self
        
        
        
        self.termsView.font = layoutVars.smallFont
        self.termsView.isEditable = true
        //self.termsView.delegate = self
        self.termsView.backgroundColor = UIColor.white
        self.termsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.termsView)
        
        
        let termsToolBar = UIToolbar()
        termsToolBar.barStyle = UIBarStyle.default
        termsToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        termsToolBar.sizeToFit()
        let closeTermsButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TermsViewController.closeTextView))
        
        
        termsToolBar.setItems([closeTermsButton], animated: false)
        termsToolBar.isUserInteractionEnabled = true
        termsView.inputAccessoryView = termsToolBar
        
        self.regenerateBtn.addTarget(self, action: #selector(TermsViewController.regenerateTerms), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.regenerateBtn)
        
        
        
        //print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.termsView,
            "regenBtn":self.regenerateBtn
            ] as [String:Any]
        
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view1]-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[regenBtn]-|", options: [], metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-72-[view1]-220-[regenBtn(40)]-10-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange")
        //if (text == "\n") {
            //textView.resignFirstResponder()
        //}
        return true
    }
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {        print("textFieldDidBeginEditing")
        
        
        editsMade = true
        //self.terms = self.termsView.text!
        
        /*
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y -= 250
            
            
        }, completion: { finished in
            print("Napkins opened!")
        })
 */
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        editsMade = true
        self.terms = self.termsView.text!
        
        /*
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y += 250
                
                
            }, completion: { finished in
            })
        }
 */
    }
    
    @objc func closeTextView(){
        self.termsView.resignFirstResponder()
    }
    
    
    
    @objc func regenerateTerms(){
        //self.termsView.resignFirstResponder()
        
        
        
        let alertController = UIAlertController(title: "Regenerate Contract Terms?", message: "Would you like to regenerate the contract terms now based on current items?  All custom edits to terms will be overwritten.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
            //_ = self.navigationController?.popViewController(animated: true)
            
            
            self.editsMade = true
            
            
            self.indicator = SDevIndicator.generate(self.view)!
            
            
            var parameters:[String:String]
            parameters = [
                "contractID":self.contractID,
                "refresh":"1"
                
                
            ]
            
            print("parameters = \(parameters)")
            
            
            
            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contractTerms.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                
                
                //self.checkForSalesRepSignature()
                //self.getContract()
                
                //self.layoutViews()
                //self.delegate.updateTerms(_terms: self.terms)
                
                //self.editsMade = false
                
                //self.goBack()
                }.responseJSON(){
                    response in
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        self.json = JSON(json)
                        let newTerms = self.json["newTerms"].stringValue
                       // self.contract.terms = newTerms
                        
                        
                        
                        
                        //self.itemsArray.remove(at: _row)
                        
                        
                        //self.updateContract(_contract: self.contract)
                        self.terms = newTerms
                        self.termsView.text = newTerms
                        
                    }
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
            }
            
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    @objc func submit() {
        print("share")
        
        if editsMade == false{
            
            simpleAlert(_vc: self, _title: "No Edits Made", _message: "")
        }else{
            
            self.terms = self.termsView.text
            
            var parameters:[String:String]
            parameters = [
                "contractID":self.contractID,
                "termsDescription":self.terms,
                "refresh":"0"
                
                
            ]
            
            print("parameters = \(parameters)")
            
            
            
            self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contractTerms.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                
                
                //self.checkForSalesRepSignature()
                //self.getContract()
                
                //self.layoutViews()
                self.delegate.updateTerms(_terms: self.terms)
                
                self.editsMade = false
                
                self.goBack()
            }
            
            
            
        }
        
        
    }
   
    
    
    
    
    
    
    @objc func goBack(){
        //_ = navigationController?.popViewController(animated: true)
        
        
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without updating?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
        
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
