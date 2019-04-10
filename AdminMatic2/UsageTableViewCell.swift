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
    
    var statusIcon: UIImageView!
    var usage:Usage!
    var usageNameLbl: Label!
    var usageDateLbl: Label!
    var usageStartLbl: Label!
    var usageStopLbl: Label!
    var usageQtyLbl: Label!
    var usageUnitCostLbl: Label!
    var usageTotalLbl: Label!
    var checkMarkView:UIImageView = UIImageView()
    var usagePriceLbl: Label!
    
     let layoutVars : LayoutVars = LayoutVars()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
       
        
        
        
        
       
    }
    
    
    func layoutPortrait(){
        
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        statusIcon = UIImageView()
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(statusIcon)

        
        usageNameLbl = Label(text: "") // not sure how to refer to the cell size here
        usageDateLbl = Label(text: "") // not sure how to refer to the cell size here
        usageTotalLbl = Label(text: "") // not sure how to refer to the cell size here
        contentView.addSubview(usageNameLbl)
        contentView.addSubview(usageDateLbl)
        contentView.addSubview(usageTotalLbl)
        
        /////////  Auto Layout   //////////////////////////////////////
        print("usage table view cell")
        //auto layout group
        let usageViewsDictionary = ["stsIcon":statusIcon,"view1": self.usageNameLbl,"view2": self.usageDateLbl,"view3": self.usageTotalLbl] as [String:AnyObject]
        
        let usageViewWidth = (layoutVars.fullWidth - 30) / 2
        let metricsDictionary = ["halfWidth": usageViewWidth] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[stsIcon(30)]-[view1]-[view2(60)]-[view3(40)]-5-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[stsIcon(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view1(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view2(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view3(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
    }
    
    func layoutLandscape(){
        
        
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
 
        
        
        statusIcon = UIImageView()
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        statusIcon.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statusIcon)

        usageNameLbl = Label(text: "") // not sure how to refer to the cell size here
        usageDateLbl = Label(text: "") // not sure how to refer to the cell size here
        usageStartLbl = Label(text: "") // not sure how to refer to the cell size here
        usageStopLbl = Label(text: "") // not sure how to refer to the cell size here
        usageTotalLbl = Label(text: "") // not sure how to refer to the cell size here
        usagePriceLbl = Label(text: "") // not sure how to refer to the cell size here
        contentView.addSubview(usageNameLbl)
        contentView.addSubview(usageDateLbl)
        contentView.addSubview(usageStartLbl)
        contentView.addSubview(usageStopLbl)
        contentView.addSubview(usageTotalLbl)
        contentView.addSubview(usagePriceLbl)
        
        /////////  Auto Layout   //////////////////////////////////////
        print("usage table view cell")
        //auto layout group
        let usageViewsDictionary = ["stsIcon":statusIcon,"view1": self.usageNameLbl,"view2": self.usageDateLbl,"view3": self.usageStartLbl,"view4": self.usageStopLbl,"view5": self.usageTotalLbl,"view6": self.usagePriceLbl] as [String:AnyObject]
        
        let usageViewWidth = (layoutVars.fullWidth - 30) / 2
        let metricsDictionary = ["halfWidth": usageViewWidth] as [String:Any]
        
        
        //"H:|-5-[sts(30)]-[name]-[date(60)]-[start(80)]-[stop(80)]-[qty(40)]-[price(60)]-5-|"
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[stsIcon(30)]-[view1]-[view2(60)]-[view3(80)]-[view4(80)]-[view5(40)]-[view6(60)]-5-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[stsIcon(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view1(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view2(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view3(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view4(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view5(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view6(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
        
    }
    
    func layoutForLabor(){
        print("layoutForLabor")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
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
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[view1]-[view2(75)]-[view3(100)]-5-|", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view1(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view2(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view3(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
    }

    
    func layoutForMaterial(){
        print("layoutForMaterial")
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        usageDateLbl = Label(text: "") // not sure how to refer to the cell size here
        usageQtyLbl = Label(text: "") // not sure how to refer to the cell size here
        usageUnitCostLbl = Label(text: "") // not sure how to refer to the cell size here
        usageTotalLbl = Label(text: "") // not sure how to refer to the cell size here
        
        contentView.addSubview(usageDateLbl)
        contentView.addSubview(usageQtyLbl)
        contentView.addSubview(usageUnitCostLbl)
        contentView.addSubview(usageTotalLbl)
        
        
        checkMarkView = UIImageView()
        checkMarkView.translatesAutoresizingMaskIntoConstraints = false
        checkMarkView.backgroundColor = UIColor.clear
        checkMarkView.contentMode = .scaleAspectFit
        contentView.addSubview(checkMarkView)
        
        /////////  Auto Layout   //////////////////////////////////////
        print("usage table view cell")
        //auto layout group
        let usageViewsDictionary = ["view1": self.usageDateLbl,"view2": self.usageQtyLbl,"view3": self.usageUnitCostLbl,"view4": self.usageTotalLbl,"view5": self.checkMarkView] as [String:AnyObject]
        
        let usageViewWidth = (layoutVars.fullWidth - 30) / 2
        let metricsDictionary = ["halfWidth": usageViewWidth] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[view1(65)]-[view2(50)]-[view3(75)]-[view4(100)]-[view5(50)]-5-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: usageViewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[view1(30)]", options: [], metrics: metricsDictionary, views: usageViewsDictionary))
        
    }
    
    
    func setCheck(){
        print("setCheck")
        let blueCheckImg = UIImage(named:"checkMarkBlue.png")
        checkMarkView.image = blueCheckImg
    }
    
    func unSetCheck(){
        print("unSetCheck")
        let grayCheckImg = UIImage(named:"checkMarkGray.png")
        checkMarkView.image = grayCheckImg
    }
    
    
    
    func setStatus(status: String) {
        switch (status) {
        case "1":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "4":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        case "5":
            let statusImg = UIImage(named:"waitingStatus.png")
            statusIcon.image = statusImg
            break;
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }
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
