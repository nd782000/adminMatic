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
    
    
    @objc func displayHomeView() {
        
        appDelegate.menuChange(100)//home
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
