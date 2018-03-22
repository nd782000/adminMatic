//
//  PayrollEntryTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 2/21/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation
import UIKit

class PayrollEntryTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate {
    
    var delegate:PayrollDelegate!

    var parentVC:UIViewController!
    
    var row:Int!
    var payroll:Payroll!
    var startBtn:Button!
    var stopBtn:Button!
    var startTxtField: PaddedTextField!
    var startPicker: DatePicker!
    var stopTxtField: PaddedTextField!
    var stopPicker: DatePicker!
    
    
    var breakLbl: Label!
    var breakTxtField: PaddedTextField!
    
    //var addShiftBtn:Button!
    
    var resetBtn:Button!
    
    var lockIcon:UIImageView!
    
    var startStopFormatter = DateFormatter()

    
    let layoutVars : LayoutVars = LayoutVars()
    
    var spaceButton:UIBarButtonItem!

    var metricsDictionary: [String:Any]!
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        //startStopFormatter.dateFormat = "hh:mm a"
        
        self.metricsDictionary = ["halfWidth": layoutVars.halfWidth]
        self.spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        let theDateFormat = DateFormatter.Style.none
        let theTimeFormat = DateFormatter.Style.short
        startStopFormatter.dateStyle = theDateFormat
        startStopFormatter.timeStyle = theTimeFormat
        
        
        
        
    }
    
    
    func layoutStartViews(){
        print("cell layout start")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        //start
        self.startBtn = Button(titleText: "Start")
        self.startBtn.backgroundColor = UIColor(hex:0x005100, op:1)
        self.contentView.addSubview(startBtn)
        self.startBtn.addTarget(self, action: #selector(PayrollEntryTableViewCell.startTime), for: UIControlEvents.touchUpInside)
        
        
        startPicker = DatePicker()
        startPicker.datePickerMode = UIDatePickerMode.time
        
        self.startTxtField = PaddedTextField()
        self.startTxtField.leftMargin = 0.0
        self.startTxtField.textAlignment = .center
        
        self.startTxtField.returnKeyType = UIReturnKeyType.next
        self.startTxtField.delegate = self
        //self.startTxtField.tag = 8
        self.startTxtField.inputView = self.startPicker
        self.contentView.addSubview(self.startTxtField)
        
        
        let startToolBar = UIToolbar()
        startToolBar.barStyle = UIBarStyle.default
        startToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        startToolBar.sizeToFit()
        //let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
       
        let setStartButton = UIBarButtonItem(title: "Set Start", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PayrollEntryTableViewCell.handleStartPicker))
        startToolBar.setItems([spaceButton, setStartButton], animated: false)
        startToolBar.isUserInteractionEnabled = true
        startTxtField.inputAccessoryView = startToolBar
        
        lockIcon = UIImageView()
        lockIcon.backgroundColor = UIColor.clear
        lockIcon.contentMode = .scaleAspectFill
        let lockImg = UIImage(named:"lockIcon.png")
        lockIcon.image = lockImg
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(lockIcon)
        
    
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["startBtn": self.startBtn,"startTxt": self.startTxtField,"lockIcon":lockIcon] as [String:AnyObject]
        
        //let metricsDictionary = ["halfWidth": layoutVars.halfWidth] as [String:Any]
        
        if self.payroll.verified == "1"{
                        
            self.startTxtField.isEnabled = false
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[startBtn(halfWidth)]-[startTxt]-[lockIcon(20)]-5-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        }else{
            lockIcon.isHidden = true
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[startBtn(halfWidth)]-[startTxt]-5-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[startBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[startTxt(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    func layoutStopViews(){
        print("cell layout stop")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        //stop
        self.stopBtn = Button(titleText: "Stop")
        self.stopBtn.backgroundColor = UIColor.red
        self.contentView.addSubview(stopBtn)
        self.stopBtn.addTarget(self, action: #selector(PayrollEntryTableViewCell.stopTime), for: UIControlEvents.touchUpInside)
        
        
        stopPicker = DatePicker()
        stopPicker.datePickerMode = UIDatePickerMode.time
        
        
        self.stopTxtField = PaddedTextField()
        self.stopTxtField.leftMargin = 0.0
        self.stopTxtField.textAlignment = .center
        
        self.stopTxtField.returnKeyType = .done
        self.stopTxtField.delegate = self
        //self.startTxtField.tag = 8
        self.stopTxtField.inputView = self.stopPicker
        self.contentView.addSubview(self.stopTxtField)
        
        
        let stopToolBar = UIToolbar()
        stopToolBar.barStyle = UIBarStyle.default
        stopToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        stopToolBar.sizeToFit()
        //let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let setStopButton = UIBarButtonItem(title: "Set Stop", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PayrollEntryTableViewCell.handleStopPicker))
        
        stopToolBar.setItems([spaceButton, setStopButton], animated: false)
        stopToolBar.isUserInteractionEnabled = true
        stopTxtField.inputAccessoryView = stopToolBar
        
        lockIcon = UIImageView()
        lockIcon.backgroundColor = UIColor.clear
        lockIcon.contentMode = .scaleAspectFill
        let lockImg = UIImage(named:"lockIcon.png")
        lockIcon.image = lockImg
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(lockIcon)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["stopBtn": self.stopBtn,"stopTxt": self.stopTxtField,"lockIcon":lockIcon] as [String:AnyObject]
        
        //let metricsDictionary = ["halfWidth": layoutVars.halfWidth] as [String:Any]
        
        if self.payroll.verified == "1"{
             self.stopTxtField.isEnabled = false
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[stopBtn(halfWidth)]-[stopTxt]-[lockIcon(20)]-5-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        }else{
            lockIcon.isHidden = true
             contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[stopBtn(halfWidth)]-[stopTxt]-5-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
        }
       
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[stopBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[stopTxt(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
    func layoutBreakViews(){
        print("cell layout break")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        //break
        self.breakLbl = Label(text: "Break (mins.):")
        self.breakLbl.textAlignment = .right
        self.contentView.addSubview(breakLbl)
        
        self.breakTxtField = PaddedTextField()
        self.breakTxtField.leftMargin = 0.0
        self.breakTxtField.textAlignment = .center
        self.breakTxtField.returnKeyType = .done
        self.breakTxtField.delegate = self
        
        //self.startTxtField.tag = 8
        self.breakTxtField.keyboardType = .numberPad
        self.contentView.addSubview(self.breakTxtField)
        
        
        let breakToolBar = UIToolbar()
        breakToolBar.barStyle = UIBarStyle.default
        breakToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        breakToolBar.sizeToFit()
        //let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let setBreakButton = UIBarButtonItem(title: "Set Break", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PayrollEntryTableViewCell.handleBreakSet))
        breakToolBar.setItems([spaceButton, setBreakButton], animated: false)
        breakToolBar.isUserInteractionEnabled = true
        breakTxtField.inputAccessoryView = breakToolBar
        
        lockIcon = UIImageView()
        lockIcon.backgroundColor = UIColor.clear
        lockIcon.contentMode = .scaleAspectFill
        let lockImg = UIImage(named:"lockIcon.png")
        lockIcon.image = lockImg
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(lockIcon)
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["breakLbl": self.breakLbl,"breakTxt": self.breakTxtField,"lockIcon":lockIcon] as [String:AnyObject]
        if self.payroll.verified == "1"{
            self.breakTxtField.isEnabled = false
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[breakLbl(halfWidth)]-[breakTxt]-[lockIcon(20)]-5-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[lockIcon(20)]", options: [], metrics: nil, views: viewsDictionary))
        }else{
            lockIcon.isHidden = true
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[breakLbl(halfWidth)]-[breakTxt]-5-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
        }
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[breakLbl(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[breakTxt(40)]", options: [], metrics: nil, views: viewsDictionary))
    }
    
    
    /*
    func layoutAddViews(){
        print("cell layout add")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        //add
        self.addShiftBtn = Button(titleText: "Add Shift")
        self.addShiftBtn.backgroundColor = UIColor.darkGray
        self.contentView.addSubview(addShiftBtn)
        self.addShiftBtn.addTarget(self, action: #selector(PayrollEntryTableViewCell.addShift), for: UIControlEvents.touchUpInside)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["addBtn": self.addShiftBtn] as [String:AnyObject]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[addBtn]-50-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
    }
 */
    
    func layoutResetViews(){
        print("cell layout reset")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        //reset
        self.resetBtn = Button(titleText: "Reset Shift")
        self.resetBtn.backgroundColor = UIColor.darkGray
        self.contentView.addSubview(resetBtn)
        self.resetBtn.addTarget(self, action: #selector(PayrollEntryTableViewCell.resetShift), for: UIControlEvents.touchUpInside)
        
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["resetBtn": self.resetBtn] as [String:AnyObject]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[resetBtn]-50-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[resetBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
    }
    
    
    @objc func startTime() {
        print("startTime")
        
        if self.payroll.verified == "1"{
            //need userLevel greater then 1 to access this
        simpleAlert(_vc: self.parentVC, _title: "Payroll Locked", _message: "This payroll entry has already been verified by the office and can not be edited.")
                return
        }
        
        self.startTxtField.text =  startStopFormatter.string(from: Date())
        
        startPicker.date = Date()
        
        
        self.delegate.editStart(row: self.row, start: Date())
    }
    
    @objc func stopTime() {
        print("stopTime")
        
        if self.payroll.verified == "1"{
            //need userLevel greater then 1 to access this
            simpleAlert(_vc: self.parentVC, _title: "Payroll Locked", _message: "This payroll entry has already been verified by the office and can not be edited.")
            return
        }
        
        self.stopTxtField.text =  startStopFormatter.string(from: Date())
        
        stopPicker.date = Date()
        
        self.delegate.editStop(row: self.row, stop: Date())
    }
    
    
    /*
    @objc func addShift() {
        print("addShift")
        
    }
 */
    
    @objc func resetShift() {
        print("resetShift")
        
        if self.payroll.verified == "1"{
            //need userLevel greater then 1 to access this
            simpleAlert(_vc: self.parentVC, _title: "Payroll Locked", _message: "This payroll entry has already been verified by the office and can not be edited.")
            return
        }
        
        
        let alertController = UIAlertController(title: "Reset Shift?", message: "Are you sure you want to reset this shift?", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
            self.delegate.resetShift(row: self.row)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.parentVC.present(alertController, animated: true, completion: nil)
        
        
        
        
        
        
    }
    
    
   
    
    
    @objc func handleStartPicker(){
        self.startTxtField.resignFirstResponder()
        /*
        if self.payroll.verified == "1"{
            //need userLevel greater then 1 to access this
            simpleAlert(_vc: self.parentVC, _title: "Payroll Locked", _message: "This payroll entry has already been verified by the office and can not be edited.")
            return
        }*/
        
        
        
        self.startTxtField.text =  startStopFormatter.string(from: startPicker.date)
        
        self.delegate.editStart(row: self.row, start: startPicker.date)
        
    }
    
    @objc func handleStopPicker(){
        self.stopTxtField.resignFirstResponder()
        /*
        if self.payroll.verified == "1"{
            //need userLevel greater then 1 to access this
            simpleAlert(_vc: self.parentVC, _title: "Payroll Locked", _message: "This payroll entry has already been verified by the office and can not be edited.")
            return
        }*/
        
        self.stopTxtField.text =  startStopFormatter.string(from: stopPicker.date)
        
        self.delegate.editStop(row: self.row, stop: stopPicker.date)
        
    }
    
    @objc func handleBreakSet(){
        self.breakTxtField.resignFirstResponder()
        
        /*
        if self.payroll.verified == "1"{
            //need userLevel greater then 1 to access this
            simpleAlert(_vc: self.parentVC, _title: "Payroll Locked", _message: "This payroll entry has already been verified by the office and can not be edited.")
            return
        }
 */
        
        
        if Int(breakTxtField.text!) != nil{
            let breakTime = Int(breakTxtField.text!)
            //print("call delegate \(self.row)  \(breakTime)")
            self.delegate.editBreak(row: self.row, lunch: breakTime!)
        }
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textfield did begin editing")
        
       
        
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}



