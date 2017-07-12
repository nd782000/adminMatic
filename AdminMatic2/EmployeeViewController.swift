//
//  EmployeeViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Nuke




class EmployeeViewController: ViewControllerWithMenu, UITextFieldDelegate, UIScrollViewDelegate, TimeEntryDelegate  {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    var employeeJSON: JSON!
    var employee:Employee!
       
    
    var tapBtn:UIButton!
    
    //employee info
    var employeeView:UIView!
    var employeeImage:UIImageView!
    var activityView:UIActivityIndicatorView!

    var employeeLbl:GreyLabel!
    var employeePhoneBtn:UIButton!
    var phoneNumberClean:String!
    
    var appScoreLbl:InfoLabel!
    
    
    var workingStatusIcon:UIView!
    var workingLbl:InfoLabel!
    
    //todays info, crew, crew leader, helpers, truck
    var todaysDetailsView:UIView!
    var todaysDetailsLbl:InfoLabel!
    var crewLbl:InfoLabel!
    var crewLeaderLbl:InfoLabel!
    var helperLbl:InfoLabel!
    var truckLbl:InfoLabel!
    
    //sign in / out buttons
    var signInOutView:UIView!
    
    var logInOutBtn:Button!
    
    
    
    //var newShift:Bool!
    var shiftID:String!
    var startTime:String!
    var workTimer:Timer!
    var totalShiftTime:String!
    
    
     /*
     var signInBtn:Button!
     var signOutBtn:Button!
     
     var startTimeLbl:InfoLabel!
     // var startTimeEditBtn:Button!
     var startTimeEditTxt:UITextField!
     
     var stopTimeLbl:InfoLabel!
     //var stopTimeEditBtn:Button!
     var stopTimeEditTxt:UITextField!
     */
    
    
    
    
    var logInView:LogInView!
    var activeTextField:PaddedTextField?
    
    var timeEntryView:TimeEntryView!
    
    
    var keyBoardShown:Bool = false
    
    
    
    
    
    init(_employee:Employee){
        super.init(nibName:nil,bundle:nil)
        print("init _employeeID = \(_employee.ID)")
        self.employee = _employee
        
        
       
        
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        print("view will appear")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        

        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Employee"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.layoutViews()
         self.getCurrentShift()
        if(self.employee.ID != "1"){
                getEmployeeData(_id:self.employee.ID!)
            }
    }
    
    func getEmployeeData(_id:String){
        
        
       // indicator = SDevIndicator.generate(self.view)!
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.employee(["empID":_id as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.employeeJSON = JSON(json)
                self.parseEmployeeJSON()
                
            }
            
            
            
        }

        
        
        
        
    }
    
    func parseEmployeeJSON(){
        
        print("parseEmployeeJSON")
        
        self.employee = Employee(_ID: self.employeeJSON["employees"][0]["ID"].stringValue, _name: self.employeeJSON["employees"][0]["name"].stringValue, _lname: self.employeeJSON["employees"][0]["lname"].stringValue, _fname: self.employeeJSON["employees"][0]["fname"].stringValue, _username: self.employeeJSON["employees"][0]["username"].stringValue, _pic: self.employeeJSON["employees"][0]["pic"].stringValue, _phone: self.employeeJSON["employees"][0]["phone"].stringValue, _depID: self.employeeJSON["employees"][0]["depID"].stringValue, _payRate: self.employeeJSON["employees"][0]["payRate"].stringValue, _appScore: self.employeeJSON["employees"][0]["appScore"].stringValue)
        
        
        layoutViews()
    } 
    
    func layoutViews(){
        
        print("layoutViews")
       // indicator.dismissIndicator()
        
        //////////   containers for different sections
        self.employeeView = UIView()
        self.employeeView.backgroundColor = layoutVars.backgroundColor
        self.employeeView.layer.borderColor = layoutVars.borderColor
        self.employeeView.layer.borderWidth = 1.0
        self.employeeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.employeeView)
        
        
        self.todaysDetailsView = UIView()
        self.todaysDetailsView.alpha = 0.1
        self.todaysDetailsView.backgroundColor = layoutVars.backgroundColor
        self.todaysDetailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.todaysDetailsView)
        
        self.signInOutView = UIView()
        self.signInOutView.backgroundColor = layoutVars.backgroundColor
        self.signInOutView.layer.borderColor = layoutVars.borderColor
        self.signInOutView.layer.borderWidth = 1.0
        self.signInOutView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.signInOutView)
        
        //auto layout group
        let viewsDictionary = [
            "view1":self.employeeView,
            "view2":self.todaysDetailsView,
            "view3":self.signInOutView
            
        ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view3(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[view1(100)][view2(180)][view3(fullHeight)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        print("step2")
        
        
        
        ///////////   employee section   /////////////
        //image
        self.employeeImage = UIImageView()
        
       // if(self.employee.ID == "1"){
           // self.employeeImage.image = UIImage(named: "cMurphy.png")
       // }else{
        
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = CGPoint(x: self.employeeImage.frame.size.width / 2, y: self.employeeImage.frame.size.height / 2)
        employeeImage.addSubview(activityView)
        activityView.startAnimating()
        
        
        
        let imgURL:URL = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.employee.pic!)!
        
        print("imgURL = \(imgURL)")
        
        
        
        Nuke.loadImage(with: imgURL, into: self.employeeImage!){ [weak view] in
            print("nuke loadImage")
            self.employeeImage?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
        }
        

        
        
        /*
            let imgUrl = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.employee.pic!)
            
            
        if(self.employeeImage.image == nil){
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imgUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.employeeImage.image = UIImage(data: data!)
                }
            }
        }
        */

       // }
        
        
        
        
        self.employeeImage.layer.cornerRadius = 5.0
        self.employeeImage.layer.borderWidth = 2
        self.employeeImage.layer.borderColor = layoutVars.borderColor
        self.employeeImage.clipsToBounds = true
        self.employeeImage.translatesAutoresizingMaskIntoConstraints = false
        self.employeeView.addSubview(self.employeeImage)
        
        //name
        self.employeeLbl = GreyLabel()
        self.employeeLbl.text = self.employee.name
        self.employeeLbl.font = layoutVars.labelFont
        self.employeeView.addSubview(self.employeeLbl)
        
        //phone
        
        
        
        self.phoneNumberClean = cleanPhoneNumber(self.employee.phone)
        
        
        self.employeePhoneBtn = Button()
        self.employeePhoneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.employeePhoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.employeePhoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        
        self.employeePhoneBtn.setTitle(self.phoneNumberClean, for: UIControlState.normal)
        self.employeePhoneBtn.addTarget(self, action: #selector(EmployeeViewController.handlePhone), for: UIControlEvents.touchUpInside)
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.contentMode = .scaleAspectFill
        phoneIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.employeePhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        
        self.employeeView.addSubview(self.employeePhoneBtn)
        
        
        self.appScoreLbl = InfoLabel()
        self.appScoreLbl.text = "\(self.employee.appScore!) App Pts."
        self.employeeView.addSubview(self.appScoreLbl)
        
        
        
        
        
        
        //working status
        self.workingStatusIcon = UIView()
        self.workingStatusIcon.layer.cornerRadius = 10
        self.workingStatusIcon.layer.masksToBounds = true
        self.workingStatusIcon.backgroundColor = UIColor.red
        self.workingStatusIcon.translatesAutoresizingMaskIntoConstraints = false
        self.employeeView.addSubview(self.workingStatusIcon)
        
        self.workingLbl = InfoLabel()
        
        self.workingLbl.text = "Not Working"
        self.employeeView.addSubview(self.workingLbl)
        
        self.workingStatusIcon.alpha = 0
        self.workingLbl.alpha = 0
        
        
        
        
        //auto layout group
        let employeeViewsDictionary = [
            "view1":self.employeeImage,
            "view2":self.employeeLbl,
            "view3":self.employeePhoneBtn,
            "view4":self.workingStatusIcon,
            "view5":self.workingLbl,
            "view6":self.appScoreLbl
        ] as [String:Any]
        
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view1(80)]-10-[view2(210)]", options: [], metrics: nil, views: employeeViewsDictionary))
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[view3(210)]", options: [], metrics: nil, views: employeeViewsDictionary))
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[view6(160)]", options: [], metrics: nil, views: employeeViewsDictionary))

        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-220-[view4(15)]-[view5]", options: [], metrics: nil, views: employeeViewsDictionary))
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view1(80)]", options: [], metrics: nil, views: employeeViewsDictionary))
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view2(30)][view3(30)]-[view4(16)]-9-|", options: [], metrics: nil, views: employeeViewsDictionary))
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view5(19)]-8-|", options: [], metrics: nil, views: employeeViewsDictionary))
        self.employeeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view6(19)]-8-|", options: [], metrics: nil, views: employeeViewsDictionary))

        
        
        
        ///////////   Today's Info   /////////////
        
        self.todaysDetailsLbl = InfoLabel()
        self.todaysDetailsLbl.text = "Today's Details:"
        self.todaysDetailsView.addSubview(self.todaysDetailsLbl)
        
        let crewFont:UIFont = UIFont(name: "HelveticaNeue-Bold", size: 30)!
        
        
        
        self.crewLbl = InfoLabel()
        
        self.crewLbl.text = "LM1"
        self.crewLbl.font = crewFont
        self.crewLbl.textColor = UIColor.white
        self.crewLbl.textAlignment = NSTextAlignment.center;
        self.crewLbl.backgroundColor = UIColor.red
        self.crewLbl.layer.cornerRadius = 5.0
        self.todaysDetailsView.addSubview(self.crewLbl)
        
        self.crewLeaderLbl = InfoLabel()
        self.crewLeaderLbl.text = "Crew Leader: Nick DiGiando"
        self.todaysDetailsView.addSubview(self.crewLeaderLbl)
        
        
        
        self.truckLbl = InfoLabel()
        self.truckLbl.text = "Truck: Bone Crusher"
        self.todaysDetailsView.addSubview(self.truckLbl)
        
        self.helperLbl = InfoLabel()
        
        self.helperLbl.text = "Helpers: Braulio Ramirez, Jose Ramirez, Josh Brown"
        self.todaysDetailsView.addSubview(self.helperLbl)
        
        //auto layout group
        let todaysViewsDictionary = [
            "view1":self.todaysDetailsLbl,
            "view2":self.crewLbl,
            "view3":self.crewLeaderLbl,
            "view4":self.truckLbl,
            "view5":self.helperLbl
        ] as [String:Any]
        
        self.todaysDetailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view1(200)]", options: [], metrics: nil, views: todaysViewsDictionary))
        self.todaysDetailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2(120)]", options: [], metrics: nil, views: todaysViewsDictionary))
        self.todaysDetailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3(300)]", options: [], metrics: nil, views: todaysViewsDictionary))
        self.todaysDetailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4(300)]", options: [], metrics: nil, views: todaysViewsDictionary))
        self.todaysDetailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5(300)]", options: [], metrics: nil, views: todaysViewsDictionary))
        self.todaysDetailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view1(20)]-[view2(50)]-[view3(20)][view4(20)][view5(20)]", options: [], metrics: nil, views: todaysViewsDictionary))
        
        
    
        ///////////   Sign In / Out   /////////////
        self.logInView = LogInView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.logInView.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        self.logInView.userTxt.delegate = self
        self.logInView.userTxt.text = self.employee.username
        self.logInView.passTxt.delegate = self
        
        
        
        self.timeEntryView = TimeEntryView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.timeEntryView.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        self.timeEntryView.delegate = self
        
  
        self.logInOutBtn = Button()
        self.logInOutBtn.translatesAutoresizingMaskIntoConstraints = false
        //self.logInOutBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.logInOutBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0)
        
        ////print("appDelegate.loggedInUser = " + appDelegate.loggedInUser)
        
        //if(appDelegate.loggedInEmployee?.ID == self.employee.ID){
            //logged in
        if(appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) == self.employee.ID){
            
           // appDelegate.defaults = defaults
            
            self.logInOutBtn.setTitle("Log Out (\(self.employee.fname!))", for: UIControlState.normal)
            self.logInOutBtn.addTarget(self, action: #selector(self.logOut), for: UIControlEvents.touchUpInside)
            
            displayTimeEntryView()
            
            
        }else{
            //not logged in
            
            self.logInOutBtn.setTitle("Log In (\(self.employee.fname!))", for: UIControlState.normal)
            self.logInOutBtn.addTarget(self, action: #selector(EmployeeViewController.attemptLogIn), for: UIControlEvents.touchUpInside)
            
            displayLogInView()
            
            
        }
        
        
        
        
        
        
        
        self.signInOutView.addSubview(self.logInOutBtn)
        
        
        //auto layout group
        let signInOutViewsDictionary = [
            "logInOutBtn":self.logInOutBtn
        ] as [String:Any]
        
        self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[logInOutBtn]-10-|", options: [], metrics: nil, views: signInOutViewsDictionary))
        
        self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[logInOutBtn(40)]-|", options: [], metrics: nil, views: signInOutViewsDictionary))
        
        
        
        
        
        
       
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            // tableView.contentInset.bottom = keyboardFrame.height
            if(!keyBoardShown){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    // var fabricTopFrame = self.fabricTop.frame
                    self.view.frame.origin.y -= keyboardFrame.height
                    
                    
                }, completion: { finished in
                    // //print("Napkins opened!")
                })
            }
            
            
        }
        keyBoardShown = true
    }

    
    func keyboardDidHide(notification: NSNotification) {
        keyBoardShown = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            // var fabricTopFrame = self.fabricTop.frame
            self.view.frame.origin.y = 0
            
            
        }, completion: { finished in
            ////print("Napkins opened!")
        })
        
    }
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    
    
    func attemptLogIn(){
        
        //print("setLoginStatus")
        self.logInView.passTxt.reset()
        
        
        
        if(!self.logInView.userTxt.text!.isEmpty && !self.logInView.passTxt.text!.isEmpty){
            
            indicator = SDevIndicator.generate(self.view)!
            
            
           // Alamofire.request(API.Router.logIn(self.logInView.userTxt.text!,self.logInView.passTxt.text!)).responseJSON(){
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            //, "cb":timeStamp as AnyObject
            
            
            Alamofire.request(API.Router.logIn(["user":self.logInView.userTxt.text! as AnyObject,"pass":self.logInView.passTxt.text! as AnyObject, "cb":timeStamp as AnyObject])).responseJSON(){
                
            response in
                
                //print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                //print(response.result)   // result of response serialization
                
                ////print("JSON 1 \(json)")
                if let json = response.result.value {
                    //print("Log In Json = \(json)")
                    let LogInJson = JSON(json)
                    
                    let loggedIn = LogInJson["loggedIn"].stringValue
                    
                    if(loggedIn == "true"){
                        self.logInOutBtn.setTitle("Log Out (\(self.employee.name!))", for: UIControlState.normal)
                        //print("Login Success")
                        self.appDelegate.loggedInEmployee = self.employee
                        
                        
                        
                        self.appDelegate.scheduleViewController.personalScheduleArray.removeAll()
                        self.appDelegate.scheduleViewController.personalHistoryArray.removeAll()
                        self.appDelegate.scheduleViewController.personalHistoryLoaded = false
                        self.appDelegate.scheduleViewController.personalScheduleLoaded = false
                       // self.appDelegate.scheduleViewController.personalMode = false
                        
                        
                        
                        
                        self.displayTimeEntryView()
                        
                        
                        self.logInOutBtn.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                        self.logInOutBtn.addTarget(self, action: #selector(self.logOut), for: UIControlEvents.touchUpInside)
                        
                        self.logInView.userTxt.resignFirstResponder()
                        self.logInView.passTxt.resignFirstResponder()
                        
                        
                        
                        
                        print("set values for appDelegate id = \(self.employee.ID)")
                        //print("set values for appDelegate name = \(self.employee.name)")
                        //print("set values for appDelegate pic = \(self.employee.pic)")
                        
                        self.appDelegate.defaults = UserDefaults.standard
                        self.appDelegate.defaults.setValue(self.employee.ID, forKey: loggedInKeys.loggedInId)
                       // self.appDelegate.defaults.setValue(self.employee.name, forKey: loggedInKeys.loggedInName)
                       // self.appDelegate.defaults.setValue(self.employee.pic, forKey: loggedInKeys.loggedInPic)
                        self.appDelegate.defaults.synchronize()
                        //self.appDelegate.defaults = defaults
                        
                        
                        
                        
                        
                        
                        
                    }else{
                        //print("Login Fail")
                        // self.logInView.userTxt.error()
                        self.logInView.passTxt.error()
                    }
                }
                
                self.indicator.dismissIndicator()
                
            }
        }else{
            //print("Invalid Login Credentials")
            //self.logInView.userTxt.error()
            self.logInView.passTxt.error()
        }
        
        
        
        
        
        
    }
    
    
    func displayLogInView(){
        //print("displayLogInView")
        
        //clear all subviews
        for view in signInOutView.subviews{
            view.removeFromSuperview()
        }
        
        
        
        self.signInOutView.addSubview(self.logInView)
        self.signInOutView.addSubview(self.logInOutBtn)
        
        let logInViewsDictionary = [
            "logInView":self.logInView,
            "logInOutBtn":self.logInOutBtn
        ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344] as [String:Any]
        
        
        
        self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[logInView(width)]", options: [], metrics: sizeVals, views: logInViewsDictionary))
        self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[logInOutBtn]-10-|", options: [], metrics: sizeVals, views: logInViewsDictionary))
        
        self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[logInView]-[logInOutBtn(40)]-|", options: [], metrics: nil, views: logInViewsDictionary))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    
    
    
    
    
    
    
   
    func logOut() {
        
        //print("setLoginStatus")
        
        self.logInOutBtn.setTitle("Log In (\(self.employee.name!))", for: UIControlState.normal)
        
        self.appDelegate.loggedInEmployee = nil
        //self.appDelegate.loggedInUserFName = ""
        //self.appDelegate.loggedInUserPic = ""
        
        
        self.appDelegate.scheduleViewController.personalScheduleArray.removeAll()
        self.appDelegate.scheduleViewController.personalHistoryArray.removeAll()
        self.appDelegate.scheduleViewController.personalHistoryLoaded = false
        self.appDelegate.scheduleViewController.personalScheduleLoaded = false
        //self.appDelegate.scheduleViewController.personalMode = false
        
        displayLogInView()
        
        self.logInOutBtn.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        self.logInOutBtn.addTarget(self, action: #selector(EmployeeViewController.attemptLogIn), for: UIControlEvents.touchUpInside)
        
        self.logInView.passTxt.text = ""
        
        
        self.appDelegate.defaults = UserDefaults.standard
        self.appDelegate.defaults.setValue("0", forKey: loggedInKeys.loggedInId)
        //self.appDelegate.defaults.setValue("", forKey: loggedInKeys.loggedInName)
       // self.appDelegate.defaults.setValue("", forKey: loggedInKeys.loggedInPic)
        self.appDelegate.defaults.synchronize()
        
        //self.appDelegate.defaults = defaults

    }
    
 
    
    
    
    
    
    /*
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //print("NEXT")
        switch (textField.tag) {
        case logInView.userTxt.tag:
            logInView.passTxt.becomeFirstResponder()
            break;
        case logInView.passTxt.tag:
            //logInView.passTxt.becomeFirstResponder()
            self.logInView.endEditing(true)
            
            break;
        default:
            break;
        }
        return true
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.logInView.endEditing(true)
    }
    
    
   */
    
    
    
    
    
    
    ////////////    Payroll Methods    ///////////////////////
    
    
    
    
    
   
    
    func getCurrentShift(){
        //print("getCurrentShift")
        //["user":self.logInView.userTxt.text! as AnyObject
        //Alamofire.request(API.Router.CurrentShiftByEmployee(self.employeeID)).responseJSON(){
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        
         Alamofire.request(API.Router.currentShiftByEmployee(["empID":self.employee.ID! as AnyObject, "cb":timeStamp as AnyObject])).responseJSON(){
            
            response in
            
            //print(response.request ?? "")  // original URL request
            //print(response.response  ?? "") // URL response
            //print(response.data  ?? "")     // server data
            //print(response.result  )   // result of response serialization
            
            ////print("JSON 1 \(json)")
            if let json = response.result.value {
                //if error == nil {
                
                self.setTimeBtnsAndLbls(_json: JSON(json))
                
                // } else {
                ////print("JSON ERROR: \(error)")
                
                //}
            }
            
        }
        
    }
    
    
    func displayTimeEntryView(){
        //print("displayTimeEntryView")
        
        //clear all subviews
        for view in signInOutView.subviews{
            view.removeFromSuperview()
        }
        
       
        
       // self.signInOutView.addSubview(self.timeEntryView)
        self.signInOutView.addSubview(self.logInOutBtn)
        
        let timeEntryViewsDictionary = [
            "timeEntryView":self.timeEntryView,
            "logInOutBtn":self.logInOutBtn
        ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344] as [String:Any]
        
        
        
       // self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[timeEntryView(width)]", options: [], metrics: sizeVals, views: timeEntryViewsDictionary))
        self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[logInOutBtn]-10-|", options: [], metrics: sizeVals, views: timeEntryViewsDictionary))
        
        //self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[timeEntryView]-[logInOutBtn(40)]-|", options: [], metrics: nil, views: timeEntryViewsDictionary))
        
         self.signInOutView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[logInOutBtn(40)]-|", options: [], metrics: nil, views: timeEntryViewsDictionary))
        
        
        
        
        
    }
    
    
    
    
    
    
    
    func editStartTime(){
        //print("editStartTime")
        signIn()
    }
    
    
    func editStopTime(){
        //print("editStopTime")
        signOut()
        
    }

    
    
    
    func signIn(){
        
        //print("signIn")
        
        self.timeEntryView.signInBtn.isEnabled = false
        self.timeEntryView.signInBtn.alpha = 0.5
        self.timeEntryView.signOutBtn.isEnabled = true
        self.timeEntryView.signOutBtn.alpha = 1.0
        
        let start = Date()
        //print("startTime = \(start)")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "US/Eastern")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedStartTime = dateFormatter.string(from: start)
        //print("formattedStartTime = \(formattedStartTime)")
        
        
        let startDate = Date()
        ////print("startTime = \(start)")
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeZone = TimeZone(identifier: "US/Eastern")
        //dateFormatter2.timeZone = TimeZone(name: "US/Eastern")
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        let formattedStartDate = dateFormatter2.string(from: startDate)
        //print("formattedStartDate = \(formattedStartDate)")
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        
        //request without json return
        Alamofire.request(API.Router.workShiftStart(["empID" :self.employee.ID  as AnyObject, "startTime" : formattedStartTime as AnyObject, "startDate" :formattedStartDate  as AnyObject, "cb":timeStamp as AnyObject])).responseJSON(){
            response in
            
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                self.setTimeBtnsAndLbls(_json: JSON(json))
            }
            
            
        }
    }
    
     
    
    
    func signOut(){
        //print("signOut \(self.startTime)")
        
        self.timeEntryView.signOutBtn.isEnabled = false
        self.timeEntryView.signOutBtn.alpha = 0.5
        self.timeEntryView.signInBtn.isEnabled = true
        self.timeEntryView.signInBtn.alpha = 1.0
        
        
        
        let stopTime = Date()
        //print("stopTime = \(stopTime)")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "US/Eastern")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let formattedStopTime = dateFormatter.string(from: stopTime)
        
        self.totalShiftTime = dateDiff(date1: self.startTime,date2: formattedStopTime)
        
        
        
        
        
        
        
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        
        //request without json return
        //print("shiftID = \(shiftID)")
        Alamofire.request(API.Router.workShiftStop(["ID" : shiftID  as AnyObject, "startTime" : startTime  as AnyObject,  "stopTime" : formattedStopTime  as AnyObject, "total" : totalShiftTime  as AnyObject, "cb":timeStamp as AnyObject])).responseJSON(){
            response in
            
            //print(response.request ?? "")  // original URL request
            //print(response.response  ?? "") // URL response
            //print(response.data  ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                self.setTimeBtnsAndLbls(_json: JSON(json))
            }
            
        }
    }
    
    
    
    func dateDiff(date1:String,date2:String) -> String {
        //print("dateDiff")
        let f:DateFormatter = DateFormatter()
        f.timeZone = NSTimeZone(name: "US/Eastern") as TimeZone!
        f.dateFormat = "yyyy-M-dd'T'HH:mm:ss"
        
        
        let startDate = f.date(from: date1)
        let endDate = f.date(from: date2)
        //print("startDate \(startDate)")
        //print("endDate \(endDate)")
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        
        let flags = NSCalendar.Unit.minute
        let components = calendar.components(flags, from: startDate!, to: endDate!, options: [])
        
        
        let minutes = components.minute
        //print("minutes \(Float(minutes!)/60)")
        
        
        
        
        
        let hours = Float(minutes!) / 60
        //print("hours \(hours)")
        
        let formattedHours = String(format: "%0.2f", hours)
        //print("formattedHours \(formattedHours)")
        return formattedHours;
    }
    
    
    
    
    
    func editBreakTime(){
        //print("editBreakTime")
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func setTimeBtnsAndLbls(_json:JSON){
        //reset time labels
        //print("setTimeBtnsAndLbls : \(_json)")
        self.timeEntryView.startTimeLbl.alpha = 0
        self.timeEntryView.startTimeValueLbl.alpha = 0
        self.timeEntryView.stopTimeLbl.alpha = 0
        self.timeEntryView.stopTimeValueLbl.alpha = 0
        self.timeEntryView.startTimeValueLbl.text = ""
        self.timeEntryView.stopTimeValueLbl.text = ""
        
        
        var json:JSON = _json
        /////////  Detrmine working status   ///////////////////////
        //set start and stop times
        
        //print("self.json[0] \(json[0])")
        if(json[0]["ID"] != JSON.null){
            //print(json[0]["ID"].string ?? "")
            shiftID = json[0]["ID"].string
        }
        
        if(json[0]["startTime"] == JSON.null){                                        //not started working
            //print("2")
            //show start btn
            //hide stop btn
            self.timeEntryView.signOutBtn.isEnabled = false
            self.timeEntryView.signOutBtn.alpha = 0.5
            
            self.timeEntryView.startTimeLbl.alpha = 0
            self.timeEntryView.startTimeValueLbl.alpha = 0
            self.timeEntryView.stopTimeLbl.alpha = 0
            self.timeEntryView.stopTimeValueLbl.alpha = 0
            
            self.workingStatusIcon.backgroundColor = UIColor.red
            self.workingLbl.text = "Not Working"
            self.workingStatusIcon.alpha = 1.0
            self.workingLbl.alpha = 1.0
            
            if(self.workTimer != nil){
                self.workTimer.invalidate()
                self.workTimer = nil
            }
            
        }else if(json[0]["startTime"] != JSON.null && json[0]["stopTime"] == JSON.null){    //started but not stopped
            //print("3")
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.timeZone = NSTimeZone(name: "US/Eastern") as TimeZone!
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            self.startTime = json[0]["startTime"].string!
            //print("startTime = \(startTime)")
            //hide start btn
            //show stop btn
            workTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(EmployeeViewController.displayWorkingTime), userInfo: nil, repeats: true)
            self.workingStatusIcon.backgroundColor = UIColor.green
            self.workingLbl.text = "Working for:"
            self.workingStatusIcon.alpha = 1.0
            self.workingLbl.alpha = 1.0
            
            self.timeEntryView.signOutBtn.isEnabled = true
            self.timeEntryView.signOutBtn.alpha = 1.0
            self.timeEntryView.signInBtn.isEnabled = false
            self.timeEntryView.signInBtn.alpha = 0.5
            
            let startDateDb = json[0]["startTime"].string!
            //print("startTime from database = \(startDateDb)")
            
            
            self.timeEntryView.startTimeLbl.alpha = 1
            self.timeEntryView.startTimeLbl.text = "Signed In: "
            self.timeEntryView.startTimeValueLbl.alpha = 1
            self.timeEntryView.startTimeValueLbl.text = "\(startDateDb)"
            
        }else{                                                              //started and stopped, start new shift
            //print("4")
            
            let startDateDb = json[0]["startTime"].string!
            //print("startTime from database = \(startDateDb)")
            let stopDateDb = json[0]["stopTime"].string!
            //print("stopTime from database = \(stopDateDb)")
            
            //show start btn
            //hide stop btn
            
            self.timeEntryView.signInBtn.isEnabled = true
            self.timeEntryView.signInBtn.alpha = 1.0
            self.timeEntryView.signOutBtn.isEnabled = false
            self.timeEntryView.signOutBtn.alpha = 0.5
            
            self.timeEntryView.startTimeLbl.alpha = 1
            self.timeEntryView.startTimeLbl.text = "Signed In: "
            self.timeEntryView.startTimeValueLbl.alpha = 1
            self.timeEntryView.startTimeValueLbl.text = "\(startDateDb)"
            
            self.timeEntryView.stopTimeLbl.text = "Signed Out: "
            self.timeEntryView.stopTimeLbl.alpha = 1.0
            self.timeEntryView.stopTimeValueLbl.text = "\(stopDateDb)"
            self.timeEntryView.stopTimeValueLbl.alpha = 1
            
            
            self.workingStatusIcon.backgroundColor = UIColor.red
            self.workingLbl.text = "Not Working"
            self.workingStatusIcon.alpha = 1.0
            self.workingLbl.alpha = 1.0
            if(self.workTimer != nil){
                self.workTimer.invalidate()
                self.workTimer = nil
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    func displayWorkingTime() {
        
        
        let now = NSDate()
        // let start = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFromString = dateFormatter.date(from: self.startTime!)
        
        
        
        
        
        
        
        
               
        
        //let workingTime = now.offsetFrom(dateFromString!)
        let workingTime = now.compare(dateFromString!)
        ////println("workingTime = \(workingTime)")
        self.workingLbl.text = "Working for: \(workingTime)"
        self.workingStatusIcon.backgroundColor = UIColor.green
    }
    
    
    
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    func handlePhone(){
        
        callPhoneNumber(self.phoneNumberClean)
        
        /*
        
        if (self.phoneNumberClean != "No Number Saved"){
            
            let alertController = UIAlertController(title: "CALL \(self.employee.name!)", message: "Confirm Phone Call", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                //print("Cancel")
            }
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                
                print("self.phoneNumberClean = \(self.phoneNumberClean)")
                
                
                UIApplication.shared.open(NSURL(string: "tel://\(self.phoneNumberClean)")! as URL, options: [:], completionHandler: nil)
            }
            
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
            /*
            
            let alert = UIAlertController(title: "CALL \(self.employeeName!)", message: "Confirm Phone Call", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                //UIApplication.shared.openURL(NSURL(string: "tel://\(self.phoneNumberClean)")! as URL)
                UIApplication.shared.open(NSURL(string: "tel://\(self.phoneNumberClean)")! as URL, options: [:], completionHandler: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
                self.dismiss(animated: false, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
 */
        }
 */
        
    }
    
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
        //print("Test")
        if(self.workTimer != nil){
            self.workTimer.invalidate()
            self.workTimer = nil
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}
