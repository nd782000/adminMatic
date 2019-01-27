//
//  ScheduleSettingsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 5/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

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
    var mowSort:String!
    
    var plowSortSwitch:UISwitch = UISwitch()
    var plowSortSwitchLbl:Label = Label()
    var plowSort:String!
    
    
    var plowDepthTxtField:PaddedTextField!
    var plowDepthPicker: Picker!
    var plowDepthArray = ["All Depths","1 Inch","2 Inches","3 Inches","4 Inches","5 Inches","6 Inches","7 Inches","8 Inches","9 Inches","10 Inches","11 Inches","12 Inches"]
    var plowDepth:String = "0"
    
    
    
    
    var delegate:ScheduleDelegate!
    
    var editsMade:Bool = false
    
    
    
    
    init(_allDates:String,_startDate:String,_endDate:String,_startDateDB:String,_endDateDB:String,_mowSort:String,_plowSort:String, _plowDepth:String){
        super.init(nibName:nil,bundle:nil)
        print("init _allDates = \(_allDates)  _startDate = \(_startDate)   _stopDate = \(_endDate)  _mowSort = \(_mowSort) _plowSort = \(_plowSort) _plowDepth = \(_plowDepth)")
        self.allDates = _allDates
        self.startDate = _startDate
        self.endDate = _endDate
        self.startDateDB = _startDateDB
        self.endDateDB = _endDateDB
        self.mowSort = _mowSort
        self.plowSort = _plowSort
        self.plowDepth = _plowDepth
        
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
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(ScheduleSettingsViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.layoutViews()
        
    }
    
    
    func layoutViews(){
        
        print("layoutViews")
        // indicator.dismissIndicator()
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        if(self.allDates == "1"){
            allDatesSwitch.isOn = true
        }else{
            allDatesSwitch.isOn = false
        }
        allDatesSwitch.translatesAutoresizingMaskIntoConstraints = false
        allDatesSwitch.addTarget(self, action: #selector(ScheduleSettingsViewController.allDatesValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(allDatesSwitch)
        
        allDatesSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        allDatesSwitchLbl.text = "All Dates"
        safeContainer.addSubview(allDatesSwitchLbl)

        
        
        
        startLbl.translatesAutoresizingMaskIntoConstraints = false
        startLbl.text = "Start Date"
        safeContainer.addSubview(startLbl)
        
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        startPickerView = DatePicker()
        startPickerView.datePickerMode = UIDatePicker.Mode.date
        startStopFormatter.dateFormat = "MM/dd/yy"
        
        self.startTxtField = PaddedTextField()
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPickerView
        //self.startTxtField.text = self.startDate
        self.startTxtField.attributedPlaceholder = NSAttributedString(string:startDate,attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        safeContainer.addSubview(self.startTxtField)
        
        
        print("layoutViews 1")
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        let setStartButton = UIBarButtonItem(title: "Set Start Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        //stop
        
        stopLbl.translatesAutoresizingMaskIntoConstraints = false
        stopLbl.text = "Stop Date"
        safeContainer.addSubview(stopLbl)
        
        print("layoutViews 2")
        stopPickerView = DatePicker()
        stopPickerView.datePickerMode = UIDatePicker.Mode.date
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.returnKeyType = UIReturnKeyType.next
        self.stopTxtField.delegate = self
        self.stopTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPickerView
        self.stopTxtField.attributedPlaceholder = NSAttributedString(string:endDate,attributes:[NSAttributedString.Key.foregroundColor: layoutVars.buttonColor1])
        safeContainer.addSubview(self.stopTxtField)
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        let setStopButton = UIBarButtonItem(title: "Set Stop Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UsageEntryTableViewCell.handleStopPicker))
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar
        

        print("layoutViews 3")
        
        
        if(self.mowSort == "1"){
            mowSortSwitch.isOn = true
        }else{
            mowSortSwitch.isOn = false
        }
        mowSortSwitch.translatesAutoresizingMaskIntoConstraints = false
        mowSortSwitch.addTarget(self, action: #selector(ScheduleSettingsViewController.mowSortValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(mowSortSwitch)
        
        mowSortSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        mowSortSwitchLbl.text = "Sort for Mowing"
        safeContainer.addSubview(mowSortSwitchLbl)
        
        
        
        plowSortSwitch.translatesAutoresizingMaskIntoConstraints = false
        plowSortSwitch.addTarget(self, action: #selector(ScheduleSettingsViewController.plowSortValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(plowSortSwitch)
        
        plowSortSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        plowSortSwitchLbl.text = "Sort for Plowing"
        safeContainer.addSubview(plowSortSwitchLbl)
        
        
        
        
        
        
        
        //status picker
        self.plowDepthPicker = Picker()
        self.plowDepthPicker.tag = 1
        self.plowDepthPicker.delegate = self
        self.plowDepthPicker.selectRow(Int(plowDepth)!, inComponent: 0, animated: false)
        self.plowDepthTxtField = PaddedTextField()
        self.plowDepthTxtField.textAlignment = NSTextAlignment.center
        self.plowDepthTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.plowDepthTxtField.delegate = self
        
        self.plowDepthTxtField.inputView = plowDepthPicker
        safeContainer.addSubview(self.plowDepthTxtField)
        let plowDepthToolBar = UIToolbar()
        plowDepthToolBar.barStyle = UIBarStyle.default
        plowDepthToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        plowDepthToolBar.sizeToFit()
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ScheduleSettingsViewController.cancelPlowDepthInput))
        let setPlowDepthButton = UIBarButtonItem(title: "Set Plow Depth", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ScheduleSettingsViewController.handlePlowDepthChange))
        plowDepthToolBar.setItems([closeButton, spaceButton, setPlowDepthButton], animated: false)
        plowDepthToolBar.isUserInteractionEnabled = true
        plowDepthTxtField.inputAccessoryView = plowDepthToolBar
        
        
        
        if(self.plowSort == "1"){
            plowSortSwitch.isOn = true
            plowDepthTxtField.alpha = 1.0
        }else{
            plowSortSwitch.isOn = false
            plowDepthTxtField.alpha = 0.0
            
        }
        self.plowDepthTxtField.text = self.plowDepthArray[Int(plowDepth)!]

        
        
        
        //auto layout group
        let viewsDictionary = [
            "allDatesSwitch":allDatesSwitch,
            "allDatesSwitchLbl":allDatesSwitchLbl,
            "startLbl":self.startLbl,
            "view1":self.startTxtField,
            "stopLbl":self.stopLbl,
            "view2":self.stopTxtField,
            "mowSwitch":self.mowSortSwitch,
            "mowLbl":self.mowSortSwitchLbl,
            "plowSwitch":self.plowSortSwitch,
            "plowLbl":self.plowSortSwitchLbl,
            "plowDepthTxtField":self.plowDepthTxtField
            ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navHeight":layoutVars.navAndStatusBarHeight + 20] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[allDatesSwitch(60)]-[allDatesSwitchLbl]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[startLbl(80)]-[view1(80)]-[stopLbl(80)]-[view2(80)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mowSwitch(60)]-[mowLbl]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[plowSwitch(60)]-[plowLbl]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[plowDepthTxtField(200)]", options: [], metrics: sizeVals, views: viewsDictionary))
       // safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view3(60)]-[view4]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[allDatesSwitch(40)]-[startLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[allDatesSwitch(40)]-[stopLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[allDatesSwitch(40)]-[view1(40)]-[mowSwitch(40)]-[plowSwitch(40)]-[plowDepthTxtField(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[allDatesSwitchLbl(40)]-[view2(40)]-[mowLbl(40)]-[plowLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        
        
    }
    
    @objc func mowSortValueDidChange(sender:UISwitch!)
    {
        print("mowSortValueDidChange")
        
        editsMade = true
        if (sender.isOn == true){
            print("on")
            mowSort = "1"
            plowSort = "0"
            plowSortSwitch.isOn = false
        }
        else{
            print("off")
            mowSort = "0"
        }
        
        
    }
    
    
    @objc func plowSortValueDidChange(sender:UISwitch!)
    {
        print("plowSortValueDidChange")
        
        editsMade = true
        if (sender.isOn == true){
            print("on")
            plowSort = "1"
            mowSort = "0"
            mowSortSwitch.isOn = false
            plowDepthTxtField.alpha = 1.0
        }
        else{
            print("off")
            plowSort = "0"
            plowDepth = "0"
            plowDepthTxtField.alpha = 0.0
        }
        
        
    }
    
    @objc func cancelPlowDepthInput(){
        print("Cancel Plow Depth Input")
        self.plowDepthTxtField.resignFirstResponder()
    }
    
    
    
    
    
    
    @objc func allDatesValueDidChange(sender:UISwitch!)
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
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
       
        let count:Int = self.plowDepthArray.count
       
       
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    /*
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        print("pickerview tag: \(pickerView.tag)")
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:60))
        
        var rowString = String()
        if(pickerView.tag == 1){
            let myImageView = UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
            rowString = statusArray[row]
            switch row {
            case 0:
                myImageView.image = UIImage(named:"unDoneStatus.png")
                break
            case 1:
                myImageView.image = UIImage(named:"inProgressStatus.png")
                break
            case 2:
                myImageView.image = UIImage(named:"doneStatus.png")
                break
            case 3:
                myImageView.image = UIImage(named:"cancelStatus.png")
                break
            case 4:
                myImageView.image = UIImage(named:"waitingStatus.png")
                break
            default:
                myImageView.image = nil
            }
            let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
            myLabel.font = layoutVars.smallFont
            myLabel.text = rowString
            myView.addSubview(myLabel)
            myView.addSubview(myImageView)
            
        }else{
            
            
            rowString = scheduleTypeArray[row]
            
            let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
            myLabel.font = layoutVars.smallFont
            myLabel.text = rowString
            myView.addSubview(myLabel)
            
        }
        return myView
        
    }
 */
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.plowDepthArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
       
            //self.scheduleTypeValueToUpdate = "\(row + 1)"
            self.plowDepth = "\(row)"
            self.plowDepthTxtField.text = self.plowDepthArray[self.plowDepthPicker.selectedRow(inComponent: 0)]
        
        
    }
    /*
    func cancelPicker(){
        //self.statusValueToUpdate = self.statusValue
        self.statusTxtField.resignFirstResponder()
        self.scheduleTypeTxtField.resignFirstResponder()
    }
 */
     
    
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
    
    
    @objc func handlePlowDepthChange(){
        self.plowDepthTxtField.resignFirstResponder()
        editsMade = true
        plowDepth = "\(self.plowDepthPicker.selectedRow(inComponent: 0))"
    }
    
    
    
    
    
    
    
    
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        if(editsMade == true){
            delegate.updateSettings(_allDates:self.allDates, _startDate:self.startDate, _endDate:self.endDate, _startDateDB:self.startDateDB, _endDateDB:self.endDateDB, _mowSort:self.mowSort, _plowSort:self.plowSort, _plowDepth:self.plowDepth)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}

