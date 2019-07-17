//
//  InvoiceItemTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


class InvoiceItemTableViewCell: UITableViewCell {
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var invoiceItem:InvoiceItem2!
    
    
    var nameLbl: UILabel! = UILabel()
    var totalPriceLbl: UILabel! = UILabel()
    var descriptionLbl: UILabel! = UILabel()
   // var totalImagesLbl: UILabel! = UILabel()
    
    //var addItemLbl:Label = Label()
    
    
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
        nameLbl.text = self.invoiceItem.name
        nameLbl.font = self.layoutVars.labelBoldFont
        contentView.addSubview(nameLbl)
        
        totalPriceLbl.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLbl.text = "\(self.invoiceItem.qty) x \(layoutVars.numberAsCurrency(_number: self.invoiceItem.price)) = \(layoutVars.numberAsCurrency(_number:self.invoiceItem.total))"
        totalPriceLbl.textAlignment = .right
        totalPriceLbl.font = self.layoutVars.labelBoldFont
        contentView.addSubview(totalPriceLbl)
        
      
        
        
        descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        descriptionLbl.numberOfLines = 0
        descriptionLbl.text = invoiceItem.custDescription
        contentView.addSubview(descriptionLbl)
        
        /*
        totalImagesLbl.translatesAutoresizingMaskIntoConstraints = false
        if self.invoiceItem.totalImages! == "1"{
            totalImagesLbl.text = "(\(self.invoiceItem.totalImages!) Image)"
        }else{
            totalImagesLbl.text = "(\(self.invoiceItem.totalImages!) Images)"
        }
        
        totalImagesLbl.textAlignment = .center
        contentView.addSubview(totalImagesLbl)
        */
        
        
        let viewsDictionary = ["name":nameLbl,"totalPrice":totalPriceLbl,"description":descriptionLbl] as [String:AnyObject]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name(110)]-[totalPrice]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[description]-|", options: [], metrics: nil, views: viewsDictionary))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[totalImages]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[totalPrice(20)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[description]-|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
