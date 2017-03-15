//
//  ViewController.swift
//  Atlantic_Blank
//
//  Created by Nicholas Digiando on 4/6/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import UIKit


class ViewControllerWithMenu: UIViewController, UIActionSheetDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var homeButton:UIBarButtonItem!
    var delegate:MenuDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        
        homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(ViewControllerWithMenu.displayHomeView))
        navigationItem.rightBarButtonItem = homeButton
    }
    
    
    func displayHomeView() {
        
        appDelegate.menuChange(100)//home
        
    }
    
    
    //Old Menu Style
    /*
     func displayMenuSheet() {
     let sheet: UIActionSheet = UIActionSheet()
     let title: String = "Menu"
     sheet.title  = title
     sheet.delegate = self
     sheet.addButton(withTitle: "Cancel")
     sheet.addButton(withTitle: "Customers")
     sheet.addButton(withTitle: "Vendors")
     sheet.addButton(withTitle: "Items")
     sheet.addButton(withTitle: "Employees")
     sheet.addButton(withTitle: "Schedule")
     sheet.addButton(withTitle: "Equipment")
     sheet.cancelButtonIndex = 0;
     sheet.show(in: self.view)
     }
     
    //Action Sheet Delegate
    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch (buttonIndex) {
            case 1:
                delegate.menuChange(1)
                break;
            case 2:
                delegate.menuChange(2)
                break;
            case 3:
                delegate.menuChange(3)
                break;
            case 4:
                delegate.menuChange(4)
            break;
            case 5:
                delegate.menuChange(5)
            break;

            case 6:
                delegate.menuChange(6)
            break
            default:
                break;
        }
    }
   */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
