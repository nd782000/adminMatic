//
//  PayrollTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 2/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation
import UIKit

class PayrollSummaryTableViewCell: UITableViewCell {
    
    
    var payroll:Payroll!
    var dateLbl: Label!
    var startLbl: Label!
    var stopLbl: Label!
    var breakLbl: Label!
    var totalLbl: Label!
    
    let layoutVars : LayoutVars = LayoutVars()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        
    }
    
    
    func layoutViewsPortrait(){
        
        print("portrait cell")
        
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        dateLbl = Label(text: "")
        contentView.addSubview(dateLbl)
        
        startLbl = Label(text: "")
        contentView.addSubview(startLbl)
        
        stopLbl = Label(text: "")
        contentView.addSubview(stopLbl)
        
        totalLbl = Label(text: "")
        contentView.addSubview(totalLbl)
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["date": self.dateLbl,"start": self.startLbl,"stop": self.stopLbl,"total": self.totalLbl] as [String:AnyObject]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[date]-[start(72)]-[stop(72)]-[total(55)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[date(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[start(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[stop(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[total(30)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
    func layoutViewsLandscape(){
        
        print("landscape cell")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        dateLbl = Label(text: "")
        contentView.addSubview(dateLbl)
        
        startLbl = Label(text: "")
        contentView.addSubview(startLbl)
        
        stopLbl = Label(text: "")
        contentView.addSubview(stopLbl)
        
        breakLbl = Label(text: "")
        contentView.addSubview(breakLbl)
        
        totalLbl = Label(text: "")
        contentView.addSubview(totalLbl)
        
        /////////  Auto Layout   //////////////////////////////////////
        //auto layout group
        let viewsDictionary = ["date": self.dateLbl,"start": self.startLbl,"stop": self.stopLbl,"break": self.breakLbl,"total": self.totalLbl] as [String:AnyObject]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[date]-[start(72)]-[stop(72)]-[break(72)]-[total(55)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[date(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[start(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[stop(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[break(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[total(30)]", options: [], metrics: nil, views: viewsDictionary))
        
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


