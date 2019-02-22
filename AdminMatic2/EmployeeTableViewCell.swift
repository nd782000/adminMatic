//
//  EmployeeTableViewCell.swift
//  Atlantic_Blank
//
//  Created by Nicholas Digiando on 8/9/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import Foundation
import UIKit
import Alamofire



class EmployeeTableViewCell: UITableViewCell {
    
    var employee:Employee!
    var nameLbl: UILabel! = UILabel()
    var phoneLbl: UILabel! = UILabel()
    var employeeImageView:UIImageView = UIImageView()
    
    var activityView:UIActivityIndicatorView!
    var layoutVars:LayoutVars = LayoutVars()
    
    var badgeCount:Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       
        
    }
    
    func layoutViews(){
        print("layoutViews")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        phoneLbl.isHidden = true
        
        
        self.selectionStyle = .none
        self.employeeImageView.layer.cornerRadius = 5.0
        self.employeeImageView.layer.borderWidth = 1
        self.employeeImageView.layer.borderColor = layoutVars.borderColor
        self.employeeImageView.clipsToBounds = true
        self.employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.employeeImageView)
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.font = layoutVars.smallBoldFont
        contentView.addSubview(nameLbl)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        //activityView.center = CGPoint(x: self.employeeImageView.frame.size.width / 2, y: self.employeeImageView.frame.size.height / 2)
        employeeImageView.addSubview(activityView)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[name]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
    }
    
    func setImageUrl(_url:String){
        
        
        
        Alamofire.request(_url).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                //cell.imageView.image = image
                //cell.image = self.imageArray[indexPath.row]
                //self.employeeImage.image = image
                self.employeeImageView.image = image
                
                self.activityView.stopAnimating()
                
                
            }
        }
        
        
        
        
        
        
        
        
        
        
        
    }
    
    func addBadge(_active:Bool){
        let badgeXPos:CGFloat = CGFloat(70 + (self.badgeCount * 25))
        let badgeView:UIImageView = UIImageView(frame: CGRect(x: badgeXPos, y: 36.0, width: 20.0, height: 20.0))
        
        badgeView.clipsToBounds = true
        self.contentView.addSubview(badgeView)
        if _active{
            badgeView.image = UIImage(named: "badgeStarIcon")
        }else{
            badgeView.image = UIImage(named: "badgeStarGrayIcon")
        }
        self.badgeCount += 1
    }
    
    func addNoLicenseText(){
       // let badgeXPos:CGFloat = CGFloat(70 + (self.badgeCount * 25))
        
        let noLicenseLbl:Label = Label(frame: CGRect(x: 70, y: 36.0, width: 200.0, height: 20.0))
        noLicenseLbl.translatesAutoresizingMaskIntoConstraints = true
        //let badgeView:UIImageView = UIImageView(frame: CGRect(x: badgeXPos, y: 36.0, width: 20.0, height: 20.0))
        noLicenseLbl.font = layoutVars.extraSmallFont
        noLicenseLbl.text = "No Licenses Recorded"
        self.contentView.addSubview(noLicenseLbl)
        
    }
    
    func setPhone(){
        print("set phone")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //phoneLbl.isHidden = true
        
        
        self.selectionStyle = .none
        self.employeeImageView.layer.cornerRadius = 5.0
        self.employeeImageView.layer.borderWidth = 1
        self.employeeImageView.layer.borderColor = layoutVars.borderColor
        self.employeeImageView.clipsToBounds = true
        self.employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.employeeImageView)
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.font = layoutVars.smallBoldFont
        contentView.addSubview(nameLbl)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        //activityView.center = CGPoint(x: self.employeeImageView.frame.size.width / 2, y: self.employeeImageView.frame.size.height / 2)
        employeeImageView.addSubview(activityView)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        /*
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[name]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        let viewsDictionary2 = ["activityView":activityView] as [String : Any]
        
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityView]-|", options: [], metrics: nil, views: viewsDictionary2))
        employeeImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityView]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
        
        */
        
        
        phoneLbl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(phoneLbl)
        self.phoneLbl.isHidden = false
        
        if(self.employee.phone == "" || self.employee.phone == "No Phone Number"){
            self.phoneLbl.text = "No Phone on File"
            self.phoneLbl.textColor = UIColor.red
        }else{
            self.phoneLbl.text = self.employee.phone
            self.phoneLbl.textColor = UIColor.black
        }
        
        print("set phone 1")
        //contentView.removeConstraints(contentView.constraints)
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl,"phone":phoneLbl] as [String : Any]
        
        print("set phone 2")
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[name(25)][phone(25)]", options: [], metrics: nil, views: viewsDictionary))
        print("set phone 3")
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[name]", options: [], metrics: nil, views: viewsDictionary))
        print("set phone 4")
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-20-[phone]", options: [], metrics: nil, views: viewsDictionary))
        
    }
}
