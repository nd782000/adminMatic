//
//  FieldNoteTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit

class FieldNoteTableViewCell: UITableViewCell {
    
    var fieldNote:FieldNote!
    var noteLbl: UILabel! = UILabel()
    
    var picImageView:UIImageView = UIImageView()
    
    
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
        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        let viewsDictionary = ["pic":self.picImageView,"note":noteLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[note]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
    }
    
    func setImageUrl(_url:String?){
        
        if(_url == nil){
            setBlankImage()
        }else{
            let url = URL(string: _url!)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.picImageView.image = UIImage(data: data!)
                }
            }
            
        }
        
    }
    
    func setBlankImage(){
        self.picImageView.image = layoutVars.defaultImage
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
