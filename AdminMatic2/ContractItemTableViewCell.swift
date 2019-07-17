//
//  ContractItemTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 4/17/18.
//  Copyright © 2018 Nick. All rights reserved.
//



import Foundation
import UIKit
//import SwiftyJSON
 

class ContractItemTableViewCell: UITableViewCell {
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var contractItem:ContractItem2!

    
    var nameLbl: UILabel! = UILabel()
    var totalPriceLbl: UILabel! = UILabel()
    var descriptionLbl: UILabel! = UILabel()
    var totalImagesLbl: UILabel! = UILabel()
    
    var addItemLbl:Label = Label()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    func layoutViews(){
        
        print("layoutCellViews")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.text = self.contractItem.name
        nameLbl.font = self.layoutVars.labelBoldFont
        contentView.addSubview(nameLbl)
        
        totalPriceLbl.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLbl.text = "\(self.contractItem.qty) x \(layoutVars.numberAsCurrency(_number: self.contractItem.price!)) = \(layoutVars.numberAsCurrency(_number:self.contractItem.total!))"
        totalPriceLbl.textAlignment = .right
        totalPriceLbl.font = self.layoutVars.labelBoldFont
        contentView.addSubview(totalPriceLbl)
        
        var taskDescription:String = ""
        
        let taskCount = self.contractItem.tasks.count
        if taskCount == 0{
            taskDescription = "No Tasks or Description"
        }else{
            for i in 0 ..< taskCount {
                if i == taskCount - 1{
                    taskDescription += "-\(self.contractItem.tasks[i].taskDescription!)"
                }else{
                    taskDescription += "-\(self.contractItem.tasks[i].taskDescription!)\n"
                }
                
            }
        }
        
        
        
        
        
        descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        descriptionLbl.numberOfLines = 0
        descriptionLbl.text = taskDescription
        contentView.addSubview(descriptionLbl)
        
        
        totalImagesLbl.translatesAutoresizingMaskIntoConstraints = false
        if self.contractItem.totalImages! == "1"{
            totalImagesLbl.text = "(\(self.contractItem.totalImages!) Image)"
        }else{
            totalImagesLbl.text = "(\(self.contractItem.totalImages!) Images)"
        }
        
        totalImagesLbl.textAlignment = .center
        contentView.addSubview(totalImagesLbl)
        
        
        let viewsDictionary = ["name":nameLbl,"totalPrice":totalPriceLbl,"description":descriptionLbl,"totalImages":totalImagesLbl] as [String:AnyObject]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name(110)]-[totalPrice]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[description]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[totalImages]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[totalPrice(20)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[description][totalImages(20)]-|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    func layoutAddBtn(){
        
        print("layoutAddBtn")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.addItemLbl.text = "+ Add Item"
        self.addItemLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.addItemLbl.backgroundColor = UIColor.clear
        
        self.addItemLbl.layer.cornerRadius = 4.0
        self.addItemLbl.clipsToBounds = true
        self.addItemLbl.textAlignment = .center
        self.addItemLbl.font = layoutVars.labelBoldFont
        contentView.addSubview(self.addItemLbl)
        
        
        let viewsDictionary = ["addBtn":self.addItemLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
   
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
