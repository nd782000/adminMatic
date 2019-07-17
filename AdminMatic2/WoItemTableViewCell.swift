//
//  WoItemTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

 
class WoItemTableViewCell: UITableViewCell {
    
   // var woItem:WoItem!
    var woItem:WoItem2!
    var typeLbl:DetailLabel! = DetailLabel()
    var priceLbl:DetailLabel! = DetailLabel()
    var woItemJSON:JSON!
    
    
    
    var statusIcon: UIImageView!
    
    var nameLbl: UILabel! = UILabel()
    var estLbl: UILabel! = UILabel()
    var actLbl: UILabel! = UILabel()
    
    var addItemLbl:Label = Label()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       
    }
    func layoutViews(){
        
        print("layoutViews")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        self.selectionStyle = .none
        
        
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        estLbl.translatesAutoresizingMaskIntoConstraints = false
        actLbl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLbl)
        contentView.addSubview(estLbl)
        contentView.addSubview(actLbl)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["status":statusIcon,"name":nameLbl,"est":estLbl,"act":actLbl] as [String:AnyObject]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[status(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-7-[status(30)]-15-[name]-5-[est(50)]-10-[act(50)]-5-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        
        
        
        
    }
    
    func layoutAddBtn(){
        
        print("layoutAddBtn")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // self.selectedImageView.image = nil
        
        self.addItemLbl.text = "Add Item"
        self.addItemLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        //self.addItemLbl.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        self.addItemLbl.backgroundColor = UIColor.clear

        self.addItemLbl.layer.cornerRadius = 4.0
        self.addItemLbl.clipsToBounds = true
        self.addItemLbl.textAlignment = .center
        contentView.addSubview(self.addItemLbl)
        
        
        let viewsDictionary = ["addBtn":self.addItemLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
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
