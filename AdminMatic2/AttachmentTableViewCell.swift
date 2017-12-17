//
//  AttachmentTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Nuke

class AttachmentTableViewCell: UITableViewCell {
    
    var attachment:Attachment!
    var noteLbl: UILabel! = UILabel()
    var imageQtyLbl: UILabel! = UILabel()
    
    var picImageView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.picImageView.layer.cornerRadius = 10.0
        self.picImageView.layer.borderWidth = 1
        self.picImageView.layer.borderColor = layoutVars.borderColor
        self.picImageView.clipsToBounds = true
        self.picImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.picImageView)
        
        noteLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noteLbl)
        
        imageQtyLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageQtyLbl)
        
        
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        //activityView.center = CGPoint(x: self.picImageView.frame.size.width, y: self.picImageView.frame.size.height)
        
        activityView.translatesAutoresizingMaskIntoConstraints = false

        picImageView.addSubview(activityView)
        
        
        
        

        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        let viewsDictionary = ["pic":self.picImageView,"note":noteLbl, "imageQty":imageQtyLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[note(20)]-[imageQty(20)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[note]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[imageQty]-|", options: [], metrics: nil, views: viewsDictionary))
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        picImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        picImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
    }
    
    
    func setImageUrl(_url:String){
        
        let imgURL:URL = URL(string: _url)!
        
        print("set imgURL = \(imgURL)")
        
        
        
        Nuke.loadImage(with: imgURL, into: self.picImageView){ 
            //print("nuke loadImage")
            self.picImageView.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
        }
    }
    
    func setBlankImage(){
        self.picImageView.image = layoutVars.defaultImage
        self.activityView.stopAnimating()
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
