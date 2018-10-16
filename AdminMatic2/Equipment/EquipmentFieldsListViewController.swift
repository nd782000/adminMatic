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





class EquipmentFieldsListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, EquipmentFieldListDelegate{
    var indicator: SDevIndicator!
    
    
    
    
    var layoutVars:LayoutVars = LayoutVars()
    var equipmentListDelegate:EquipmentListDelegate!
    var viewMode:String = "TYPE"
    let items = ["Type","Fuel","Engine"]
    
    var equipmentFieldsTableView:TableView!
    
    
    
    var typeNameArray:[String] = []
    var typeIDArray:[String] = []
    //var typeCodeArray:[String] = []
    
    var fuelNameArray:[String] = []
    var fuelIDArray:[String] = []
    
    var engineNameArray:[String] = []
    var engineIDArray:[String] = []

    
    var addFieldBtn:Button = Button(titleText: "Add New Field")
    
    var editsMade:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Equipment Fields"
        view.backgroundColor = layoutVars.backgroundColor
        
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ItemViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        indicator = SDevIndicator.generate(self.view)!
        
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EquipmentFieldsListViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        
        
        getEquipmentFields()
    }
    
    
    func getEquipmentFields(){
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
         typeNameArray = []
         typeIDArray = []
         //typeCodeArray = []
        
         fuelNameArray = []
         fuelIDArray = []
        
         engineNameArray = []
         engineIDArray = []
        
        
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
            if let json = response.result.value {
                
                let typesCount = JSON(json)["types"].count
                print("typescount: \(typesCount)")
                for i in 0 ..< typesCount {
                    self.typeIDArray.append(JSON(json)["types"][i]["ID"].stringValue)
                    self.typeNameArray.append(JSON(json)["types"][i]["name"].stringValue)
                    //self.typeCodeArray.append(JSON(json)["types"][i]["code"].stringValue)
                }
                
                let fuelTypesCount = JSON(json)["fuelTypes"].count
                print("fuelTypesCount: \(fuelTypesCount)")
                for i in 0 ..< fuelTypesCount {
                    self.fuelIDArray.append(JSON(json)["fuelTypes"][i]["ID"].stringValue)
                    self.fuelNameArray.append(JSON(json)["fuelTypes"][i]["name"].stringValue)
                }
                
                let engineTypesCount = JSON(json)["engineTypes"].count
                print("engineTypesCount: \(engineTypesCount)")
                for i in 0 ..< engineTypesCount {
                    self.engineIDArray.append(JSON(json)["engineTypes"][i]["ID"].stringValue)
                    self.engineNameArray.append(JSON(json)["engineTypes"][i]["name"].stringValue)
                }
                self.layoutViews()
            }
        }
    }
    
    
    
    func layoutViews(){
        
        // Close Indicator
        
        
        indicator.dismissIndicator()
        
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
        
        
        
        
        
        self.addFieldBtn.addTarget(self, action: #selector(EquipmentFieldsListViewController.addField), for: UIControlEvents.touchUpInside)
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
            break
        case 1:
            //equipmentArray.sorted(by: { $0.type > $1.type })
            viewMode = "FUEL"
            break
        default:
            //equipmentArray.sorted(by: { $0.status > $1.status })
            viewMode = "ENGINE"
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
        default:
            cell.layoutViews(_name: self.typeNameArray[indexPath.row], _ID: self.typeIDArray[indexPath.row])
            break
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! EquipmentFieldTableViewCell
        
        
        //let newEquipmentFieldViewController = NewEditEquipmentFieldViewController(_name: currentCell.name, _ID: currentCell.ID, _code: currentCell.code, _field: self.viewMode)
        
        let newEquipmentFieldViewController = NewEditEquipmentFieldViewController(_name: currentCell.name, _ID: currentCell.ID, _field: self.viewMode)
        
        navigationController?.pushViewController(newEquipmentFieldViewController, animated: false )
        newEquipmentFieldViewController.delegate = self
        
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! EquipmentFieldTableViewCell
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            
            
            if currentCell.name == "N/A" || currentCell.name == "Other"{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Unable to Delete", _message: "You can't delete the N/A or Other fields.")
                return
            }
            
            
            let alertController = UIAlertController(title: "Delete \(currentCell.name) Field?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default) {
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
            //self.present(alertController, animated: true, completion: nil)
            present(alertController, animated: true)
            
        }
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


