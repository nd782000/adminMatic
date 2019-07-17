//
//  ImageCollectionViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 2/14/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
     
    var textLabel: UILabel!
    var imageView: UIImageView!
    var layoutVars: LayoutVars = LayoutVars()
    var image:Image2!
    var activityView:UIActivityIndicatorView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //print("imageCell init")
        
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        
        imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.backgroundColor = UIColor.darkGray
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //print("imageCell init 1")
        textLabel = UILabel()
        textLabel.font = UIFont(name: "Helvetica Neue", size: 14)!
        textLabel.layer.backgroundColor = UIColor(hex: 0x005100, op: 0.5).cgColor
        textLabel.textColor = UIColor.white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.textAlignment = .left
        contentView.addSubview(textLabel)
        
       // print("imageCell init 2")
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.contentView.frame.size.width / 2, y: self.contentView.frame.size.height / 2)
        contentView.addSubview(activityView)

        let viewsDictionary = ["image":imageView,"label":textLabel] as [String : Any]
        let viewsConstraint_H:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|[image]|", options: [], metrics: nil, views: viewsDictionary)
        let viewsConstraint_H2:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: viewsDictionary)
        let viewsConstraint_V:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]|", options: [], metrics: nil, views: viewsDictionary)
        let viewsConstraint_V2:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:[label(30)]|", options: [], metrics: nil, views: viewsDictionary)
        
        contentView.addConstraints(viewsConstraint_H)
        contentView.addConstraints(viewsConstraint_H2)
        contentView.addConstraints(viewsConstraint_V)
        contentView.addConstraints(viewsConstraint_V2)
        
       // print("imageCell init 3")
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



