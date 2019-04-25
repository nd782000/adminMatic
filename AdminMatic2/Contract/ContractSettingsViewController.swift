//
//  ContractSettingsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit

 


class ContractSettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    var status:String!
    var salesRep:String!
    var salesRepName:String!
    
    
    
    var filterArray:[String] = ["New","Sent","Awarded","Scheduled","Declined","Waiting","Cancelled"]
    
    var filterLbl:GreyLabel!
    var filterTxtField:PaddedTextField!
    var filterPicker: Picker!
    
    
    //rep search
    var repLbl:GreyLabel!
    var repSearchBar:UISearchBar = UISearchBar()
    var repResultsTableView:TableView = TableView()
    var repSearchResults:[String] = []
    
    
    
    
    var clearFiltersBtn:Button = Button(titleText: "Clear All Filters")
    
    var contractSettingsDelegate:ContractSettingsDelegate!
    
    var editsMade:Bool = false
    
    
    
    
    init(_status:String, _salesRep:String, _salesRepName:String){
        super.init(nibName:nil,bundle:nil)
        //print("init _status = \(_status)  _salesRep = \(_salesRep)")
        
        self.status = _status
        self.salesRep = _salesRep
        self.salesRepName = _salesRepName
        
        
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
        title = "Contract Settings"
        
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
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.filterPicker = Picker()
        self.filterPicker.delegate = self
        
        self.filterLbl = GreyLabel()
        self.filterLbl.translatesAutoresizingMaskIntoConstraints = false
        self.filterLbl.text = "Status:"
        safeContainer.addSubview(self.filterLbl)
        
        self.filterTxtField = PaddedTextField()
        if status != ""{
            self.filterTxtField.text = self.filterArray[Int(status)!]
            
            self.filterPicker.selectRow(Int(status)!, inComponent: 0, animated: false)
                
                
           
        }
        //setFilterText()
        
        self.filterTxtField.textAlignment = NSTextAlignment.center
        self.filterTxtField.tag = 1
        self.filterTxtField.delegate = self
        self.filterTxtField.tintColor = UIColor.clear
        self.filterTxtField.inputView = filterPicker
        safeContainer.addSubview(self.filterTxtField)
        
        
        //print("layoutViews 1")
        let filterToolBar = UIToolbar()
        filterToolBar.barStyle = UIBarStyle.default
        filterToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        filterToolBar.sizeToFit()
        
        let filterCloseButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ContractSettingsViewController.cancelFilter))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let filterSelectButton = BarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ContractSettingsViewController.filter))
        
        filterToolBar.setItems([filterCloseButton, spaceButton, filterSelectButton], animated: false)
        filterToolBar.isUserInteractionEnabled = true
        
        filterTxtField.inputAccessoryView = filterToolBar
        
        
        
        
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
        let closeRepButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ContractSettingsViewController.cancelRepInput))
        
        repToolBar.setItems([closeRepButton], animated: false)
        repToolBar.isUserInteractionEnabled = true
        repSearchBar.inputAccessoryView = repToolBar
        
        
        
        
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
            "filterLbl":self.filterLbl,"filterTxt":self.filterTxtField,"repLbl":self.repLbl,
            "repSearchBar":self.repSearchBar,
            "repTable":self.repResultsTableView,"clearFiltersBtn":self.clearFiltersBtn
            ] as [String:Any]
        
        let halfWidth = (layoutVars.fullWidth/2)-15
        let fullHeight = layoutVars.fullHeight - 344
        let navHeight = layoutVars.navAndStatusBarHeight + 20
        
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": halfWidth, "height": 24,"fullHeight":fullHeight, "navHeight":navHeight] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[filterLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[filterTxt]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[repLbl]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[repSearchBar]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[repTable]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[clearFiltersBtn]-40-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[filterLbl(40)][filterTxt(40)]-20-[repLbl(40)][repSearchBar(40)][repTable]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[filterLbl(40)][filterTxt(40)]-20-[repLbl(40)][repSearchBar(40)]-20-[clearFiltersBtn(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    
    //picker view methods
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        var count:Int = 1
        
        //if pickerView == filterPicker {
            //print("numberOfComponents = \(filterArray.count )")
            count = filterArray.count
        //}
        
        return count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var title = ""
        
       // if pickerView == filterPicker {
            //print("titleForRow = \(filterArray[row])")
            title = filterArray[row]
        //}
        
        
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
                print("Oh no! \(regexError)")
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
    
    
    
    
    
    
    
    @objc func cancelFilter() {
        filterTxtField.resignFirstResponder()
    }
    
    
    
    @objc func filter() {
        filterTxtField.resignFirstResponder()
        
        //print("set filter")
        
        let row = self.filterPicker.selectedRow(inComponent: 0)
        
        
        editsMade = true
        
        //resetVals()
        status = "\(row)"
        
        
        self.filterTxtField.text = self.filterArray[Int(status)!]
        
        //setFilterText()
        
        
    }
    
    
    
   
    
    
    @objc func clearFilters() {
        
        //self.status = ""
        resetVals()
        
        contractSettingsDelegate.updateSettings(_status: self.status, _salesRep: self.salesRep, _salesRepName: self.salesRepName)
        
        goBack()
    }
    
    func resetVals(){
        //print("resetVals")
        self.status = ""
        self.salesRep = ""
        self.salesRepName = ""
    }
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        if(editsMade == true){
            contractSettingsDelegate.updateSettings(_status: self.status, _salesRep: self.salesRep, _salesRepName: self.salesRepName)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}

