//
//  LicenseTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/29/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation
import UIKit

class LicenseTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var license:License!
    var badgeIcon: UIImageView!
    var nameLbl: UILabel!
    var numberLbl: UILabel!
    var expirationLbl: UILabel!
    var expirationValueLbl: UILabel!
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func layoutNoLicenseView(){
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        badgeIcon = UIImageView()
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.backgroundColor = UIColor.clear
        badgeIcon.contentMode = .scaleAspectFill
        contentView.addSubview(badgeIcon)
        
        nameLbl = UILabel()
        nameLbl.text = "No Recorded Licenses"
        nameLbl.font = layoutVars.smallBoldFont
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
        setStatus(status: "0")
        
        
        let viewsDictionary = ["badge":badgeIcon,"name":nameLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[badge(40)]-[name]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[badge(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[name(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    func layoutViews(_license:License){
        self.license = _license
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        badgeIcon = UIImageView()
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.backgroundColor = UIColor.clear
        badgeIcon.contentMode = .scaleAspectFill
        contentView.addSubview(badgeIcon)
        
        nameLbl = UILabel()
        nameLbl.font = layoutVars.smallBoldFont
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
       
        numberLbl = UILabel()
        numberLbl.font = layoutVars.extraSmallFont
        numberLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(numberLbl)
        
        
        expirationLbl = UILabel()
        expirationLbl.font = layoutVars.extraSmallFont
        expirationLbl.textAlignment = .right
        expirationLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expirationLbl)
        
        expirationValueLbl = UILabel()
        expirationValueLbl.font = layoutVars.extraSmallFont
        print("license.status = \(String(describing: license.status))")
        if license.status == "0"{
            print("text color should be red")
            expirationValueLbl.textColor = UIColor.red
        }else if license.status == "1"{
            expirationValueLbl.textColor = UIColor.orange
        }
        //numberLbl.textColor = UIColor.red
        expirationValueLbl.textAlignment = .right
        expirationValueLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expirationValueLbl)
        
        
        
        
        nameLbl.text = self.license.name!
        numberLbl.text = "Lic.# \(self.license.number!)"
        expirationLbl.text = "Expires:"
        expirationValueLbl.text = self.license.expiration!
        
        setStatus(status: self.license.status)
        
        
        
        
        
        
        
        
       
        
        let viewsDictionary = ["badge":badgeIcon,"name":nameLbl,"number":numberLbl,"expirationLbl":expirationLbl,"expirationValue":expirationValueLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[badge(40)]-[name]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[badge(40)]-[number(120)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[expirationLbl]-[expirationValue]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[badge(40)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[name(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[number(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[expirationLbl(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[expirationValue(30)]|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    func setStatus(status: String) {
        print("set status \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"badgeStarGrayIcon.png")
            badgeIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"badgeStarIcon.png")
            badgeIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"badgeStarIcon.png")
            badgeIcon.image = statusImg
            break;
        
            
        default:
            let statusImg = UIImage(named:"badgeStarIcon.png")
            badgeIcon.image = statusImg
            break;
        }
    }
    
    
   
    
}

