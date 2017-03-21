//
//  Image.swift
//  AdminMatic2
//
//  Created by Nick on 2/14/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit

class Image {
    
    var ID: String!
    var thumbPath: String!
    var rawPath: String!
    var name: String!
    var width: String!
    var height: String!
    var description: String!
    
    
    var customer: String!
    var woID: String!
    
    var dateAdded: String!
    var createdBy: String!
    var type: String!
    
    var tags: String!
    
    var image: UIImage?
    
    var uploadProgress:Float = 0.0
    var uploadStatus:String = "Uploading..."
    
    
    
    required init( _id: String?, _thumbPath:String?, _rawPath:String?, _name:String?, _width:String?, _height:String?, _description:String?, _customer:String?, _woID:String?, _dateAdded:String?, _createdBy:String?, _type:String?, _tags:String?) {
        //print(json)
        if _id != nil {
            self.ID = _id
        }else{
            self.ID = ""
        }
        if _thumbPath != nil {
            self.thumbPath = _thumbPath
        }else{
            self.thumbPath = ""
        }
        if _rawPath != nil {
            self.rawPath = _rawPath
        }else{
            self.rawPath = ""
        }
        
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        
        if _width != nil {
            self.width = _width
        }else{
            self.width = ""
        }
        if _height != nil {
            self.height = _height
        }else{
            self.height = ""
        }
        if _description != nil {
            self.description = _description
            if(self.description == ""){
                self.description = "No description provided."
            }
        }else{
            self.description = "No description provided."
        }
        if _customer != nil {
            self.customer = _customer
        }else{
            self.customer = ""
        }
        if _woID != nil {
            self.woID = _woID
        }else{
            self.woID = ""
        }
        if _dateAdded != nil {
            self.dateAdded = _dateAdded
        }else{
            self.dateAdded = ""
        }
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        
        if _tags != nil {
            self.tags = _tags
        }else{
            self.tags = ""
        }


        
    }
}
