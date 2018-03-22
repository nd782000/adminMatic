//
//  DepartmentTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//





/*
 
 
import Foundation
import UIKit
import Nuke

class DepartmentTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    var department:Department!
    //var dateLbl: UILabel!
    
    var employeeImageView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    
    var nameLbl: UILabel!
    var depHeadLbl: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        self.employeeImageView.layer.cornerRadius = 5.0
        self.employeeImageView.layer.borderWidth = 1
        self.employeeImageView.layer.borderColor = layoutVars.borderColor
        self.employeeImageView.clipsToBounds = true
        self.employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.employeeImageView)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        employeeImageView.addSubview(activityView)
        
        
        
        
        nameLbl = UILabel()
        nameLbl.font = layoutVars.smallBoldFont
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
        depHeadLbl = UILabel()
        depHeadLbl.font = layoutVars.extraSmallFont
        depHeadLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(depHeadLbl)
        
        
        
        
    }
    
    
    func layoutViews(){
        
        nameLbl.text = ""
        depHeadLbl.text = ""
        
    
        let viewsDictionary = ["pic":employeeImageView,"name":nameLbl,"depHead":depHeadLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pic(50)]-[name]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pic(50)]-24-[depHead]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[name(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[depHead(30)]|", options: [], metrics: nil, views: viewsDictionary))
        
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
        
    }
    
    func setImageUrl(_url:String){
        let imgURL:URL = URL(string: _url)!
        Nuke.loadImage(with: imgURL, into: self.employeeImageView){
            //print("nuke loadImage")
            self.employeeImageView.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
        }
    }
    
    
    
    
    
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
 
 
*/




