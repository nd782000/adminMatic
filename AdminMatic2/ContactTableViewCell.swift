//
//  ContactTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//
 

import Foundation
import UIKit

class ContactTableViewCell: UITableViewCell {
    
    var contact:Contact!
    var nameLbl: Label! = Label()
    var detailLbl: DetailLabel! = DetailLabel()
    
    var iconView:UIImageView = UIImageView()
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var addContactLbl:Label = Label()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.selectionStyle = .none
        
        self.iconView.clipsToBounds = true
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.iconView)
        
        
        
        
        //print("contactTableCell")
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        detailLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailLbl)
        
        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["icon":self.iconView,"name":nameLbl,"detail":detailLbl] as [String : Any]
        
        let viewsConstraint_V:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[icon(30)]", options: [], metrics: nil, views: viewsDictionary)
        
        
        
        
        let viewsConstraint_V2:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(18)]-6-[detail(14)]", options: NSLayoutConstraint.FormatOptions.alignAllLeft, metrics: nil, views: viewsDictionary)
        
        let viewsConstraint_H:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[icon(30)]-[name]-|", options: [], metrics: nil, views: viewsDictionary)
        
        contentView.addConstraints(viewsConstraint_H)
        contentView.addConstraints(viewsConstraint_V)
        contentView.addConstraints(viewsConstraint_V2)
        
    }
    
    func layoutAddBtn(){
        
        print("layoutAddBtn")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.addContactLbl.text = "+ Add Contact"
        self.addContactLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.addContactLbl.backgroundColor = UIColor.clear
        
        self.addContactLbl.layer.cornerRadius = 4.0
        self.addContactLbl.clipsToBounds = true
        self.addContactLbl.textAlignment = .center
        self.addContactLbl.font = layoutVars.labelBoldFont
        contentView.addSubview(self.addContactLbl)
        
        
        let viewsDictionary = ["addBtn":self.addContactLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
}
