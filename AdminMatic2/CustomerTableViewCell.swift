//
//  CustomerTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit

class CustomerTableViewCell: UITableViewCell {
    
    var customer:Customer!
    var iconView:UIImageView = UIImageView()
    var id: String!
    var name: String!
    var address: String!
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
        addressLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addressLbl)
    
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["icon":self.iconView,"name":nameLbl,"address":addressLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[icon(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(18)]-6-[address(14)]", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[icon(30)]-[name]-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
