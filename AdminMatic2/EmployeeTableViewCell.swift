//
//  EmployeeTableViewCell.swift
//  Atlantic_Blank
//
//  Created by Nicholas Digiando on 8/9/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import Foundation
import UIKit


class EmployeeTableViewCell: UITableViewCell {
    
    
    var employee:Employee!
    
   
    var nameLbl: UILabel! = UILabel()
    
   
    var employeeImageView:UIImageView = UIImageView()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.employeeImageView.layer.cornerRadius = 10.0
        self.employeeImageView.layer.borderWidth = 1
        self.employeeImageView.layer.borderColor = layoutVars.borderColor
        self.employeeImageView.clipsToBounds = true
        self.employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.employeeImageView)
        
               
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLbl)
       
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl] as [String : Any]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[name]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
    }
    
    

    func setImageUrl(_url:String){
        
        
        let url = URL(string: _url)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.employeeImageView.image = UIImage(data: data!)
            }
        }
    }
        

  
    
}
