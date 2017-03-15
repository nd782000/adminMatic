//
//  TimeEntryView.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class TimeEntryView: UIView {
    var layoutVars:LayoutVars = LayoutVars()
    
    var delegate:TimeEntryDelegate!
    
    /*
     
     //main variables passed to this VC
     var employeeID:String!
     var employeeName:String!
     var employeePic:String!
     var employeePhone:String!
     
     
     //employee info
     var employeeView:UIView!
     var employeeImage:UIImageView!
     var employeeLbl:GreyLabel!
     var employeePhoneBtn:UIButton!
     var phoneNumberClean:String!
     var workingStatusIcon:UIView!
     var workingLbl:InfoLabel!
     
     */
    
    //todays info, crew, crew leader, helpers, truck
    var backgroundView:UIView!
    
    
    //sign in / out buttons
    //var signInOutView:UIView!
    var signInBtn:Button!
    var signOutBtn:Button!
    
    //var newShift:Bool!
    // var shiftID:String!
    var startTime:String!
    var stopTime:String!
    
    
    
    
    
    // var workTimer:NSTimer!
    // var totalShiftTime:String!
    
    
    var startTimeLbl:InfoLabel!
    var startTimeValueLbl:InfoLabel!
    // var startTimeEditBtn:Button!
    // var startTimeValueLbl:UITextField!
    
    var stopTimeLbl:InfoLabel!
    var stopTimeValueLbl:InfoLabel!
    //var stopTimeEditBtn:Button!
    //var stopTimeValueLbl:UITextField!
    
    var editTimesBtn:Button!
    
    //var keyBoardShown:Bool = false
    //var useKeyboard:Bool = true
    //var datePicker:UIDatePicker!
    // var timePicker:UIDatePicker!
    
    // var datePickerView: UIDatePicker!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        layoutViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func layoutViews(){
        
        
        self.signInBtn = Button()
        self.signOutBtn = Button()
        
        
        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = layoutVars.backgroundColor
        //self.backgroundView.backgroundColor = UIColor.blueColor()
        
        self.backgroundView.layer.borderColor = layoutVars.borderColor
        //self.backgroundView.layer.borderWidth = 1.0
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backgroundView)
        
        
        //auto layout group
        let viewsDictionary = [
            "backgroundView":self.backgroundView
        ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24] as [String : Any]
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView(width)]", options: NSLayoutFormatOptions.alignAllTop, metrics: sizeVals, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
        
        
        
        
        
        ///////////   Sign In / Out   /////////////
        
        let btnFont:UIFont = UIFont(name: "HelveticaNeue-Bold", size: 24)!
        
        
        self.signInBtn = Button()
        self.signInBtn.titleLabel?.font = btnFont
        self.signInBtn.setTitle("Sign In", for: UIControlState.normal)
        self.signInBtn.backgroundColor = layoutVars.buttonColor1
        self.signInBtn.addTarget(self, action: #selector(TimeEntryView.signIn), for: UIControlEvents.touchUpInside)
        self.backgroundView.addSubview(self.signInBtn)
        
        self.signOutBtn = Button()
        self.signOutBtn.titleLabel?.font = btnFont
        self.signOutBtn.setTitle("Sign Out", for: UIControlState.normal)
        self.signOutBtn.backgroundColor = UIColor.red
        self.signOutBtn.addTarget(self, action: #selector(TimeEntryView.signOut), for: UIControlEvents.touchUpInside)
        self.backgroundView.addSubview(self.signOutBtn)
        
        
        
        
        self.startTimeLbl = InfoLabel()
        self.startTimeLbl.text = "Start Time:"
        self.backgroundView.addSubview(self.startTimeLbl)
        
        
        self.startTimeValueLbl = InfoLabel()
        self.startTimeValueLbl.backgroundColor = UIColor.white
        self.startTimeValueLbl.layer.cornerRadius = 4.0
        // self.startTimeValueLbl.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        self.backgroundView.addSubview(self.startTimeValueLbl)
        
        
        self.stopTimeLbl = InfoLabel()
        self.stopTimeLbl.text = "Stop Time:"
        self.backgroundView.addSubview(self.stopTimeLbl)
        
        self.stopTimeValueLbl = InfoLabel()
        self.stopTimeValueLbl.backgroundColor = UIColor.white
        self.stopTimeValueLbl.layer.cornerRadius = 4.0
        //self.stopTimeValueLbl.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        self.backgroundView.addSubview(self.stopTimeValueLbl)
        
        startTimeLbl.alpha = 0
        startTimeValueLbl.alpha = 0
        stopTimeLbl.alpha = 0
        stopTimeValueLbl.alpha = 0
        
        
        
        //auto layout group
        let backgroundViewsDictionary = [
            "view1":self.signInBtn,
            "view2":self.signOutBtn,
            "view3":self.startTimeLbl,
            "view4":self.startTimeValueLbl,
            "view5":self.stopTimeLbl,
            "view6":self.stopTimeValueLbl
            ] as [String : Any]
        
        //let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24]
        
        
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view1(halfWidth)]-10-[view2(halfWidth)]", options: NSLayoutFormatOptions.alignAllTop, metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(50)]-[view3(25)][view4(30)]-[view5(25)][view6(30)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view2(50)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3(width)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[view4]-15-|", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5(width)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[view6]-15-|", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    ////////////    Payroll Methods    ///////////////////////
    
    
    
    
    
    
    
    
    func signIn(){
        
        print("signIn")
        
        self.signInBtn.isEnabled = false
        self.signInBtn.alpha = 0.5
        self.signOutBtn.isEnabled = true
        self.signOutBtn.alpha = 1.0


            delegate.editStartTime()

        /*
        let start = Date()
        print("startTime = \(start)")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "US/Eastern") as TimeZone!
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
 
       // let formattedStartTime = dateFormatter.string(from: start)
        //let formattedStartTime = dateFormatter.string(from: start as Date)
        //print("formattedStartTime = \(formattedStartTime)")
        
       
        let startDate = Date(_dateRaw: NSDate())
        //print("startTime = \(start)")
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeZone = NSTimeZone(name: "US/Eastern") as TimeZone!
        dateFormatter2.dateFormat = "yyyy-MM-dd"
       // let formattedStartDate = dateFormatter2.string(from: startDate)
        //print("formattedStartDate = \(formattedStartDate)")
        */
        
    }
    
    func signOut(){
        print("signOut \(self.startTime)")
        
        
        self.signOutBtn.isEnabled = false
        self.signOutBtn.alpha = 0.5
        self.signInBtn.isEnabled = true
        self.signInBtn.alpha = 1.0
        
        
        /*
        let stopTime = Date()
        print("stopTime = \(stopTime)")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "US/Eastern") as TimeZone!
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        self.totalShiftTime = dateDiff(self.startTime,date2: stopTime)
        */
        delegate.editStopTime()
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    func dateDiff(date1:String,date2:String) -> String {
        print("dateDiff")
        let f:DateFormatter = DateFormatter()
        f.timeZone = NSTimeZone(name: "US/Eastern") as TimeZone!
        f.dateFormat = "yyyy-M-dd'T'HH:mm:ss"
        
        
        let startDate = f.date(from: date1)
        let endDate = f.date(from: date2)
        print("startDate \(startDate)")
        print("endDate \(endDate)")
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        
        
        let flags = NSCalendar.Unit.minute
        let components = calendar.components(flags, from: startDate!, to: endDate!, options: [])
        
        
        let minutes = components.minute
        print("minutes \(Float(minutes!)/60)")
        
        
        
        
        
        
        let hours = Float(minutes!) / 60
        print("hours \(hours)")
        
        let formattedHours = String(format: "%0.2f", hours)
        print("formattedHours \(formattedHours)")
        
        
        return formattedHours;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func setTimeBtnsAndLbls(_json:JSON){
        //reset time labels
        startTimeLbl.alpha = 0
        startTimeValueLbl.alpha = 0
        stopTimeLbl.alpha = 0
        stopTimeValueLbl.alpha = 0
        startTimeValueLbl.text = ""
        stopTimeValueLbl.text = ""
        
        
        
        /*
         
         
         var json:JSON = _json
         /////////  Detrmine working status   ///////////////////////
         //set start and stop times
         
         print("self.json[0] \(json[0])")
         if(json[0]["ID"] != nil){
         print(json[0]["ID"].string)
         shiftID = json[0]["ID"].string
         }
         
         if(json[0]["startTime"] == nil){                                        //not started working
         print("2")
         //show start btn
         //hide stop btn
         self.signOutBtn.enabled = false
         self.signOutBtn.alpha = 0.5
         
         startTimeLbl.alpha = 0
         startTimeEditTxt.alpha = 0
         stopTimeLbl.alpha = 0
         stopTimeEditTxt.alpha = 0
         
         self.workingStatusIcon.backgroundColor = UIColor.redColor()
         self.workingLbl.text = "Not Working"
         self.workingStatusIcon.alpha = 1.0
         self.workingLbl.alpha = 1.0
         
         if(self.workTimer != nil){
         self.workTimer.invalidate()
         self.workTimer = nil
         }
         
         }else if(json[0]["startTime"] != nil && json[0]["stopTime"] == nil){    //started but not stopped
         print("3")
         
         let dateFormatter = NSDateFormatter()
         
         dateFormatter.timeZone = NSTimeZone(name: "US/Eastern")
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         
         self.startTime = json[0]["startTime"].string!
         print("startTime = \(startTime)")
         //hide start btn
         //show stop btn
         workTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "displayWorkingTime", userInfo: nil, repeats: true)
         self.workingStatusIcon.backgroundColor = UIColor.greenColor()
         self.workingLbl.text = "Working for:"
         self.workingStatusIcon.alpha = 1.0
         self.workingLbl.alpha = 1.0
         
         self.signOutBtn.enabled = true
         self.signOutBtn.alpha = 1.0
         self.signInBtn.enabled = false
         self.signInBtn.alpha = 0.5
         
         let startDateDb = json[0]["startTime"].string!
         print("startTime from database = \(startDateDb)")
         
         
         startTimeLbl.alpha = 1
         startTimeLbl.text = "Signed In: "
         startTimeEditTxt.alpha = 1
         startTimeEditTxt.text = "\(startDateDb)"
         
         }else{                                                              //started and stopped, start new shift
         print("4")
         
         let startDateDb = json[0]["startTime"].string!
         print("startTime from database = \(startDateDb)")
         let stopDateDb = json[0]["stopTime"].string!
         print("stopTime from database = \(stopDateDb)")
         
         //show start btn
         //hide stop btn
         
         self.signInBtn.enabled = true
         self.signInBtn.alpha = 1.0
         self.signOutBtn.enabled = false
         self.signOutBtn.alpha = 0.5
         
         startTimeLbl.alpha = 1
         startTimeLbl.text = "Signed In: "
         startTimeEditTxt.alpha = 1
         startTimeEditTxt.text = "\(startDateDb)"
         
         stopTimeLbl.text = "Signed Out: "
         stopTimeLbl.alpha = 1.0
         stopTimeEditTxt.text = "\(stopDateDb)"
         stopTimeEditTxt.alpha = 1
         
         
         self.workingStatusIcon.backgroundColor = UIColor.redColor()
         self.workingLbl.text = "Not Working"
         self.workingStatusIcon.alpha = 1.0
         self.workingLbl.alpha = 1.0
         if(self.workTimer != nil){
         self.workTimer.invalidate()
         self.workTimer = nil
         }
         
         }
         
         */
        
    }
    
    
    
    
    
    
    
    
    
    
    /*
     func displayWorkingTime() {
     
     
     let now = NSDate()
     // let start = NSDate()
     let dateFormatter:NSDateFormatter = NSDateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     let dateFromString = dateFormatter.dateFromString(self.startTime!)
     // let workingTime = now.offsetFrom(dateFromString!)
     //println("workingTime = \(workingTime)")
     // self.workingLbl.text = "Working for: \(workingTime)"
     //self.workingStatusIcon.backgroundColor = UIColor.greenColor()
     }
     
     
     */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     
     
     // That's my custom picker - adjust whatever you need
     func createPicker(sender: UITextField){
     
     
     
     self.datePickerView = UIDatePicker(frame: CGRectMake(0, 200, view.frame.width, 300))
     self.datePickerView.backgroundColor = .whiteColor()
     
     
     let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
     doneToolbar.backgroundColor = layoutVars.buttonColor1
     
     
     
     // Add pickerview and toolbar to textfield
     sender.inputView = datePickerView
     sender.inputAccessoryView = doneToolbar
     }
     func donePicker() {
     
     startTimeEditTxt.resignFirstResponder()
     }
     
     //MARK:- Date and time
     func setDateAndTime() {
     
     let dateFormatter = NSDateFormatter()
     dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
     let strDate = dateFormatter.stringFromDate(datePickerView.date)
     print("picked date: \(strDate)")
     }
     
     
     func datePickerChanged(sender: AnyObject) {
     setDateAndTime()
     }
     
     func timePickerChanged(sender: AnyObject) {
     setDateAndTime()
     }
     
     
     */
    
    
    
    
    
    
}
