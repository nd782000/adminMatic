//
//  BugTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 3/27/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit

class BugTableViewCell: UITableViewCell {
    
    var bug:Bug!
    var iconView:UIImageView = UIImageView()
    var titleLbl: Label! = Label()
    var statusIcon: UIImageView!

    //var statusLbl: DetailLabel! = DetailLabel()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.iconView.clipsToBounds = true
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.iconView.image = UIImage(named:"bugIcon.png")
        self.contentView.addSubview(self.iconView)
        
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLbl)
        
        
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        statusIcon.clipsToBounds = true
        contentView.addSubview(statusIcon)
        
        /*
        statusLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLbl)
 */
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["icon":self.iconView,"title":titleLbl,"status":statusIcon] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[icon(30)]-[title]-[status(30)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[icon(30)]", options: [], metrics: nil, views: viewsDictionary))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[title(30)]", options: [], metrics: nil, views: viewsDictionary))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(30)]", options: [], metrics: nil, views: viewsDictionary))
       
    }
    
    
    func setStatus(status: String) {
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
            let statusImg = UIImage(named:"cancelStatus.png")
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
        
    }
}
