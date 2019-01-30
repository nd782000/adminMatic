//
//  LicenseViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/29/19.
//  Copyright © 2019 Nick. All rights reserved.
//


//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class LicenseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    var employee:Employee!
    
    
    var licenseTableView:TableView! // = TableView()
    
    
    init(_employee:Employee){
        super.init(nibName:nil,bundle:nil)
        
        self.employee = _employee
        
        
        print("view will appear")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "\(self.employee.fname!)'s Licenses"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(LicenseViewController.goBack), for: UIControl.Event.touchUpInside)
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
        
        print("layoutViews employee licenses = \(self.employee.licenseArray.count)")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
       
        
        self.licenseTableView = TableView()
        self.licenseTableView.delegate  =  self
        self.licenseTableView.dataSource = self
        //self.licenseTableView.rowHeight = UITableView.automaticDimension
        //self.licenseTableView.estimatedRowHeight = 60.0
        self.licenseTableView.rowHeight = 60.0
        
        //self.detailsTableView.rowHeight = 40.0
        self.licenseTableView.register(LicenseTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(licenseTableView)
        //if shouldUpdateTable {
        //self.serviceTableView.reloadData()
        // shouldUpdateTable = false
        // }
        
        /*
         self.addServiceButton.addTarget(self, action: #selector(EquipmentServiceListViewController.addService), for: UIControl.Event.touchUpInside)
         safeContainer.addSubview(self.addServiceButton)
         */
        
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            "licenseTable":self.licenseTableView
            
            ] as [String:Any]
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[licenseTable]|", options: [], metrics: nil, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[licenseTable]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    
    
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        if self.employee.licenseArray.count == 0{
            count = 1
        }else{
            count = self.employee.licenseArray.count
        }
        
        
        
        return count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = licenseTableView.dequeueReusableCell(withIdentifier: "cell") as! LicenseTableViewCell
        
        if self.employee.licenseArray.count == 0{
            cell.layoutNoLicenseView()

        }else{
            cell.layoutViews(_license: self.employee.licenseArray[indexPath.row])
        }
        

       
        
        return cell
        
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


