//
//  UsageTableViewCell.swift
//  Atlantic_Blank
//
//  Created by nicholasdigiando on 4/9/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//


import Foundation
import UIKit

class UsageTableViewCell: UITableViewCell {
    
    var usageNameLbl: Label!
    var usageDateLbl: Label!
    var usageTotalLbl: Label!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        let layoutVars : LayoutVars = LayoutVars()
        usageNameLbl = Label(text: "") // not sure how to refer to the cell size here
        usageDateLbl = Label(text: "") // not sure how to refer to the cell size here
        usageTotalLbl = Label(text: "") // not sure how to refer to the cell size here
        contentView.addSubview(usageNameLbl)
        contentView.addSubview(usageDateLbl)
        contentView.addSubview(usageTotalLbl)
        
        /////////  Auto Layout   //////////////////////////////////////
        print("usage table view cell")
        //auto layout group
        let usageViewsDictionary = ["view1": self.usageNameLbl,"view2": self.usageDateLbl,"view3": self.usageTotalLbl] as [String:AnyObject]
        
        let usageViewWidth = (layoutVars.fullWidth - 30) / 2
        let metricsDictionary = ["halfWidth": usageViewWidth] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[view1]-15-[view2(80)]-15-[view3(100)]-5-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view1(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view2(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view3(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
