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
    var lead:Lead2!
    //var name: String!
    var statusIcon: UIImageView!
    var titleLbl: UILabel!
    var urgentLbl: UILabel!
    var descriptionLbl: UILabel!
    var daysAgedLbl: UILabel!
    
     
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
    func layoutViews(){
        
        
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
        
        urgentLbl = UILabel()
        urgentLbl.font = layoutVars.extraSmallFont
        urgentLbl.textColor = UIColor.red
        urgentLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(urgentLbl)
        
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
        urgentLbl.text = ""
        descriptionLbl.text = ""
        daysAgedLbl.text = ""
        setStatus(status: lead.statusID)
        
        
        
        
        
       
        
        
        titleLbl.text = self.lead.custNameAndID!
        
        //titleLbl.text = self.lead.custNameAndZone
        
        
        descriptionLbl.text = lead.description
        
        
        switch lead.daysAged! {
        case "0":
            daysAgedLbl.text = "Today"
            break
        case "1":
            daysAgedLbl.text = "Yesterday"
            break
        
        default:
            daysAgedLbl.text = "\(lead.daysAged!) Days"
        }
       
        
        let viewsDictionary = ["status":statusIcon,"title":titleLbl,"urgent":urgentLbl,"description":descriptionLbl,"daysAged":daysAgedLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[title]-|", options: [], metrics: nil, views: viewsDictionary))
        
        if(lead.urgent == "1"){
            urgentLbl.text = "\u{22C6}URGENT\u{22C6}"
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[urgent(80)]-[description]-[daysAged(65)]-|", options: [], metrics: nil, views: viewsDictionary))

        }else{
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[status(40)]-[description]-[daysAged(65)]-|", options: [], metrics: nil, views: viewsDictionary))
        }
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[urgent(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[description(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[daysAged(30)]|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    func setStatus(status: String) {
        print("set status \(status)")
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

