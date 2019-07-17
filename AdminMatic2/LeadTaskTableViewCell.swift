//
//  LeadTaskTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 11/13/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
//import Nuke
 
class LeadTaskTableViewCell: UITableViewCell {
    
    var task:Task2!
    var checkMarkView:UIImageView = UIImageView()
    var thumbView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    var taskLbl: Label! = Label()
    var imageQtyLbl: Label! = Label()
    
    var statusLbl: Label! = Label()
    
    //var addTasksLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func layoutViews(){
        print("cell layout")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        taskLbl = Label()
        taskLbl.text = self.task.task
        taskLbl.font = layoutVars.buttonFont
        taskLbl.numberOfLines = 2
        //taskLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(taskLbl)
        
        
        checkMarkView = UIImageView()
        checkMarkView.translatesAutoresizingMaskIntoConstraints = false
        checkMarkView.backgroundColor = UIColor.clear
        checkMarkView.contentMode = .scaleAspectFill
        contentView.addSubview(checkMarkView)
        
        
        
        self.thumbView.clipsToBounds = true
        self.thumbView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.thumbView)
        self.setBlankImage()
        
        taskLbl.translatesAutoresizingMaskIntoConstraints = false
        taskLbl.numberOfLines = 0;
        
        contentView.addSubview(taskLbl)
        
       // let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self.task.task)
        
       // strikethroughStyle
       // UIStringAttributes { StrikethroughStyle = NSUnderlineStyle.Single })
        //attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        
        switch task.status {
        case "0":
            statusLbl.text = ""
            break
        case "1":
            statusLbl.text = "--- Assigned ---"
            break
        case "2":
            statusLbl.text = "--- Not Needed ---"
            break
        default:
            statusLbl.text = ""
        }
        statusLbl.textColor = UIColor.red
        statusLbl.textAlignment = .center
        statusLbl.translatesAutoresizingMaskIntoConstraints = false
        statusLbl.font = layoutVars.microFont
        contentView.addSubview(statusLbl)
        
        
        
        
        
        
        
        if(self.task.images!.count > 1){
            imageQtyLbl.text = "+\(self.task.images!.count - 1)"
            imageQtyLbl.layer.opacity = 0.5
        }else{
            imageQtyLbl.text = ""
            imageQtyLbl.layer.opacity = 0.0
        }
        imageQtyLbl.translatesAutoresizingMaskIntoConstraints = false
        imageQtyLbl.backgroundColor = UIColor.white
        
        imageQtyLbl.font = layoutVars.largeFont
        imageQtyLbl.textAlignment = .center
        contentView.addSubview(imageQtyLbl)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.center = CGPoint(x: self.thumbView.frame.size.width, y: self.thumbView.frame.size.height)
        thumbView.addSubview(activityView)
        
        if(self.task.images!.count > 0){
            self.setImageUrl(_url: self.task.images![0].thumbPath)
        }
        
        
        
        
        
        
        
        
        
        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
    }
    
    func setConstraints(){
        
        let viewsDictionary = ["checkMark":self.checkMarkView,"thumbs":self.thumbView,"task":taskLbl,"status":statusLbl, "imageQty":imageQtyLbl] as [String:AnyObject]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth - 90] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[checkMark(0)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[task(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[status(20)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[thumbs(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[imageQty(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMark(0)]-[task]-[thumbs(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMark(0)]-[task]-[imageQty(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMark(0)]-[status]-[imageQty(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    func setConstraintsWithCheckMark(){
        
        let viewsDictionary = ["checkMark":self.checkMarkView,"thumbs":self.thumbView,"task":taskLbl,"status":statusLbl, "imageQty":imageQtyLbl] as [String:AnyObject]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth - 90] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[checkMark(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[task(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[status(20)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[thumbs(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[imageQty(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMark(30)]-[task]-[thumbs(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMark(30)]-[task]-[imageQty(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMark(30)]-[status]-[imageQty(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
    }
    
    
    
    /*
    func layoutAddBtn(){
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // self.selectedImageView.image = nil
        self.selectionStyle = .none
        self.addTasksLbl.text = "Add Task"
        self.addTasksLbl.textColor = UIColor.white
        self.addTasksLbl.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        self.addTasksLbl.layer.cornerRadius = 4.0
        self.addTasksLbl.clipsToBounds = true
        self.addTasksLbl.textAlignment = .center
        contentView.addSubview(self.addTasksLbl)
        
        
        let viewsDictionary = ["addBtn":self.addTasksLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
 */
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setImageUrl(_url:String?){
        //print("set Task ImageUrl")
        
        //print("url = \(String(describing: _url))")
        
        if(_url == nil){
            setBlankImage()
        }else{
            
            //let url = URL(string: _url!)
            
            /*
            Nuke.loadImage(with: url!, into: self.thumbView){ 
                //print("nuke loadImage")
                self.thumbView.handle(response: $0, isFromMemoryCache: $1)
                self.activityView.stopAnimating()
                
            }
            */
            
            
            Alamofire.request(_url!).responseImage { response in
                debugPrint(response)
                
                //print(response.request)
                //print(response.response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    self.thumbView.image = image
                    
                    self.activityView.stopAnimating()
                    
                    
                    self.activityView.stopAnimating()
                    
                    
                }
            }
            
            
        }
    }
    
    func setBlankImage(){
        self.thumbView.image = layoutVars.defaultImage
    }
    
    func setCheck(){
        let blueCheckImg = UIImage(named:"checkMarkBlue.png")
        checkMarkView.image = blueCheckImg
    }
    
    func unSetCheck(){
        let grayCheckImg = UIImage(named:"checkMarkGray.png")
        checkMarkView.image = grayCheckImg
    }
    
    
    
    
    
}

