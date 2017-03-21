//
//  ImageUploadProgressTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 3/20/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class ImageUploadProgressTableViewCell: UITableViewCell {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imageData:Image!
    var uploadDelegate:ImageUploadProgressDelegate!
    let saveURLString:String = "https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php"
    var progressLbl: UILabel! = UILabel()
    var progressView:UIProgressView!
    var progressValue:Float!
    var selectedImageView:UIImageView = UIImageView()
    var scoreAdjust:Int?
    var layoutVars:LayoutVars = LayoutVars()
    var indexPath:IndexPath!
    var reloadBtn:UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func layoutViews(){
        print("cell layoutviews")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        self.selectedImageView.layer.cornerRadius = 5.0
        self.selectedImageView.clipsToBounds = true
        self.selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.selectedImageView.image = self.imageData.image
        self.contentView.addSubview(self.selectedImageView)
        
        self.progressLbl = Label(text: imageData.uploadStatus, valueMode: false)
        self.progressLbl.font = self.progressLbl.font.withSize(20)
        self.progressLbl.textAlignment = .left
        self.progressLbl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.progressLbl)
        
        self.reloadBtn = Button()
        self.reloadBtn.translatesAutoresizingMaskIntoConstraints = false
        self.reloadBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        
        self.reloadBtn.setTitle("Reload", for: UIControlState.normal)
        self.reloadBtn.addTarget(self, action: #selector(ImageUploadProgressTableViewCell.handleReload), for: UIControlEvents.touchUpInside)
        self.contentView.addSubview(self.reloadBtn)
        self.reloadBtn.isHidden = true
        
        self.progressView = UIProgressView()
        self.progressView.tintColor = layoutVars.buttonColor1
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.setProgress(imageData.uploadProgress, animated: true)
        self.contentView.addSubview(self.progressView)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.selectedImageView,"progressLbl":progressLbl,"reloadBtn":reloadBtn,"progressBar":progressView] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progressBar(6)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[progressLbl(200)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[reloadBtn(80)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[reloadBtn(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[progressBar]-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    func handleReload(){
        self.progressLbl.text = "Uploading"
        self.reloadBtn.isHidden = true
        self.progressLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.progressView.progress = 0.0
        self.progressView.progressTintColor = UIColor(hex: 0x005100, op: 1.0)
        upload()
    }
    
    func upload(){
        print("cell start upload")
        
        var createdBy:String = ""
        
        if(appDelegate.loggedInEmployee?.ID == ""){
            createdBy = "0"
        }else{
            createdBy = (appDelegate.loggedInEmployee?.ID)!
        }
        
                var parameters:[String:String]
                parameters = [
                    "name":imageData.name,
                    "desc":imageData.description,
                    "tags":"",
                    "customer":imageData.customer,
                    "createdBy":createdBy,
                    "fieldNote":"0",
                    "task":"0"
                ]
                print("parameters = \(parameters)")
                
                let URL = try! URLRequest(url: self.saveURLString, method: .post, headers: nil)
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    print("alamofire upload")
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                    
                    if  let imageData = UIImageJPEGRepresentation(self.imageData.image!.fixedOrientation(), 0.85) {
                        multipartFormData.append(imageData, withName: "pic", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                        
                    }
                    
                }, with: URL, encodingCompletion: { (result) in
                    
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (Progress) in
                           // print("Upload Progress: \(Progress.fractionCompleted)")
                            
                            DispatchQueue.main.async() {
                                self.progressView.progress = Float(Progress.fractionCompleted)
                                    if  (Progress.fractionCompleted == 1.0) {
                                        print("upload finished")
                                        self.progressLbl.text = "Upload Complete"
                                    }
                                }
                        })
                        
                        upload.responseJSON { response in
                           // print(response.request ?? "")  // original URL request
                            //print(response.response ?? "") // URL response
                           // print(response.data ?? "")     // server data
                            print("result = \(response.result)")   // result of response serialization
                            
                            if("\(response.result)" == "FAILURE") {
                               self.progressLbl.text = "Failed"
                                self.reloadBtn.isHidden = false
                                self.progressLbl.textColor = UIColor.red
                                self.progressView.progressTintColor = UIColor.red
                            }
                            
                            if let result = response.result.value {
                                let json = result as! NSDictionary
                                let thumbBase = JSON(json)["thumbBase"].stringValue
                                let rawBase = JSON(json)["rawBase"].stringValue
                                let thumbPath = "\(thumbBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                                let rawPath = "\(rawBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                                
                                let image = Image(_id: JSON(json)["images"][0]["ID"].stringValue, _thumbPath: thumbPath, _rawPath: rawPath, _name: JSON(json)["images"][0]["name"].stringValue, _width: JSON(json)["images"][0]["width"].stringValue, _height: JSON(json)["images"][0]["height"].stringValue, _description: JSON(json)["images"][0]["description"].stringValue, _customer: JSON(json)["images"][0]["customer"].stringValue, _woID: JSON(json)["images"][0]["woID"].stringValue, _dateAdded: JSON(json)["images"][0]["dateAdded"].stringValue, _createdBy: JSON(json)["images"][0]["createdBy"].stringValue, _type: JSON(json)["images"][0]["type"].stringValue, _tags: JSON(json)["images"][0]["tags"].stringValue)
                                
                                self.scoreAdjust = JSON(json)["scoreAdjust"].intValue
                                
                                self.uploadDelegate.returnImage(_indexPath:self.indexPath ,_image: image, _scoreAdjust: self.scoreAdjust!)
                            }
                        }
                        upload.responseString { response in
                            print("RESPONSE: \(response)")
                        }
                    case .failure(let encodingError):
                        print("fail \(encodingError)")
                        self.progressLbl.text = "Failed"
                        self.reloadBtn.isHidden = false
                        self.progressLbl.textColor = UIColor.red
                        self.progressView.progressTintColor = UIColor.red
                        
                    }
                })
    }
}
