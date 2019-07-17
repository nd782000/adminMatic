//
//  ImageUploadPrepTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 3/18/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
//import Nuke
 

class ImageUploadPrepCollectionViewCell: UICollectionViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    var layoutVars:LayoutVars = LayoutVars()

    //data object
    var imageData:Image2!
    var uiImage:UIImage?
    var delegate:ImageUploadPrepDelegate!
    var indexPath:IndexPath!
    
    var imageLoaded:Bool = false
    
    var selectedImageView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    
    var descriptionTxt: UITextView = UITextView()
    var descriptionPlaceHolder:String = "Caption..."
    
    var editLbl:Label!
    
    
    var addImagesLbl:Label = Label()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cell init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    
    
    func layoutViews(){
        print("image upload prep cell layout")
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done

        
        self.selectedImageView.layer.cornerRadius = 5.0
        self.selectedImageView.contentMode = .scaleAspectFill
        self.selectedImageView.clipsToBounds = true
        self.selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.selectedImageView)
        
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.contentView.frame.size.width / 2, y: self.contentView.frame.size.height / 2)
        contentView.addSubview(activityView)
        
        
        
        
        //print("self.imageData.ID = \(self.imageData.ID)")
        if(self.imageData.ID == "0"){
            //self.selectedImageView.image = self.uiImage
            let image = UIImage(data: self.imageData.imageData!)
             self.selectedImageView.image = image?.resized(withPercentage: 0.25)
            self.activityView.stopAnimating()
        }else{
            
            
           // let imgURL:URL = URL(string: self.imageData.mediumPath)!
            
            //print("imgURL = \(imgURL)")
            
            if(imageLoaded == false){
                self.activityView.startAnimating()
            }
            
           
            
                Alamofire.request(self.imageData.mediumPath!).responseImage { response in
                    debugPrint(response)
                    
                    //print(response.request)
                    //print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        
                        self.selectedImageView.image = image
                        
                        
                        
                        self.activityView.stopAnimating()
                        self.imageLoaded = true
                        
                        
                    }
                }
            

            
            
            
        }
        
        
       
        self.descriptionTxt.text = descriptionPlaceHolder
        self.descriptionTxt.textColor = UIColor.lightGray
        
        
        self.descriptionTxt.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionTxt.delegate = self
        self.descriptionTxt.font = layoutVars.smallFont
        self.descriptionTxt.returnKeyType = UIReturnKeyType.done
        self.descriptionTxt.layer.cornerRadius = 4
        self.descriptionTxt.clipsToBounds = true
        self.descriptionTxt.backgroundColor = layoutVars.backgroundLight
        self.descriptionTxt.showsHorizontalScrollIndicator = false;
        self.contentView.addSubview(self.descriptionTxt)
        
        
        
        
        self.editLbl = Label(text: "Tap to Edit")
        //self.editBtn.backgroundColor = UIColor.clear
        self.editLbl.backgroundColor = UIColor.clear
        self.editLbl.textColor = UIColor.white
        self.editLbl.translatesAutoresizingMaskIntoConstraints = false
        self.editLbl.textAlignment = .left
        
        
        let editIcon:UIImageView = UIImageView()
        editIcon.backgroundColor = UIColor.clear
        editIcon.contentMode = .scaleAspectFill
        editIcon.translatesAutoresizingMaskIntoConstraints = false
        //editIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let editImg = UIImage(named:"drawIcon.png")
        editIcon.image = editImg
        self.selectedImageView.addSubview(editIcon)
        
        let editIcon2:UIImageView = UIImageView()
        editIcon2.backgroundColor = UIColor.clear
        editIcon2.contentMode = .scaleAspectFill
        editIcon2.translatesAutoresizingMaskIntoConstraints = false
        //editIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let editImg2 = UIImage(named:"cropIcon.png")
        editIcon2.image = editImg2
        self.selectedImageView.addSubview(editIcon2)
        
        
        self.selectedImageView.addSubview(self.editLbl)
        
        
        if(self.imageData.ID != "0"){
            editIcon.isHidden = true
            editIcon2.isHidden = true
            self.editLbl.isHidden = true
            
            self.descriptionTxt.isEditable = false
            self.descriptionTxt.text = self.imageData.description
            self.descriptionTxt.textColor = UIColor.black
        }

        

        print("cell layout constraints")

        let viewsDictionary = ["pic":self.selectedImageView,"desc":descriptionTxt] as [String : Any]
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
      
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[desc]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pic(250)][desc]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        let viewsDictionary2 = ["editIcon":editIcon,"editIcon2":editIcon2, "editLbl":self.editLbl] as [String : Any]
        
        
        
        selectedImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[editIcon(20)]-[editIcon2(20)]-[editLbl(100)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary2))
        
        
        selectedImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[editIcon(20)]-|", options: [], metrics: nil, views: viewsDictionary2))
         selectedImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[editIcon2(20)]-|", options: [], metrics: nil, views: viewsDictionary2))
        selectedImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[editLbl(40)]-|", options: [], metrics: nil, views: viewsDictionary2))
        
        print("cell layout finish constraints")
        
        
    }
    
    
    func layoutViewsAdd(){
        print("cell layout Add")
         self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectedImageView.image = nil
        
        self.addImagesLbl.text = "Add Images"
        self.addImagesLbl.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        self.addImagesLbl.layer.cornerRadius = 4.0
        self.addImagesLbl.clipsToBounds = true
        self.addImagesLbl.textAlignment = .center
        self.addImagesLbl.textColor = UIColor.white
        contentView.addSubview(self.addImagesLbl)
        
        /*if(self.imageData.ID != "0"){
            self.addImagesLbl.isHidden = true
        }
        */
        
        let viewsDictionary = ["addBtn":self.addImagesLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
        }

    
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            
            delegate.updateDescription(_index:indexPath.row, _description:descriptionTxt.text)
            
            descriptionTxt.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        self.delegate.scrollToCell(_indexPath: self.indexPath)
        if self.descriptionTxt.textColor == UIColor.lightGray {
            self.descriptionTxt.text = nil
            self.descriptionTxt.textColor = UIColor.black
        }
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if self.descriptionTxt.text.isEmpty {
            self.descriptionTxt.text = descriptionPlaceHolder
            self.descriptionTxt.textColor = UIColor.lightGray
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.contentView.endEditing(true)
        return false
    }
    
    
    func setText(){
        
        if(imageData.description != "No description provided."){
            self.descriptionTxt.text = imageData.description
            self.descriptionTxt.textColor = UIColor.black
        }
        
        if self.descriptionTxt.text.isEmpty {
            self.descriptionTxt.text = descriptionPlaceHolder
            self.descriptionTxt.textColor = UIColor.lightGray
        }
        
        
        
    }
    
    
   
    
    
}
