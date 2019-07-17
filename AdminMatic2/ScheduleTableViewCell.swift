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
    var workOrder:WorkOrder2!
    var lead:Lead2?
    var contract:Contract2?
    var invoice:Invoice2?
    var dateLbl: UILabel!
    var customerLbl: UILabel!
    var firstItemLbl: UILabel!
    var chargeLbl: UILabel!
    var priceLbl: UILabel!
    
    var titleLbl :UILabel!
    var IDLbl: UILabel!
    var statusNameLbl: UILabel!
    
    var priorityLbl: UILabel!
    var depthLbl: UILabel!
    var monitoringLbl: UILabel!
    
    var statusIcon: UIImageView!
    
    var remainingQtyLbl: UILabel!
    
    
    
    var profitBarView:UIView!
    var incomeView:UIView!
    var costView:UIView!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
       
    }
    
    
    
    func layoutViews(_scheduleMode:String){
        
        print("layout views _scheduleMode = \(_scheduleMode)")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        dateLbl = UILabel()
        customerLbl = UILabel()
        firstItemLbl = UILabel()
        statusIcon = UIImageView()
        chargeLbl = UILabel()
        priceLbl = UILabel()
        priorityLbl = UILabel()
        depthLbl = UILabel()
        monitoringLbl = UILabel()
        remainingQtyLbl = UILabel()
        titleLbl = UILabel()
        IDLbl = UILabel()
        statusNameLbl = UILabel()
        
        customerLbl.font = layoutVars.smallFont
        firstItemLbl.font = layoutVars.smallFont
        titleLbl.font = layoutVars.smallFont
        
        
        chargeLbl.font = layoutVars.textFieldFont
        chargeLbl.textAlignment = .center
        priceLbl.font = layoutVars.textFieldFont
        IDLbl.font = layoutVars.textFieldFont
        
        remainingQtyLbl.font = layoutVars.textFieldFont
        
        
        //statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        
        
        
        dateLbl.text = ""
        firstItemLbl.text = ""
        customerLbl.text = ""
        chargeLbl.text = ""
        priceLbl.text = ""
        priorityLbl.text = ""
        depthLbl.text = ""
        monitoringLbl.text = ""
        remainingQtyLbl.text = ""
        titleLbl.text = ""
        IDLbl.text = ""
        statusNameLbl.text = ""
        
        setStatus(status: "")
        
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        firstItemLbl.translatesAutoresizingMaskIntoConstraints = false
        customerLbl.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        chargeLbl.translatesAutoresizingMaskIntoConstraints = false
        priceLbl.translatesAutoresizingMaskIntoConstraints = false
        priorityLbl.translatesAutoresizingMaskIntoConstraints = false
        depthLbl.translatesAutoresizingMaskIntoConstraints = false
        monitoringLbl.translatesAutoresizingMaskIntoConstraints = false
        remainingQtyLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        IDLbl.translatesAutoresizingMaskIntoConstraints = false
        statusNameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        print("layout views 2")
            
        self.profitBarView = UIView()
        self.profitBarView.backgroundColor = UIColor.gray
        self.profitBarView.layer.borderColor = layoutVars.borderColor
        self.profitBarView.layer.borderWidth = 1.0
        self.profitBarView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.profitBarView)
        
        
        print("layout views 3")
        let viewsDictionary = ["dateLbl":dateLbl,"customerLbl":customerLbl,"firstItemLbl":firstItemLbl,"statusIcon":statusIcon, "chargeLbl":self.chargeLbl, "profitBarView":self.profitBarView, "priceLbl":self.priceLbl, "priorityLbl":self.priorityLbl, "depthLbl":self.depthLbl, "monitoringLbl":self.monitoringLbl, "remainingQtyLbl":self.remainingQtyLbl, "titleLbl":self.titleLbl,"IDLbl":self.IDLbl,"statusNameLbl":self.statusNameLbl] as [String : Any]
        
        
        print("layout views 4")
            switch (_scheduleMode){
            case "LEAD":
                
                contentView.addSubview(dateLbl)
                contentView.addSubview(customerLbl)
                contentView.addSubview(firstItemLbl)
                //contentView.addSubview(chargeLbl)
                //contentView.addSubview(priceLbl)
                //contentView.addSubview(priorityLbl)
                //contentView.addSubview(depthLbl)
                // contentView.addSubview(monitoringLbl)
                // contentView.addSubview(remainingQtyLbl)
                
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[statusIcon(30)]-[dateLbl]-[firstItemLbl]", options: [], metrics: nil, views: viewsDictionary))
               // contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[chargeLbl(25)]-[profitBarView(100)]-[priceLbl]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[dateLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[firstItemLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                
                break
                
            case "CONTRACT":
                
                contentView.addSubview(dateLbl)
                contentView.addSubview(customerLbl)
                contentView.addSubview(firstItemLbl)
                //contentView.addSubview(chargeLbl)
                //contentView.addSubview(priceLbl)
                //contentView.addSubview(priorityLbl)
                //contentView.addSubview(depthLbl)
                // contentView.addSubview(monitoringLbl)
                // contentView.addSubview(remainingQtyLbl)
                
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[statusIcon(30)]-[dateLbl]-[firstItemLbl]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[dateLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[firstItemLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                
                break
                
                
                case "CUSTOMER":
                    
                    contentView.addSubview(dateLbl)
                    contentView.addSubview(customerLbl)
                    contentView.addSubview(firstItemLbl)
                    contentView.addSubview(chargeLbl)
                    contentView.addSubview(priceLbl)
                    
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[statusIcon(30)]-[dateLbl]-[firstItemLbl]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[chargeLbl(25)]-[profitBarView(100)]-[priceLbl]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[dateLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[firstItemLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[chargeLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[profitBarView(6)]-4-|", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[priceLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                    
                    break
                case "ITEM":
                    print("layout views 4a")
                    contentView.addSubview(dateLbl)
                    contentView.addSubview(customerLbl)
                    contentView.addSubview(firstItemLbl)
                    contentView.addSubview(chargeLbl)
                    contentView.addSubview(priceLbl)
                    contentView.addSubview(remainingQtyLbl)
                   
                    print("layout views 4b")
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[statusIcon(30)]-[customerLbl]-|", options: [], metrics: nil, views: viewsDictionary))
                   contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[remainingQtyLbl]-|", options: [], metrics: nil, views: viewsDictionary))
                    print("layout views 4c")
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerLbl(22)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[remainingQtyLbl(15)]-4-|", options: [], metrics: nil, views: viewsDictionary))
                   print("layout views 4d")
                
                break
                case "SCHEDULE":
                    
                    contentView.addSubview(dateLbl)
                    contentView.addSubview(customerLbl)
                    contentView.addSubview(firstItemLbl)
                    contentView.addSubview(chargeLbl)
                    contentView.addSubview(priceLbl)
                    
                    print("layout views 5")
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[statusIcon(30)]-[customerLbl]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[chargeLbl(25)]-[profitBarView(100)]-[priceLbl]", options: [], metrics: nil, views: viewsDictionary))
                     print("layout views 5a")
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[customerLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[chargeLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                    print("layout views 5b")
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[profitBarView(6)]-4-|", options: [], metrics: nil, views: viewsDictionary))
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[priceLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                
                break
            case "INVOICE":
                
                contentView.addSubview(dateLbl)
                contentView.addSubview(priceLbl)
                contentView.addSubview(IDLbl)
                contentView.addSubview(titleLbl)
                contentView.addSubview(statusNameLbl)
                profitBarView.isHidden = true
                
                priceLbl.font = layoutVars.smallFont
                priceLbl.textAlignment = .right
                dateLbl.textAlignment = .right
                dateLbl.font = layoutVars.textFieldFont
                
                statusNameLbl.font = layoutVars.textFieldFont
                statusNameLbl.textAlignment = .center
                
                print("layout views 5")
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[statusIcon(30)]-8-[titleLbl]-[priceLbl]-|", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-48-[IDLbl(60)][statusNameLbl][dateLbl(80)]-|", options: [], metrics: nil, views: viewsDictionary))
                print("layout views 5a")
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[titleLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[priceLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[IDLbl(15)]-2-|", options: [], metrics: nil, views: viewsDictionary))
                print("layout views 5b")
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLbl(15)]-2-|", options: [], metrics: nil, views: viewsDictionary))
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[statusNameLbl(15)]-2-|", options: [], metrics: nil, views: viewsDictionary))
                
                break
                
                
                
            case "PLOWING":
                print("layout views 6")
                
                contentView.addSubview(dateLbl)
                contentView.addSubview(customerLbl)
                contentView.addSubview(firstItemLbl)
                //contentView.addSubview(chargeLbl)
                //contentView.addSubview(priceLbl)
                contentView.addSubview(priorityLbl)
                contentView.addSubview(depthLbl)
                contentView.addSubview(monitoringLbl)
                //contentView.addSubview(remainingQtyLbl)
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[statusIcon(30)]-[customerLbl]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[priorityLbl(100)]-[depthLbl(30)]-[monitoringLbl(90)]-[profitBarView(100)]", options: [], metrics: nil, views: viewsDictionary))
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[customerLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[priorityLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[depthLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[monitoringLbl(15)]|", options: [], metrics: nil, views: viewsDictionary))
                 contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[profitBarView(6)]-4-|", options: [], metrics: nil, views: viewsDictionary))
                
                break
            default:
                print("cell type not set")
                
            }
           
        
       
        
       
        print("layout views 7")
        
        
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
    
    func setStatus(status: String, type:String = "WORKORDER") {
        switch (type) {
        case "CONTRACT":
            switch (status) {
            case "0":
                let statusImg = UIImage(named:"unDoneStatus.png")
                statusIcon.image = statusImg
                break;
            case "1":
                let statusImg = UIImage(named:"inProgressStatus.png")
                statusIcon.image = statusImg
                break;
            case "2":
                let statusImg = UIImage(named:"acceptedStatus.png")
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
            case "6":
                let statusImg = UIImage(named:"cancelStatus.png")
                statusIcon.image = statusImg
                break;
            default:
                let statusImg = UIImage(named:"inProgressStatus.png")
                statusIcon.image = statusImg
                break;
            }
            break
        case "INVOICE":
            
            
           
            
                switch (status) {
                case "0":
                    let statusImg = UIImage(named:"syncIcon.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Syncing to QuickBooks"
                    statusNameLbl.textColor = UIColor.red
                    break;
                case "1":
                    let statusImg = UIImage(named:"pendingIcon.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Invoice Pending"
                    statusNameLbl.textColor = UIColor.red
                    break;
                case "2":
                    let statusImg = UIImage(named:"inProgressStatus.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Invoice Final"
                    break;
                case "3":
                    let statusImg = UIImage(named:"acceptedStatus.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Invoice Emailed/Printed"
                    break;
                case "4":
                    let statusImg = UIImage(named:"doneStatus.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Invoice Paid"
                    break;
                case "5":
                    let statusImg = UIImage(named:"cancelStatus.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Invoice Voided"
                    statusNameLbl.textColor = UIColor.red
                    break;
                    
                default:
                    let statusImg = UIImage(named:"unDoneStatus.png")
                    statusIcon.image = statusImg
                    statusNameLbl.text = "Syncing to QuickBooks"
                    statusNameLbl.textColor = UIColor.red
                    break;
                }
            
            break
        default:
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
