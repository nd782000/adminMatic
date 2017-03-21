//
//  ImageUploadPrepTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 3/18/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit


class ImageUploadPrepCollectionViewCell: UICollectionViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    //data object
    var imageData:Image!
    var delegate:ImageUploadPrepDelegate!
    var indexPath:IndexPath!
    
    var selectedImageView:UIImageView = UIImageView()
   // var activityView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    
    //var nameTxt:UITextField = UITextField()
    //var namePlaceHolder:String = "Name..."
    
    var descriptionTxt: UITextView = UITextView()
    var descriptionPlaceHolder:String = "Caption..."
    
    
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    
   
    
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cell init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    
    
    func layoutViews(){
        print("cell layout")
        
    
        //contentView.layer.borderWidth = 2.0
        //contentView.layer.borderColor = UIColor.red.cgColor
        
        
        self.selectedImageView.layer.cornerRadius = 5.0
        //self.selectedImageView.layer.borderWidth = 1
        //self.selectedImageView.layer.borderColor = layoutVars.borderColor
        self.selectedImageView.contentMode = .scaleAspectFill
        self.selectedImageView.clipsToBounds = true
        self.selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.selectedImageView)
        
        self.selectedImageView.image = self.imageData.image
        
        
        //activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
       // activityView.center = CGPoint(x: self.contentView.frame.size.width / 2, y: self.contentView.frame.size.height / 2)
       // contentView.addSubview(activityView)

        
       
        
      
        //self.groupDescriptionTxt = UITextView()
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
        
        
        
        
        
        
         print("cell layout 2")
        
        let viewsDictionary = ["pic":self.selectedImageView,"desc":descriptionTxt] as [String : Any]
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
      
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[desc]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pic(160)][desc]-|", options: [], metrics: nil, views: viewsDictionary))
        
         print("cell layout 3")
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            //nameTxt.resignFirstResponder()
            
            delegate.updateDescription(_index:indexPath.row, _description:descriptionTxt.text)
            
            descriptionTxt.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        //var indexPath: IndexPath? {
          //  return (superview as? UITableView)?.indexPath(for: self)
        //}
        
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
    

    
}
