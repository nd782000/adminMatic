//
//  ScheduleTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/4/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit

class ScheduleTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var workOrder:WorkOrder!
    var dateLbl: UILabel!
    var customerLbl: UILabel!
    var firstItemLbl: UILabel!
    var chargeLbl: UILabel!
    var priceLbl: UILabel!
    
    var statusIcon: UIImageView!
    
    
    var profitBarView:UIView!
    var incomeView:UIView!
    var costView:UIView!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        dateLbl = UILabel()
        customerLbl = UILabel()
        firstItemLbl = UILabel()
        statusIcon = UIImageView()
        chargeLbl = UILabel()
        priceLbl = UILabel()
        
        customerLbl.font = layoutVars.smallFont
        firstItemLbl.font = layoutVars.smallFont
        
        chargeLbl.font = layoutVars.textFieldFont
        chargeLbl.textAlignment = .center
        priceLbl.font = layoutVars.textFieldFont
        
              
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        contentView.addSubview(dateLbl)
        contentView.addSubview(customerLbl)
        contentView.addSubview(firstItemLbl)
        contentView.addSubview(chargeLbl)
        contentView.addSubview(priceLbl)
       
    }
    
    
    
    func layoutViews(_scheduleMode:String){
        dateLbl.text = ""
        firstItemLbl.text = ""
        customerLbl.text = ""
         chargeLbl.text = ""
         priceLbl.text = ""
        
        setStatus(status: "")
        
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        firstItemLbl.translatesAutoresizingMaskIntoConstraints = false
        customerLbl.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        chargeLbl.translatesAutoresizingMaskIntoConstraints = false
        priceLbl.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.profitBarView = UIView()
        self.profitBarView.backgroundColor = UIColor.gray
        self.profitBarView.layer.borderColor = layoutVars.borderColor
        self.profitBarView.layer.borderWidth = 1.0
        self.profitBarView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.profitBarView)
        
        let viewsDictionary = ["view1":dateLbl,"view2":customerLbl,"view3":firstItemLbl,"view4":statusIcon, "view6":self.chargeLbl, "view7":self.profitBarView, "view8":self.priceLbl] as [String : Any]
        
        
        if (_scheduleMode == "CUSTOMER"){
            
           
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[view4(30)]-[view1]-[view3]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[view6(25)]-[view7(100)]-[view8]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[view1(30)]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[view3(30)]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view4(30)]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view6(15)]|", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view7(6)]-4-|", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view8(15)]|", options: [], metrics: nil, views: viewsDictionary))
        }else{
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[view4(30)]-[view2]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[view6(25)]-[view7(100)]-[view8]", options: [], metrics: nil, views: viewsDictionary))
           
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[view2(30)]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[view4(30)]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view6(15)]|", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view7(6)]-4-|", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view8(15)]|", options: [], metrics: nil, views: viewsDictionary))
        }
        
        incomeView = UIView()
        incomeView.layer.cornerRadius = 3
        incomeView.layer.masksToBounds = true
        incomeView.backgroundColor = layoutVars.buttonColor1
        incomeView.translatesAutoresizingMaskIntoConstraints = false
        self.profitBarView.addSubview(self.incomeView)
        
        costView = UIView()
        costView.layer.cornerRadius = 3
        costView.layer.masksToBounds = true
        costView.backgroundColor = UIColor.red
        costView.translatesAutoresizingMaskIntoConstraints = false
        self.profitBarView.addSubview(self.costView)
        
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
    
    
    func setProfitBar(_price:String, _cost:String){
        //Profit Info
        //print("setProfitBar")
        //print("_price = \(_price)")
        //print("_cost \(_cost)")
        // profit bar vars
        let profitBarWidth = Float(100.00)
        
        
        let income = Float(_price)
        let cost = Float(_cost)
        
        //print("income = \(income)")
         //print("cost = \(cost)")
        
       // print("101")
        var scaleFactor = Float(0.00)
        var costWidth = Float(0.00)
        
        //print("102")
        if(Float(income!) > 0.0){
            //print("greater")
            scaleFactor = Float(Float(profitBarWidth) / Float(income!))
            costWidth = cost! * scaleFactor
            if(costWidth > profitBarWidth){
                costWidth = profitBarWidth
            }
        }else{
            costWidth = profitBarWidth
        }
        
        
        let costBarOffset = profitBarWidth - costWidth
        
        //print("income = \(income)")
        //print("cost = \(cost)")
        //print("scaleFactor = \(scaleFactor)")
        //print("costWidth = \(costWidth)")
        //print("profitBarWidth = \(profitBarWidth)")
        //print("costBarOffset = \(costBarOffset)")
        
        
        let profitBarViewsDictionary = [
            
            "incomeView":self.incomeView,
            "costView":self.costView
            ]  as [String:AnyObject]
        
        let profitBarSizeVals = ["profitBarWidth":profitBarWidth as AnyObject,"costWidth":costWidth as AnyObject,"costBarOffset":costBarOffset as AnyObject]  as [String:AnyObject]
        
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[incomeView(profitBarWidth)]|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[costView(costWidth)]-costBarOffset-|", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[incomeView(6)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
        self.profitBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[costView(6)]", options: [], metrics: profitBarSizeVals, views: profitBarViewsDictionary))
    }
   
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
