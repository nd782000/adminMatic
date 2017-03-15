//
//  TaskTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit

class TaskTableViewCell: UITableViewCell {
    
    var task:Task!
    var thumbView:UIImageView = UIImageView()
    var taskLbl: Label! = Label()
    
    var statusIcon: UIImageView!

    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.thumbView.clipsToBounds = true
        self.thumbView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.thumbView)
       
        
        taskLbl.translatesAutoresizingMaskIntoConstraints = false
        taskLbl.numberOfLines = 0;
        
        contentView.addSubview(taskLbl)
        
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["thumbs":self.thumbView,"task":taskLbl,"status":statusIcon] as [String:AnyObject]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth - 90] as [String:Any]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[thumbs(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[task(>=50)]-|", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[thumbs(50)]-5-[task]-[status(40)]-15-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setImageUrl(_url:String?){
        print("set Task ImageUrl")
        print("url = \(_url)")
        
        if(_url == nil){
            setBlankImage()
        }else{
            
            let url = URL(string: _url!)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.thumbView.image = UIImage(data: data!)
                }
            }
        }
    }
    
    func setBlankImage(){
        self.thumbView.image = layoutVars.defaultImage
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
    
}
