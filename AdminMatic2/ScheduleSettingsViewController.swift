//
//  ScheduleSettingsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 5/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit

class ScheduleSettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate{
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var allDates:String = "1"
    var startDate:String!
    var endDate:String!
    var startDateDB:String!
    var endDateDB:String!
    var sort:String!
    
    
    var allDatesSwitch:UISwitch = UISwitch()
    var allDatesSwitchLbl:Label = Label()
    
    var startLbl:Label = Label()
    var startTxtField: PaddedTextField!
    var startPickerView :DatePicker!//edit mode
    
    var stopLbl:Label = Label()
    var stopTxtField: PaddedTextField!
    var stopPickerView :DatePicker!//edit mode
    
    var startStopFormatter = DateFormatter()
    
    
    
    var mowSortSwitch:UISwitch = UISwitch()
    var mowSortSwitchLbl:Label = Label()
    
    var delegate:ScheduleDelegate!
    
    var editsMade:Bool = false
    
    
    
    
    init(_allDates:String,_startDate:String,_endDate:String,_startDateDB:String,_endDateDB:String,_sort:String){
        super.init(nibName:nil,bundle:nil)
        print("init _allDates = \(_allDates)  _startDate = \(_startDate)   _stopDate = \(_endDate)  _sort = \(_sort)")
        self.allDates = _allDates
        self.startDate = _startDate
        self.endDate = _endDate
        self.startDateDB = _startDateDB
        self.endDateDB = _endDateDB
        self.sort = _sort
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Schedule Settings"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.layoutViews()
        
    }
    
    
    func layoutViews(){
        
        print("layoutViews")
        // indicator.dismissIndicator()
        
        if(self.allDates == "1"){
            allDatesSwitch.isOn = true
        }else{
            allDatesSwitch.isOn = false
        }
        allDatesSwitch.translatesAutoresizingMaskIntoConstraints = false
        allDatesSwitch.addTarget(self, action: #selector(ScheduleSettingsViewController.allDatesValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(allDatesSwitch)
        
        allDatesSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        allDatesSwitchLbl.text = "All Dates"
        self.view.addSubview(allDatesSwitchLbl)

        
        
        
        startLbl.translatesAutoresizingMaskIntoConstraints = false
        startLbl.text = "Start Date"
        self.view.addSubview(startLbl)
        
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePickerMode.date
        startStopFormatter.dateFormat = "MM/dd/yy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        //self.startTxtField.text = self.startDate
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:startDate,attributes:[NSForegroundColorAttributeName: layoutVars.buttonColor1])
        self.view.addSubview(self.startTxtField)
        
        
        print("layoutViews 1")
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Date", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        
        stopLbl.translatesAutoresizingMaskIntoConstraints = false
        stopLbl.text = "Stop Date"
        self.view.addSubview(stopLbl)
        
        print("layoutViews 2")
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePickerMode.date
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:endDate,attributes:[NSForegroundColorAttributeName: layoutVars.buttonColor1])
        self.view.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Date", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar
        

        print("layoutViews 3")
        
        
        
        
        if(self.sort == "1"){
            mowSortSwitch.isOn = true
        }else{
            mowSortSwitch.isOn = false
        }
        mowSortSwitch.translatesAutoresizingMaskIntoConstraints = false
        mowSortSwitch.addTarget(self, action: #selector(ScheduleSettingsViewController.mowSortValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(mowSortSwitch)
        
        mowSortSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        mowSortSwitchLbl.text = "Sort for Mowing"
        self.view.addSubview(mowSortSwitchLbl)
        
        
        
        
        
        //auto layout group
        let viewsDictionary = [
            "allDatesSwitch":allDatesSwitch,
            "allDatesSwitchLbl":allDatesSwitchLbl,
            "startLbl":self.startLbl,
            "view1":self.startTxtField,
            "stopLbl":self.stopLbl,
            "view2":self.stopTxtField,
            "view3":self.mowSortSwitch,
            "view4":self.mowSortSwitchLbl
            ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navHeight":layoutVars.navAndStatusBarHeight + 20] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[allDatesSwitch(60)]-[allDatesSwitchLbl]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[startLbl(80)]-[view1(80)]-[stopLbl(80)]-[view2(80)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view3(60)]-[view4]-|", options: [], metrics: sizeVals, views: viewsDictionary))
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view3(60)]-[view4]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[allDatesSwitch(40)]-[startLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[allDatesSwitch(40)]-[stopLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[allDatesSwitch(40)]-[view1(40)]-[view3(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[allDatesSwitchLbl(40)]-[view2(40)]-[view4(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
        
    }
    
    func mowSortValueDidChange(sender:UISwitch!)
    {
        print("sortValueDidChange")
        
        editsMade = true
        if (sender.isOn == true){
            print("on")
            sort = "1"
        }
        else{
            print("off")
            sort = "0"
        }
        
        
    }
    
    func allDatesValueDidChange(sender:UISwitch!)
    {
        print("allDatesValueDidChange")
        
        editsMade = true
        if (sender.isOn == true){
            print("on")
            allDates = "1"
            startDate = ""
            endDate = ""
            startDateDB = ""
            endDateDB = ""
            startTxtField.text = ""
            stopTxtField.text = ""
        }
        else{
            print("off")
            allDates = "0"
        }
        
        
    }
    
    
    func handleStartPicker()
    {
        //print("handle start picker")
        self.startTxtField.resignFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        self.startTxtField.text = dateFormatter.string(from: startPickerView.date)
        startDate = dateFormatter.string(from: startPickerView.date)
        startDateDB = dateFormatterDB.string(from: startPickerView.date)
        //getPerformance()
        
        editsMade = true

        allDatesSwitch.isOn = false
        self.allDates = "0"
    }
    
    
    func handleStopPicker()
    {
        // print("handle stop picker")
        self.stopTxtField.resignFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        self.stopTxtField.text = dateFormatter.string(from: stopPickerView.date)
        endDate = dateFormatter.string(from: stopPickerView.date)
        endDateDB = dateFormatterDB.string(from: stopPickerView.date)
        //getPerformance()
        
        editsMade = true
        allDatesSwitch.isOn = false
        self.allDates = "0"
    }
    
    
    
    
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        if(editsMade == true){
            delegate.updateSettings(_allDates:self.allDates, _startDate:self.startDate, _endDate:self.endDate, _startDateDB:self.startDateDB, _endDateDB:self.endDateDB, _sort:self.sort)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}
