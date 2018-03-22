//
//  LogInView.swift
//  AdminMatic2
//
//  Created by Nick on 1/4/17.
//  Copyright © 2017 Nick. All rights reserved.
//

/*
import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class LogInView: UIView {
    var layoutVars:LayoutVars = LayoutVars()
    
    //todays info, crew, crew leader, helpers, truck
    var backgroundView:UIView!
    var userTxt:PaddedTextField!
    var passTxt:PaddedTextField!

    override init(frame: CGRect){
        super.init(frame: frame)
        layoutViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func layoutViews(){
        print("LogInView")
        
        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = layoutVars.backgroundColor
        
        self.backgroundView.layer.borderColor = layoutVars.borderColor
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backgroundView)
        
        
        //auto layout group
        let viewsDictionary = [
            "backgroundView":self.backgroundView
        ] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"halfWidth": (layoutVars.fullWidth/2)-15, "height": 24] as [String : Any]
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        print("LogInView 2")
        
        self.userTxt = PaddedTextField(placeholder: "User Name")
        self.userTxt.tag = 1
        self.backgroundView.addSubview(self.userTxt)
        self.userTxt.autocorrectionType = UITextAutocorrectionType.no
        
        
        self.passTxt = PaddedTextField(placeholder: "Password")
        self.passTxt.tag = 2
        //self.passTxt.secureTextEntry = true;
        self.passTxt.isSecureTextEntry = true
        self.backgroundView.addSubview(self.passTxt)
        
        
        //auto layout group
        let backgroundViewsDictionary = [
            "userTxt":self.userTxt,
            "passTxt":self.passTxt
        ]as [String : Any]
        
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[userTxt(halfWidth)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[passTxt(halfWidth)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        self.backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[userTxt(40)]-10-[passTxt(40)]", options: [], metrics: sizeVals, views: backgroundViewsDictionary))
        
        print("LogInView 3")
        
        
    }
    
}
 */

