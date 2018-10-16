//
//  EquipmentTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 12/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
//import Nuke

class EquipmentTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var equipment:Equipment!
    //var dateLbl: UILabel!
    
    var equipmentImageView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    
    var nameLbl: UILabel!
    var typeLbl: UILabel!
    var typeValueLbl: UILabel!
    var crewLbl: UILabel!
    
    var statusIcon: UIImageView!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        self.equipmentImageView.layer.cornerRadius = 5.0
        self.equipmentImageView.layer.borderWidth = 1
        self.equipmentImageView.layer.borderColor = layoutVars.borderColor
        self.equipmentImageView.clipsToBounds = true
        self.equipmentImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.equipmentImageView)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        equipmentImageView.addSubview(activityView)
        
        
        
        
        nameLbl = UILabel()
        nameLbl.font = layoutVars.smallBoldFont
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
        typeLbl = UILabel()
        typeLbl.text = "Type:"
        typeLbl.font = layoutVars.extraSmallFont
        typeLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLbl)
        
        typeValueLbl = UILabel()
        typeValueLbl.font = layoutVars.extraSmallFont
        typeValueLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeValueLbl)
        
        crewLbl = UILabel()
        crewLbl.font = layoutVars.extraSmallFont
        crewLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(crewLbl)
        
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        
    }
    
    
    func layoutViews(){
        
        
        
        
        nameLbl.text = ""
        typeValueLbl.text = ""
        crewLbl.text = ""
        
        
        
        //nameLbl.text = equipment.name
        //typeLbl.text = equipment.type
        //typeLbl.text = equipment.type
        
        //if (cell.lead)
        
        
        
        
        let viewsDictionary = ["pic":equipmentImageView,"name":nameLbl,"type":typeLbl,"typeValue":typeValueLbl,"crew":crewLbl,"status":statusIcon] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pic(50)]-[name]-[status(30)]-|", options: [], metrics: nil, views: viewsDictionary))
        
       
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pic(50)]-[type(36)][typeValue]-[crew(80)]-[status(30)]-|", options: [], metrics: nil, views: viewsDictionary))
       
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[status(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[name(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[type(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeValue(30)]|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[crew(30)]|", options: [], metrics: nil, views: viewsDictionary))
        
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        equipmentImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        equipmentImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
        
    }
    
    func setImageUrl(_url:String){
        let imgURL:URL = URL(string: _url)!
        /*
        Nuke.loadImage(with: imgURL, into: self.equipmentImageView){
            //print("nuke loadImage")
            self.equipmentImageView.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
        }
 */
    }
    
    
    
    
    
    func setStatus(status: String) {
        print("set status status = \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"onlineIcon.png")
            statusIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"needsRepairIcon.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"brokenIcon.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"winterizedIcon.png")
            statusIcon.image = statusImg
            break;
        default:
            //let statusImg = UIImage(named:"onlineIcon.png")
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}


