//
//  TermsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/13/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


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
    
    var editable:Bool!
    
    init(_terms:String, _contractID:String, _editable:Bool = true){
        
        
        super.init(nibName:nil,bundle:nil)
        self.terms = _terms
        self.contractID = _contractID
        self.editable = _editable
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Terms"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        if self.editable{
            submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditContractViewController.submit))
            navigationItem.rightBarButtonItem = submitButton
        }
        
        layoutViews()
    }
    
    
    
    
    
    
    
    
    func layoutViews(){
       
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.termsView.layer.borderWidth = 1
        self.termsView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.termsView.layer.cornerRadius = 4.0
 
        self.termsView.text = self.terms
        
        self.termsView.delegate = self
        
        self.termsView.font = layoutVars.smallFont
        self.termsView.isEditable = self.editable
        self.termsView.backgroundColor = UIColor.white
        self.termsView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.termsView)
        
       if self.editable{
            let termsToolBar = UIToolbar()
            termsToolBar.barStyle = UIBarStyle.default
            termsToolBar.barTintColor = UIColor(hex:0x005100, op:1)
            termsToolBar.sizeToFit()
            let closeTermsButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TermsViewController.closeTextView))
        
        
            termsToolBar.setItems([closeTermsButton], animated: false)
            termsToolBar.isUserInteractionEnabled = true
            termsView.inputAccessoryView = termsToolBar
        }
        
        self.regenerateBtn.addTarget(self, action: #selector(TermsViewController.regenerateTerms), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.regenerateBtn)
        
        
        
        //print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.termsView,
            "regenBtn":self.regenerateBtn
            ] as [String:Any]
        
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        if self.editable == true{
           
            self.regenerateBtn.isHidden = false
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view1]-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[regenBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view1]-220-[regenBtn(40)]-|", options: [], metrics: nil, views: viewsDictionary))
            
        }else{
           
            self.regenerateBtn.isHidden = true
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view1]-|", options: [], metrics: nil, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view1]-|", options: [], metrics: nil, views: viewsDictionary))
            
        }
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange")
        
        return true
    }
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {        print("textFieldDidBeginEditing")
        editsMade = true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        editsMade = true
        self.terms = self.termsView.text!
        
    }
    
    @objc func closeTextView(){
        self.termsView.resignFirstResponder()
    }
    
    
    
    @objc func regenerateTerms(){
        
        let alertController = UIAlertController(title: "Regenerate Contract Terms?", message: "Would you like to regenerate the contract terms now based on current items?  All custom edits to terms will be overwritten.", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
            
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
                
                }.responseJSON(){
                    response in
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        self.json = JSON(json)
                        let newTerms = self.json["newTerms"].stringValue
                        self.terms = newTerms
                        self.termsView.text = newTerms
                        
                    }
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
            }
            
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    @objc func submit() {
        print("share")
        
        if editsMade == false{
            
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Edits Made", _message: "")
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
                
                
                self.delegate.updateTerms(_terms: self.terms)
                
                self.editsMade = false
                
                self.goBack()
            }
        
        }
        
    }
   
    
    @objc func goBack(){
        
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without updating?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                _ = self.navigationController?.popViewController(animated: false)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
