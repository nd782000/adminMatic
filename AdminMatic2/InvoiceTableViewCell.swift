//
//  InvoiceTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/27/19.
//  Copyright © 2019 Nick. All rights reserved.
//


/*
 Status
 0 = syncing to QB
 1 = pending
 2 = final
 3 = sent (printed/emailed)
 4 = paid
 5 = void
 */



import Foundation
import UIKit

class InvoiceTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var invoice:Invoice2!
    var statusIcon: UIImageView!
    var titleLbl: UILabel!
    var totalLbl: UILabel!
    var dateLbl: UILabel!
    var IDLbl: UILabel!
    var statusNameLbl: UILabel!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
    func layoutViews(){
        
        //print("cell contract total = \(self.contract.total)")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        titleLbl = UILabel()
        titleLbl.font = layoutVars.smallBoldFont
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLbl)
        
        totalLbl = UILabel()
        totalLbl.font = layoutVars.smallBoldFont
        totalLbl.textAlignment = .right
        totalLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalLbl)
        
        dateLbl = UILabel()
        dateLbl.font = layoutVars.extraSmallFont
        dateLbl.textAlignment = .right
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLbl)
        
        IDLbl = UILabel()
        IDLbl.font = layoutVars.extraSmallFont
        IDLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(IDLbl)
        
        statusNameLbl = UILabel()
        statusNameLbl.font = layoutVars.extraSmallFont
        statusNameLbl.textAlignment = .center
        statusNameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusNameLbl)
        
        
        
        
       
        
        
        
        let viewsDictionary = ["status":statusIcon,"title":titleLbl,"total":totalLbl,"ID":IDLbl,"statusName":statusNameLbl,"date":dateLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[status(40)]-[title]-[total(90)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[ID(60)][statusName][date(80)]-|", options: [], metrics: nil, views: viewsDictionary))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[date(80)]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title(30)][ID(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[total(30)][statusName(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[total(30)][date(20)]", options: [], metrics: nil, views: viewsDictionary))
        
       
        
    }
    
    
   
    
    func setStatus(status: String) {
        print("set status \(status)")
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
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

