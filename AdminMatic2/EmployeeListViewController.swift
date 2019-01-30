//
//  EmployeeListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView

import Foundation
import UIKit
import Alamofire
//import SwiftyJSON
import MessageUI


class EmployeeListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    var employeeTableView: TableView!
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var groupMessageBtn:Button = Button(titleText: "Group Text Message")

    var employeeViewController:EmployeeViewController!
    
    
    
    
    var controller:MFMessageComposeViewController = MFMessageComposeViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Employee List"
        
        layoutViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        print("view will appear")
       
        if appDelegate.employeeArray.count == 0{
            print("internet connection failed")
            
            let alertController = UIAlertController(title: "Lost Internet Connection", message: "Try connecting again", preferredStyle: UIAlertController.Style.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            //let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                //(result : UIAlertAction) -> Void in
                //print("Cancel")
           // }
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
               // _ = self.navigationController?.popViewController(animated: true)
                
                self.appDelegate.getEmployeeList()
            }
            alertController.addAction(okAction)
           // alertController.addAction(DestructiveAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
            
            
        }
        
        
    }
    
    
    
    
   
    func layoutViews(){
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        self.employeeTableView =  TableView()
        
        //print("layoutViews")
        
        self.employeeTableView.layer.cornerRadius = 0
        self.employeeTableView.delegate  =  self
        self.employeeTableView.dataSource  =  self
        self.employeeTableView.rowHeight = 60.0
        self.employeeTableView.tableHeaderView = nil;
        self.employeeTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        safeContainer.addSubview(self.employeeTableView)
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        //self.countView.layer.borderColor = layoutVars.borderColor
        //self.countView.layer.borderWidth = 1.0
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        self.countLbl.text = "\(appDelegate.employeeArray.count) Active Employees "
        self.countView.addSubview(self.countLbl)
        
        
        
        
        
        self.groupMessageBtn.layer.cornerRadius = 0
        self.groupMessageBtn.addTarget(self, action: #selector(EmployeeListViewController.groupMessage), for: UIControl.Event.touchUpInside)
        
       // self.groupMessageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width - 100, height: 50)
       // self.groupMessageBtn.translatesAutoresizingMaskIntoConstraints = true
       // self.groupMessageBtn.layer.borderColor = UIColor.white.cgColor
        //self.groupMessageBtn.layer.borderWidth = 1.0
        safeContainer.addSubview(self.groupMessageBtn)
        
        
        
        
        //auto layout group
        let viewsDictionary = [
            
            "empTable":self.employeeTableView,
            "countView":self.countView,
            "groupMessageBtn":self.groupMessageBtn
        ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[empTable(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[groupMessageBtn(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[empTable][countView(30)][groupMessageBtn(40)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        
         
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
        
        //cell.imageView?.image = nil
        
        cell.employee = appDelegate.employeeArray[indexPath.row]
        cell.layoutViews()
        cell.activityView.startAnimating()
        
        //print("setImageUrl http://atlanticlawnandgarden.com/uploads/general/thumbs/\(cell.employee.pic!)")
        cell.nameLbl.text = cell.employee.name
        
        //print("setImageUrl http://atlanticlawnandgarden.com/uploads/general/thumbs/\(cell.employee.pic!)")
        
        cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.employee.pic!)
        
        cell.badgeCount = 0
        
        for license in cell.employee.licenseArray{
            if license.status == "0"{
                cell.addBadge(_active: false)
            }else{
                cell.addBadge(_active: true)
            }
        }
        
        
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
        let call = UITableViewRowAction(style: .normal, title: "Call") { action, index in
            //print("call button tapped")
            //callPhoneNumber(currentCell.employee.phone)
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(currentCell.employee.phone))")! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            tableView.setEditing(false, animated: true)
        }
        call.backgroundColor = self.layoutVars.buttonColor1
        let text = UITableViewRowAction(style: .normal, title: "Text") { action, index in
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                    if (MFMessageComposeViewController.canSendText()) {
                        self.controller = MFMessageComposeViewController()
                        self.controller.recipients = [currentCell.employee.phone]
                        self.controller.messageComposeDelegate = self
                        self.controller.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                        self.controller.navigationBar.shadowImage = UIImage()
                        self.controller.navigationBar.isTranslucent = true
                        self.controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EmployeeListViewController.dismissMessage))
                        self.controller.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
                        self.present(self.controller, animated: true, completion: nil)
                        tableView.setEditing(false, animated: true)
                    }
            }
        }
        text.backgroundColor = UIColor.orange
        return [call,text]
    }
    
    
    
    
    
    
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("didfinish")
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
        //getBatch()
        //print("try and send text")
        
        
        
        
        
        
    }
    
       
    @objc func dismissMessage(){
        print("dismiss")
       // controller.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    @objc func groupMessage(){
        print("group message")
        
        let groupMessageViewController = GroupMessageViewController()
        
        navigationController?.pushViewController(groupMessageViewController, animated: false )
        
        
    }
    

    func goBack(){
      _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
