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
//import Nuke



class EmployeeTableViewCell: UITableViewCell {
    
    var employee:Employee!
    var nameLbl: UILabel! = UILabel()
    var phoneLbl: UILabel! = UILabel()
    var employeeImageView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    var layoutVars:LayoutVars = LayoutVars()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.employeeImageView.layer.cornerRadius = 5.0
        self.employeeImageView.layer.borderWidth = 1
        self.employeeImageView.layer.borderColor = layoutVars.borderColor
        self.employeeImageView.clipsToBounds = true
        self.employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.employeeImageView)
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        phoneLbl.translatesAutoresizingMaskIntoConstraints = false
        phoneLbl.isHidden = true
        contentView.addSubview(phoneLbl)
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        //activityView.center = CGPoint(x: self.employeeImageView.frame.size.width / 2, y: self.employeeImageView.frame.size.height / 2)
        employeeImageView.addSubview(activityView)

        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl] as [String : Any]
    
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
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
                
                //let image2 = Image(_path: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.employee.pic!)
                //self.imageFullViewController = ImageFullViewController(_image: image2)
                //self.imageFullViewController = ImageFullViewController(_image: image)
            }
        }
        
        
        
        /*
        let imgURL:URL = URL(string: _url)!
        Nuke.loadImage(with: imgURL, into: self.employeeImageView){ 
            //print("nuke loadImage")
            self.employeeImageView.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
        }
 */
        
        
        
        
        
        
        
        
        
    }
    
    func setPhone(){
        self.phoneLbl.isHidden = false
        if(self.employee.phone == "" || self.employee.phone == "No Phone Number"){
            self.phoneLbl.text = "No Phone on File"
            self.phoneLbl.textColor = UIColor.red
        }else{
            self.phoneLbl.text = self.employee.phone
            self.phoneLbl.textColor = UIColor.black
        }
        
        
        //contentView.removeConstraints(contentView.constraints)
        let viewsDictionary = ["pic":self.employeeImageView,"name":nameLbl,"phone":phoneLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[name(25)][phone(25)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[name]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-20-[phone]", options: [], metrics: nil, views: viewsDictionary))
        
    }
}
