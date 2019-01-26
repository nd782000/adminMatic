//
//  EquipmentFieldsListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/29/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON




protocol EquipmentFieldListDelegate{
    func reDrawEquipmentFieldList()
}





class EquipmentFieldsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EquipmentFieldListDelegate{
    var indicator: SDevIndicator!
    
    
    
    
    var layoutVars:LayoutVars = LayoutVars()
    var equipmentListDelegate:EquipmentListDelegate!
    var viewMode:String = "TYPE"
    let items = ["Type","Fuel","Engine","Inspection"]
    
    
    var editButton:UIBarButtonItem!
    var equipmentFieldsTableView:TableView!
    
    
    
    var typeNameArray:[String] = []
    var typeIDArray:[String] = []
    //var typeCodeArray:[String] = []
    
    var fuelNameArray:[String] = []
    var fuelIDArray:[String] = []
    
    var engineNameArray:[String] = []
    var engineIDArray:[String] = []
    
    var inspectionNameArray:[String] = []
    var inspectionIDArray:[String] = []
    
    var inspectionIDArrayJSON: [JSON] = []//data array

    
    var addFieldBtn:Button = Button(titleText: "Add New Field")
    
    var editsMade:Bool = false
    
    var sortEditsMade:Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Equipment Fields"
        view.backgroundColor = layoutVars.backgroundColor
        
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(ItemViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        
        
        
        
        getEquipmentFields()
    }
    
    
    func getEquipmentFields(){
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        
         typeNameArray = []
         typeIDArray = []
         //typeCodeArray = []
        
         fuelNameArray = []
         fuelIDArray = []
        
         engineNameArray = []
         engineIDArray = []
        
        inspectionNameArray = []
        inspectionIDArray = []
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        
        var parameters:[String:String]
        parameters = [
            "cb":"\(timeStamp)"
        ]
        
        print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/equipmentFields.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            
            
            
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let types = json["types"] as? [[String: Any]],
                    let fuelTypes = json["fuelTypes"] as? [[String: Any]],
                    let engineTypes = json["engineTypes"] as? [[String: Any]],
                    let questions = json["questions"] as? [[String: Any]]{
                    //let crews = json["crews"] as? [[String: Any]],
                    //let vendors = json["vendors"] as? [[String: Any]]{
                    for type in types {
                        if let typeID = type["ID"] as? String {
                            self.self.typeIDArray.append(typeID)
                        }
                        if let name = type["name"] as? String {
                            self.typeNameArray.append(name)
                        }
                    }
                    
                    for fuelType in fuelTypes {
                        if let typeID = fuelType["ID"] as? String {
                            self.fuelIDArray.append(typeID)
                        }
                        if let name = fuelType["name"] as? String {
                            self.fuelNameArray.append(name)
                        }
                    }
                    
                    for engineType in engineTypes {
                        if let typeID = engineType["ID"] as? String {
                            self.engineIDArray.append(typeID)
                        }
                        if let name = engineType["name"] as? String {
                            self.engineNameArray.append(name)
                        }
                    }
                    for question in questions {
                        if let ID = question["ID"] as? String {
                            self.inspectionIDArray.append(ID)
                        }
                        if let name = question["questionText"] as? String {
                            self.inspectionNameArray.append(name)
                        }
                    }
                    
                    
                    
                    self.layoutViews()
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            
            
            
            
            
        }
    }
    
    
    
    func layoutViews(){
        
        // Close Indicator
        
        
        indicator.dismissIndicator()
        
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.displayEditView))
        
        
        
        
        equipmentFieldsTableView = TableView()
        
        let customSC = SegmentedControl(items: items)
    
        customSC.addTarget(self, action: #selector(self.changeView(sender:)), for: .valueChanged)
        
        switch viewMode {
        case "TYPE":
            //equipmentArray.sorted(by: { $0.crew > $1.crew })
            customSC.selectedSegmentIndex = 0
            break
        case "FUEL":
            //equipmentArray.sorted(by: { $0.type > $1.type })
            customSC.selectedSegmentIndex = 1
            break
        case "ENGINE":
            //equipmentArray.sorted(by: { $0.type > $1.type })
            customSC.selectedSegmentIndex = 2
            break
        case "Inspection":
            //equipmentArray.sorted(by: { $0.type > $1.type })
            customSC.selectedSegmentIndex = 3
            break
        default:
            //equipmentArray.sorted(by: { $0.status > $1.status })
            customSC.selectedSegmentIndex = 0
            break
        }
        
        
        self.view.addSubview(customSC)
        
        
        
        self.equipmentFieldsTableView.delegate  =  self
        self.equipmentFieldsTableView.dataSource = self
        equipmentFieldsTableView.rowHeight = 60.0
        self.equipmentFieldsTableView.register(EquipmentFieldTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.equipmentFieldsTableView)
        
        
        
        
        
        self.addFieldBtn.addTarget(self, action: #selector(EquipmentFieldsListViewController.addField), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addFieldBtn)
        
        
        
        
        
        
        //auto layout group
        let viewsDictionary = [
            "view1":customSC,
            "view2":self.equipmentFieldsTableView,
            "view3":self.addFieldBtn
            ] as [String : Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth, "fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view3(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
    
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[view1(40)][view2][view3(40)]|", options:[], metrics: sizeVals, views: viewsDictionary))
    
    }
    
    
    
    
    
    /////////////// Search Methods   ///////////////////////
    
    @objc func changeView(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            //equipmentArray.sorted(by: { $0.crew > $1.crew })
            viewMode = "TYPE"
            navigationItem.rightBarButtonItem = nil
            break
        case 1:
            //equipmentArray.sorted(by: { $0.type > $1.type })
            viewMode = "FUEL"
            navigationItem.rightBarButtonItem = nil
            break
        case 2:
            //equipmentArray.sorted(by: { $0.type > $1.type })
            viewMode = "ENGINE"
            navigationItem.rightBarButtonItem = nil
            break
        default:
            //equipmentArray.sorted(by: { $0.status > $1.status })
            viewMode = "INSPECTION"
            navigationItem.rightBarButtonItem = editButton
            break
        }
        
        equipmentFieldsTableView.reloadData()
    
        scrollToTop()
        
    }
    
    func scrollToTop() {
        if (self.equipmentFieldsTableView.numberOfSections > 0 ) {
            let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
            self.equipmentFieldsTableView.scrollToRow(at: top as IndexPath, at: .top, animated: true);
        }
    }
    
    @objc func displayEditView(){
        print("Edit Cells")
        equipmentFieldsTableView.isEditing = !equipmentFieldsTableView.isEditing
        switch equipmentFieldsTableView.isEditing {
        case true:
            editButton.title = "Done"
        case false:
            editButton.title = "Edit"
            if sortEditsMade{
                saveSort(_leave:false)
            }
        }
        navigationItem.rightBarButtonItem = editButton
        
        
       
    }
    
    
    
    
    func saveSort(_leave:Bool){
        print("save sort")
        
        indicator = SDevIndicator.generate(self.view)!
        
        
       
        
        
        let parameters = [
            "dataBase":"equipment",
            "table": "inspectionQs",
            "IDs": NSArray(array: self.inspectionIDArray)
            ] as [String : Any]
        
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/itemSort.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("field delete response = \(response)")
            }
            .responseJSON(){
                response in
                
                self.indicator.dismissIndicator()
                self.sortEditsMade = false
                if _leave{
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
                
                
                
        }
        
        
        
    }
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        var count:Int = 0
        switch viewMode {
        case "TYPE":
            count = typeIDArray.count
            break
        case "FUEL":
            count = fuelIDArray.count
            break
        case "ENGINE":
            count = engineIDArray.count
            break
        case "INSPECTION":
            count = inspectionIDArray.count
            break
        default:
            count = typeIDArray.count
            break
        }
        
        
        return count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = equipmentFieldsTableView.dequeueReusableCell(withIdentifier: "cell") as! EquipmentFieldTableViewCell
        
        switch viewMode {
        case "TYPE":
            cell.layoutViews(_name: self.typeNameArray[indexPath.row], _ID: self.typeIDArray[indexPath.row])
            //cell.code = self.typeCodeArray[indexPath.row]
            break
        case "FUEL":
            cell.layoutViews(_name: self.fuelNameArray[indexPath.row], _ID: self.fuelIDArray[indexPath.row])
            break
        case "ENGINE":
            cell.layoutViews(_name: self.engineNameArray[indexPath.row], _ID: self.engineIDArray[indexPath.row])
            break
        case "INSPECTION":
            cell.layoutViews(_name: self.inspectionNameArray[indexPath.row], _ID: self.inspectionIDArray[indexPath.row])
            break
        default:
            cell.layoutViews(_name: self.typeNameArray[indexPath.row], _ID: self.typeIDArray[indexPath.row])
            break
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        if tableView.isEditing {
            return
        }
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentFieldTableViewCell
        
        
        let newEquipmentFieldViewController = NewEditEquipmentFieldViewController(_name: currentCell.name, _ID: currentCell.ID, _field: self.viewMode)
        
        navigationController?.pushViewController(newEquipmentFieldViewController, animated: false )
        newEquipmentFieldViewController.delegate = self
        
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! EquipmentFieldTableViewCell
        
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
            
            
            if currentCell.name == "N/A" || currentCell.name == "Other"{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Unable to Delete", _message: "You can't delete the N/A or Other fields.")
                return
            }
            
            
            let alertController = UIAlertController(title: "Delete \(currentCell.name) Field?", message: "", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.deleteField(_ID:currentCell.ID)
                switch self.viewMode {
                case "TYPE":
                    self.typeNameArray.remove(at: indexPath.row)
                    self.typeIDArray.remove(at: indexPath.row)
                    //self.typeCodeArray.remove(at: indexPath.row)
                    break
                case "FUEL":
                    self.fuelNameArray.remove(at: indexPath.row)
                    self.fuelIDArray.remove(at: indexPath.row)
                    break
                case "ENGINE":
                    self.engineNameArray.remove(at: indexPath.row)
                    self.engineIDArray.remove(at: indexPath.row)
                    break
                case "INSPECTION":
                    self.inspectionNameArray.remove(at: indexPath.row)
                    self.inspectionIDArray.remove(at: indexPath.row)
                    break
                default:
                    self.typeNameArray.remove(at: indexPath.row)
                    self.typeIDArray.remove(at: indexPath.row)
                   // self.typeCodeArray.remove(at: indexPath.row)
                    break
                }
                self.equipmentFieldsTableView.reloadData()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true)
            
        }
    }
    
    //reorder cells
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let ID = inspectionIDArray[sourceIndexPath.row]
        inspectionIDArray.remove(at: sourceIndexPath.row)
        inspectionIDArray.insert(ID, at: destinationIndexPath.row)
        
        let name = inspectionNameArray[sourceIndexPath.row]
        inspectionNameArray.remove(at: sourceIndexPath.row)
        inspectionNameArray.insert(name, at: destinationIndexPath.row)
        
        sortEditsMade = true
    }
    
    
    
    func deleteField(_ID:String){
        
            indicator = SDevIndicator.generate(self.view)!
            
            editsMade = true
            
            var parameters:[String:String]
            parameters = [
                "field": self.viewMode,
                "ID":_ID
                
            ]
            
            print("parameters = \(parameters)")
            
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/equipmentField.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("field delete response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    
                    if JSON(json)["errorArray"][0]["error"].stringValue.count > 0{
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Error with Delete", _message: JSON(json)["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                    
                
                    
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
            
        
        
        
    }
    
    

    
    
    @objc func addField(){
        print("Add Field")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }
        
        let newEquipmentFieldViewController = NewEditEquipmentFieldViewController(_field: viewMode)
        newEquipmentFieldViewController.delegate = self
        navigationController?.pushViewController(newEquipmentFieldViewController, animated: false )
    }
    
    
    
    
    
    
    
    
    func reDrawEquipmentFieldList(){
        print("reDraw Equipment Field List")
        
        
        getEquipmentFields()
        editsMade = true
        
        
    }
    
    
    
    @objc func goBack(){
        if sortEditsMade == true{
            print("sortEditsMade = true")
            let alertController = UIAlertController(title: "Sort Change", message: "Leave without saving?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Don't Save", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
                _ = self.navigationController?.popViewController(animated: true)
                return
            }
            
            let okAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                self.saveSort(_leave:true)
               // _ = self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
        
        
        if editsMade {
            self.equipmentListDelegate.reDrawEquipmentList()
        }
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


