//
//  ContractTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 4/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation
import UIKit

class ContractTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var contract:Contract2!
    var statusIcon: UIImageView!
    var titleLbl: UILabel!
    var descriptionLbl: UILabel!
    //var name: String!
    var daysAgedLbl: UILabel!
    
    
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
        
        descriptionLbl = UILabel()
        descriptionLbl.font = layoutVars.extraSmallFont
        descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLbl)
        
        daysAgedLbl = UILabel()
        daysAgedLbl.font = layoutVars.extraSmallFont
        daysAgedLbl.textColor = UIColor.red
        daysAgedLbl.textAlignment = .right
        daysAgedLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysAgedLbl)
        
        
       
        
        
        titleLbl.text = ""
        setStatus(status: contract.status)
        
        
        
        //titleLbl.text = self.name!
        
        titleLbl.text = self.contract.custNameAndID!
        
        descriptionLbl.text = contract.title
        
        if contract.daysAged! == "0"{
            daysAgedLbl.text = "Today"
        }else if contract.daysAged! == "1"{
            daysAgedLbl.text = "Yesterday"
        }else{
            daysAgedLbl.text = "\(contract.daysAged!) Days"
        }
        
        
        
        
        let viewsDictionary = ["status":statusIcon,"title":titleLbl,"description":descriptionLbl,"daysAged":daysAgedLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[title]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[description]-[daysAged(65)]-|", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title(30)][description(20)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title(30)][daysAged(20)]", options: [], metrics: nil, views: viewsDictionary))
       
    }
    
    
    /*
    func setStatus(status: String) {
        print("set status \(status)")
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
            let statusImg = UIImage(named:"doneStatus.png")
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
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    */
    
    func setStatus(status: String) {
        print("set status \(status)")
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
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

