//
//  EmployeeListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class EmployeeListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    
    var layoutVars:LayoutVars = LayoutVars()
    var employeeTableView: TableView!
    var employeeViewController:EmployeeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Employee List"
        
        layoutViews()
    }
    
   
    func layoutViews(){
        
        self.employeeTableView =  TableView()
        
        //print("layoutViews")
        
        self.employeeTableView.delegate  =  self
        self.employeeTableView.dataSource  =  self
        self.employeeTableView.rowHeight = 60.0
        self.employeeTableView.tableHeaderView = nil;
        self.employeeTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.employeeTableView)
        
        //auto layout group
        let viewsDictionary = [
            
            "view2":self.employeeTableView
        ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view2(height)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("appDelegate.employeeArray.count = \(appDelegate.employeeArray.count)")
        return appDelegate.employeeArray.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        let cell:EmployeeTableViewCell = employeeTableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeTableViewCell
        
        cell.imageView?.image = nil
        
        cell.employee = appDelegate.employeeArray[indexPath.row]
        
        
        //print("setImageUrl http://atlanticlawnandgarden.com/uploads/general/thumbs/\(cell.employee.pic!)")
        cell.nameLbl.text = cell.employee.name
        
        //print("setImageUrl http://atlanticlawnandgarden.com/uploads/general/thumbs/\(cell.employee.pic!)")
        
        cell.setImageUrl(_url: "http://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.employee.pic!)
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! EmployeeTableViewCell;
        
        
        self.employeeViewController = EmployeeViewController(_employee: currentCell.employee)
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
        navigationController?.pushViewController(self.employeeViewController, animated: false )
        
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! EmployeeTableViewCell;
        
        let call = UITableViewRowAction(style: .normal, title: "Phone") { action, index in
            //print("call button tapped")
            
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                
                UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(currentCell.employee.phone))")! as URL, options: [:], completionHandler: nil)
            }
            
            
        }
        call.backgroundColor = layoutVars.buttonTint
        return [call]
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    

    func goBack(){
      _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
