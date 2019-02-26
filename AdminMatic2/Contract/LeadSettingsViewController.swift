//
//  LeadSettingsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/21/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit



 
class LeadSettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    var status:String!
    var salesRep:String!
    var salesRepName:String!
    var zoneID:String!
    var zoneName:String!
    
    
    
    var statusArray:[String] = ["Not Started","In Progress","Finished","Cancelled","Waiting"]
    
    var statusLbl:Label = Label()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    
    
    //rep search
    var repLbl:GreyLabel!
    var repSearchBar:UISearchBar = UISearchBar()
    var repResultsTableView:TableView = TableView()
    var repSearchResults:[String] = []
    
    
    //zone
    var zoneLbl:Label = Label()
    var zoneTxtField:PaddedTextField!
    var zonePicker: Picker!
    
    
    
    var clearFiltersBtn:Button = Button(titleText: "Clear All Filters")
    
    // var imageDelegate:ImageViewDelegate!
    var leadSettingsDelegate:LeadSettingsDelegate!
    
    var editsMade:Bool = false
    
    
    
    
    init(_status:String, _salesRep:String, _salesRepName:String, _zoneID:String, _zoneName:String){
        super.init(nibName:nil,bundle:nil)
        //print("init _status = \(_status)  _salesRep = \(_salesRep) _zoneID = \(_zoneID) _zoneName = \(_zoneName)")
        
        self.status = _status
        self.salesRep = _salesRep
        self.salesRepName = _salesRepName
        self.zoneID = _zoneID
        self.zoneName = _zoneName
        
        
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
        title = "Lead Settings"
        
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageSettingsViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        self.layoutViews()
        
    }
    
    
    func layoutViews(){
        
        //print("layoutViews")
        // indicator.dismissIndicator()
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.statusPicker = Picker()
        self.statusPicker.tag = 1
        self.statusPicker.delegate = self
        
        self.statusLbl.translatesAutoresizingMaskIntoConstraints = false
        self.statusLbl.text = "Status:"
        safeContainer.addSubview(self.statusLbl)
        
        self.statusTxtField = PaddedTextField()
        if status != ""{
            self.statusTxtField.text = self.statusArray[Int(status)! - 1]
            
            self.statusPicker.selectRow(Int(status)! - 1, inComponent: 0, animated: false)
                
                
            
        }
        //setFilterText()
        
        self.statusTxtField.textAlignment = NSTextAlignment.center
        self.statusTxtField.tag = 1
        self.statusTxtField.delegate = self
        self.statusTxtField.tintColor = UIColor.clear
        self.statusTxtField.inputView = statusPicker
        safeContainer.addSubview(self.statusTxtField)
        
        
        //print("layoutViews 1")
        let statusToolBar = UIToolbar()
        statusToolBar.barStyle = UIBarStyle.default
        statusToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        statusToolBar.sizeToFit()
        
        let statusCloseButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadSettingsViewController.cancelStatus))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let statusSelectButton = BarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadSettingsViewController.setStatus))
        
        statusToolBar.setItems([statusCloseButton, spaceButton, statusSelectButton], animated: false)
        statusToolBar.isUserInteractionEnabled = true
        
        statusTxtField.inputAccessoryView = statusToolBar
        
        
        
        
        //sales rep
        self.repLbl = GreyLabel()
        self.repLbl.text = "Sales Rep:"
        
        safeContainer.addSubview(repLbl)
        
        
        
        repSearchBar.placeholder = "Sales Rep..."
        repSearchBar.translatesAutoresizingMaskIntoConstraints = false
        //customerSearchBar.layer.cornerRadius = 4
        
        repSearchBar.layer.borderWidth = 1
        repSearchBar.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        repSearchBar.layer.cornerRadius = 4.0
        repSearchBar.inputView?.layer.borderWidth = 0
        
        repSearchBar.clipsToBounds = true
        
        repSearchBar.backgroundColor = UIColor.white
        repSearchBar.barTintColor = UIColor.white
        repSearchBar.searchBarStyle = UISearchBar.Style.default
        repSearchBar.delegate = self
        //repSearchBar.tag = 2
        safeContainer.addSubview(repSearchBar)
        
        
        let repToolBar = UIToolbar()
        repToolBar.barStyle = UIBarStyle.default
        repToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        repToolBar.sizeToFit()
        let closeRepButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadSettingsViewController.cancelRepInput))
        
        repToolBar.setItems([closeRepButton], animated: false)
        repToolBar.isUserInteractionEnabled = true
        repSearchBar.inputAccessoryView = repToolBar
        
        
        //zone
        self.zonePicker = Picker()
        self.zonePicker.tag = 2
        self.zonePicker.delegate = self
        
        self.zoneLbl.translatesAutoresizingMaskIntoConstraints = false
        self.zoneLbl.text = "Zone:"
        safeContainer.addSubview(self.zoneLbl)
        
        self.zoneTxtField = PaddedTextField()
        if zoneID != ""{
            self.zoneTxtField.text = self.zoneName
            //self.zonePicker.selectRow(Int(status)! - 1, inComponent: 0, animated: false)

        }
        
        
        
        self.zoneTxtField.textAlignment = NSTextAlignment.center
        self.zoneTxtField.tag = 2
        self.zoneTxtField.delegate = self
        self.zoneTxtField.tintColor = UIColor.clear
        self.zoneTxtField.inputView = zonePicker
        safeContainer.addSubview(self.zoneTxtField)
        
        
        //print("layoutViews 1")
        let zoneToolBar = UIToolbar()
        zoneToolBar.barStyle = UIBarStyle.default
        zoneToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        zoneToolBar.sizeToFit()
        
        let zoneCloseButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadSettingsViewController.cancelZone))
        let zoneSelectButton = BarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeadSettingsViewController.setZone))
        
        zoneToolBar.setItems([zoneCloseButton, spaceButton, zoneSelectButton], animated: false)
        zoneToolBar.isUserInteractionEnabled = true
        
        zoneTxtField.inputAccessoryView = zoneToolBar
        
        
        
        
        if(self.appDelegate.salesRepIDArray.count == 0){
            repSearchBar.isUserInteractionEnabled = false
        }
        
        
        if(salesRepName != ""){
            repSearchBar.text = salesRepName
        }
        
        
        
        self.repResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.repResultsTableView.delegate  =  self
        self.repResultsTableView.dataSource = self
        self.repResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "repCell")
        self.repResultsTableView.alpha = 0.0
        
        
        
        
        
        
        
        
        self.clearFiltersBtn.addTarget(self, action: #selector(ImageSettingsViewController.clearFilters), for: UIControl.Event.touchUpInside)
        
        // self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width - 100, height: 50)
        self.clearFiltersBtn.translatesAutoresizingMaskIntoConstraints = false
        //self.clearFiltersBtn.layer.borderColor = UIColor.white.cgColor
        //self.clearFiltersBtn.layer.borderWidth = 1.0
        safeContainer.addSubview(self.clearFiltersBtn)
        
        
        
        safeContainer.addSubview(self.repResultsTableView)
        
        
        let viewsDictionary = [
            "statusLbl":self.statusLbl,"statusTxt":self.statusTxtField,"repLbl":self.repLbl,
            "repSearchBar":self.repSearchBar,"repTable":self.repResultsTableView,"zoneLbl":self.zoneLbl,"zoneTxt":self.zoneTxtField,"clearFiltersBtn":self.clearFiltersBtn
            ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navHeight":layoutVars.navAndStatusBarHeight + 20] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[statusLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[statusTxt]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[repLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[repSearchBar]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[repTable]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[zoneLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[zoneTxt]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[clearFiltersBtn]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[statusLbl(40)][statusTxt(40)]-20-[repLbl(40)][repSearchBar(40)][repTable]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[statusLbl(40)][statusTxt(40)]-20-[repLbl(40)][repSearchBar(40)]-20-[zoneLbl(40)][zoneTxt(40)]-20-[clearFiltersBtn(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    
    //picker view methods
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count:Int = 1
        if pickerView.tag == 1{
            
            
            //if pickerView == filterPicker {
            //print("numberOfComponents = \(statusArray.count )")
            count = statusArray.count
            //}
        }else{
            //var count:Int = 1
            
            //if pickerView == filterPicker {
            //print("numberOfComponents = \(statusArray.count )")
            count = self.appDelegate.zones.count
        }
        
        return count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var title = ""
        if pickerView.tag == 1{
            // if pickerView == filterPicker {
            //print("titleForRow = \(statusArray[row])")
            title = statusArray[row]
            //}
        }else{
            //print("titleForRow = \(self.appDelegate.zones[row].name)")
            title = self.appDelegate.zones[row].name
        }
        
        
        return title
        
        
    }
    
    
    /*
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     if pickerView == filterPicker {
     filter()
     } else if pickerView == orderPicker{
     setOrder()
     }
     }
     */
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    /////////////// Search Delegate Methods   ///////////////////////
    
    /*
     func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
     <#code#>
     }
     */
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        //print("search edit")
        //print("searchText.count = \(searchText.count)")
        
        
        if (searchText.count == 0) {
            self.repResultsTableView.alpha = 0.0
            self.salesRep = ""
            self.salesRepName = ""
        }else{
            self.repResultsTableView.alpha = 1.0
        }
        
        
        
        
        filterSearchResults()
    }
    
    
    
    func filterSearchResults(){
        
        
        //print("Rep filter")
        repSearchResults = []
        self.repSearchResults = self.appDelegate.salesRepNameArray.filter({( aRep: String ) -> Bool in
            return (aRep.lowercased().range(of: repSearchBar.text!.lowercased(), options:.regularExpression) != nil)})
        self.repResultsTableView.reloadData()
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.repResultsTableView.reloadData()
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y -= 160
            
            
        }, completion: { finished in
            //print("Napkins opened!")
        })
        
        
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
        // self.tableViewMode = "TASK"
        
        
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y += 160
                
                
            }, completion: { finished in
            })
        }
        
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.repResultsTableView.reloadData()
        
        
        searchBar.resignFirstResponder()
        
        // self.tableViewMode = "TASK"
        
    }
    
    
    
    
    /////////////// Table Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        
        count = self.repSearchResults.count
        
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let searchString = self.repSearchBar.text!.lowercased()
        let cell:CustomerTableViewCell = repResultsTableView.dequeueReusableCell(withIdentifier: "repCell") as! CustomerTableViewCell
        
        cell.nameLbl.text = self.repSearchResults[indexPath.row]
        cell.name = self.repSearchResults[indexPath.row]
        if let i = self.appDelegate.salesRepNameArray.index(of: cell.nameLbl.text!) {
            cell.id = self.self.appDelegate.salesRepIDArray[i]
        } else {
            cell.id = ""
        }
        
        //text highlighting
        let baseString:NSString = cell.name as NSString
        let highlightedText = NSMutableAttributedString(string: cell.name)
        var error: NSError?
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        if let regexError = error {
            //print("Oh no! \(regexError)")
        } else {
            for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
            }
        }
        cell.nameLbl.attributedText = highlightedText
        
        
        return cell
        // break
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
        self.salesRep = currentCell.id
        self.salesRepName = currentCell.name
        
        repSearchBar.text = currentCell.name
        repResultsTableView.alpha = 0.0
        repSearchBar.resignFirstResponder()
        
        editsMade = true
    }
    
    
    
    
    
    
    @objc func cancelRepInput(){
        //print("Cancel Rep Input")
        self.repSearchBar.resignFirstResponder()
        self.repResultsTableView.alpha = 0.0
    }
    
    
    
    
    
    
    @objc func cancelStatus() {
        statusTxtField.resignFirstResponder()
    }
    
    
    
    @objc func setStatus() {
        statusTxtField.resignFirstResponder()
        
        //print("set Status")
        
        let row = self.statusPicker.selectedRow(inComponent: 0)
        
        
        editsMade = true
        
        //resetVals()
        status = "\(row + 1)"
        
        
        self.statusTxtField.text = self.statusArray[row]
        
       
        //setFilterText()
        
        
    }
    
    
    @objc func cancelZone() {
        zoneTxtField.resignFirstResponder()
    }
    
    
    
    @objc func setZone() {
        zoneTxtField.resignFirstResponder()
        
        //print("set Zone")
        
        let row = self.zonePicker.selectedRow(inComponent: 0)
        
        
        editsMade = true
        
        //resetVals()
        zoneID = self.appDelegate.zones[row].ID!
        zoneName = self.appDelegate.zones[row].name!
        
        
        self.zoneTxtField.text = self.appDelegate.zones[row].name
        
        //setFilterText()
        
        
    }
    
    
    
    
    
    
    @objc func clearFilters() {
        
        //self.status = ""
        resetVals()
        
        leadSettingsDelegate.updateSettings(_status: self.status, _salesRep: self.salesRep, _salesRepName: self.salesRepName, _zoneID: self.zoneID, _zoneName: self.zoneName)
        
        goBack()
    }
    
    func resetVals(){
        //print("resetVals")
        self.status = ""
        self.salesRep = ""
        self.salesRepName = ""
        self.zoneID = ""
        self.zoneName = ""
    }
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        if(editsMade == true){
            leadSettingsDelegate.updateSettings(_status: self.status, _salesRep: self.salesRep, _salesRepName: self.salesRepName, _zoneID: self.zoneID, _zoneName: self.zoneName)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}

