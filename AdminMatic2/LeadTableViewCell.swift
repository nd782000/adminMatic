//
//  LeadTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 11/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit

class LeadTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var lead:Lead!
    //var dateLbl: UILabel!
    var statusIcon: UIImageView!
    var titleLbl: UILabel!
    var urgentLbl: UILabel!
    var descriptionLbl: UILabel!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        
        urgentLbl = UILabel()
        urgentLbl.font = layoutVars.extraSmallFont
        urgentLbl.textColor = UIColor.red
        urgentLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(urgentLbl)
        
        descriptionLbl = UILabel()
        descriptionLbl.font = layoutVars.extraSmallFont
        descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLbl)
        
        
    }
    
    
    func layoutViews(_scheduleMode:String){
        titleLbl.text = ""
        urgentLbl.text = ""
        descriptionLbl.text = ""
        setStatus(status: "")
        
        
        titleLbl.text = "Lead #\(lead.ID!) for \(lead.customerName!)"
        
         descriptionLbl.text = lead.description
        
        //if (cell.lead)
       
        
        
        
        let viewsDictionary = ["status":statusIcon,"title":titleLbl,"urgent":urgentLbl,"description":descriptionLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[title]-|", options: [], metrics: nil, views: viewsDictionary))
        
        if(lead.urgent == "1"){
            urgentLbl.text = "\u{22C6}URGENT\u{22C6}"
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[urgent(80)]-[description]-|", options: [], metrics: nil, views: viewsDictionary))

        }else{
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[description]-|", options: [], metrics: nil, views: viewsDictionary))
        }
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[urgent(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[description(30)]|", options: [], metrics: nil, views: viewsDictionary))
        
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
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

