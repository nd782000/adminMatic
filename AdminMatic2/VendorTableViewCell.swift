//
//  VendorTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit

class VendorTableViewCell: UITableViewCell {
    
    var iconView:UIImageView = UIImageView()
    
    var id: String!
    var name: String!
    var address: String!
    var phone: String!
    
    
    var nameLbl: Label! = Label()
    var addressLbl: DetailLabel! = DetailLabel()
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.iconView.clipsToBounds = true
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.iconView.image = UIImage(named:"personIcon.png")
        self.contentView.addSubview(self.iconView)
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["icon":self.iconView,"name":nameLbl] as [String : Any]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[icon(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[name(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[icon(30)]-[name]-|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
}
