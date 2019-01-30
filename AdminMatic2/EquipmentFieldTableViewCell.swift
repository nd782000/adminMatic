//
//  EquipmentFieldTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 12/29/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit

class EquipmentFieldTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    
    var titleLbl: UILabel!
    var name: String = ""
    var ID: String = "0"
   // var code: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
     
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        titleLbl = UILabel()
        titleLbl.font = layoutVars.smallBoldFont
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLbl)
    }
    
    
    func layoutViews(_name:String, _ID:String){
        self.name = _name
        self.ID = _ID
        titleLbl.numberOfLines = 0
        titleLbl.text = _name
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["title":titleLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[title]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title(>=30)]-|", options: [], metrics: nil, views: viewsDictionary))
    }
}


