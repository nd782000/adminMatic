//
//  ItemTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
 
class ItemTableViewCell: UITableViewCell {
    
    var item:Item2!
    var nameLbl: Label! = Label()
    var typeLbl:DetailLabel! = DetailLabel()
    var priceLbl:DetailLabel! = DetailLabel()
    
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        
        
        
    }
    
    func layoutViews(){
        
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
        typeLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLbl)
        
        priceLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLbl)
        priceLbl.textAlignment = NSTextAlignment.right
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["name":nameLbl,"type":typeLbl,"price":priceLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(14)]-5-[type]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[type(150)][price(120)]-20-|", options: NSLayoutConstraint.FormatOptions.alignAllTop, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name(250)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        nameLbl.text = ""
        typeLbl.text = ""
        priceLbl.text = ""
        
        typeLbl.text = "\(item.type!) Type"
        priceLbl.text = "$\(item.price!)/\(item.units!)"
        nameLbl.text = item.name!
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
}
