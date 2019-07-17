//
//  Image2.swift
//  AdminMatic2
//
//  Created by Nick on 7/11/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation
import UIKit

class Image2:Codable {
    
    enum CodingKeys : String, CodingKey {
        case ID
       // case thumbPath
       // case mediumPath
        //case rawPath
        case name
        case fileName
        case width
        case height
        case description
        case customer
        case custName = "customerName"
        case woID
        case albumID = "album"
        case leadTaskID
        case contractTaskID
        case taskID
        case equipmentID
        case usageID
        case vendorID
        case dateAdded
        case createdBy = "createdByName"
        case type
        case tags
        
        case index
        case liked
        case likes
        
        //case image
        
    }
    
    var ID: String
    var fileName: String
    var name: String
    var width: String
    var height: String
    
    
    var description: String = ""
    
    
    
    var customer: String? = "0"
    var custName: String? = ""
    
    var albumID: String = "0"
    var dateAdded: String = ""
    var createdBy: String? = ""
    var type: String = ""
    
    
    var woID: String? = "0"
    var leadTaskID: String? = "0"
    var contractTaskID: String? = "0"
    var taskID: String? = "0"
    var equipmentID: String? = "0"
    
    var usageID:String? = "0"
    var vendorID:String? = "0"
    
    
    
    
    var tags: String? = ""
    
    //var image: UIImage?
    
    //var image: Data
    
    
    var thumbPath: String?
    var mediumPath: String?
    var rawPath: String?
    
    var imageData:Data?
    
    
    var uploadProgress:Float? = 0.0
    var uploadStatus:String? = "Uploading..."
    
    var index:Int? = 0
    var liked:String? = "0"
    var likes:String? = "0"
    
    var toBeSaved:String? = "0"
    
    // var topImage:String = "1"
    
   // var layoutVars:LayoutVars = LayoutVars()
    
    let rawBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/raw/"
    let mediumBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/medium/"
    let thumbBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/thumbs/"
    
    let noPicPath: String = "https://www.atlanticlawnandgarden.com/cp/img/noImageIcon.png"
    
    
    init( _id: String, _fileName:String, _name:String, _width:String, _height:String, _description:String, _dateAdded:String, _createdBy:String, _type:String) {
        //print(json)
        
       // print("image init")
        
        
            self.ID = _id
            self.fileName = _fileName
        
        
            self.name = _name
        
            self.width = _width
        
            self.height = _height
        
            self.description = _description
            if(self.description == ""){
                self.description = "No description provided."
            }
        
            self.dateAdded = _dateAdded
        
            self.createdBy = _createdBy
        
            self.type = _type
        
       /*
        self.thumbPath  = "\(self.layoutVars.thumbBase)\(self.fileName)"
        self.mediumPath  = "\(self.layoutVars.mediumBase)\(self.fileName)"
        self.rawPath  = "\(self.layoutVars.rawBase)\(self.fileName)"
        */
        
    }
    
    /*
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //scanDate = try container.decode(Date.self, forKey: .scanDate)
        image = try container.decode(UIImage.self, forKey: .image)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
       // try container.encode(scanDate, forKey: .scanDate)
        try container.encode(image, forKey: .image, quality: .png)
    }
*/
    
    
    /*
    
    //simple init for fullView viewing only
    init( _path:String) {
        //print(json)
       
            self.rawPath = "https://atlanticlawnandgarden.com/uploads/general/" + _path
            self.mediumPath = "https://atlanticlawnandgarden.com/uploads/general/medium/" + _path
            self.thumbPath = "https://atlanticlawnandgarden.com/uploads/thumbs/" + _path
        
        
    }
    
    
    
    
    //init for equipment
    init(_ID:String) {
        //print(json)
       
            self.ID = _ID
            self.rawPath = "https://atlanticlawnandgarden.com/uploads/general/Equipment(\(_ID)).jpeg"
            self.mediumPath = "https://atlanticlawnandgarden.com/uploads/general/medium/Equipment(\(_ID)).jpeg"
            self.thumbPath = "https://atlanticlawnandgarden.com/uploads/general/thumbs/Equipment(\(_ID)).jpeg"
       
        
        
    }
    
    //init for equipment w/out pic
    init(_ID:String, _noPicPath:String) {
        //print(json)
       
            self.ID = _ID
       
            self.rawPath = _noPicPath
            self.mediumPath = _noPicPath
            self.thumbPath = _noPicPath
        
        
    }
    */
    
    
    
    func setDefaultPath(){
        
        self.rawPath = noPicPath
        self.mediumPath = noPicPath
        self.thumbPath = noPicPath
    }
    
    
    
    func setImagePaths(){
       
        
        
        self.thumbPath  = "\(self.thumbBase)\(self.fileName)"
        self.mediumPath  = "\(self.mediumBase)\(self.fileName)"
        self.rawPath  = "\(self.rawBase)\(self.fileName)"
        
        
    }
    
    func setEquipmentImagePaths(){
        
        
        
        //self.ID = _ID
        self.rawPath = "https://atlanticlawnandgarden.com/uploads/general/Equipment(\(self.ID)).jpeg"
        self.mediumPath = "https://atlanticlawnandgarden.com/uploads/general/medium/Equipment(\(self.ID)).jpeg"
        self.thumbPath = "https://atlanticlawnandgarden.com/uploads/general/thumbs/Equipment(\(self.ID)).jpeg"
        
        
    }
    
    func urlStringToData(_urlString:String)->Data{
        let url = URL(fileURLWithPath: _urlString)
        let data = (try? Data(contentsOf: url))! //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
       // imageView.image = UIImage(data: data!)
        return data
    }
    
   
    
    
    
    
}


