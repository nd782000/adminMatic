//
//  NewWoItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/30/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import DKImagePickerController






class NewWoItemViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
   var delegate:WoDelegate!  // refreshing the list
   // var fieldNoteDelegate:FieldNoteDelegate!  // refreshing the list
    var indicator: SDevIndicator!
    var backButton:UIButton!
    
    
  
    
    
    var woID:String!
    var charge:String!
    
    var itemSearchBar:UISearchBar = UISearchBar()
    var itemResultsTableView:TableView = TableView()
    var itemSearchResults:[String] = []
    
    
    var estQtyLbl:Label!
    var estQtyTxtField: PaddedTextField!
    
    var priceLbl:Label!
    var priceTxtField: PaddedTextField!

    
    
    var submitBtn:Button = Button(titleText: "Submit")
    
   
    
    var keyBoardShown:Bool = false
    
    
    
    //linking result arrays
    var ids = [String]()
    var names = [String]()
    var types = [String]()
    var prices = [String]()
    var units = [String]()
    
    var selectedID:String = ""
    var selectedName:String = ""
    var selectedType:String = ""
    var selectedPrice:String = ""
    var selectedUnit:String = ""
    
    var keyboardHeight:CGFloat = 216
    
    
    
    init(_woID:String, _charge:String){
        super.init(nibName:nil,bundle:nil)
        
        print("new Item init")
       
        self.woID = _woID
        self.charge = _charge
        
    }
    
  
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print("ImmageUploadPrep viewDidLoad")
        
        title = "Add Item"
        
        
        view.backgroundColor = layoutVars.backgroundColor
        
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
    }
    
    
    
    
    func loadLinkList(_linkType:String, _loadScript:API.Router){
        print("load link list")
        
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
                        if let type = result["type"] as? String {
                            self.types.append(type)
                        }
                        if let price = result["price"] as? String {
                            self.prices.append(price)
                        }
                        if let unit = result["unit"] as? String {
                            self.units.append(unit)
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            self.layoutViews()
        }
    }
    
    
    
    func layoutViews(){
        
        print("layoutViews")
        if(indicator != nil){
            indicator.dismissIndicator()
        }
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
    
        itemSearchBar.placeholder = "Item..."
        itemSearchBar.translatesAutoresizingMaskIntoConstraints = false
        itemSearchBar.layer.cornerRadius = 4
        itemSearchBar.clipsToBounds = true
        itemSearchBar.backgroundColor = UIColor.white
        itemSearchBar.barTintColor = UIColor.clear
        itemSearchBar.searchBarStyle = UISearchBarStyle.minimal
        itemSearchBar.delegate = self
        self.view.addSubview(itemSearchBar)
        
        
        self.itemResultsTableView.delegate  =  self
        self.itemResultsTableView.dataSource = self
        //might want to change to custom linkCell class
        self.itemResultsTableView.register(NewWoItemTableViewCell.self, forCellReuseIdentifier: "linkCell")
        self.itemResultsTableView.alpha = 0.0
        self.view.addSubview(self.itemResultsTableView)
        
        self.estQtyLbl = Label(text: "Estimated Qty")
        self.estQtyLbl.textAlignment = .right
        self.view.addSubview(self.estQtyLbl)
        
        
        self.estQtyTxtField = PaddedTextField()
        self.estQtyTxtField.delegate = self
        
        self.estQtyTxtField.keyboardType = UIKeyboardType.decimalPad
        self.estQtyTxtField.tag = 10
        
        self.view.addSubview(self.estQtyTxtField)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let estQtyToolBar = UIToolbar()
        estQtyToolBar.barStyle = UIBarStyle.default
        estQtyToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        estQtyToolBar.sizeToFit()
        let setEstQtyButton = UIBarButtonItem(title: "Set Qty", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewWoItemViewController.handleEstQty))
        estQtyToolBar.setItems([spaceButton, setEstQtyButton], animated: false)
        estQtyToolBar.isUserInteractionEnabled = true
        estQtyTxtField.inputAccessoryView = estQtyToolBar
        
        
        
        
        
        self.priceLbl = Label(text: "Unit Price")
        self.priceLbl.textAlignment = .right
        self.view.addSubview(self.priceLbl)
        
        
        self.priceTxtField = PaddedTextField()
        self.priceTxtField.delegate = self
        
        self.priceTxtField.keyboardType = UIKeyboardType.decimalPad
        self.priceTxtField.tag = 11
        
        self.view.addSubview(self.priceTxtField)
        
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let priceToolBar = UIToolbar()
        priceToolBar.barStyle = UIBarStyle.default
        priceToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        priceToolBar.sizeToFit()
        let setPriceButton = UIBarButtonItem(title: "Set Price", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewWoItemViewController.handlePrice))
        priceToolBar.setItems([spaceButton2, setPriceButton], animated: false)
        priceToolBar.isUserInteractionEnabled = true
        priceTxtField.inputAccessoryView = priceToolBar
        
        
        
        
        
        
        
        self.submitBtn.addTarget(self, action: #selector(NewWoItemViewController.submit), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.submitBtn)
        
        
        setConstraints()
    }
    
    
    func setConstraints(){
        print("set constraints")
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight + 5, "keyboardHeight":self.keyboardHeight] as [String : Any]
        
        
        
            //auto layout group
            let viewsDictionary = [
                "estQtyLbl":self.estQtyLbl, "estQty":self.estQtyTxtField,"priceLbl":self.priceLbl, "price":self.priceTxtField,"searchBar":self.itemSearchBar, "searchTable":self.itemResultsTableView, "submitBtn":self.submitBtn
                ] as [String:Any]
            
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[estQtyLbl(150)]-[estQty]-|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[priceLbl(150)]-[price]-|", options: [], metrics: nil, views: viewsDictionary))

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[searchBar(40)]-10-[estQtyLbl(40)]-10-[priceLbl(40)]-[searchTable]-[submitBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
             self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[searchBar(40)]-10-[estQty(40)]-10-[price(40)]-[searchTable]-[submitBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
     
    
    
    func handleEstQty()
    {
        //print("handle qty")
        if(Double(estQtyTxtField.text!) == nil){
            self.estQtyTxtField.resignFirstResponder()
        }else{
            let qty = Double(estQtyTxtField.text!)
            //print("call delegate \(self.row)  \(qty)")
            self.estQtyTxtField.resignFirstResponder()
        }
        
        
    }
    
    func handlePrice()
    {
        //print("handle qty")
        if(Double(priceTxtField.text!) == nil){
            self.priceTxtField.resignFirstResponder()
        }else{
            let price = Double(priceTxtField.text!)
            //print("call delegate \(self.row)  \(qty)")
            // self.delegate.editQty(row: self.row, qty: qty!)
            self.priceTxtField.resignFirstResponder()
        }
        
        
    }
    
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        return self.itemSearchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = itemResultsTableView.dequeueReusableCell(withIdentifier: "linkCell") as! NewWoItemTableViewCell
       itemResultsTableView.rowHeight = 50.0
        cell.nameLbl.text = self.itemSearchResults[indexPath.row]
        cell.name = self.itemSearchResults[indexPath.row]
        if let i = self.names.index(of: cell.nameLbl.text!) {
            cell.id = self.ids[i]
            cell.type = self.types[i]
            cell.price = self.prices[i]
            cell.unit = self.units[i]
        } else {
            cell.id = ""
            cell.type = ""
            cell.price = ""
            cell.unit = ""
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! NewWoItemTableViewCell
        selectedID = currentCell.id
        
        selectedName = currentCell.name
        selectedType = currentCell.type
        selectedPrice = currentCell.price
        selectedUnit = currentCell.unit
        
        self.priceTxtField.text = currentCell.price
        print("select item")
       
        tableView.deselectRow(at: indexPath, animated: true)
        itemSearchBar.text = currentCell.name
        itemSearchBar.resignFirstResponder()
        self.itemResultsTableView.alpha = 0.0
    }
    
    
    
    /////////////// Search Delegate Methods   ///////////////////////
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        print("search edit")
        print("searchText.characters.count = \(searchText.characters.count)")
        
        
        if (searchText.characters.count == 0) {
            self.itemResultsTableView.alpha = 0.0
            self.selectedID = ""
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
        print("search cancel")
        searchBar.text = ""
        selectedID = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        self.itemResultsTableView.alpha = 0.0
    }
    
    
    
    func submit(){
        print("Submit")
        
        
        if(self.selectedID == ""){
           
            
            let alertController = UIAlertController(title: "Select an Item", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //self.popView()
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
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
        
                if(self.priceTxtField.text == self.priceTxtField.placeHolder){
                    priceString = "0.00"
                }else{
                    priceString = self.priceTxtField.text!
            
                }
        
        
                //cache buster
                let now = Date()
                let timeInterval = now.timeIntervalSince1970
                let timeStamp = Int(timeInterval)
                //, "cb":timeStamp as AnyObject
        
        
        
        
                let parameters = ["woID": self.woID!,"itemID": selectedID as AnyObject,"estQty": estQtyString as AnyObject,"price": priceString as AnyObject,"chargeID": self.charge as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "cb":timeStamp as AnyObject] as [String : Any]
        
        print("parameters : \(parameters)")
                
                layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/new/workOrderItem.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new item response = \(response)")
                    }
                    
                    .responseJSON(){
                        response in
                        
                        print(response.request ?? "")  // original URL request
                        print(response.response ?? "") // URL response
                        print(response.data ?? "")     // server data
                        print(response.result)   // result of response serialization
                        
                        
                        self.indicator.dismissIndicator()
                        
                        self.goBack()
                        self.delegate.refreshWo()
                        
                }
                
        
        
    }
    
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    
    
    
    func goBack(){
        print("go back")
        
       
            _ = navigationController?.popViewController(animated: false)
               
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
