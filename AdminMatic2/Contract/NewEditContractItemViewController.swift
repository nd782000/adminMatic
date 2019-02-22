//
//  NewContractItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/15/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import DKImagePickerController
 

class NewEditContractItemViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,  UIPickerViewDelegate, UIPickerViewDataSource{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:EditContractDelegate!
    var editDelegate:EditContractItemDelegate!
    var indicator: SDevIndicator!
    var backButton:UIButton!
    
    
    var contract:Contract!
    var itemCount:Int!
    //var charge:String!
    
    let safeContainer:UIView = UIView()
    
    var itemSearchBar:UISearchBar = UISearchBar()
    var itemResultsTableView:TableView = TableView()
    var itemSearchResults:[String] = []
    
    var chargeTypeLbl:Label!
    var chargeTypeTxtField:PaddedTextField!
    var chargeTypePicker: Picker!
    var chargeTypeArray = ["NC - No Charge", "FL - Flat Priced", "T & M - Time & Material"]
    
    
    var estQtyLbl:Label!
    var estQtyTxtField: PaddedTextField!
    
    var priceLbl:Label!
    var priceTxtField: PaddedTextField!
    
    
    
    var hideUnitsLbl:Label!
    var hideUnitsSwitch:UISwitch = UISwitch()
    
    var totalLbl:Label!
    var totalTxtField: PaddedTextField!
    //var total:String = "0.00"
    
    var infoLbl:Label!
    
    
    
    var submitBtn:Button = Button(titleText: "Submit")
    
    
    
    var keyBoardShown:Bool = false
    
    
    
    //linking result arrays
    var ids = [String]()
    var names = [String]()
    var types = [String]()
    var prices = [String]()
    var units = [String]()
    var taxes = [String]()
    var subcontractors = [String]()
    
    var contractItem:ContractItem!
    
    
    var keyboardHeight:CGFloat = 216
    
    var editMode:Bool = false
    
    var editsMade:Bool = false
    
    init(_contract:Contract,_itemCount:Int){
        super.init(nibName:nil,bundle:nil)
        
        //print("new Item init")
        
        title = "Add Item"
        
        self.contract = _contract
        self.itemCount = _itemCount
        
    }
    
    //init for edit
   
    init(_contract:Contract,_contractItem:ContractItem){
        super.init(nibName:nil,bundle:nil)
        //print("edit Item init")
        
        title = "Edit Item"
        self.contract = _contract
        self.contractItem = _contractItem
        
        editMode = true
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
        
        
        view.backgroundColor = layoutVars.backgroundColor
        
        
        /*
        //custom back button
        backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
 */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
    }
    
    
    
    
    func loadLinkList(_linkType:String, _loadScript:API.Router){
        //print("load link list")
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        Alamofire.request(_loadScript).responseJSON() {
            
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json[_linkType] as? [[String: Any]] {
                    for result in results {
                        if let id = result["ID"] as? String {
                            self.ids.append(id)
                        }
                        if let name = result["name"] as? String {
                            self.names.append(name)
                        }
                        if let type = result["typeID"] as? String {
                            self.types.append(type)
                        }
                        if let price = result["price"] as? String {
                            self.prices.append(price)
                        }
                        if let unit = result["unit"] as? String {
                            self.units.append(unit)
                        }
                        if let tax = result["tax"] as? String {
                            self.taxes.append(tax)
                        }
                        if let subcontractor = result["subcontractor"] as? String {
                            self.subcontractors.append(subcontractor)
                        }
                    }
                }
            } catch {
                //print("Error deserializing JSON: \(error)")
            }
            
            self.layoutViews()
        }
    }
    
    
    
    func layoutViews(){
        
        //print("layoutViews")
        if(indicator != nil){
            indicator.dismissIndicator()
        }
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //set container to safe bounds of view
        //let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        if self.contractItem == nil{
            itemSearchBar.placeholder = "Item..."
        }else{
            itemSearchBar.text = self.contractItem.name
        }
        
        itemSearchBar.translatesAutoresizingMaskIntoConstraints = false
        itemSearchBar.layer.cornerRadius = 4
        itemSearchBar.clipsToBounds = true
        itemSearchBar.backgroundColor = UIColor.white
        itemSearchBar.barTintColor = UIColor.clear
        itemSearchBar.searchBarStyle = UISearchBar.Style.minimal
        itemSearchBar.delegate = self
        safeContainer.addSubview(itemSearchBar)
        
        
        self.itemResultsTableView.delegate  =  self
        self.itemResultsTableView.dataSource = self
        //might want to change to custom linkCell class
        self.itemResultsTableView.register(NewWoItemTableViewCell.self, forCellReuseIdentifier: "linkCell")
        self.itemResultsTableView.alpha = 0.0
        
        
        
        //charge type
        self.chargeTypeLbl = Label(text: "Charge Type:")
        chargeTypeLbl.textAlignment = .right
        safeContainer.addSubview(chargeTypeLbl)
        
        self.chargeTypePicker = Picker()
        self.chargeTypePicker.delegate = self
        self.chargeTypePicker.dataSource = self
        self.chargeTypePicker.tag = 1
        
        
        self.chargeTypeTxtField = PaddedTextField(placeholder: "Charge Type...")
        self.chargeTypeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.chargeTypeTxtField.delegate = self
        self.chargeTypeTxtField.inputView = chargeTypePicker
        safeContainer.addSubview(self.chargeTypeTxtField)
        
        
        let chargeTypeToolBar = UIToolbar()
        chargeTypeToolBar.barStyle = UIBarStyle.default
        chargeTypeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        chargeTypeToolBar.sizeToFit()
        let closeChargeTypeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelChargeTypeInput))
        
        let setChargeTypeButton = UIBarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleChargeTypeChange))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        chargeTypeToolBar.setItems([closeChargeTypeButton, spaceButton, setChargeTypeButton], animated: false)
        chargeTypeToolBar.isUserInteractionEnabled = true
        chargeTypeTxtField.inputAccessoryView = chargeTypeToolBar
        
        if self.contractItem != nil{
            if(contractItem.chargeType != ""){
                chargeTypeTxtField.text = chargeTypeArray[Int(contractItem.chargeType)! - 1]
                self.chargeTypePicker.selectRow(Int(self.contractItem.chargeType)! - 1, inComponent: 0, animated: false)
            
            
            }
        }else{
            chargeTypeTxtField.text = chargeTypeArray[Int(contract.chargeType)! - 1]
            self.chargeTypePicker.selectRow(Int(self.contract.chargeType)! - 1, inComponent: 0, animated: false)
            //self.contractItem.chargeType = contract.chargeType
        }
        
        
        
        
        
        
        self.estQtyLbl = Label(text: "Estimated Qty")
        
        
        
        self.estQtyLbl.textAlignment = .right
        safeContainer.addSubview(self.estQtyLbl)
        
        
        
        self.estQtyTxtField = PaddedTextField()
        
        if self.contractItem != nil{
            self.estQtyTxtField.text = self.contractItem.qty
        }
        
        
        self.estQtyTxtField.delegate = self
        
        self.estQtyTxtField.keyboardType = UIKeyboardType.decimalPad
        self.estQtyTxtField.tag = 10
        
        safeContainer.addSubview(self.estQtyTxtField)
        
       
        
        let estQtyToolBar = UIToolbar()
        estQtyToolBar.barStyle = UIBarStyle.default
        estQtyToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        estQtyToolBar.sizeToFit()
        let setEstQtyButton = UIBarButtonItem(title: "Set Qty", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleEstQty))
        estQtyToolBar.setItems([spaceButton, setEstQtyButton], animated: false)
        estQtyToolBar.isUserInteractionEnabled = true
        estQtyTxtField.inputAccessoryView = estQtyToolBar
        
        
        
        
        
        self.priceLbl = Label(text: "Unit Price $")
        self.priceLbl.textAlignment = .right
        safeContainer.addSubview(self.priceLbl)
        self.priceTxtField = PaddedTextField()
        if self.contractItem != nil{
            self.priceTxtField.text = self.contractItem.price
        }
        self.priceTxtField.delegate = self
        self.priceTxtField.keyboardType = UIKeyboardType.decimalPad
        self.priceTxtField.tag = 11
        safeContainer.addSubview(self.priceTxtField)
        
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let priceToolBar = UIToolbar()
        priceToolBar.barStyle = UIBarStyle.default
        priceToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        priceToolBar.sizeToFit()
        let setPriceButton = UIBarButtonItem(title: "Set Price", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handlePrice))
        priceToolBar.setItems([spaceButton2, setPriceButton], animated: false)
        priceToolBar.isUserInteractionEnabled = true
        priceTxtField.inputAccessoryView = priceToolBar
        
        
        
        //hide units
        self.hideUnitsLbl = Label(text: "Hide Qty:")
        self.hideUnitsLbl.textAlignment = .right
        self.hideUnitsLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(hideUnitsLbl)
        
        if self.contractItem != nil{
            if(self.contractItem.hideUnits != "0" && self.contractItem.hideUnits != ""){
                hideUnitsSwitch.isOn = true
            }else{
                hideUnitsSwitch.isOn = false
            }
        }else{
            hideUnitsSwitch.isOn = false
        }
 
        hideUnitsSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        hideUnitsSwitch.addTarget(self, action: #selector(self.hideUnitsSwitchValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(hideUnitsSwitch)
        
        
        
        self.totalLbl = Label(text: "Total $")
        self.totalLbl.textAlignment = .right
        safeContainer.addSubview(self.totalLbl)
        self.totalTxtField = PaddedTextField()
        
        if self.contractItem != nil{
            
                if(self.contractItem.chargeType == "1" || self.contractItem.qty == "0" || self.contractItem.price == "0.00"){
                    self.contractItem.total = "0.00"
                }else{
                    self.contractItem.total = String(format: "%.2f", Double(self.contractItem.qty)! * Double(self.contractItem.price)!)
                }
            
            
        }
        
        if self.contractItem != nil{
            self.totalTxtField.text = self.contractItem.total
        }
        self.totalTxtField.isEnabled = false
        self.totalTxtField.alpha = 0.5
    
        
        safeContainer.addSubview(self.totalTxtField)
        
        self.infoLbl = Label(text:"")
        setInfoTxt()
        
        self.infoLbl.textAlignment = .center
        self.infoLbl.numberOfLines = 0
        
        safeContainer.addSubview(self.infoLbl)
        
        
        
        
        self.submitBtn.addTarget(self, action: #selector(self.submit), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.submitBtn)
        
        safeContainer.addSubview(self.itemResultsTableView)
        
        
        setConstraints()
    }
    
    func setInfoTxt(){
        if self.contractItem == nil{
            self.infoLbl.text = "Hiding qty. presents the item as (1 x Total).  The item total is not including any sales tax."
        }else if self.contractItem.taxCode == "0"{
            self.infoLbl.text = "Hiding qty. presents the item as (1 x Total).  The item total is not including any sales tax. \(String(describing: self.contractItem.name!)) is non taxable."
        }else{
            self.infoLbl.text = "Hiding qty. presents the item as (1 x Total).  The item total is not including any sales tax.  \(String(describing: self.contractItem.name!)) is taxable."
        }
    }
    
    
    func setConstraints(){
        //print("set constraints")
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight + 5, "keyboardHeight":self.keyboardHeight] as [String : Any]
        
        
        
        //auto layout group
        let viewsDictionary = [
            "chargeTypeLbl":self.chargeTypeLbl,"chargeType":self.chargeTypeTxtField,
            "estQtyLbl":self.estQtyLbl, "estQty":self.estQtyTxtField,"priceLbl":self.priceLbl, "price":self.priceTxtField,"totalLbl":self.totalLbl, "total":self.totalTxtField,"hideUnitsLbl":self.hideUnitsLbl,
            "hideUnitsSwitch":self.hideUnitsSwitch,"infoLbl":self.infoLbl,"searchBar":self.itemSearchBar, "searchTable":self.itemResultsTableView, "submitBtn":self.submitBtn
            ] as [String:Any]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeLbl(175)]-[chargeType]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[estQtyLbl(175)]-[estQty]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[hideUnitsLbl(175)]-[hideUnitsSwitch]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[priceLbl(175)]-[price]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[totalLbl(175)]-[total]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[infoLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(40)]-10-[chargeTypeLbl(40)]-10-[estQtyLbl(40)]-10-[priceLbl(40)]-10-[totalLbl(40)]-10-[hideUnitsLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(40)]-10-[chargeType(40)]-10-[estQty(40)]-10-[price(40)]-10-[total(40)]-10-[hideUnitsSwitch(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(40)]-[searchTable]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submitBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[infoLbl(90)]-[submitBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    
    @objc func handleEstQty()
    {
        if self.contractItem == nil{
            self.estQtyTxtField.resignFirstResponder()
            self.itemSearchBar.becomeFirstResponder()
            
            layoutVars.simpleAlert(_vc: self, _title: "Select an Item", _message: "Select an item before adding an estimated quantity.")
            self.estQtyTxtField.text = ""
            
            return
        }
        //print("handle qty")
        if(Double(estQtyTxtField.text!) == nil){
            self.estQtyTxtField.resignFirstResponder()
        }else{
            //let qty = Double(estQtyTxtField.text!)
            //print("call delegate \(self.row)  \(qty)")
            self.estQtyTxtField.resignFirstResponder()
        }
        
        if estQtyTxtField.text == ""{
            estQtyTxtField.text = "0.00"
        }
        self.contractItem.qty = estQtyTxtField.text!
        
        if self.contractItem.chargeType == "1"{
            self.contractItem.total = "0.00"
            self.totalTxtField.text = self.contractItem.total
        }else{
            self.contractItem.total = String(format: "%.2f", Double(self.contractItem.qty)! * Double(self.contractItem.price)!)
            self.totalTxtField.text = self.contractItem.total
        }
            
        
        
        editsMade = true
    }
    
    @objc func handlePrice()
    {
        
        if self.contractItem == nil{
            self.priceTxtField.resignFirstResponder()
            self.itemSearchBar.becomeFirstResponder()
            
            layoutVars.simpleAlert(_vc: self, _title: "Select an Item", _message: "Select an item before adding a price.")
            self.priceTxtField.text = ""
            
            return
        }
        
        //print("handle qty")
        if(Double(priceTxtField.text!) == nil){
            self.priceTxtField.resignFirstResponder()
        }else{
            // let price = Double(priceTxtField.text!)
            //print("call delegate \(self.row)  \(qty)")
            // self.delegate.editQty(row: self.row, qty: qty!)
            self.priceTxtField.resignFirstResponder()
        }
        
        
        if priceTxtField.text == "" || self.contractItem.chargeType == "1"{
            priceTxtField.text = "0.00"
        }
        self.contractItem.price = priceTxtField.text!
        if self.contractItem.chargeType == "1"{
            self.contractItem.total = "0.00"
            self.totalTxtField.text = self.contractItem.total
            
        }else{
            self.contractItem.total = String(format: "%.2f", Double(self.contractItem.qty)! * Double(self.contractItem.price)!)
            self.totalTxtField.text = self.contractItem.total
            
        }
        
        editsMade = true
        
    }
    
    
    @objc func hideUnitsSwitchValueDidChange(sender:UISwitch!)
    {
        //print("switchValueDidChange groupImages = \(groupImages)")
        
        if self.contractItem == nil{
            
            sender.isOn = false
            self.itemSearchBar.becomeFirstResponder()
            
            layoutVars.simpleAlert(_vc: self, _title: "Select an Item First", _message: "")
            //self.priceTxtField.text = ""
            //self.priceTxtField.resignFirstResponder()
            
            return
        }
        
        if (sender.isOn == true){
            //print("on")
            self.contractItem.hideUnits = "1"
        }
        else{
            //print("off")
            self.contractItem.hideUnits = "0"
        }
        
        editsMade = true
    }
    
    //picker methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return pickerData.count
        //print("picker count = \(self.weekArray.count)")
        
        return self.chargeTypeArray.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return pickerData[row]
        // print("picker title = \(self.weekArray[row])")
        return self.chargeTypeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.contractItem == nil{
            self.chargeTypeTxtField.resignFirstResponder()
            self.itemSearchBar.becomeFirstResponder()
            
            
            self.chargeTypeTxtField.resignFirstResponder()
            
            layoutVars.simpleAlert(_vc: self, _title: "Select an Item First", _message: "")
            //self.priceTxtField.text = ""
            //self.priceTxtField.resignFirstResponder()
            
            return
        }
        
        self.contractItem.chargeType = "\(row + 1)"
        
       // self.employeeValue = appDelegate.employeeArray[row].name
       
    }
    
    
    @objc func cancelChargeTypeInput(){
        //self.statusValueToUpdate = self.statusValue
        self.chargeTypeTxtField.resignFirstResponder()
    }
    
   
    
    @objc func handleChargeTypeChange(){
        //print("handle chargeType change")
        if self.contractItem == nil{
            self.chargeTypeTxtField.resignFirstResponder()
            self.itemSearchBar.becomeFirstResponder()
            
            self.priceTxtField.resignFirstResponder()
            
            layoutVars.simpleAlert(_vc: self, _title: "Select an Item First", _message: "")
            //self.priceTxtField.text = ""
            //self.priceTxtField.resignFirstResponder()
            
            return
        }
        
        self.contractItem.chargeType = "\(self.chargeTypePicker.selectedRow(inComponent: 0) + 1)"
        //self.scheduleTypeValue = "\(self.scheduleTypePicker.selectedRow(inComponent: 0))"
        self.chargeTypeTxtField.text = self.chargeTypeArray[self.chargeTypePicker.selectedRow(inComponent: 0)]
        
        
        
        
        //warn users about items being set to $0 on change to NC
        if self.chargeTypePicker.selectedRow(inComponent: 0) + 1 == 1 {
            self.contractItem.price = "0.00"
            self.priceTxtField.text = self.contractItem.price
            
            self.contractItem.total = "0.00"
            self.totalTxtField.text = self.contractItem.total
        }
        
        self.chargeTypeTxtField.resignFirstResponder()
        
        
        
        
        self.editsMade = true
        
        
        
    }
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection")
        return self.itemSearchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("cellForRowAt")
        let cell = itemResultsTableView.dequeueReusableCell(withIdentifier: "linkCell") as! NewWoItemTableViewCell
        itemResultsTableView.rowHeight = 50.0
        cell.nameLbl.text = self.itemSearchResults[indexPath.row]
        cell.name = self.itemSearchResults[indexPath.row]
        if let i = self.names.index(of: cell.nameLbl.text!) {
            cell.id = self.ids[i]
            cell.type = self.types[i]
            cell.price = self.prices[i]
            cell.unit = self.units[i]
            cell.tax = self.taxes[i]
            cell.subcontractor = self.subcontractors[i]
        } else {
            cell.id = ""
            cell.type = ""
            cell.price = ""
            cell.unit = ""
            cell.tax = ""
            cell.subcontractor = ""
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! NewWoItemTableViewCell
        
        
        
        
        if self.contractItem == nil{
            self.contractItem = ContractItem(_ID: "0", _chargeType: self.contract.chargeType, _contractID: self.contract.ID, _itemID: currentCell.id, _name: currentCell.name, _price: currentCell.price, _qty: "0.00", _total: "0.00", _type: currentCell.type, _taxCode: currentCell.tax, _subcontractor: currentCell.subcontractor, _hideUnits: "0")
        }else{
            
            self.contractItem.itemID = currentCell.id
            self.contractItem.name = currentCell.name
            self.contractItem.type = currentCell.type
            self.contractItem.price = currentCell.price
            self.contractItem.taxCode = currentCell.tax
            self.contractItem.subcontractor = currentCell.subcontractor
            
            if(self.contractItem.qty == "0" || self.contractItem.qty == "0.00" || self.contractItem.qty == "" || self.contractItem.price == "0" || self.contractItem.price == "0.00" || self.contractItem.price == ""){
                self.contractItem.total = "0.00"
            }else{
                self.contractItem.total = String(format: "%.2f", Double(self.contractItem.qty)! * Double(self.contractItem.price)!)
            }
            self.totalTxtField.text = self.contractItem.total
            
        }
       
        setInfoTxt()
       
        if self.contractItem.chargeType == "1"{
            self.contractItem.price = "0.00"
            self.priceTxtField.text = self.contractItem.price
            self.contractItem.total = "0.00"
            self.totalTxtField.text = self.contractItem.total
            
        }else{
            self.priceTxtField.text = currentCell.price
        }
        //print("select item")
        
        //print("select type = \(self.contractItem.type)")
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        itemSearchBar.text = currentCell.name
        itemSearchBar.resignFirstResponder()
        self.itemResultsTableView.alpha = 0.0
        
        editsMade = true
    }
    
    
    
    /////////////// Search Delegate Methods   ///////////////////////
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        //print("search edit")
        ////print("searchText.characters.count = \(searchText.characters.count)")
        //print("searchText.characters.count = \(searchText.count)")
        
        
        if (searchText.count == 0) {
            self.itemResultsTableView.alpha = 0.0
            if contractItem != nil{
                self.contractItem.ID = ""
            }
        }else{
            self.itemResultsTableView.alpha = 1.0
        }
        
        filterSearchResults()
    }
    
    
    
    func filterSearchResults(){
        itemSearchResults = []
        
        self.itemSearchResults = self.names.filter({( aCustomer: String ) -> Bool in
            return (aCustomer.lowercased().range(of: itemSearchBar.text!.lowercased()) != nil)            })
        self.itemResultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.itemResultsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.itemResultsTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        //print("search cancel")
        searchBar.text = ""
        self.contractItem.ID = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        self.itemResultsTableView.alpha = 0.0
    }
    
    
    
    @objc func submit(){
        //print("Submit")
        
       // print("self.estQtyLbl.text = \(self.estQtyLbl.text)")
        if(self.contractItem.name == ""){
            let alertController = UIAlertController(title: "Select an Item", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                //self.popView()
            }
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            return
        }
        
        if(self.estQtyTxtField.text == ""){
            let alertController = UIAlertController(title: "Estimate a Quantity", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                //self.popView()
            }
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            return
        }
        
        
        
        
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        var estQtyString:String
        
        if(self.estQtyTxtField.text == self.estQtyTxtField.placeHolder){
            estQtyString = "0"
        }else{
            estQtyString = self.estQtyTxtField.text!
            
        }
        
        var priceString:String
        
        if(self.priceTxtField.text == self.priceTxtField.placeHolder || self.priceTxtField.text == ""){
            priceString = "0.00"
        }else{
            priceString = self.priceTxtField.text!
            
        }
        
        //var totalString:String
        
        if(estQtyString == "0" || priceString == "0.00"){
            self.contractItem.total = "0.00"
        }else{
            self.contractItem.total = String(format: "%.2f", Double(self.contractItem.qty)! * Double(self.contractItem.price)!)
        }
        
       
        
        
        
        let parameters:[String:String]
        
        if editMode == false{
            
            //print("contractItemID = \(self.contractItem.ID)")
            //print("contractID = \(contract.ID!)")
            ////print("ID = \(selectedID)")
           // //print("sort = \(itemCount)")
            //print("type = \(self.contractItem.type)")
            //print("chargeType = \(self.contractItem.chargeType!)")
            //print("qty = \(self.contractItem.qty)")
            //print("price = \(self.contractItem.price)")
            //print("total = \(self.contractItem.total)")
            //print("name = \(self.contractItem.name)")
            //print("tax = \(self.contractItem.taxCode)")
            //print("subcontractor = \(self.contractItem.subcontractor)")
            //print("hideUnits = \(self.contractItem.hideUnits)")
            
            parameters = ["contractItemID": "0","contractID":self.contract.ID!,"itemID": self.contractItem.ID, "type":self.contractItem.type, "chargeType": self.contractItem.chargeType!, "qty": self.contractItem.qty, "price": self.contractItem.price, "total":self.contractItem.total, "name":self.contractItem.name,"taxCode":self.contractItem.taxCode,"subcontractor":self.contractItem.subcontractor,"hideUnits":self.contractItem.hideUnits]
        }else{
            
            //print("contractItemID = \(self.contractItem.ID)")
            //print("contractID = \(contract.ID!)")
            //print("itemID = \(self.contractItem.itemID)")
            ////print("sort = \(self.sort)")
            //print("type = \(self.contractItem.type)")
            //print("chargeType = \(self.contractItem.chargeType!)")
            //print("qty = \(self.contractItem.qty)")
            //print("price = \(self.contractItem.price)")
            //print("total = \(self.contractItem.total)")
            //print("name = \(self.contractItem.name)")
            //print("tax = \(self.contractItem.taxCode)")
            //print("subcontractor = \(self.contractItem.subcontractor)")
            //print("hideUnits = \(self.contractItem.hideUnits)")
            
            parameters = ["contractItemID": self.contractItem.ID,"contractID":self.contract.ID!,"itemID": self.contractItem.itemID, "type":self.contractItem.type, "chargeType": self.contractItem.chargeType!, "qty": self.contractItem.qty, "price": self.contractItem.price, "total":self.contractItem.total, "name":self.contractItem.name,"taxCode":self.contractItem.taxCode,"subcontractor":self.contractItem.subcontractor,"hideUnits":self.contractItem.hideUnits]
        }
        
        
        //print("parameters : \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/contractItem.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("new item response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                //print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                //print(response.result)   // result of response serialization
                
                
                
                
                if let json = response.result.value {
                    var addReturn:JSON!
                    addReturn = JSON(json)
                    
                    
                    
                    
                    
                    let subTotal = addReturn["subTotal"]
                    //print("subTotal: \(subTotal)")
                    
                    let taxTotal = addReturn["taxTotal"]
                    //print("taxTotal: \(taxTotal)")
                    
                    let total = addReturn["total"]
                    //print("total: \(total)")
                    
                    let terms = addReturn["newTerms"]
                    //print("terms: \(terms)")
                    
                    
                    self.contract.subTotal = subTotal.stringValue
                    self.contract.taxTotal = taxTotal.stringValue
                    self.contract.total = total.stringValue
                    self.contract.terms = terms.stringValue
                }
                
                
                
                
                
                self.indicator.dismissIndicator()
                
                self.editsMade = false
                
                self.goBack()
                
                if self.delegate != nil{
                    self.delegate.updateContract(_contract: self.contract)

                }
                
                
                
                
                
                if self.editDelegate != nil{
                    
                    self.editDelegate.updateContractItem(_contractItem: self.contractItem)
                    
                }
                
        }
        
        
        
    }
    
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("textFieldShouldReturn")
        self.view.endEditing(true)
        return false
        
    }
    
    
    
    
    
    
    
    @objc func goBack(){
        //print("go back")
        
        if(self.editsMade == true){
            //print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                //print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                _ = self.navigationController?.popViewController(animated: false)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

