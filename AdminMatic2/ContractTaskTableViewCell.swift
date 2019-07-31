//
//  ContractTaskTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 8/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//
//  TaskTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//
 
import Foundation
import UIKit
import Alamofire
//import AlamofireImage
//import Nuke

class ContractTaskTableViewCell: UITableViewCell {
    
    var task:ContractTask2!
    var thumbView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    var taskLbl: UILabel! = UILabel()
    var imageQtyLbl: Label! = Label()
    
    //var statusIcon: UIImageView!
    
    var addTasksLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func layoutViews(){
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.thumbView.image = nil
        self.selectionStyle = .none
        
        self.thumbView.clipsToBounds = true
        self.thumbView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.thumbView)
        self.setBlankImage()
        
        taskLbl.translatesAutoresizingMaskIntoConstraints = false
        taskLbl.numberOfLines = 0;
        
        contentView.addSubview(taskLbl)
        
        imageQtyLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageQtyLbl)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.center = CGPoint(x: self.thumbView.frame.size.width, y: self.thumbView.frame.size.height)
        thumbView.addSubview(activityView)
        
        
        /*
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        */
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["thumbs":self.thumbView,"task":taskLbl, "imageQty":imageQtyLbl] as [String:AnyObject]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth - 90] as [String:Any]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[thumbs(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[task(>=20)]-[imageQty(20)]-|", options: [], metrics: nil, views: viewsDictionary))
        
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        
        // contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[note(20)]-[imageQty(20)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[thumbs(50)]-5-[task]-15-|", options: [], metrics: sizeVals, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[thumbs(50)]-5-[imageQty]-15-|", options: [], metrics: sizeVals, views: viewsDictionary))
    }
    
    
    func layoutAddBtn(){
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // self.selectedImageView.image = nil
        
        self.addTasksLbl.text = "Add Task"
        self.addTasksLbl.textColor = UIColor.white
        self.addTasksLbl.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        self.addTasksLbl.layer.cornerRadius = 4.0
        self.addTasksLbl.clipsToBounds = true
        self.addTasksLbl.textAlignment = .center
        
        self.addTasksLbl.translatesAutoresizingMaskIntoConstraints = false
        self.addTasksLbl.numberOfLines = 0;
        
        
        contentView.addSubview(self.addTasksLbl)
        
        
        let viewsDictionary = ["addBtn":self.addTasksLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[addBtn(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setImageUrl(_url:String?){
        print("set Task ImageUrl")
        
        print("url = \(String(describing: _url))")
        
        if(_url == nil){
            setBlankImage()
        }else{
            
            
            Alamofire.request(_url!).responseImage { response in
                debugPrint(response)
                
                //print(response.request)
                //print(response.response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    self.thumbView.image = image
                    
                    
                    
                    self.activityView.stopAnimating()
                    
                    
                }
            }
            
            
            //let url = URL(string: _url!)
            
            //cell.activityIndicator.startAnimating()
            
            //let cellImageView = cell.imageView
            
           /*
            Nuke.loadImage(with: url!, into: self.thumbView){
                //self.thumbView.handle(response: <#T##Result<Image>#>, isFromMemoryCache: <#T##Bool#>)
                }
                */
                
            //Nuke.loadImage(with: url!, into: self.thumbView) {
                //self.thumbView.handle(response: $0, isFromMemoryCache: $1)
                
                //cell.activityIndicator.stopAnimating()
            //}
                
                
             /*
                self.activityView.startAnimating()
            Nuke.loadImage(with: url!, into: self.thumbView){
                //print("nuke loadImage")
                //self.thumbView.handle(response: $, isFromMemoryCache: <#T##Bool#>)
                //self.thumbView.handle(response: $0, isFromMemoryCache: $1)
                //self.thumbView.handle(response: , isFromMemoryCache: <#T##Bool#>)
                //self.activityView.stopAnimating
                
            }
 */
            
            
            
            
        }
    }
    
    func setBlankImage(){
        self.thumbView.image = layoutVars.defaultImage
    }
    
    /*
    
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
 */
    
    
    
}
