//
//  HomeCollectionViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/6/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
     
    var textLabel: UILabel!
    var imageView: UIImageView!
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 20, width: frame.size.width, height: frame.size.height*1/2))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        contentView.addSubview(imageView)
        textLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height+20, width: frame.size.width, height: frame.size.height/3))
        textLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        textLabel.textColor = UIColor(hex: 0x005100, op: 1.0)
        
        textLabel.textAlignment = .center
        contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    }

    

