//
//  BugViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/27/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class BugViewController: UIViewController, UITextViewDelegate{
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var bug:Bug!
    var layoutVars:LayoutVars = LayoutVars()
    
    var indicator: SDevIndicator!
    
    
    var titleTxtView: UITextView!
    var titlePlaceHolder:String = "Bug Title..."
    
    var descriptionTxtView: UITextView!
    var descriptionPlaceHolder:String = "Bug Description..."
    
    
    var backButton: UIButton!
   
    var submitNoteButton:Button!
    var bugEdit:Bool = false
   
    init(){
        print("init")
        super.init(nibName:nil,bundle:nil)
        
        
    }
    
    
    init(_bug:Bug){
        bug = _bug
        super.init(nibName:nil,bundle:nil)

        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Record Bug"
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(BugViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        //self.picker.delegate = self
        
        
        self.titleTxtView = UITextView()
        self.descriptionTxtView = UITextView()
        
        if(bug != nil){
            
             print("bug set")
            if(self.bug.title == ""){
                //empty text box
                self.titleTxtView.text = titlePlaceHolder
                self.titleTxtView.textColor = UIColor.lightGray
                
            }else{
                //set text box
                self.titleTxtView.text = self.bug.title
                self.titleTxtView.textColor = UIColor.black
            }
            
            
            self.titleTxtView.translatesAutoresizingMaskIntoConstraints = false
            self.titleTxtView.delegate = self
            self.titleTxtView.contentInset = UIEdgeInsetsMake(-65.0,10.0,0,0.0);
            self.titleTxtView.font = layoutVars.smallFont
            self.titleTxtView.returnKeyType = UIReturnKeyType.done
            self.titleTxtView.layer.borderWidth = 2
            self.titleTxtView.layer.borderColor = layoutVars.borderColor
            self.titleTxtView.backgroundColor = layoutVars.backgroundLight
            self.titleTxtView.showsHorizontalScrollIndicator = false;
            self.view.addSubview(self.titleTxtView)
            
            
            
            if(self.bug.description == ""){
                //empty text box
                self.descriptionTxtView.text = descriptionPlaceHolder
                self.descriptionTxtView.textColor = UIColor.lightGray
                
            }else{
                //set text box
                self.descriptionTxtView.text = self.bug.description
                self.descriptionTxtView.textColor = UIColor.black
            }
            
            
            self.descriptionTxtView.translatesAutoresizingMaskIntoConstraints = false
            self.descriptionTxtView.delegate = self
            self.descriptionTxtView.contentInset = UIEdgeInsetsMake(-65.0,10.0,0,0.0);
            self.descriptionTxtView.font = layoutVars.smallFont
            self.descriptionTxtView.returnKeyType = UIReturnKeyType.done
            self.descriptionTxtView.layer.borderWidth = 2
            self.descriptionTxtView.layer.borderColor = layoutVars.borderColor
            self.descriptionTxtView.backgroundColor = layoutVars.backgroundLight
            self.descriptionTxtView.showsHorizontalScrollIndicator = false;
            self.view.addSubview(self.descriptionTxtView)
            
            
            self.submitNoteButton = Button(titleText: "Submit Bug")
            self.view.addSubview(self.submitNoteButton)
            self.submitNoteButton.isHidden = true
            
            
        }else{
            
            // bug = nil
             print("bug unset")
                self.titleTxtView.text = titlePlaceHolder
                self.titleTxtView.textColor = UIColor.lightGray
                
            
            self.titleTxtView.translatesAutoresizingMaskIntoConstraints = false
            self.titleTxtView.delegate = self
            self.titleTxtView.contentInset = UIEdgeInsetsMake(-65.0,10.0,0,0.0);
            self.titleTxtView.font = layoutVars.smallFont
            self.titleTxtView.returnKeyType = UIReturnKeyType.done
            self.titleTxtView.layer.borderWidth = 2
            self.titleTxtView.layer.borderColor = layoutVars.borderColor
            self.titleTxtView.backgroundColor = layoutVars.backgroundLight
            self.titleTxtView.showsHorizontalScrollIndicator = false;
            self.view.addSubview(self.titleTxtView)
            
            
            
           print("1")
                self.descriptionTxtView.text = descriptionPlaceHolder
                self.descriptionTxtView.textColor = UIColor.lightGray
                
            
            
            self.descriptionTxtView.translatesAutoresizingMaskIntoConstraints = false
            self.descriptionTxtView.delegate = self
            self.descriptionTxtView.contentInset = UIEdgeInsetsMake(-65.0,10.0,0,0.0);
            self.descriptionTxtView.font = layoutVars.smallFont
            self.descriptionTxtView.returnKeyType = UIReturnKeyType.done
            self.descriptionTxtView.layer.borderWidth = 2
            self.descriptionTxtView.layer.borderColor = layoutVars.borderColor
            self.descriptionTxtView.backgroundColor = layoutVars.backgroundLight
            self.descriptionTxtView.showsHorizontalScrollIndicator = false;
            self.view.addSubview(self.descriptionTxtView)
            
            print("2")
            self.submitNoteButton = Button(titleText: "Submit Bug")
            self.submitNoteButton.addTarget(self, action: #selector(BugViewController.saveData), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.submitNoteButton)
        }
       
        
        
        /////////////////  Auto Layout   ////////////////////////////////////////////////
        
        //apply to each view
        
        //auto layout group
        let viewsDictionary = [
            "title":self.titleTxtView,
            "desc":self.descriptionTxtView,
            "submit":self.submitNoteButton
            ] as [String : Any]
        
        print("3")
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40] as [String : Any]
        
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[title(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[desc(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[submit(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[title(30)]-[desc(80)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submit(40)]-15-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
      print("4")
    }
    
    
   
    
    
    
    @objc func saveData(){
        print("Save Data")
        
        
        if(self.descriptionTxtView.text != descriptionPlaceHolder){
           
            
            indicator = SDevIndicator.generate(self.view)!
            
            var parameters:[String:String]
            parameters = [
                "title": "\(self.titleTxtView.text!)",
                "description": "\(self.descriptionTxtView.text!)",
                "createdBy": "\(String(describing: self.appDelegate.loggedInEmployee?.ID))"
                
            ]
            
            print("parameters = \(parameters)")
            
            
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/new/bug.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("bug response = \(response)")
                }
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let bugReturnJSON = JSON(value)
                        self.indicator.dismissIndicator()
                        print("bug return = \(bugReturnJSON)")
                        
                    case .failure(let error):
                        self.indicator.dismissIndicator()
                        //self.usageTableView.reloadData()
                        print("Error 4xx / 5xx: \(error)")
                    }

                        
                        
                        
            }
            
            
        }
    }
    
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.descriptionTxtView.textColor == UIColor.lightGray {
            self.descriptionTxtView.text = nil
            self.descriptionTxtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.descriptionTxtView.text.isEmpty {
            self.descriptionTxtView.text = descriptionPlaceHolder
            self.descriptionTxtView.textColor = UIColor.lightGray
        }
        bugEdit = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
    
    
    
    @objc func goBack(){
        //print("Go Back")
        
        if(self.bugEdit == true){
            //print("edits made, should update list and wo")
            
            let alertController = UIAlertController(title: nil, message: "Leave without submitting?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                //print("Cancel")
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                _ = self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            alertController.addAction(DestructiveAction)
            self.present(alertController, animated: true, completion: nil)
            
            
            
            
            
            
            
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //print("text should return")
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //func updateImage(_image: UIImage) {
       // self.imageView.image = _image
   // }
    
}





