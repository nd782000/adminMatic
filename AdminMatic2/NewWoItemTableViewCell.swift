//
//  NewWoItemTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 5/1/17.
//  Copyright © 2017 Nick. All rights reserved.
//

 

import Foundation
import UIKit

class NewWoItemTableViewCell: UITableViewCell {
    
    //var customer:Customer!
    //var iconView:UIImageView = UIImageView()
    var id: String!
    var name: String!
    var type: String!
    var price: String!
    var unit: String!
    var tax: String!
    var subcontractor: String!
    var nameLbl: Label! = Label()
    var unitLbl: DetailLabel! = DetailLabel()
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        unitLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(unitLbl)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["name":nameLbl,"unit":unitLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(18)]-6-[unit(14)]", options: NSLayoutConstraint.FormatOptions.alignAllLeft, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[unit]-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
