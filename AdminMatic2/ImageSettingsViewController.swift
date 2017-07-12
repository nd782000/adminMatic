//
//  ImageSettingsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/25/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit




class ImageSettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var uploadedBy:String!
    var portfolio:String!
    var fieldNote:String!
    var task:String!
    
    
    
    var filterArray:[String] = ["All Images","My Images","Portfolio Images","Fieldnote Images","Task Images"]
    
    var filterLbl:Label = Label()
    var filterTxtField:PaddedTextField!
    var filterPicker: Picker!
    
    var order:String!

    var orderArray:[String] = ["Newest Images","Oldest Images","Most Liked Images"]
    
    var orderLbl:Label = Label()
    var orderTxtField:PaddedTextField!
    var orderPicker: Picker!
    
    
   // var imageDelegate:ImageViewDelegate!
    var imageSettingsDelegate:ImageSettingsDelegate!
    
    var editsMade:Bool = false
    
    
    
    
    init(_uploadedBy:String,_portfolio:String,_fieldNote:String,_task:String,_order:String){
        super.init(nibName:nil,bundle:nil)
        print("init _uploadedBy = \(_uploadedBy) _portfolio = \(_portfolio)   _fieldNote = \(_fieldNote) _task = \(_task) _order = \(_order)")
        
        self.uploadedBy = _uploadedBy
        self.portfolio = _portfolio
        self.fieldNote = _fieldNote
        self.task = _task
        self.order = _order
        
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
        title = "Image Settings"
        
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
        
        self.filterPicker = Picker()
        self.filterPicker.delegate = self
        
        self.filterLbl.translatesAutoresizingMaskIntoConstraints = false
        self.filterLbl.text = "Filter by:"
        self.view.addSubview(self.filterLbl)
        
        self.filterTxtField = PaddedTextField()
        
        setFilterText()
        
        self.filterTxtField.textAlignment = NSTextAlignment.center
        self.filterTxtField.tag = 1
        self.filterTxtField.delegate = self
        self.filterTxtField.tintColor = UIColor.clear
        self.filterTxtField.inputView = filterPicker
        self.view.addSubview(self.filterTxtField)
        
        
        print("layoutViews 1")
        let filterToolBar = UIToolbar()
        filterToolBar.barStyle = UIBarStyle.default
        filterToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        filterToolBar.sizeToFit()
        
        let filterCloseButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ImageSettingsViewController.cancelFilter))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let filterSelectButton = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ImageSettingsViewController.filter))
        
        filterToolBar.setItems([filterCloseButton, spaceButton, filterSelectButton], animated: false)
        filterToolBar.isUserInteractionEnabled = true
        
        filterTxtField.inputAccessoryView = filterToolBar
        
        
        
        self.orderPicker = Picker()
        self.orderPicker.delegate = self
        
        self.orderLbl.translatesAutoresizingMaskIntoConstraints = false
        self.orderLbl.text = "Order by:"
        self.view.addSubview(self.orderLbl)
        
        self.orderTxtField = PaddedTextField()
        
       setOrderText()
        
        
        self.orderTxtField.textAlignment = NSTextAlignment.center
        self.orderTxtField.tag = 1
        self.orderTxtField.delegate = self
        self.orderTxtField.tintColor = UIColor.clear
        self.orderTxtField.inputView = orderPicker
        self.view.addSubview(self.orderTxtField)
        
        
        print("layoutViews 1")
        let orderToolBar = UIToolbar()
        orderToolBar.barStyle = UIBarStyle.default
        orderToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        orderToolBar.sizeToFit()
        
        let orderCloseButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ImageSettingsViewController.cancelOrder))
        let orderSelectButton = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ImageSettingsViewController.setOrder))
        
        orderToolBar.setItems([orderCloseButton, spaceButton, orderSelectButton], animated: false)
        orderToolBar.isUserInteractionEnabled = true
        
        orderTxtField.inputAccessoryView = orderToolBar
        print("layoutViews 2")
        
        let viewsDictionary = [
            "filterLbl":self.filterLbl,"filterTxt":self.filterTxtField,"orderLbl":self.orderLbl,"orderTxt":self.orderTxtField
            ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navHeight":layoutVars.navAndStatusBarHeight + 20] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[filterLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[filterTxt]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[orderLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[orderTxt]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
       
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[filterLbl(40)][filterTxt(40)]-20-[orderLbl(40)][orderTxt(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    
    //picker view methods
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        var count:Int = 1
        
        if pickerView == filterPicker {
            print("numberOfComponents = \(filterArray.count )")
            count = filterArray.count
        } else if pickerView == orderPicker{
            print("numberOfComponents = \(orderArray.count )")
            count = orderArray.count
        }
        
        return count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var title = ""
        
        if pickerView == filterPicker {
            print("titleForRow = \(filterArray[row])")
            title = filterArray[row]
        } else if pickerView == orderPicker{
            print("titleForRow = \(orderArray[row])")
            title = orderArray[row]
        }
        
        
            return title
            
        
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    func cancelFilter() {
        filterTxtField.resignFirstResponder()
    }
    
    
    
    func filter() {
        filterTxtField.resignFirstResponder()

        print("set filter")

        let row = self.filterPicker.selectedRow(inComponent: 0)
        
        
        editsMade = true
        
        resetVals()
        
        switch row {
        case 0:
            //all
            print("all")
        case 1:
            //my
            self.uploadedBy = self.appDelegate.loggedInEmployee?.ID
        case 2:
            //portfolio
            self.portfolio = "1"
        case 3:
            //fieldnote
            self.fieldNote = "1"
        case 4:
            //task
            self.task = "1"
            
        default:
            print("default")
            
        }
        
        
        setFilterText()
        
        
    }
    
    
    
    func cancelOrder() {
        orderTxtField.resignFirstResponder()
    }
    
    
    
    func setOrder() {
        orderTxtField.resignFirstResponder()
        
        print("set order")
        
        let row = self.orderPicker.selectedRow(inComponent: 0)
        
        
        editsMade = true
        
        
        switch row {
        case 0:
            //newest
            print("newest")
            order = "ID DESC"
        case 1:
            //oldest
            print("oldest")
            order = "ID ASC"
        case 2:
            //most liked
            print("most liked")
            order = "likes DESC, ID DESC"
        default:
            print("default")
            
        }
        
        setOrderText()
        
        
        
    }
    
    func setFilterText(){
        if(self.uploadedBy != "0"){
            self.filterTxtField.text = self.filterArray[1]//my
            self.filterPicker.selectRow(1, inComponent: 0, animated: true)
        }else if(self.portfolio == "1"){
            self.filterTxtField.text = self.filterArray[2]//portfolio
            self.filterPicker.selectRow(2, inComponent: 0, animated: true)
        }else if(self.fieldNote == "1"){
            self.filterTxtField.text = self.filterArray[3]//fieldnote
            self.filterPicker.selectRow(3, inComponent: 0, animated: true)
        }else if(self.task == "1"){
            self.filterTxtField.text = self.filterArray[4]//task
            self.filterPicker.selectRow(4, inComponent: 0, animated: true)
        }else{
            self.filterTxtField.text = self.filterArray[0]//all
        }
    }
    
    func setOrderText(){
        if(self.order == "ID DESC"){
            self.orderTxtField.text = self.orderArray[0]//newest
        }else{
            self.orderTxtField.text = self.orderArray[1]//most likes
            self.orderPicker.selectRow(1, inComponent: 0, animated: true)
        }
    }

    

    func resetVals(){
        print("resetVals")
        self.portfolio = "0"
        self.fieldNote = "0"
        self.task = "0"
        self.uploadedBy = "0"
        
    }
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        if(editsMade == true){
            imageSettingsDelegate.updateSettings(_uploadedBy:self.uploadedBy, _portfolio:self.portfolio, _fieldNote:self.fieldNote, _task:self.task, _order: self.order)

        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}
