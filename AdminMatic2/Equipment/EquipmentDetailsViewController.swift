//
//  EquipmentServiceListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/31/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class EquipmentDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    var equipment:Equipment!
    
   
    var detailsTableView:TableView! // = TableView()
    
    
    init(_equipment:Equipment){
        super.init(nibName:nil,bundle:nil)
        
        self.equipment = _equipment
        
        
        print("view will appear")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Equipment Details"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(EquipmentDetailsViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        layoutViews()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
   
    
    func layoutViews(){
        
        print("layoutViews")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
       
        
        self.detailsTableView = TableView()
        self.detailsTableView.delegate  =  self
        self.detailsTableView.dataSource = self
        self.detailsTableView.rowHeight = UITableView.automaticDimension
        self.detailsTableView.estimatedRowHeight = 40.0
        
        self.detailsTableView.register(EquipmentFieldTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(detailsTableView)
        
        
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            "detailsTable":self.detailsTableView
            
            ] as [String:Any]
        
        
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[detailsTable]|", options: [], metrics: nil, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[detailsTable]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
  
    
   
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
       
        count = 11
        
        
        return count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailsTableView.dequeueReusableCell(withIdentifier: "cell") as! EquipmentFieldTableViewCell
        switch indexPath.row{
        case 0:
            cell.layoutViews(_name: "Name: \(self.equipment.name!)", _ID: "")
            break
        case 1:
            
            cell.layoutViews(_name: "Type: \(self.equipment.typeName!)", _ID: "")
            break
            
        case 2:
            
            cell.layoutViews(_name: "Crew: \(self.equipment.crewName!)", _ID: "")
            break
        
        case 3:
            
            
            cell.layoutViews(_name: "Make: \(self.equipment.make!)", _ID: "")
            break
        case 4:
            
            cell.layoutViews(_name: "Model: \(self.equipment.model!)", _ID: "")
            break
        case 5:
            
            cell.layoutViews(_name: "Serial/Vin: \(self.equipment.serial!)", _ID: "")
            break
        case 6:
            
            cell.layoutViews(_name: "Fuel: \(self.equipment.fuelTypeName!)", _ID: "")
            break
        case 7:
            
            cell.layoutViews(_name: "Engine: \(self.equipment.engineTypeName!)", _ID: "")
            break
        case 8:
            
            cell.layoutViews(_name: "Purchased: \(self.equipment.purchaseDate!)", _ID: "")
            break
        case 9:
            
            cell.layoutViews(_name: "Vendor: \(self.equipment.dealerName!)", _ID: self.equipment.dealer)
            cell.titleLbl.textColor = UIColor.blue
            break
        case 10:
            
            cell.layoutViews(_name: "Description: \(self.equipment.description!)", _ID: "")
            break
            
       
        
        default:
            
            break
        }
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        
        if indexPath.row == 9{
            let vendorViewController = VendorViewController(_vendorID: equipment.dealer)
            navigationController?.pushViewController(vendorViewController, animated: false )
        }
        
        
        
        
        
    }
 
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
    
}


