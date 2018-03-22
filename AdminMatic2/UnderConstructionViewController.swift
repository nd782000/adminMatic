//
//  UnderConstructionViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/6/17.
//  Copyright © 2017 Nick. All rights reserved.
//


/*
import Foundation
import UIKit
import Alamofire
import SwiftyJSON




class UnderConstructionViewController: ViewControllerWithMenu  {
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    //var indicator: SDevIndicator!
    
    
    
    var holdOnLbl:GreyLabel!
    var holdOnLbl2:GreyLabel!
    
    
    init(){
        super.init(nibName:nil,bundle:nil)
        
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Hold On"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(UnderConstructionViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
       // let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
       // navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.layoutViews()
        // self.getCurrentShift()
        
        
        
        
    }
    
    
    
    
    
    
    func layoutViews(){
        
        
        
        
               //name
        self.holdOnLbl = GreyLabel()
        self.holdOnLbl.textAlignment = .center
        self.holdOnLbl.text = "Hold on ten minutes!"
        self.holdOnLbl.font = layoutVars.labelFont
        self.view.addSubview(self.holdOnLbl)
        
        self.holdOnLbl2 = GreyLabel()
        self.holdOnLbl2.textAlignment = .center
        self.holdOnLbl2.text = "I'm still working on it."
        self.holdOnLbl2.font = layoutVars.labelFont
        self.view.addSubview(self.holdOnLbl2)
        
        //phone
        
        
        
        
        
        //auto layout group
        let employeeViewsDictionary = [
            "view1":self.holdOnLbl,
            "view2":self.holdOnLbl2
            ] as [String:Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view1]-10-|", options: [], metrics: nil, views: employeeViewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2]-10-|", options: [], metrics: nil, views: employeeViewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[view1(30)][view2(30)]", options: [], metrics: nil, views: employeeViewsDictionary))
        
        
        
        
        
        
    }
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Test")
    }
    
}
 */

