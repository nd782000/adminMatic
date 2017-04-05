//
//  ImageSettingsViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/25/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit




class ImageSettingsViewController: UIViewController{
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    var portfolio:String!
    var fieldNote:String!
    
    var portfolioSwitch:UISwitch = UISwitch()
    var portfolioSwitchLbl:Label = Label()
    
    var fieldNoteSwitch:UISwitch = UISwitch()
    var fieldNoteSwitchLbl:Label = Label()
    
    var imageDelegate:ImageViewDelegate!
    
    var editsMade:Bool = false
    
    
    
    
    init(_portfolio:String,_fieldNote:String){
        super.init(nibName:nil,bundle:nil)
        print("init _portfolio = \(_portfolio)   _fieldNote = \(_fieldNote)")
        self.portfolio = _portfolio
        self.fieldNote = _fieldNote
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Image Settings"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.layoutViews()
        
    }
    
    
    func layoutViews(){
        
        print("layoutViews")
        // indicator.dismissIndicator()
        
        if(self.portfolio == "1"){
            portfolioSwitch.isOn = true
        }else{
            portfolioSwitch.isOn = false
        }
        portfolioSwitch.translatesAutoresizingMaskIntoConstraints = false
        portfolioSwitch.addTarget(self, action: #selector(ImageSettingsViewController.portfolioValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(portfolioSwitch)
        
        portfolioSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        portfolioSwitchLbl.text = "Portfolio Images Only"
        self.view.addSubview(portfolioSwitchLbl)
        
        
        
        if(self.fieldNote == "1"){
            fieldNoteSwitch.isOn = true
        }else{
            fieldNoteSwitch.isOn = false
        }
        fieldNoteSwitch.translatesAutoresizingMaskIntoConstraints = false
        fieldNoteSwitch.addTarget(self, action: #selector(ImageSettingsViewController.fieldNoteValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(fieldNoteSwitch)
        
        fieldNoteSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        fieldNoteSwitchLbl.text = "Include Field Note Images"
        self.view.addSubview(fieldNoteSwitchLbl)

        
        //auto layout group
        let viewsDictionary = [
            "view1":self.portfolioSwitch,
            "view2":self.portfolioSwitchLbl,
            "view3":self.fieldNoteSwitch,
            "view4":self.fieldNoteSwitchLbl
            ] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24,"fullHeight":layoutVars.fullHeight - 344, "navHeight":layoutVars.navAndStatusBarHeight + 20] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view1(60)]-[view2]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view3(60)]-[view4]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[view1(40)]-[view3(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[view2(40)]-[view4(40)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
    }
    
    func portfolioValueDidChange(sender:UISwitch!)
    {
        print("portfolioValueDidChange")
        
        editsMade = true
        if (sender.isOn == true){
            print("on")
            portfolio = "1"
        }
        else{
            print("off")
            portfolio = "0"
        }
        
        
    }
    
    func fieldNoteValueDidChange(sender:UISwitch!)
    {
        print("fieldNoteValueDidChange")
        
        editsMade = true

        if (sender.isOn == true){
            print("on")
            fieldNote = "1"
        }
        else{
            print("off")
            fieldNote = "0"
        }
        
        
    }

    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        if(editsMade == true){
            imageDelegate.updateSettings(_portfolio:self.portfolio, _fieldNote:self.fieldNote)

        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Test")
    }
    
}
